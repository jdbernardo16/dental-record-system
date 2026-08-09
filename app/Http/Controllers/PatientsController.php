<?php

namespace App\Http\Controllers;

use App\Actions\RegisterPatientAction;
use App\Enums\AttachmentCategory;
use App\Enums\CivilStatus;
use App\Enums\DentitionType;
use App\Enums\RestorationType;
use App\Enums\Sex;
use App\Enums\ToothCondition;
use App\Enums\ToothSurface;
use App\Http\Requests\ConfirmImportRequest;
use App\Http\Requests\ImportPatientsRequest;
use App\Http\Requests\StorePatientRequest;
use App\Http\Requests\UpdatePatientRequest;
use App\Models\Consultation;
use App\Models\Patient;
use App\Repositories\PatientRepository;
use App\Services\DentalChartService;
use App\Services\PatientImportService;
use App\Services\SettingsService;
use App\Support\PdfExport;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Redirect;
use Inertia\Inertia;
use Inertia\Response;
use InvalidArgumentException;
use Symfony\Component\HttpFoundation\StreamedResponse;

class PatientsController extends Controller
{
    /**
     * Display a paginated, searchable listing of patients.
     */
    public function index(Request $request): Response
    {
        $this->authorize('viewAny', Patient::class);

        return Inertia::render('Patients/Index', $this->indexProps($request));
    }

    /**
     * Stream a CSV export of the currently filtered patient list.
     */
    public function exportCsv(Request $request): StreamedResponse
    {
        $this->authorize('viewAny', Patient::class);

        $filters = $this->indexFilters($request);

        return response()->streamDownload(function () use ($filters) {
            $handle = fopen('php://output', 'w');
            fwrite($handle, "\xEF\xBB\xBF");
            fputcsv($handle, array_merge(['patient_number'], PatientImportService::IMPORTABLE_COLUMNS));

            app(PatientRepository::class)
                ->query($filters)
                ->cursor()
                ->each(function (Patient $patient) use ($handle) {
                    fputcsv($handle, [
                        $this->csvCell($patient->patient_number),
                        $this->csvCell($patient->first_name),
                        $this->csvCell($patient->middle_name ?? ''),
                        $this->csvCell($patient->last_name),
                        $this->csvCell($patient->getRawOriginal('sex')),
                        $this->csvCell($patient->birth_date?->format('Y-m-d')),
                        $this->csvCell($patient->getRawOriginal('civil_status')),
                        $this->csvCell($patient->nationality),
                        $this->csvCell($patient->occupation ?? ''),
                        $this->csvCell($patient->contact_number),
                        $this->csvCell($patient->address),
                        $this->csvCell($patient->email_address ?? ''),
                    ]);
                });

            fclose($handle);
        }, 'patients-'.now()->format('Ymd-Hi').'.csv', ['Content-Type' => 'text/csv; charset=utf-8']);
    }

    /**
     * Neutralize spreadsheet formula injection for CSV cell values.
     */
    private function csvCell(?string $value): string
    {
        if ($value === null || $value === '') {
            return '';
        }

        $first = $value[0];

        return in_array($first, ['=', '+', '-', '@', "\t", "\r"], true)
            ? "'".$value
            : $value;
    }

    /**
     * Sanitize query params into a filter array for the patient repository.
     *
     * Lenient whitelist approach: unknown or malformed values are dropped
     * (never redirect/throw), and missing sort/direction fall back to the
     * default listing (created_at descending).
     *
     * @return array<string, mixed>
     */
    private function indexFilters(Request $request): array
    {
        $sort = $request->query('sort');
        $sort = in_array($sort, ['name', 'patient_number', 'sex', 'age', 'created_at'], true)
            ? $sort
            : 'created_at';

        $direction = $request->query('direction');
        if (! in_array($direction, ['asc', 'desc'], true)) {
            $direction = $sort === 'created_at' ? 'desc' : 'asc';
        }

        return [
            'search' => is_string($request->query('search')) ? $request->query('search') : null,
            'sex' => in_array($request->query('sex'), ['male', 'female'], true)
                ? $request->query('sex')
                : null,
            'civil_status' => in_array($request->query('civil_status'), array_keys(CivilStatus::meta()), true)
                ? $request->query('civil_status')
                : null,
            'age_min' => $this->positiveInt($request->query('age_min')),
            'age_max' => $this->positiveInt($request->query('age_max')),
            'date_from' => $this->isoDate($request->query('date_from')),
            'date_to' => $this->isoDate($request->query('date_to')),
            'sort' => $sort,
            'direction' => $direction,
        ];
    }

    private function positiveInt(mixed $value): ?int
    {
        return is_string($value) && ctype_digit($value) ? (int) $value : null;
    }

    private function isoDate(mixed $value): ?string
    {
        return is_string($value) && preg_match('/^\d{4}-\d{2}-\d{2}$/', $value) === 1
            ? $value
            : null;
    }

    /**
     * Stream a CSV template containing only the importable header row.
     */
    public function importTemplate(): StreamedResponse
    {
        return response()->streamDownload(function () {
            $handle = fopen('php://output', 'w');
            fputcsv($handle, PatientImportService::IMPORTABLE_COLUMNS);
            fclose($handle);
        }, 'patient-import-template.csv', ['Content-Type' => 'text/csv; charset=utf-8']);
    }

    /**
     * Validate an uploaded CSV and preview per-row statuses before commit.
     */
    public function importPreview(ImportPatientsRequest $request): Response
    {
        $service = app(PatientImportService::class);

        try {
            $preview = $service->preview(
                $service->validateRows($service->parse($request->file('file')))
            );
        } catch (InvalidArgumentException $e) {
            return Redirect::back()->withErrors(['file' => $e->getMessage()]);
        }

        return Inertia::render('Patients/Index', [
            ...$this->indexProps($request),
            'importPreview' => $preview,
        ]);
    }

    /**
     * Commit a previously previewed import batch.
     */
    public function import(ConfirmImportRequest $request): RedirectResponse
    {
        try {
            $result = app(PatientImportService::class)
                ->import($request->validated()['token'], $request->user());
        } catch (InvalidArgumentException $e) {
            return Redirect::back()->withErrors(['token' => $e->getMessage()]);
        }

        return Redirect::back()->with('importResult', $result);
    }

    /**
     * Shared props for the patient index page (full render or partial reload).
     *
     * @return array<string, mixed>
     */
    private function indexProps(Request $request): array
    {
        $filters = $this->indexFilters($request);

        return [
            'patients' => app(PatientRepository::class)
                ->query($filters)
                ->paginate(20)
                ->withQueryString(),
            'filters' => $filters,
            'can' => [
                'create' => $request->user()->can('patients.create'),
                'update' => $request->user()->can('patients.update'),
                'delete' => $request->user()->can('patients.delete'),
                'import' => $request->user()->can('patients.create'),
            ],
        ];
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
        $canViewChart = $request->user()->can('dental-chart.view');
        $canUpdateChart = $request->user()->can('dental-chart.update');

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
            'chartOptions' => [
                'conditions' => ToothCondition::meta(),
                'restorations' => RestorationType::meta(),
                'surfaces' => ToothSurface::meta(),
                'dentitions' => DentitionType::meta(),
            ],
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
                    'create' => $request->user()->can('consents.create'),
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
                'chart' => [
                    'view' => $canViewChart,
                    'update' => $canUpdateChart,
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
                ->paginate(10, ['*'], 'consultations_page')
                ->appends($request->query());
        }

        if ($canViewTreatments) {
            $props['treatments'] = $patient->treatments()
                ->with('dentist:id,name', 'consultation:id,chief_complaint')
                ->latest('treatment_date')
                ->paginate(10, ['*'], 'treatments_page')
                ->appends($request->query());
        }

        if ($canViewConsents) {
            $props['consentForms'] = $patient->consentForms()
                ->with('patient')
                ->latest()
                ->paginate(10, ['*'], 'consents_page')
                ->appends($request->query());
        }

        if ($canViewAttachments) {
            $props['attachments'] = $patient->attachments()
                ->with('uploadedBy:id,name')
                ->latest()
                ->paginate(10, ['*'], 'files_page')
                ->appends($request->query());
        }

        if ($canViewChart) {
            $props['chartState'] = app(DentalChartService::class)->currentState($patient->id, 'adult');
            $props['chartEntryCount'] = $patient->chartEntries()->count();
        }

        if ($canViewAppointments) {
            $props['appointments'] = $patient->appointments()
                ->with('dentist:id,name')
                ->orderByDesc('appointment_date')
                ->orderByDesc('start_time')
                ->paginate(10, ['*'], 'appointments_page')
                ->appends($request->query());
        }

        return Inertia::render('Patients/Show', $props);
    }

    /**
     * Show the printable full-record export for the given patient.
     */
    public function export(Request $request, Patient $patient): Response
    {
        $this->authorize('view', $patient);

        return Inertia::render('Patients/Export', $this->patientExportData($request, $patient));
    }

    /**
     * Preview (and optionally download) a templated PDF document of the
     * patient's full record — streamed inline so the browser shows its
     * built-in PDF viewer.
     */
    public function pdf(Request $request, Patient $patient): \Illuminate\Http\Response
    {
        $this->authorize('view', $patient);

        return PdfExport::make(
            'pdf.patient-record',
            $this->patientExportData($request, $patient),
            "patient-record-{$patient->patient_number}",
        );
    }

    /**
     * Shared record data for the printable page and the PDF document.
     *
     * @return array<string, mixed>
     */
    private function patientExportData(Request $request, Patient $patient): array
    {
        $canViewClinical = [
            'medical-history' => $request->user()->can('medical-histories.view'),
            'consultations' => $request->user()->can('consultations.view'),
            'chart' => $request->user()->can('dental-chart.view'),
            'treatments' => $request->user()->can('treatments.view'),
            'consents' => $request->user()->can('consents.view'),
            'attachments' => $request->user()->can('attachments.view'),
        ];

        $chartService = app(DentalChartService::class);

        return [
            'patient' => $patient,
            'canViewClinical' => $canViewClinical,
            'medicalHistory' => $canViewClinical['medical-history'] ? $patient->medicalHistory : null,
            'consultations' => $canViewClinical['consultations']
                ? $patient->consultations()->with('dentist:id,name')->latest('consultation_date')->get()
                : collect(),
            'chartState' => $canViewClinical['chart']
                ? [
                    'adult' => $chartService->currentState($patient->id, 'adult'),
                    'primary' => $chartService->currentState($patient->id, 'primary'),
                ]
                : null,
            'chartHistory' => $canViewClinical['chart']
                ? $chartService->history($patient->id)->take(100)->values()
                : collect(),
            'treatments' => $canViewClinical['treatments']
                ? $patient->treatments()->with('dentist:id,name', 'consultation:id,chief_complaint')->latest('treatment_date')->get()
                : collect(),
            'consentForms' => $canViewClinical['consents']
                ? $patient->consentForms()->with('patient', 'dentist:id,name', 'sections')->latest()->get()
                : collect(),
            'attachments' => $canViewClinical['attachments']
                ? $patient->attachments()->with('uploadedBy:id,name')->latest()->get()
                : collect(),
            'options' => [
                'conditions' => ToothCondition::meta(),
                'restorations' => RestorationType::meta(),
                'surfaces' => ToothSurface::meta(),
                'dentitions' => DentitionType::meta(),
            ],
            'clinic' => [
                'name' => app(SettingsService::class)->get('clinic.name', 'Dental Clinic'),
                'address' => app(SettingsService::class)->get('clinic.address', ''),
            ],
            'exportedAt' => now()->format('F j, Y g:i A'),
        ];
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
