<?php

namespace App\Http\Controllers;

use App\Actions\RegisterPatientAction;
use App\Enums\AttachmentCategory;
use App\Enums\CivilStatus;
use App\Enums\DentitionType;
use App\Enums\Sex;
use App\Http\Requests\StorePatientRequest;
use App\Http\Requests\UpdatePatientRequest;
use App\Models\Consultation;
use App\Models\Patient;
use App\Repositories\PatientRepository;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Redirect;
use Inertia\Inertia;
use Inertia\Response;

class PatientsController extends Controller
{
    /**
     * Display a paginated, searchable listing of patients.
     */
    public function index(Request $request): Response
    {
        $this->authorize('viewAny', Patient::class);

        return Inertia::render('Patients/Index', [
            'patients' => app(PatientRepository::class)
                ->search($request->query('search'))
                ->withQueryString(),
            'filters' => [
                'search' => $request->query('search'),
            ],
            'can' => [
                'create' => $request->user()->can('patients.create'),
                'update' => $request->user()->can('patients.update'),
                'delete' => $request->user()->can('patients.delete'),
            ],
        ]);
    }

    /**
     * Show the form for creating a new patient.
     */
    public function create(Request $request): Response
    {
        $this->authorize('create', Patient::class);

        return Inertia::render('Patients/Create', [
            'sexOptions' => $this->enumOptions(Sex::meta()),
            'civilStatusOptions' => $this->enumOptions(CivilStatus::meta()),
        ]);
    }

    /**
     * Store a newly created patient.
     */
    public function store(StorePatientRequest $request): RedirectResponse
    {
        $this->authorize('create', Patient::class);

        $patient = app(RegisterPatientAction::class)
            ->handle($request->validated(), $request->user());

        if ($request->boolean('wizard')) {
            return Redirect::route('wizard.index', $patient);
        }

        return Redirect::route('patients.show', $patient);
    }

    /**
     * Display the given patient.
     */
    public function show(Request $request, Patient $patient): Response
    {
        $this->authorize('view', $patient);

        $canViewMedicalHistory = $request->user()->can('medical-histories.view');
        $canViewConsultations = $request->user()->can('consultations.view');
        $canViewTreatments = $request->user()->can('treatments.view');
        $canViewConsents = $request->user()->can('consents.view');
        $canViewAttachments = $request->user()->can('attachments.view');
        $canViewAppointments = $request->user()->can('appointments.view');

        $props = [
            'patient' => $patient,
            'consultationCount' => $patient->consultations()->count(),
            'consultationOptions' => [
                'periodontal' => Consultation::periodontalOptions(),
                'occlusion' => Consultation::occlusionOptions(),
                'appliances' => Consultation::applianceOptions(),
                'tmd' => Consultation::tmdOptions(),
            ],
            'toothOptions' => DentitionType::meta()['adult']['teeth'],
            'attachmentOptions' => [
                'categories' => AttachmentCategory::meta(),
                'xrayTypes' => AttachmentCategory::XRAY_TYPES,
            ],
            'can' => [
                'update' => $request->user()->can('patients.update'),
                'delete' => $request->user()->can('patients.delete'),
                'medicalHistory' => [
                    'view' => $canViewMedicalHistory,
                    'edit' => $request->user()->can('medical-histories.create'),
                ],
                'consultations' => [
                    'create' => $request->user()->can('consultations.create'),
                    'view' => $canViewConsultations,
                ],
                'treatments' => [
                    'create' => $request->user()->can('treatments.create'),
                    'sign' => $request->user()->can('treatments.sign'),
                    'view' => $canViewTreatments,
                ],
                'consents' => [
                    'view' => $canViewConsents,
                    'sign-dentist' => $request->user()->can('consents.sign-dentist'),
                ],
                'attachments' => [
                    'view' => $canViewAttachments,
                    'upload' => $request->user()->can('attachments.upload'),
                    'delete' => $request->user()->can('attachments.delete'),
                ],
                'appointments' => [
                    'view' => $canViewAppointments,
                ],
            ],
        ];

        if ($canViewMedicalHistory) {
            $props['medicalHistory'] = $patient->medicalHistory;
        }

        if ($canViewConsultations) {
            $props['consultations'] = $patient->consultations()
                ->with('dentist:id,name')
                ->latest('consultation_date')
                ->limit(20)
                ->get();
        }

        if ($canViewTreatments) {
            $props['treatments'] = $patient->treatments()
                ->with('dentist:id,name', 'consultation:id,chief_complaint')
                ->latest('treatment_date')
                ->limit(20)
                ->get();
        }

        if ($canViewConsents) {
            $props['consentForms'] = $patient->consentForms()
                ->with('patient')
                ->latest()
                ->limit(5)
                ->get();
        }

        if ($canViewAttachments) {
            $props['attachments'] = $patient->attachments()
                ->with('uploadedBy:id,name')
                ->latest()
                ->get();
        }

        if ($canViewAppointments) {
            $props['appointments'] = $patient->appointments()
                ->with('dentist:id,name')
                ->orderByDesc('appointment_date')
                ->orderByDesc('start_time')
                ->limit(20)
                ->get();
        }

        return Inertia::render('Patients/Show', $props);
    }

    /**
     * Show the form for editing the given patient.
     */
    public function edit(Request $request, Patient $patient): Response
    {
        $this->authorize('update', $patient);

        return Inertia::render('Patients/Edit', [
            'patient' => $patient,
            'sexOptions' => $this->enumOptions(Sex::meta()),
            'civilStatusOptions' => $this->enumOptions(CivilStatus::meta()),
            'can' => [
                'update' => $request->user()->can('patients.update'),
                'delete' => $request->user()->can('patients.delete'),
            ],
        ]);
    }

    /**
     * Update the given patient.
     */
    public function update(UpdatePatientRequest $request, Patient $patient): RedirectResponse
    {
        $this->authorize('update', $patient);

        $patient->update($request->validated());

        activity()
            ->performedOn($patient)
            ->withProperties(['changes' => $patient->getChanges()])
            ->log('patient.updated');

        return Redirect::route('patients.show', $patient);
    }

    /**
     * Soft-delete the given patient.
     */
    public function destroy(Request $request, Patient $patient): RedirectResponse
    {
        $this->authorize('delete', $patient);

        $patient->delete();

        activity()
            ->performedOn($patient)
            ->withProperties([
                'name' => $patient->fullName(),
                'patient_number' => $patient->patient_number,
            ])
            ->log('patient.deleted');

        return Redirect::route('patients.index');
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
