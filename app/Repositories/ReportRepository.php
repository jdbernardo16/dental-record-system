<?php

namespace App\Repositories;

use App\Models\Appointment;
use App\Models\DentalChartEntry;
use App\Models\Patient;
use App\Models\Treatment;
use Carbon\Carbon;
use Illuminate\Support\Collection;
use Illuminate\Support\Facades\DB;

final class ReportRepository
{
    /** New patients per month (last N months within range). */
    public function patientGrowth(Carbon $from, Carbon $to): Collection
    {
        return Patient::query()
            ->whereBetween('created_at', [$from->startOfMonth(), $to->endOfMonth()])
            ->selectRaw("{$this->monthExpression('created_at')} as month, COUNT(*) as count")
            ->groupBy('month')
            ->orderBy('month')
            ->get();
    }

    /** Appointments by status per month + attendance rate = completed / (completed + no_show). */
    public function appointmentSummary(Carbon $from, Carbon $to): Collection
    {
        return Appointment::query()
            ->whereBetween('appointment_date', [$from->toDateString(), $to->toDateString()])
            ->selectRaw("{$this->monthExpression('appointment_date')} as month, status, COUNT(*) as count")
            ->groupBy('month', 'status')
            ->orderBy('month')
            ->get()
            ->groupBy('month')
            ->map(function (Collection $rows, string $month) {
                $byStatus = $rows->mapWithKeys(fn ($row) => [$row->status->value => (int) $row->count])->all();
                $completed = (int) ($byStatus['completed'] ?? 0);
                $noShow = (int) ($byStatus['no_show'] ?? 0);
                $denominator = $completed + $noShow;

                return (object) [
                    'month' => $month,
                    'pending' => (int) ($byStatus['pending'] ?? 0),
                    'confirmed' => (int) ($byStatus['confirmed'] ?? 0),
                    'completed' => $completed,
                    'cancelled' => (int) ($byStatus['cancelled'] ?? 0),
                    'no_show' => $noShow,
                    'attendance_rate' => $denominator > 0 ? round($completed / $denominator * 100, 2) : 0.0,
                ];
            })
            ->values();
    }

    /** Procedure counts grouped by procedure_name (tooth/dentist filters optional). */
    public function procedureSummary(Carbon $from, Carbon $to, ?int $toothNumber = null, ?int $dentistId = null): Collection
    {
        return Treatment::query()
            ->whereBetween('treatment_date', [$from->toDateString(), $to->toDateString()])
            ->when($toothNumber, fn ($q) => $q->where('tooth_number', $toothNumber))
            ->when($dentistId, fn ($q) => $q->where('dentist_id', $dentistId))
            ->selectRaw('procedure_name, COUNT(*) as count')
            ->groupBy('procedure_name')
            ->orderByDesc('count')
            ->get();
    }

    /** Top conditions on the chart (clinical audit). */
    public function conditionSummary(Carbon $from, Carbon $to): Collection
    {
        // `condition` is a reserved word in MySQL/MariaDB — quote via the grammar.
        $condition = DB::connection()->getQueryGrammar()->wrap('condition');

        return DentalChartEntry::query()
            ->whereBetween('recorded_at', [$from->toDateString(), $to->toDateString()])
            ->selectRaw("{$condition}, COUNT(*) as count")
            ->groupBy('condition')
            ->orderByDesc('count')
            ->get();
    }

    /** Per-dentist treatment counts (workload). */
    public function dentistWorkload(Carbon $from, Carbon $to): Collection
    {
        return Treatment::query()
            ->whereBetween('treatment_date', [$from->toDateString(), $to->toDateString()])
            ->join('users', 'treatments.dentist_id', '=', 'users.id')
            ->selectRaw('users.name as dentist_name, COUNT(*) as count')
            ->groupBy('users.id', 'users.name')
            ->orderByDesc('count')
            ->get();
    }

    /**
     * Driver-aware month expression: MySQL uses DATE_FORMAT, SQLite strftime.
     * Both produce the same zero-padded '%Y-%m' label.
     */
    private function monthExpression(string $column): string
    {
        return DB::connection()->getDriverName() === 'sqlite'
            ? "strftime('%Y-%m', {$column})"
            : "DATE_FORMAT({$column}, '%Y-%m')";
    }
}
