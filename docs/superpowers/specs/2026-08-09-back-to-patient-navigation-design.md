# Back to Patient Navigation — Design Spec

**Date:** 2026-08-09
**Status:** Approved by user (verbal; Option A chosen — header button; generic "Back to patient" label)
**Branch:** feat/odontogram-revamp

## Problem

From the patient record page (`/patients/{id}`), three outbound links leave the user stranded with no way back to the patient record:

1. **View calendar** → `/appointments` (from the Appointments tab). The appointments page has no patient context at all.
2. **Dental chart** → `/patients/{id}/chart`. The page has the patient id but no back affordance.
3. **New waiver** → `/wizard/{id}`. The wizard has the patient id but no back affordance.

## Requirements

- A "Back to patient" button in the header of each destination page, linking to `route('patients.show', patient.id)`.
- Generic label only — no patient name (Option A).
- Calendar page: the back button appears **only when the user arrived from a patient record** (`?patient=` query param). The global sidebar calendar (no param) shows no back button.
- Wizard: button appears only when a patient is loaded (no-patient new-intake wizard is untouched).

## Changes

### New: `resources/js/Components/BackToPatient.vue`

Tiny shared component: `ChevronLeft` icon + "Back to patient" outline button rendering a `<Link>` to `route('patients.show', patientId)`.

- Props: `patientId` (Number, required).
- Styling mirrors existing header actions (outline button, `size="sm"` — match the "View calendar" button in `Patients/Show.vue`).

### `resources/js/Pages/Patients/Chart.vue`

- Add `<BackToPatient :patient-id="patient.id" />` to the page header, next to the `fullName()` title. No backend change (patient id already in props).

### `resources/js/Pages/Wizard/Index.vue`

- Add `<BackToPatient :patient-id="patient.id" />` to the header next to the "Patient intake" title, rendered only when `patient` is set (`v-if="patient"`). No backend change.

### `resources/js/Pages/Patients/Show.vue`

- "View calendar" button (`~line 852`) changes from `route('appointments.index')` to `route('appointments.index', { patient: patient.id })`.

### `app/Http/Controllers/AppointmentsController.php`

- `index()` reads the `patient` query param and passes `backToPatient` to the page **only when all** hold:
  - param matches `/^\d+$/` (positive int),
  - a patient with that id exists,
  - the user can `patients.view`.
- When any check fails, `backToPatient` is omitted (no back button — same as today).

### `resources/js/Pages/Appointments/Index.vue`

- Props gain `backToPatient` (Object|null: `{ id }`).
- Header renders `<BackToPatient :patient-id="backToPatient.id" />` only when the prop is present.

## Testing

- **Pest** (`tests/Feature/Appointments/ManageAppointmentsTest.php` or a new case):
  - shows back link with valid `?patient=` for a permitted user,
  - omits it with no param,
  - omits it with invalid (non-numeric) id,
  - omits it with a nonexistent patient id,
  - omits it when the user lacks `patients.view`.
- **Vitest** (`tests/js/BackToPatient.spec.js`): renders a link to `patients.show` for the given id.
- **Manual**: from `/patients/9`, click through Calendar → back, Chart → back, New waiver → back.

## Out of scope

Breadcrumbs, back links on consents/attachments pages, preserving wizard step state on return (steps persist server-side already), deep-link support.
