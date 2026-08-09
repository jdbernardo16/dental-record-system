<?php

namespace App\Http\Controllers;

use App\Enums\AppointmentStatus;
use App\Enums\CivilStatus;
use App\Enums\DentitionType;
use App\Enums\RestorationType;
use App\Enums\Sex;
use App\Enums\ToothCondition;
use App\Enums\ToothSurface;
use App\Models\Patient;
use App\Services\DentalChartService;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;
use Inertia\Inertia;
use Inertia\Response;

class WizardController extends Controller
{
    /** Steps per blueprint Flow 1 (spec tail): patient, medical history, waiver, signature, dental chart. */
    public const STEPS = [
        ['key' => 'patient', 'label' => 'Patient'],
        ['key' => 'medical_history', 'label' => 'Medical history'],
        ['key' => 'waiver', 'label' => 'Waiver'],
        ['key' => 'signature', 'label' => 'Signature'],
        ['key' => 'dental_chart', 'label' => 'Dental chart'],
    ];

    public function index(Request $request, ?Patient $patient = null): Response
    {
        if ($patient === null) {
            return Inertia::render('Wizard/Index', [
                'patient' => null,
                'steps' => self::STEPS,
                'resumeStep' => 0,
                'sexOptions' => $this->enumOptions(Sex::meta()),
                'civilStatusOptions' => $this->enumOptions(CivilStatus::meta()),
                'toothOptions' => DentitionType::meta()['adult']['teeth'],
                'statusOptions' => AppointmentStatus::meta(),
                'can' => [
                    'dentalChart' => [
                        'update' => $request->user()->can('dental-chart.update'),
                    ],
                ],
            ]);
        }

        $medicalHistory = $patient->medicalHistory;
        $hasChart = $patient->chartEntries()->exists();
        $consentDraft = $patient->consentForms()->where('status', 'unsigned')->exists();
        $consentSigned = $patient->consentForms()->whereIn('status', ['patient_signed', 'signed'])->exists();

        $resumeStep = match (true) {
            $medicalHistory === null && ! $consentDraft && ! $consentSigned => 1,
            ! $consentDraft && ! $consentSigned => 2, // waiver (no consent started yet)
            ! $consentSigned => 3,                    // signature (draft exists, not signed)
            ! $hasChart => 4,
            default => 0,
        };

        // Explicit step override (e.g. "New waiver" on the patient record jumps
        // straight to the medical history step). Clamped to the step range.
        if ($request->has('step')) {
            $resumeStep = min(max((int) $request->query('step'), 0), count(self::STEPS) - 1);
        }

        $service = app(DentalChartService::class);

        $consentSections = array_map(
            fn (string $key, array $section) => [
                'key' => $key,
                'label' => $section['label'],
                'text' => $section['text'],
            ],
            array_keys(config('consent.sections')),
            config('consent.sections'),
        );

        return Inertia::render('Wizard/Index', [
            'patient' => $patient,
            'steps' => self::STEPS,
            'resumeStep' => $resumeStep,
            'medicalHistory' => $medicalHistory,
            'consentSections' => $consentSections,
            'consentAcknowledgment' => config('consent.acknowledgment'),
            'consentAuthorization' => config('consent.authorization'),
            'consentFormId' => $patient->consentForms()
                ->where('status', 'unsigned')
                ->latest()
                ->value('id'),
            'existingInitialSvg' => $this->existingInitialSvg($patient),
            'patientAge' => $patient->age,
            'sexOptions' => $this->enumOptions(Sex::meta()),
            'civilStatusOptions' => $this->enumOptions(CivilStatus::meta()),
            'toothOptions' => DentitionType::meta()['adult']['teeth'],
            'statusOptions' => AppointmentStatus::meta(),
            'chartState' => $hasChart ? $service->currentState($patient->id, 'adult') : [],
            'chartHistory' => $hasChart ? $service->history($patient->id) : [],
            'chartOptions' => [
                'conditions' => ToothCondition::meta(),
                'restorations' => RestorationType::meta(),
                'surfaces' => ToothSurface::meta(),
                'dentitions' => DentitionType::meta(),
            ],
            'can' => [
                'dentalChart' => [
                    'update' => $request->user()->can('dental-chart.update'),
                ],
            ],
        ]);
    }

    /**
     * @param  array<string, array<string, string>>  $meta
     * @return array<int, array{value: string, label: string}>
     */
    private function enumOptions(array $meta): array
    {
        return collect($meta)
            ->map(fn (array $item, string $value) => ['value' => $value, 'label' => $item['label']])
            ->values()
            ->all();
    }

    /**
     * The SVG content of the latest unsigned draft's first initial, so the
     * waiver step can re-display what the patient already drew.
     */
    private function existingInitialSvg(Patient $patient): ?string
    {
        $draft = $patient->consentForms()
            ->where('status', 'unsigned')
            ->latest()
            ->first();

        if (! $draft) {
            return null;
        }

        $path = $draft->sections()
            ->whereNotNull('initial_svg_path')
            ->value('initial_svg_path');

        if (! $path || ! Storage::disk('local')->exists($path)) {
            return null;
        }

        return Storage::disk('local')->get($path);
    }
}
