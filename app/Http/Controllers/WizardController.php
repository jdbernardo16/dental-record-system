<?php

namespace App\Http\Controllers;

use App\Enums\AppointmentStatus;
use App\Enums\CivilStatus;
use App\Enums\DentitionType;
use App\Enums\RestorationType;
use App\Enums\Sex;
use App\Enums\ToothCondition;
use App\Enums\ToothSurface;
use App\Models\Consultation;
use App\Models\Patient;
use App\Services\DentalChartService;
use Illuminate\Http\Request;
use Inertia\Inertia;
use Inertia\Response;

class WizardController extends Controller
{
    /** Steps per blueprint Flow 1 (spec tail): patient, medical history, waiver, signature, consultation, dental chart, treatment. */
    public const STEPS = [
        ['key' => 'patient', 'label' => 'Patient'],
        ['key' => 'medical_history', 'label' => 'Medical history'],
        ['key' => 'waiver', 'label' => 'Waiver'],
        ['key' => 'signature', 'label' => 'Signature'],
        ['key' => 'consultation', 'label' => 'Consultation'],
        ['key' => 'dental_chart', 'label' => 'Dental chart'],
        ['key' => 'treatment', 'label' => 'Treatment'],
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
                'consultationOptions' => [
                    'periodontal' => Consultation::periodontalOptions(),
                    'occlusion' => Consultation::occlusionOptions(),
                    'appliances' => Consultation::applianceOptions(),
                    'tmd' => Consultation::tmdOptions(),
                ],
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
        $hasConsultation = $patient->consultations()->exists();
        $hasChart = $patient->chartEntries()->exists();
        $hasTreatment = $patient->treatments()->exists();
        $consentDraft = $patient->consentForms()->where('status', 'unsigned')->exists();
        $consentSigned = $patient->consentForms()->whereIn('status', ['patient_signed', 'signed'])->exists();

        $resumeStep = match (true) {
            $medicalHistory === null && ! $consentDraft && ! $consentSigned => 1,
            ! $consentDraft && ! $consentSigned => 2, // waiver (no consent started yet)
            ! $consentSigned => 3,                    // signature (draft exists, not signed)
            ! $hasConsultation => 4,
            ! $hasChart => 5,
            ! $hasTreatment => 6,
            default => 0,
        };

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
            'patientAge' => $patient->age,
            'sexOptions' => $this->enumOptions(Sex::meta()),
            'civilStatusOptions' => $this->enumOptions(CivilStatus::meta()),
            'consultationOptions' => [
                'periodontal' => Consultation::periodontalOptions(),
                'occlusion' => Consultation::occlusionOptions(),
                'appliances' => Consultation::applianceOptions(),
                'tmd' => Consultation::tmdOptions(),
            ],
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
            'treatments' => $patient->treatments()
                ->with('dentist:id,name', 'consultation:id,chief_complaint')
                ->latest('treatment_date')
                ->limit(20)
                ->get(),
            'consultations' => $patient->consultations()
                ->with('dentist:id,name')
                ->latest('consultation_date')
                ->limit(20)
                ->get(),
            'can' => [
                'dentalChart' => [
                    'update' => $request->user()->can('dental-chart.update'),
                ],
                'treatments' => [
                    'sign' => $request->user()->can('treatments.sign'),
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
}
