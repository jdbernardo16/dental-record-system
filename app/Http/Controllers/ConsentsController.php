<?php

namespace App\Http\Controllers;

use App\Http\Requests\SignDentistConsentRequest;
use App\Http\Requests\SignPatientConsentRequest;
use App\Http\Requests\StoreConsentRequest;
use App\Models\ConsentForm;
use App\Models\Patient;
use App\Services\ConsentService;
use App\Services\SettingsService;
use App\Support\PdfExport;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Redirect;
use Inertia\Inertia;
use Inertia\Response;

class ConsentsController extends Controller
{
    public function __construct(private readonly ConsentService $service) {}

    public function store(StoreConsentRequest $request): RedirectResponse
    {
        $this->authorize('create', ConsentForm::class);

        $patient = Patient::findOrFail($request->validated()['patient_id']);
        $form = $this->service->createDraft($patient, $request->user());
        $this->service->recordInitials($form, $request->validated()['initials'], $request->user());

        return Redirect::route('wizard.index', $patient);
    }

    public function show(Request $request, ConsentForm $consentForm): Response
    {
        $this->authorize('view', $consentForm);

        $consent = $consentForm->load(['patient', 'sections', 'dentist:id,name']);

        // Section rows don't store the text — merge it in from the consent
        // snapshot (what the patient actually saw), falling back to the
        // current template config.
        $snapshot = $consent->consent_text['sections'] ?? [];
        $consent->sections->transform(function ($section) use ($snapshot) {
            $section->text = $snapshot[$section->key]['text']
                ?? config("consent.sections.{$section->key}.text")
                ?? '';

            return $section;
        });

        return Inertia::render('Consents/Show', [
            'consent' => $consent,
        ]);
    }

    /**
     * Preview a templated PDF document of a single consent form.
     */
    public function pdf(Request $request, ConsentForm $consentForm): \Illuminate\Http\Response
    {
        $this->authorize('view', $consentForm);

        $consent = $consentForm->load(['patient', 'sections', 'dentist:id,name']);

        return PdfExport::make('pdf.consent', [
            'consent' => $consent,
            'clinic' => [
                'name' => app(SettingsService::class)->get('clinic.name', 'Dental Clinic'),
                'address' => app(SettingsService::class)->get('clinic.address', ''),
            ],
            'exportedAt' => now()->format('F j, Y g:i A'),
        ], "consent-{$consent->id}-{$consent->patient_name}");
    }

    public function patientSign(SignPatientConsentRequest $request, ConsentForm $consentForm): RedirectResponse
    {
        $this->authorize('signPatient', $consentForm);

        $this->service->signPatient(
            $consentForm,
            $request->string('signature_svg'),
            $request->input('guardian_name'),
            $request->input('guardian_svg'),
        );

        return Redirect::back();
    }

    public function dentistSign(SignDentistConsentRequest $request, ConsentForm $consentForm): RedirectResponse
    {
        $this->authorize('signDentist', $consentForm);

        $this->service->signDentist($consentForm, $request->string('signature_svg'), $request->user());

        return Redirect::back();
    }
}
