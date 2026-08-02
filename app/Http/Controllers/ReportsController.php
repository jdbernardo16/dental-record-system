<?php

namespace App\Http\Controllers;

use App\Enums\ToothCondition;
use App\Models\Appointment;
use App\Models\Patient;
use App\Repositories\ReportRepository;
use Carbon\Carbon;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Http\Request;
use Inertia\Inertia;
use Inertia\Response;
use Symfony\Component\HttpFoundation\StreamedResponse;

class ReportsController extends Controller
{
    public function __construct(private readonly ReportRepository $reports) {}

    public function index(Request $request): Response
    {
        abort_unless($request->user()->can('reports.view'), 403);

        [$from, $to] = $this->range($request);

        return Inertia::render('Reports/Index', [
            'range' => ['from' => $from->toDateString(), 'to' => $to->toDateString()],
            'patientGrowth' => $this->reports->patientGrowth($from, $to),
            'appointmentSummary' => $this->reports->appointmentSummary($from, $to),
            'procedureSummary' => $this->reports->procedureSummary($from, $to),
            'conditionSummary' => $this->reports->conditionSummary($from, $to),
            'dentistWorkload' => $this->reports->dentistWorkload($from, $to),
            'conditionLabels' => ToothCondition::meta(),
            'totals' => [
                'patients' => Patient::whereBetween('created_at', [$from->startOfMonth(), $to->endOfMonth()])->count(),
                'appointments' => Appointment::whereBetween('appointment_date', [$from->toDateString(), $to->toDateString()])->count(),
            ],
        ]);
    }

    public function export(Request $request): StreamedResponse
    {
        abort_unless($request->user()->can('reports.view'), 403);

        $report = $request->query('report', 'patientGrowth');
        [$from, $to] = $this->range($request);
        $data = match ($report) {
            'appointmentSummary' => $this->reports->appointmentSummary($from, $to),
            'procedureSummary' => $this->reports->procedureSummary($from, $to),
            'conditionSummary' => $this->reports->conditionSummary($from, $to),
            'dentistWorkload' => $this->reports->dentistWorkload($from, $to),
            default => $this->reports->patientGrowth($from, $to),
        };

        $rows = $data->map(fn ($row) => $row instanceof Model ? $row->getAttributes() : (array) $row);
        $columns = $rows->first() ? array_keys($rows->first()) : ['empty'];

        return response()->streamDownload(function () use ($rows, $columns) {
            $handle = fopen('php://output', 'w');
            fputcsv($handle, $columns);
            foreach ($rows as $row) {
                fputcsv($handle, array_values($row));
            }
            fclose($handle);
        }, "report-{$report}-{$from->format('Ymd')}-{$to->format('Ymd')}.csv", ['Content-Type' => 'text/csv']);
    }

    /** @return array{0: Carbon, 1: Carbon} */
    private function range(Request $request): array
    {
        $from = preg_match('/^\d{4}-\d{2}-\d{2}$/', (string) $request->query('from', ''))
            ? Carbon::parse($request->query('from'))
            : Carbon::now()->subDays(30);
        $to = preg_match('/^\d{4}-\d{2}-\d{2}$/', (string) $request->query('to', ''))
            ? Carbon::parse($request->query('to'))
            : Carbon::now();

        return [$from, $to];
    }
}
