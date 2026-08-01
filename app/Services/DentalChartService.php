<?php

namespace App\Services;

use App\Models\DentalChartEntry;
use Carbon\Carbon;
use Illuminate\Database\Eloquent\Collection;

final class DentalChartService
{
    /**
     * Latest state per (tooth, surface) — the rendered chart.
     * Keyed by tooth_number → ['whole' => ['condition' => ?string, 'restoration' => ?string], 'surfaces' => [surface => same]].
     *
     * @return array<int, array{whole: array{condition: ?string, restoration: ?string}, surfaces: array<string, array{condition: ?string, restoration: ?string}>}>
     */
    public function currentState(int $patientId, string $dentition): array
    {
        return $this->project(
            DentalChartEntry::where('patient_id', $patientId)
                ->where('dentition', $dentition)
                ->orderBy('recorded_at')
                ->orderBy('id')
                ->get()
        );
    }

    /**
     * Same projection but only entries recorded on or before the given date.
     *
     * @return array<int, array{whole: array{condition: ?string, restoration: ?string}, surfaces: array<string, array{condition: ?string, restoration: ?string}>}>
     */
    public function stateAsOf(int $patientId, string $dentition, Carbon $asOf): array
    {
        return $this->project(
            DentalChartEntry::where('patient_id', $patientId)
                ->where('dentition', $dentition)
                ->where('recorded_at', '<=', $asOf->toDateString())
                ->orderBy('recorded_at')
                ->orderBy('id')
                ->get()
        );
    }

    /**
     * Full immutable log, newest first.
     */
    public function history(int $patientId, ?int $toothNumber = null, ?string $from = null): Collection
    {
        return DentalChartEntry::with('recordedBy:id,name')
            ->where('patient_id', $patientId)
            ->when($toothNumber !== null, fn ($q) => $q->where('tooth_number', $toothNumber))
            ->when($from !== null, fn ($q) => $q->where('recorded_at', '>=', $from))
            ->orderByDesc('recorded_at')
            ->orderByDesc('id')
            ->get();
    }

    /**
     * @param  Collection<int, DentalChartEntry>  $rows  ordered by recorded_at, id ascending
     * @return array<int, array{whole: array{condition: ?string, restoration: ?string}, surfaces: array<string, array{condition: ?string, restoration: ?string}>}>
     */
    private function project(Collection $rows): array
    {
        $state = [];

        foreach ($rows as $row) {
            $tooth = $row->tooth_number;
            $slot = $row->surface?->value ?? 'whole';

            $state[$tooth]['whole'] ??= ['condition' => null, 'restoration' => null];
            $state[$tooth]['surfaces'] ??= [];

            if ($slot === 'whole') {
                $target = &$state[$tooth]['whole'];
            } else {
                $state[$tooth]['surfaces'][$slot] ??= ['condition' => null, 'restoration' => null];
                $target = &$state[$tooth]['surfaces'][$slot];
            }

            if ($row->condition) {
                $target['condition'] = $row->condition->value;
            }
            if ($row->restoration_type) {
                $target['restoration'] = $row->restoration_type->value;
            }

            unset($target);
        }

        return $state;
    }
}
