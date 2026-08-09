# Intake Wizard — Remove Consultation & Treatment Steps

**Date:** 2026-08-09
**Status:** Approved by user (verbal)
**Branch:** feat/odontogram-revamp

## Problem

The patient intake wizard collects a consultation and a treatment on every intake. The user wants these removed from the intake flow — consultations and treatments are done on demand from the patient record page, not on every intake.

## Requirements

- Wizard becomes 5 steps: `Patient → Medical history → Waiver → Signature → Dental chart`.
- The dental chart is the final step; its button becomes **"Finish"** → navigates to the patient record page (same as the old Finish behavior).
- Consultations/treatments remain fully available on the patient record page — the form components (`ConsultationForm.vue`, `TreatmentForm.vue`) are **kept**.
- Resume logic re-maps to the 5-step wizard.

## Changes

### `app/Http/Controllers/WizardController.php`

- `STEPS`: remove the `consultation` and `treatment` entries.
- `resumeStep` match: drop the `! $hasConsultation => 4` and `! $hasTreatment => 6` gates (and the now-unused `$hasConsultation`/`$hasTreatment` queries); re-index `! $hasChart => 4`, `default => 0`.
- Remove props no longer consumed by the frontend: `consultationOptions`, `toothOptions`, `treatments`, `consultations`, and `can.treatments.sign` (both the new-patient and resuming render paths).
- Remove the now-unused `use App\Models\Consultation` import.

### `resources/js/Pages/Wizard/Index.vue`

- Remove imports: `ConsultationForm`, `TreatmentForm`, `SignaturePadModal`, `encodeSvgPayload`, and the `Signature` lucide icon.
- Remove props: `consultationOptions`, `toothOptions`, `treatments`, `consultations` (keep `can` — chart permission).
- Remove handlers: `onConsultationSaved`, `onChartDone`, `onTreatmentSaved` (chart button calls `finishWizard` directly).
- Remove the sign-treatment modal logic: `signModalOpen`, `signingTreatment`, `signForm`, `openSign`, `confirmSign`, `closeSign`, `formatSignedAt`.
- `backStep`: drop the `current === 4 ? 1` quirk → `Math.max(0, current - 1)`.
- Template: remove the consultation step block (old step 4) and the treatment step block (old step 6 — form, treatment records list, sign buttons); chart block `v-show` re-indexed to `step === 4`; chart button becomes **Finish**; footer "Step X of 7" → dynamic `of {{ steps.length }}`; remove the `SignaturePadModal`.

## Out of Scope

- No changes to `ConsultationForm.vue` / `TreatmentForm.vue` or the patient record page.
- No changes to the dental chart step content.
- `statusOptions` (already-unused prop) left as-is.
