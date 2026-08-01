# 13 — API Contracts

## Routing Conventions

- Inertia pages: `GET /patients`, `GET /patients/{patient}` etc. — return `Inertia::render`.
- State-changing (POST/PATCH/DELETE) → 303 redirect back with Inertia toast (`success`).
- JSON endpoints (signatures, chart entries, uploads) → JSON responses, no redirect.
- Named routes via Ziggy (`route('patients.show', id)` in JS).

## Page Routes

| Route | Page | Permission |
|---|---|---|
| `GET /login` | `Auth/Login` | guest |
| `GET /dashboard` | `Dashboard/Index` | authenticated |
| `GET /patients` | `Patients/Index` | patients.view |
| `GET /patients/create` | `Patients/Create` | patients.create |
| `GET /patients/{patient}` | `Patients/Show` | patients.view |
| `PATCH /patients/{patient}` | — | patients.update |
| `DELETE /patients/{patient}` | — | patients.delete |
| `GET /wizard/{patient?}` | `Wizard/Index` | patients.view (multi-step intake) |
| `GET /appointments` | `Appointments/Index` | appointments.view |
| `POST /appointments` · `PATCH /appointments/{a}` | — | appointments.create / update |
| `POST /appointments/{a}/attendance` | — | appointments.attendance |
| `GET /consultations` | `Consultations/Index` | consultations.view |
| `GET /dental-chart` | `DentalChart/Index` | dental-chart.view |
| `GET /treatments` | `Treatments/Index` | treatments.view |
| `GET /attachments` | `Attachments/Index` | attachments.view |
| `GET /consents` | `Consents/Index` | consents.view |
| `GET /reports` | `Reports/Index` | reports.view |
| `GET /settings` | `Settings/Index` | settings.view |
| `GET /users` | `Users/Index` | users.view |

## JSON Endpoints

| Method + Path | Body | Success | Errors |
|---|---|---|---|
| `POST /api/signatures` | `{ svg: string }` | `200 { path }` | 422 malformed, 413 too large, 403 |
| `POST /treatments/{treatment}/sign` | `{ svg }` | `200 { signed_at, path }` | 403, 422, 404 |
| `POST /consents/{form}/patient-sign` | `{ svg, guardian_name?, guardian_svg? }` | `200 { status }` | 422 (minor w/o guardian), 403 |
| `POST /consents/{form}/dentist-sign` | `{ svg }` | `200 { status }` | 403, 422 |
| `POST /attachments` | multipart: `file, category, patient_id` | `201 { attachment }` | 413 > max size, 422 type |
| `POST /dental-chart/entries` | `{ tooth_number, dentition, condition, surface?, recorded_at, notes? }` | `201 { entry }` | 422 FDI range, 403 |
| `GET /patients/{patient}/chart?as_of=YYYY-MM-DD&dentition=adult` | — | `200 { state }` | 404 |

## Response Format

- **JSON success**: `{ data: ... }` (no envelope).
- **JSON error**: `{ message, errors?: {...} }` with proper HTTP code.
- **Inertia errors**: Laravel validation → `$errors` prop; redirect back with `$message` flash for toasts.

## Error Codes

| Code | Meaning | UI |
|---|---|---|
| 401 | unauthenticated (session expired on tablet) | redirect login |
| 403 | permission denied (policy) | toast "Not allowed" |
| 404 | record missing / soft-deleted | toast |
| 409 | conflicting state (e.g., appointment already completed) | toast + refresh |
| 413 | file too large | upload error inline |
| 419 | CSRF token mismatch (sleeping tablet) | auto login redirect |
| 422 | validation failed | inline field errors |
| 429 | rate limited | toast + retry-after |

## Validation Conventions

- FormRequests per write endpoint (`CreatePatientRequest`, `SignTreatmentRequest`...).
- Tooth validation: `Rule::toothNumber(dentition)` — FDI range 11–48 / 51–85.
- Signature SVG: must parse as SVG (libxml), max 512 KB, sanitized (no scripts/foreign objects).
- Appointment time window: no overlap with same dentist (unless `appointment.overlap` setting).

## Rate Limiting

- Login: 5/min per email+IP (prevents brute force on clinic tablets).
- Signature endpoints: 10/min.
- Uploads: 20/hour per user.
- Global API: 120/min per user (middleware `throttle`).

## Pagination & Filtering

- List pages: `?page=`, `?per_page=` (default 20), `?search=` (patients: name/number/contact), `?status=`, `?date=`.
- Sorted by: patients `created_at desc`; appointments `appointment_date, start_time asc`; clinical lists `recorded_at/treatment_date desc`.
