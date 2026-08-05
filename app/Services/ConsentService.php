<?php

namespace App\Services;

use App\Enums\ConsentStatus;
use App\Models\ConsentForm;
use App\Models\Patient;
use App\Models\User;

final class ConsentService
{
    public function __construct(private readonly SignatureStorageService $signatures) {}

    /**
     * Create a draft consent form with the 10 PDA sections (no initials yet).
     */
    public function createDraft(Patient $patient, User $dentist): ConsentForm
    {
        $sections = config('consent.sections');

        $form = ConsentForm::create([
            'patient_id' => $patient->id,
            'version' => config('consent.version'),
            'consent_text' => [
                'acknowledgment' => config('consent.acknowledgment'),
                'authorization' => config('consent.authorization'),
                'sections' => $sections,
            ],
            'patient_name' => $patient->fullName(),
            'dentist_id' => $dentist->id,
            'status' => ConsentStatus::Unsigned->value,
        ]);

        foreach ($sections as $key => $section) {
            $form->sections()->create([
                'key' => $key,
                'label' => $section['label'],
            ]);
        }

        activity()->performedOn($form)->causedBy($dentist)->log('consent.created');

        return $form->load('sections');
    }

    /**
     * Record per-section initials on the draft.
     *
     * @param  array<string, string>  $initials  key => raw svg
     */
    public function recordInitials(ConsentForm $form, array $initials, User $actor): ConsentForm
    {
        foreach ($initials as $key => $svg) {
            $section = $form->sections()->where('key', $key)->first();
            if (! $section) {
                continue;
            }
            $section->update([
                'initial_svg_path' => $this->signatures->store($svg, "signatures/consents/{$form->id}-initial-{$key}.svg"),
                'initialed_at' => now(),
            ]);
        }
        activity()->performedOn($form)->causedBy($actor)->log('consent.sections_initialed');

        return $form->load('sections');
    }

    /**
     * Patient (and guardian when minor) signs the form.
     */
    public function signPatient(ConsentForm $form, string $signatureSvg, ?string $guardianName, ?string $guardianSvg): ConsentForm
    {
        $patient = $form->patient()->firstOrFail();

        if ($patient->age < 18) {
            abort_unless($guardianName && $guardianSvg, 422, 'Guardian signature required for minors.');
        }

        $form->update([
            'patient_signature_path' => $this->signatures->store($signatureSvg, "signatures/consents/{$form->id}-patient.svg"),
            'guardian_name' => $guardianName,
            'guardian_signature_path' => $guardianSvg
                ? $this->signatures->store($guardianSvg, "signatures/consents/{$form->id}-guardian.svg")
                : null,
            'patient_signed_at' => now(),
            'status' => ConsentStatus::PatientSigned->value,
            'ip_address' => request()->ip(),
            'user_agent' => request()->userAgent(),
        ]);

        activity()->performedOn($form)->causedBy(request()->user())->log('consent.patient_signed');

        return $form->refresh();
    }

    /**
     * Dentist countersigns → status signed.
     */
    public function signDentist(ConsentForm $form, string $signatureSvg, User $dentist): ConsentForm
    {
        abort_unless($form->isPatientSigned(), 409, 'Patient must sign before the dentist countersigns.');

        $form->update([
            'dentist_signature_path' => $this->signatures->store($signatureSvg, "signatures/consents/{$form->id}-dentist.svg"),
            'dentist_signed_at' => now(),
            'status' => ConsentStatus::Signed->value,
        ]);

        activity()->performedOn($form)->causedBy($dentist)->log('consent.dentist_signed');

        return $form->refresh();
    }

    /**
     * Void the current form and create a fresh draft (patient re-signs).
     */
    public function voidAndRecreate(ConsentForm $form, User $actor): ConsentForm
    {
        $form->update(['status' => ConsentStatus::Voided->value]);
        activity()->performedOn($form)->causedBy($actor)->log('consent.voided');

        return $this->createDraft($form->patient()->firstOrFail(), $actor);
    }
}
