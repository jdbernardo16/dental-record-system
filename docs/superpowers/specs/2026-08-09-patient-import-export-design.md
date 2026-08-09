# Patient Import / Export (CSV) — Design

Date: 2026-08-09
Status: Approved (brainstorming, user: "Go.")

## Overview

Add bulk CSV **export** and **import** to the patient index page (`/patients`).

- **Export**: streamed CSV of the currently filtered patient list (respects the active search box), UTF-8 BOM for Excel compatibility.
- **Import**: 3-step flow — upload → server-side preview with per-row status (new / duplicate / invalid) → confirm to commit valid rows. Duplicates and invalid rows are never written.

## Decisions (user-approved)

1. **Format**: CSV only.
2. **Export scope**: current search filter ("what you see is what you get").
3. **Duplicate strategy**: rows matching an existing patient (first + last + birth date, case-insensitive) are skipped; preview shows per-row statuses before anything is written.
4. **Columns**: core demographics only (11 importable fields + read-only export columns).

## CSV contract

| Column | Importable | Notes |
|---|---|---|
| patient_number | no | export only; import auto-generates |
| first_name | yes | required |
| middle_name | yes | nullable |
| last_name | yes | required |
| sex | yes | `male` / `female` (raw enum values) |
| birth_date | yes | `Y-m-d`, must be before today |
| civil_status | yes | `single,married,widowed,separated,divorced,annulled,other` |
| nationality | yes | required |
| occupation | yes | nullable |
| contact_number | yes | required, `^[0-9+ -]{7,20}$` |
| address | yes | required |
| email_address | yes | nullable, must be valid email |

- Export adds `created_at`? **No** — keep to the 12 columns above (11 + patient_number).
- Empty strings normalize to `null` for nullable fields before validation.
- Unknown/extra columns in an uploaded file are ignored; missing **required** columns are a hard error with a clear message.

## Backend

### Dependency

Add `league/csv` (composer) for robust parsing (BOM, CRLF, quoting). If composer/network fails, fall back to native `fgetcsv` + manual BOM stripping — but attempt league/csv first.

### Routes (routes/web.php — MUST be registered BEFORE `GET /patients/{patient}`)

| Method | URI | Name | Permission |
|---|---|---|---|
| GET | `/patients/export` | `patients.export-csv` | `patients.view` |
| GET | `/patients/import/template` | `patients.import-template` | `patients.create` |
| POST | `/patients/import/preview` | `patients.import-preview` | `patients.create` |
| POST | `/patients/import` | `patients.import` | `patients.create` |

### Shared validation rules

New `app/Support/PatientRules.php` — `PatientRules::all(): array` returns the exact rules currently in `StorePatientRequest`. `StorePatientRequest::rules()` delegates to it. Import row validation reuses the same array (single source of truth).

### Export — `PatientsController@exportCsv`

Follows the `ReportsController` pattern (`response()->streamDownload` + `fputcsv`, `Content-Type: text/csv`):

- `fwrite($handle, "\xEF\xBB\xBF")` first (UTF-8 BOM).
- Query: `Patient::query()->when($search, fn ($q) => $q->search($search))->orderByDesc('created_at')`, iterated with `->cursor()` inside the stream closure (memory-safe).
- Row values mapped explicitly: enum columns via `getRawOriginal('sex'|'civil_status')`, `birth_date?->format('Y-m-d')`, nullable strings → `''`.
- Filename: `patients-YYYYMMDD-HHMM.csv`.

### Import service — new `app/Services/PatientImportService.php`

Public API:

- `parse(UploadedFile $file): array` — league/csv Reader (`setHeaderOffset(0)`), header normalization (trim, lowercase, spaces→underscores, strip BOM), required-column check, row cap (500), returns normalized rows as `['header' => value]` maps.
- `validateRows(array $rows): array` — per-row `Validator::make($row, PatientRules::all())`; converts `''` → `null` first; duplicate check per row:
  `Patient::whereRaw('LOWER(first_name) = ?', [mb_strtolower($v)])->whereRaw('LOWER(last_name) = ?', [...])->whereDate('birth_date', $v)->exists()` (trashed excluded by default scope).
  Returns `[{ row_number, data, status: 'new'|'duplicate'|'invalid', errors: [] }]`.
- `preview(array $rows): array` — returns `{ rows (capped at 10 for UI), total, summary: { new, duplicate, invalid }, token }`; stores ALL validated rows in session under `patient-import.{token}` with `expires = now()->addMinutes(30)`; token = `Str::random(40)`.
- `import(string $token, User $actor): array` — reads session rows, re-checks duplicates at commit time (race-proof), creates each valid row via `RegisterPatientAction` (auto patient number + audit log + unique-collision retry) in a per-row `DB::transaction` with try/catch, returns `{ imported, skipped_duplicate, failed }`. Forgets the session key. Logs `patients.imported` activity with counts.

### Controller methods

- `exportCsv(Request)` — permission via route middleware; reads `?search=` same as index.
- `importTemplate()` — streams a CSV with only the header row (11 importable columns).
- `importPreview(ImportPatientsRequest)` — validates file (`required|file|mimes:csv,txt|max:2048`), parses, validates rows, returns `Inertia::render('Patients/Index', [...props, 'importPreview' => ...])` with `only: ['importPreview']` for partial reload.
- `import(ConfirmImportRequest)` — `token` required; runs service; `Redirect::back()->with('importResult', $result)`.

### Flash sharing (new)

`HandleInertiaRequests::share()` adds `'importResult' => $request->session()->get('importResult')` so the confirm POST result reaches the frontend modal (standard Inertia flash pattern).

## Frontend (`resources/js/Pages/Patients/Index.vue`)

- Toolbar next to "Register patient": **Export** button (Download icon + "Export") as a plain `<a :href="route('patients.export-csv', { search: props.filters.search || undefined })">`; **Import** button (Upload icon + "Import") opens the modal. Export link always available; Import button rendered only when `can.import`.
- `can` prop additions in `PatientsController@index`: `'import' => $request->user()->can('patients.create')`.
- **Import modal** (`Modal.vue`, `max-width="lg"`), 3 steps via ref state:
  1. **Upload** — file input (accept `.csv`), "Download template" link (`route('patients.import-template')`), client size/type guard + server `importPreview.errors.file` display.
  2. **Preview** — summary line "N new · N duplicates · N invalid", table of preview rows (max 10 shown) with status badges (New=success, Duplicate=warning, Invalid=error + first error text), Back + Confirm buttons; Confirm disabled when `new === 0`.
  3. **Result** — "N imported · N skipped · N failed", Done button.
- Flow: `useForm({ file: null })` → POST `patients.import-preview` with `preserveScroll, only: ['importPreview']`; then `useForm({ token: '' })` → POST `patients.import`; result read from `$page.props.importResult` (watch it), then modal moves to step 3.
- Import modal state resets when closed.

## Security / limits

- Import gated behind `patients.create`; export behind `patients.view` (route middleware).
- File: max 2 MB, `.csv`/`.txt`; max 500 rows per import (hard error above).
- Per-row transaction; one bad row can't roll back the batch.
- Session rows expire after 30 minutes; session key forgotten after import.
- No changes to patient_number assignment (always server-generated).

## Tests (TDD — feature tests in `tests/Feature/Patients/`)

1. Export returns `text/csv`, correct headers + row data + BOM, respects `?search=`.
2. Export gated by `patients.view` (403 without).
3. Template download returns header-only CSV.
4. Preview: valid + duplicate + invalid rows → correct per-row statuses and summary, token present.
5. Preview: missing required column → error; >500 rows → error; wrong mime → error.
6. Import: creates patients with generated numbers, skips duplicates and invalid, returns counts.
7. Import gated by `patients.create`.
8. Import with expired/unknown token → error.
9. StorePatientRequest still passes (rules extraction refactor didn't change behavior — existing suite must stay green).

## Verification

- `./vendor/bin/pest` — full suite green (Breeze tests included).
- `npm run test` (vitest) — green.
- `npm run build` — clean.
- Manual smoke via browser: export downloads; import upload → preview → confirm → patients appear in table.

## Out of scope

- XLSX, multi-sheet, column selection UI, template value hints.
- Import of medical history / chart / other sub-records.
- Updating existing records (upsert) — duplicates always skipped.
