<?php

namespace App\Http\Controllers;

use App\Actions\RecordToothConditionAction;
use App\Enums\DentitionType;
use App\Enums\RestorationType;
use App\Enums\ToothCondition;
use App\Enums\ToothSurface;
use App\Http\Requests\StoreDentalChartEntryRequest;
use App\Models\DentalChartEntry;
use App\Models\Patient;
use App\Services\DentalChartService;
use Carbon\Carbon;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Redirect;
use Inertia\Inertia;
use Inertia\Response;

class DentalChartController extends Controller
{
    public function __construct(
        private readonly DentalChartService $service,
        private readonly RecordToothConditionAction $record
    ) {}

    public function show(Request $request, Patient $patient): Response
    {
        $this->authorize('viewAny', DentalChartEntry::class);

        $dentition = in_array($request->query('dentition', 'adult'), ['adult', 'primary'], true)
            ? $request->query('dentition', 'adult')
            : 'adult';
        $asOf = preg_match('/^\d{4}-\d{2}-\d{2}$/', (string) $request->query('as_of', ''))
            ? Carbon::parse($request->query('as_of'))
            : null;

        return Inertia::render('Patients/Chart', [
            'patient' => $patient,
            'dentition' => $dentition,
            'state' => $asOf
                ? $this->service->stateAsOf($patient->id, $dentition, $asOf)
                : $this->service->currentState($patient->id, $dentition),
            'asOf' => $asOf?->toDateString(),
            'history' => $this->service->history($patient->id),
            'options' => [
                'conditions' => ToothCondition::meta(),
                'restorations' => RestorationType::meta(),
                'surfaces' => ToothSurface::meta(),
                'dentitions' => DentitionType::meta(),
            ],
            'can' => [
                'update' => $request->user()->can('dental-chart.update'),
            ],
        ]);
    }

    public function store(StoreDentalChartEntryRequest $request): RedirectResponse
    {
        $this->authorize('create', DentalChartEntry::class);

        $data = $request->validated();
        $patient = Patient::findOrFail($data['patient_id']);

        $this->record->handle(
            patient: $patient,
            tooth: (int) $data['tooth_number'],
            dentition: $data['dentition'],
            condition: $data['condition'],
            surface: $data['surface'] ?? null,
            restoration: $data['restoration_type'] ?? null,
            recordedAt: $data['recorded_at'],
            notes: $data['notes'] ?? null,
            actor: $request->user(),
        );

        return Redirect::back();
    }
}
