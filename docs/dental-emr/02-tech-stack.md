# 02 — Tech Stack & Conventions

## Stack

| Layer | Choice | Version/Notes |
|---|---|---|
| Backend | Laravel | 12 (PHP 8.3) |
| Frontend | Vue 3 `<script setup>` Composition API | via Inertia.js v2 |
| Full-stack glue | Inertia.js | `laravel-vite-plugin` + `@inertiajs/vue3` |
| Styling | Tailwind CSS v4 | CSS-first config, design tokens in `@theme` (OKLCH) |
| Database | MySQL 8 | InnoDB, utf8mb4 |
| Build | Vite | |
| Signatures | `szimek/signature_pad` + `vue-signature-pad` | SVG export |
| RBAC | `spatie/laravel-permission` | |
| Auditing | `spatie/laravel-activitylog` | |
| Routes in JS | `ziggy` | |
| Dev | laravel-debugbar, Pint, PHPStan | |

## Conventions (no boilerplate exists — these are the proposed project conventions)

### Migrations
- **Anonymous class migrations** (`return new class extends Migration`).
- Naming: `create_{table}_table`, `add_{column}_to_{table}_table`.
- **No MySQL `enum()`** — all status/type columns are `string` + PHP `BackedEnum` with a `meta()` method.
- Foreign keys: `foreignId()->constrained()->cascadeOnDelete()` except where business rules require nullability (e.g., `dentist_id` nullable with `nullOnDelete()`).
- `patients` uses **soft deletes** (Phase 4 archiving); clinical data (chart entries, treatments, consents) is **append-only and never hard-deleted** — destroy is restricted to Administrator via policy.
- Timestamps on every table.

### Directory layout (from spec §15)
```
app/
├── Actions          # single-purpose workflows (e.g., RegisterPatient, SignConsent)
├── Enums            # BackedEnums with meta() (labels, colors, icons)
├── Http/Controllers # thin, Inertia pages only; no business logic
├── Models           # Eloquent, guarded: []
├── Policies         # one per guarded entity
├── Services         # multi-step business logic (state transitions, chart logic)
└── Repositories     # query/read models (search, report queries)

resources/js/
├── Components       # shared (SignaturePad, ToothChart, WizardStep...)
├── Layouts          # AppLayout (sidebar/tablet nav)
├── Pages            # one folder per module
└── Stores            # Pinia (session, chart draft state)
```

### Models
- `protected $guarded = []`; `casts()` for all enums (PHP 8.3 native enum casts).
- Trait `HasActivity` (wraps activitylog) on Patient, Appointment, Treatment, ConsentForm.
- `HasCreatedBy` trait → `created_by` user attribution.
- Scopes: `latestOf()`, `search()` on Patient.

### Services vs Actions vs Repositories
| Type | Used when | Examples |
|---|---|---|
| `Action` | Single write intent, few steps | `RegisterPatient`, `SignConsent`, `RescheduleAppointment` |
| `Service` | Multi-step business logic / state machines | `AppointmentService` (status transitions), `DentalChartService` (latest-state projection), `SignatureStorageService` |
| `Repository` | Complex reads | `ReportRepository` (monthly stats), `PatientRepository` (search) |

### Authorization
- Spatie `roles` + `permissions`; permission names `{module}.{action}` (e.g., `patients.create`).
- `Gate` preCheck via `HasRole` middleware on Inertia routes; per-action checks in Policies.
- Admin gets all permissions; catalogue is the single source of truth (`config/permissions.php`).

## Design Tokens (IMPROVISED — no Figma provided)

> All colors are **OKLCH** per project FE rules. These are placeholder tokens until a Figma design exists; see Open Questions Q10.

### Brand & UI (proposed, dental-teal)
```css
@theme {
  --color-brand-50:  oklch(0.97 0.02 200);
  --color-brand-100: oklch(0.93 0.04 200);
  --color-brand-200: oklch(0.87 0.06 200);
  --color-brand-300: oklch(0.79 0.08 200);
  --color-brand-400: oklch(0.70 0.09 200);
  --color-brand-500: oklch(0.60 0.10 200);   /* primary */
  --color-brand-600: oklch(0.53 0.09 200);
  --color-brand-700: oklch(0.45 0.08 200);
  --color-brand-800: oklch(0.37 0.06 200);
  --color-brand-900: oklch(0.30 0.05 200);
}
```

### Tooth condition color coding (spec §9 — *Color coding*)
Map `ToothCondition` → token. Used by `ToothLegend` component and chart renderer.

| Condition | Token | OKLCH | Visual intent |
|---|---|---|---|
| Caries | `--color-cond-caries` | `oklch(0.64 0.24 25)` | red — active decay |
| Filling | `--color-cond-filling` | `oklch(0.55 0.25 263)` | blue — restoration |
| Missing | `--color-cond-missing` | `oklch(0.45 0.01 280)` | neutral — absent tooth (gray-out) |
| Root canal | `--color-cond-root-canal` | `oklch(0.55 0.25 263)` | blue center dot (drawn inside tooth) |
| Crown | `--color-cond-crown` | `oklch(0.54 0.28 293)` | violet outline |
| Fracture | `--color-cond-fracture` | `oklch(0.65 0.22 41)` | orange zigzag line |
| Impacted | `--color-cond-impacted` | `oklch(0.71 0.16 85)` | amber — un-erupted |
| Pontic | `--color-cond-pontic` | `oklch(0.55 0.16 190)` | teal — bridge tooth |

### Semantic
`--color-status-pending` amber · `--color-status-confirmed` blue · `--color-status-completed` green · `--color-status-cancelled` zinc · `--color-status-no-show` red. (Appointment states, spec §7.)

## Tablet-First UI Rules (spec §13 — improvised from spec intent)

1. Minimum screen size **10″**; browsers Chrome, Safari, Edge.
2. **Wizard-style flow** (§spec tail): Patient → Medical history → Waiver → Signature → Consultation → Dental chart → Treatment record — stepper header with back/next, each step saves independently.
3. Touch targets ≥ **44×44 px**; no hover-dependent actions.
4. Large type (min 16px body); signature canvas at ≥ 300×150 logical px.
5. Responsive grid: tablets portrait-first; desktop gets sidebar layout.
6. Progress persistence: wizard step state stored in Pinia; step entities saved server-side per step so refresh/resume is safe.

## Package Dependencies (composer + npm)

```jsonc
// composer.json (proposed additions)
"spatie/laravel-permission": "^6",
"spatie/laravel-activitylog": "^4",
"inertiajs/inertia-laravel": "^2",
"tightenco/ziggy": "^2"

// package.json (proposed additions)
"@inertiajs/vue3": "^2",
"vue-signature-pad": "^3",      // wraps szimek/signature_pad
"ziggy-js": "^2",
"pinia": "^3"
```
