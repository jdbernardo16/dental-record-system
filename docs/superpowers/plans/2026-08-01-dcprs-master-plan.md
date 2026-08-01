# DCPRS — Master Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build the Dental Clinic Patient Record System (DCPRS) — a tablet-first EMR for a single dental clinic — per the backend blueprint in `docs/dental-emr/`.

**Architecture:** Laravel 12 + Vue 3 + Inertia.js v2 monolith, MySQL 8, Tailwind CSS v4. Single tenant, single clinic. Wizard-style intake (Patient → Medical history → Waiver → Signature → Consultation → Dental chart → Treatment record) with per-step persistence. Append-only dental chart log. SVG e-signatures. RBAC via Spatie with an installable permission catalogue.

**Tech Stack:** Laravel 12 (PHP 8.3) · Vue 3 `<script setup>` · Inertia v2 · Tailwind CSS v4 · MySQL 8 · Spatie Permission + Activitylog · TailAdmin Vue V2 components (ported) · ApexCharts · Flatpickr · Lucide icons · vue-signature-pad · Pest (TDD).

**Reference blueprint (read before executing):** `docs/dental-emr/` — 00-README for index, per-module docs for exact schemas/enums/permissions, 15-migration-order for migration sequence, 14-permissions for the RBAC catalogue, 18-open-questions for decisions with defaults (use defaults unless the client answered otherwise).

---

## Tech Decisions (researched via TinyFish — user delegated)

| Concern | Decision | Alternative considered / why rejected |
|---|---|---|
| Admin UI foundation | **TailAdmin Vue V2** — free/MIT, Vue 3.5 + Tailwind v4 + Vite, 500+ components, ApexCharts bundled. Port components (sidebar, header, tables, form controls, modals, alerts) into the Inertia app; keep our dental-teal tokens | TailAdmin Laravel = Blade+Alpine (wrong stack); Live Admin = Element Plus (heavy, conflicting design system); Filament = not Inertia/Vue |
| Charts | **ApexCharts** via `vue3-apexcharts` (updates blueprint Q13 default of chart.js) | chart.js = weaker admin-dashboard ergonomics; ECharts = heavier |
| Date/time picking | **Flatpickr** (TailAdmin ships it; touch-friendly) | native inputs on iOS Safari are inconsistent |
| Icons | **lucide-vue-next** | consistent with Tailwind ecosystem, tree-shakeable |
| E-signatures | `vue-signature-pad` (wraps szimek/signature_pad), SVG export | per blueprint §14 |
| RBAC / audit | `spatie/laravel-permission`, `spatie/laravel-activitylog` | per blueprint |
| Testing | **Pest** | Laravel 12 default-friendly, readable TDD |
| Calendar UI | Custom tablet **day-list view** (no FullCalendar) | FullCalendar is heavy for a single-clinic day schedule |

**Phasing** (blueprint §16): Phase 1 = auth, patients, appointments (this plan, fully detailed). Phases 2–4 = chart/consultations/treatments, signatures/uploads/reports, backup/archiving — detailed task outlines at the end; each phase gets its own bite-sized plan file when work starts (produced with this same skill).

---

## Phase 1 File Structure (locked in)

```
composer.json / package.json          # deps added per task
config/permissions.php                # 35-permission catalogue (14-permissions.md)
config/settings.php                   # default settings seeds
database/migrations/                  # 01 users, 02 RBAC (spatie), 03 patients, 04 medical_histories, 05 appointments
database/seeders/RolePermissionSeeder.php
database/seeders/SettingsSeeder.php
database/seeders/AdminUserSeeder.php
database/factories/PatientFactory.php
app/Enums/BaseEnum.php                # abstract: labels(), meta(), fromMeta()
app/Enums/Sex.php
app/Enums/CivilStatus.php
app/Enums/AppointmentStatus.php
app/Models/User.php                   # + HasRoles, isAdmin(), isDentist()
app/Models/Patient.php                # + HasActivity, age accessor, fullName(), search scope
app/Models/MedicalHistory.php
app/Models/Appointment.php
app/Actions/RegisterPatientAction.php
app/Repositories/PatientRepository.php
app/Services/AppointmentService.php   # state machine + overlap rule
app/Http/Controllers/UsersController.php
app/Http/Controllers/PatientsController.php
app/Http/Controllers/MedicalHistoriesController.php
app/Http/Controllers/AppointmentsController.php
app/Http/Controllers/DashboardController.php
app/Http/Requests/StorePatientRequest.php
app/Http/Requests/UpdatePatientRequest.php
app/Http/Requests/StoreAppointmentRequest.php
app/Http/Requests/RescheduleAppointmentRequest.php
app/Http/Requests/StoreUserRequest.php
app/Http/Requests/UpdateUserRequest.php
app/Policies/PatientPolicy.php
app/Policies/AppointmentPolicy.php
app/Policies/UserPolicy.php
app/Http/Middleware/EnsureUserIsActive.php
routes/web.php                        # all Inertia routes + permissions
resources/css/app.css                 # Tailwind v4 @theme tokens (dental teal + status colors)
resources/js/app.js / Layouts/AppLayout.vue
resources/js/Components/            # ported TailAdmin: Sidebar, Header, Table, Modal, Badge, Button, Input
resources/js/Pages/Auth/*, Dashboard/Index.vue
resources/js/Pages/Users/Index.vue, Create.vue, Edit.vue
resources/js/Pages/Patients/Index.vue, Create.vue, Show.vue
resources/js/Pages/Appointments/Index.vue
resources/js/Stores/  # pinia: session, toast
tests/Feature/Auth/*, Users/*, Patients/*, Appointments/*, Dashboard/*
tests/Unit/PatientNumberTest.php, AppointmentStateMachineTest.php
```

---

## Phase 1 Tasks

### Task 1: Scaffold Laravel 12 + Breeze (Inertia/Vue) + Pest + deps

**Files:** project-wide (scaffold), plus `composer.json`, `package.json`

- [ ] **Step 1: Scaffold the app**

The working dir already contains `docs/`. Scaffold beside it, then move contents in:

```bash
cd /Users/jdbernardo/Sites
composer create-project laravel/laravel dental-record-system-tmp
mv dental-record-system-tmp/. dental-record-system/ && rmdir dental-record-system-tmp
cd dental-record-system
```

- [ ] **Step 2: Install Breeze (Vue preset) and test tooling**

```bash
composer require laravel/breeze --dev
php artisan breeze:install vue
composer require pestphp/pest --dev
php artisan pest:install
npm install
```

Expected: `resources/js/Pages/Auth/` exists, `tests/Pest.php` exists.

- [ ] **Step 3: Install runtime deps**

```bash
composer require spatie/laravel-permission spatie/laravel-activitylog inertiajs/inertia-laravel tightenco/ziggy
php artisan vendor:publish --provider="Spatie\Permission\PermissionServiceProvider"
php artisan vendor:publish --provider="Spatie\Activitylog\ActivitylogServiceProvider"
npm install pinia ziggy-js lucide-vue-next flatpickr vue3-apexcharts apexcharts vue-signature-pad
```

- [ ] **Step 4: Verify scaffold boots**

Run: `php artisan migrate:fresh --seed && npm run build`
Expected: migrations run clean; build succeeds with zero errors.

- [ ] **Step 5: Commit**

```bash
git init && git add -A && git commit -m "chore: scaffold Laravel 12 + Breeze (Inertia/Vue) + Pest + Spatie deps"
```

---

### Task 2: Design tokens + base layout (TailAdmin Vue port)

**Files:**
- Modify: `resources/css/app.css`
- Create: `resources/js/Layouts/AppLayout.vue`, `resources/js/Components/Sidebar.vue`, `resources/js/Components/Header.vue`, `resources/js/Components/Button.vue`, `resources/js/Components/Badge.vue`, `resources/js/Components/Input.vue`, `resources/js/Stores/toast.js`
- Modify: `resources/js/app.js`

- [ ] **Step 1: Write the token CSS**

Replace `resources/css/app.css`:

```css
@import "tailwindcss";
@import "flatpickr/dist/flatpickr.min.css";

@theme {
  --color-brand-50:  oklch(0.97 0.02 200);
  --color-brand-100: oklch(0.93 0.04 200);
  --color-brand-200: oklch(0.87 0.06 200);
  --color-brand-300: oklch(0.79 0.08 200);
  --color-brand-400: oklch(0.70 0.09 200);
  --color-brand-500: oklch(0.60 0.10 200);
  --color-brand-600: oklch(0.53 0.09 200);
  --color-brand-700: oklch(0.45 0.08 200);
  --color-brand-800: oklch(0.37 0.06 200);
  --color-brand-900: oklch(0.30 0.05 200);

  --color-status-pending:   oklch(0.71 0.16 85);
  --color-status-confirmed: oklch(0.55 0.25 263);
  --color-status-completed: oklch(0.65 0.24 152);
  --color-status-cancelled: oklch(0.45 0.01 280);
  --color-status-no-show:   oklch(0.64 0.24 25);
}
```

- [ ] **Step 2: Pull TailAdmin Vue V2 and copy the base components**

```bash
git clone --depth 1 https://github.com/TailAdmin/vue-tailwind-admin-dashboard.git /tmp/tailadmin
```

Copy and adapt into `resources/js/`: `Sidebar.vue`, `Header.vue`, and the table/form/modal primitives from their `src/components/`. **Adaptation rules:** replace `vue-router` `<RouterLink>` with Inertia `<Link>`; delete demo data; keep classes untouched.

- [ ] **Step 3: Write AppLayout + toast store**

`resources/js/Layouts/AppLayout.vue` (minimal, correct):

```vue
<script setup>
import { ref } from 'vue'
import Sidebar from '../Components/Sidebar.vue'
import Header from '../Components/Header.vue'

const sidebarOpen = ref(false)
</script>

<template>
  <div class="flex h-screen overflow-hidden bg-gray-50">
    <Sidebar :open="sidebarOpen" @close="sidebarOpen = false" />
    <div class="flex flex-1 flex-col overflow-y-auto">
      <Header @toggle="sidebarOpen = !sidebarOpen" />
      <main class="flex-1 p-4 sm:p-6 lg:p-8">
        <slot />
      </main>
    </div>
  </div>
</template>
```

`resources/js/Stores/toast.js`:

```js
import { defineStore } from 'pinia'

export const useToastStore = defineStore('toast', {
  state: () => ({ message: null, type: 'success' }),
  actions: {
    show(message, type = 'success') {
      this.message = message
      this.type = type
      setTimeout(() => (this.message = null), 3500)
    },
  },
})
```

- [ ] **Step 4: Register Pinia + Ziggy in app.js**

Modify `resources/js/app.js`:

```js
import { createPinia } from 'pinia'
import { ZiggyVue } from 'ziggy-js'

createInertiaApp({
  // ...existing...
  setup({ el, App, props, plugin }) {
    return createApp({ render: () => h(App, props) })
      .use(plugin)
      .use(createPinia())
      .use(ZiggyVue)
      .mount(el)
  },
})
```

- [ ] **Step 5: Verify build + page renders**

Run: `npm run build` then `php artisan serve` and open `/login` (or `/register` while scaffolding).
Expected: Breeze auth pages still render; no console errors.

- [ ] **Step 6: Commit**

```bash
git add -A && git commit -m "feat: design tokens + TailAdmin base layout + pinia/ziggy wiring"
```

---

### Task 3: RBAC foundation — permission catalogue + 4 roles

**Files:**
- Create: `config/permissions.php`, `database/seeders/RolePermissionSeeder.php`
- Modify: `database/seeders/DatabaseSeeder.php`

- [ ] **Step 1: Write the failing test**

Create `tests/Feature/RolePermissionSeederTest.php`:

```php
<?php

use App\Models\User;
use Spatie\Permission\Models\Role;

it('seeds the four roles with the full permission catalogue', function () {
    $this->seed(RolePermissionSeeder::class);

    expect(Role::pluck('name')->all())->toContain('Administrator', 'Dentist', 'Assistant', 'Receptionist');
    expect(Role::where('name', 'Administrator')->first()->permissions)->toHaveCount(count(array_merge(...array_values(config('permissions')))));

    $receptionist = User::factory()->create()->assignRole('Receptionist');
    expect($receptionist->can('appointments.create'))->toBeTrue();
    expect($receptionist->can('patients.delete'))->toBeFalse();
});
```

- [ ] **Step 2: Run test to verify it fails**

Run: `./vendor/bin/pest tests/Feature/RolePermissionSeederTest.php`
Expected: FAIL — `RolePermissionSeeder` not found.

- [ ] **Step 3: Write the catalogue + seeder**

`config/permissions.php` — copy verbatim from `docs/dental-emr/14-permissions.md` (the `return [...]` array; 35 names).

`database/seeders/RolePermissionSeeder.php`:

```php
<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Spatie\Permission\Models\Permission;
use Spatie\Permission\Models\Role;

class RolePermissionSeeder extends Seeder
{
    public function run(): void
    {
        foreach (array_merge(...array_values(config('permissions'))) as $name) {
            Permission::firstOrCreate(['name' => $name]);
        }

        $rolePermissions = [
            'Administrator' => Permission::all()->pluck('name'),
            'Dentist' => [
                'patients.view', 'patients.create', 'patients.update',
                'medical-histories.view', 'medical-histories.create', 'medical-histories.update',
                'appointments.view',
                'consultations.view', 'consultations.create', 'consultations.update',
                'dental-chart.view', 'dental-chart.update',
                'treatments.view', 'treatments.create', 'treatments.update', 'treatments.sign',
                'attachments.view', 'attachments.upload',
                'consents.view', 'consents.create', 'consents.sign-patient', 'consents.sign-dentist',
            ],
            'Assistant' => [
                'patients.view', 'patients.update',
                'appointments.view', 'appointments.create', 'appointments.update',
                'appointments.cancel', 'appointments.attendance',
                'dental-chart.view',
                'attachments.view', 'attachments.upload',
                'consents.view', 'consents.create', 'consents.sign-patient',
            ],
            'Receptionist' => [
                'patients.view', 'patients.create',
                'appointments.view', 'appointments.create', 'appointments.update',
                'appointments.cancel', 'appointments.attendance',
            ],
        ];

        foreach ($rolePermissions as $name => $permissions) {
            Role::firstOrCreate(['name' => $name])->syncPermissions($permissions);
        }
    }
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `./vendor/bin/pest tests/Feature/RolePermissionSeederTest.php`
Expected: PASS.

- [ ] **Step 5: Wire into DatabaseSeeder + commit**

```php
// DatabaseSeeder.php run()
$this->call([RolePermissionSeeder::class, SettingsSeeder::class, AdminUserSeeder::class]);
```

```bash
git add -A && git commit -m "feat: RBAC catalogue + role seeder (35 permissions, 4 roles)"
```

---

### Task 4: Settings + default admin user seeds

**Files:**
- Create: `database/seeders/SettingsSeeder.php`, `database/seeders/AdminUserSeeder.php`
- Modify: `database/migrations/2026_01_01_000011_create_settings_table.php` (create this file — content from `docs/dental-emr/11-dashboard-reports-settings.md`)

- [ ] **Step 1: Settings migration + model + seed**

Migration per blueprint (key/value table, unique `key`). Model `App\Models\Setting` + `SettingsService::get(key, default)` reading with 60s cache:

```php
final class SettingsService
{
    public function get(string $key, mixed $default = null): mixed
    {
        return Cache::remember("settings.{$key}", 60, fn () => Setting::where('key', $key)->value('value') ?? $default);
    }
}
```

`SettingsSeeder` seeds: `clinic.name`, `clinic.address`, `consent.version=1.0`, `patient.number.prefix`, `appointment.overlap=false`, `attachment.max_size_mb=25`.

- [ ] **Step 2: Admin user seed**

```php
// AdminUserSeeder
$admin = User::firstOrCreate(
    ['email' => 'admin@clinic.test'],
    ['name' => 'Administrator', 'password' => bcrypt('password')],
);
$admin->assignRole('Administrator');
```

- [ ] **Step 3: Verify + commit**

Run: `php artisan db:seed && php artisan tinker --execute="dump(App\Models\User::where('email','admin@clinic.test')->first()->getRoleNames());"`
Expected: prints `Administrator`. Then `git add -A && git commit -m "feat: settings + admin user seeds"`.

---

### Task 5: Users management (admin-only)

**Files:** per file-structure (UserPolicy, UsersController, StoreUserRequest, UpdateUserRequest, `Pages/Users/Index.vue`, `Create.vue`, `Edit.vue`, middleware `EnsureUserIsActive`)

- [ ] **Step 1: Write the failing feature test**

`tests/Feature/Users/ManageUsersTest.php`:

```php
<?php

use App\Models\User;

it('lets an administrator create a user with a role', function () {
    $admin = User::factory()->create()->assignRole('Administrator');

    $this->actingAs($admin)->post('/users', [
        'name' => 'Dra. Cruz', 'email' => 'cruz@clinic.test', 'password' => 'password', 'role' => 'Dentist',
    ])->assertRedirect('/users');

    $user = User::where('email', 'cruz@clinic.test')->first();
    expect($user)->not->toBeNull();
    expect($user->hasRole('Dentist'))->toBeTrue();
});

it('blocks non-admins from managing users', function () {
    $receptionist = User::factory()->create()->assignRole('Receptionist');

    $this->actingAs($receptionist)->get('/users')->assertForbidden();
    $this->actingAs($receptionist)->post('/users', [
        'name' => 'X', 'email' => 'x@clinic.test', 'password' => 'password', 'role' => 'Dentist',
    ])->assertForbidden();
});

it('locks out deactivated users', function () {
    $user = User::factory()->create(['is_active' => false])->assignRole('Assistant');

    $this->actingAs($user)->get('/dashboard')->assertForbidden();
});
```

- [ ] **Step 2: Run to verify failure** — `./vendor/bin/pest tests/Feature/Users` → FAIL (routes 404).

- [ ] **Step 3: Implement**

Routes (all inside `auth` + `verified` group):

```php
Route::middleware(['auth', 'verified', 'permission:users.view'])->prefix('users')->group(function () {
    Route::get('/', [UsersController::class, 'index'])->name('users.index');
});
Route::middleware(['auth', 'verified', 'permission:users.create'])->post('/users', [UsersController::class, 'store'])->name('users.store');
Route::middleware(['auth', 'verified', 'permission:users.update'])->get('/users/{user}/edit', [UsersController::class, 'edit'])->name('users.edit');
Route::middleware(['auth', 'verified', 'permission:users.update'])->patch('/users/{user}', [UsersController::class, 'update'])->name('users.update');
Route::middleware(['auth', 'verified', 'permission:users.delete'])->delete('/users/{user}', [UsersController::class, 'destroy'])->name('users.destroy');
```

`EnsureUserIsActive` middleware: `if (! $request->user()?->is_active) abort(403);` — registered in `bootstrap/app.php` and applied to the web group.

`StoreUserRequest`: `name|string|required`, `email|required|email|unique:users`, `password|required|min:8`, `role|required|in:Administrator,Dentist,Assistant,Receptionist`.
`UsersController::store`: create + `assignRole($validated['role'])` + `activity()->log('users.created')` + `redirect()->route('users.index')` with toast.
`UserPolicy`: `create/update/delete` → `$user->can('users.*')`; pages gate via `Gate::authorize`.

- [ ] **Step 4: Verify pass** — `./vendor/bin/pest tests/Feature/Users` → PASS.

- [ ] **Step 5: Vue pages (verification-only, manual check)**

`Pages/Users/Index.vue`: TailAdmin table + `Link` to create/edit, role badges, active toggle; `Create.vue`/`Edit.vue`: TailAdmin form layout + Flatpickr-free plain inputs. Verify at `/users` logged in as admin: table renders, create works end-to-end.

- [ ] **Step 6: Commit** — `git add -A && git commit -m "feat: admin user management"`.

---

### Task 6: Patients — enums, migration, model, repository, action

**Files:** `app/Enums/BaseEnum.php`, `Sex.php`, `CivilStatus.php`, migration `create_patients_table` (blueprint `04-patients.md`), `app/Models/Patient.php`, `database/factories/PatientFactory.php`, `app/Repositories/PatientRepository.php`, `app/Actions/RegisterPatientAction.php`

- [ ] **Step 1: Write the failing unit tests**

`tests/Unit/PatientTest.php`:

```php
<?php

use App\Actions\RegisterPatientAction;
use App\Models\Patient;
use App\Models\User;
use App\Repositories\PatientRepository;
use Spatie\Activitylog\Models\Activity;

it('computes age from birth date', function () {
    $patient = Patient::factory()->create(['birth_date' => now()->subYears(25)]);
    expect($patient->age)->toBe(25);
});

it('generates sequential zero-padded numbers per year', function () {
    Patient::factory()->create(['created_at' => now()->startOfYear()]);
    $repo = app(PatientRepository::class);
    expect($repo->nextPatientNumber(now()->year))->toBe(now()->format('Y') . '-0002');
});

it('registers a patient, assigns a number, and logs activity', function () {
    $actor = User::factory()->create();
    $patient = app(RegisterPatientAction::class)->handle([
        'first_name' => 'Juan', 'last_name' => 'Dela Cruz', 'sex' => 'male',
        'birth_date' => '2000-01-01', 'civil_status' => 'single', 'nationality' => 'Filipino',
        'contact_number' => '09171234567', 'address' => 'Manila',
        'emergency_contact_person' => 'Maria', 'emergency_contact_number' => '09179876543',
    ], $actor);

    expect($patient->patient_number)->toMatch('/^\d{4}-\d{4}$/');
    expect(Activity::where('subject_type', Patient::class)->where('subject_id', $patient->id)->count())->toBe(1);
});

it('searches patients by name, number, or contact', function () {
    Patient::factory()->create(['first_name' => 'Ana', 'last_name' => 'Santos', 'contact_number' => '09171234567']);
    expect(app(PatientRepository::class)->search('Santos')->total())->toBe(1);
    expect(app(PatientRepository::class)->search('09171234567')->total())->toBe(1);
});
```

- [ ] **Step 2: Run to verify failure** — `./vendor/bin/pest tests/Unit/PatientTest.php` → FAIL.

- [ ] **Step 3: Implement**

`BaseEnum` (abstract, `implements` contract):

```php
<?php

namespace App\Enums;

abstract class BaseEnum
{
    /** @return array<string, array<string, mixed>> keyed by value */
    abstract public static function meta(): array;

    public static function labels(): array
    {
        return array_map(fn (array $m) => $m['label'], static::meta());
    }

    public static function label(string $value): string
    {
        return static::meta()[$value]['label'] ?? $value;
    }
}
```

`Sex`, `CivilStatus` per blueprint `04-patients.md` (BackedEnums implementing `meta()`).
Migration per blueprint (all 17 fields, `softDeletes`, indexes).
`Patient` model per blueprint (`casts`, `age`, `fullName()`, `search` scope, `HasActivity`).
`PatientFactory`: faker names, `patient_number => '2026-0001'` overwritten per test where needed.
`PatientRepository::search` + `nextPatientNumber` per file-structure section above.
`RegisterPatientAction` per file-structure section above.

- [ ] **Step 4: Verify pass** — `./vendor/bin/pest tests/Unit/PatientTest.php` → PASS.

- [ ] **Step 5: Commit** — `git add -A && git commit -m "feat: patient domain core (model, repo, action)"`.

---

### Task 7: Patients — controllers, policies, Inertia pages

**Files:** `PatientsController`, `StorePatientRequest`, `UpdatePatientRequest`, `PatientPolicy`, routes, `Pages/Patients/Index.vue`, `Create.vue`, `Show.vue`

- [ ] **Step 1: Write the failing feature test**

`tests/Feature/Patients/ManagePatientsTest.php`:

```php
<?php

use App\Models\Patient;
use App\Models\User;

it('renders the patient index with paginated results', function () {
    Patient::factory()->count(25)->create();
    $user = User::factory()->create()->assignRole('Receptionist');

    $this->actingAs($user)->get('/patients?search=')
        ->assertOk()
        ->assertInertia(fn ($page) => $page
            ->component('Patients/Index')
            ->has('patients.data', 20)
            ->has('patients.links'));
});

it('searches patients through the index', function () {
    Patient::factory()->create(['last_name' => 'Bautista']);
    $user = User::factory()->create()->assignRole('Receptionist');

    $this->actingAs($user)->get('/patients?search=Bautista')
        ->assertInertia(fn ($page) => $page->has('patients.data', 1));
});

it('lets receptionists create patients but not delete them', function () {
    $user = User::factory()->create()->assignRole('Receptionist');

    $this->actingAs($user)->post('/patients', [
        'first_name' => 'Liza', 'last_name' => 'Reyes', 'sex' => 'female',
        'birth_date' => '1995-05-05', 'civil_status' => 'married', 'nationality' => 'Filipino',
        'contact_number' => '09171234567', 'address' => 'Quezon City',
        'emergency_contact_person' => 'John', 'emergency_contact_number' => '09179876543',
    ])->assertRedirect();

    $patient = Patient::where('last_name', 'Reyes')->first();
    expect($patient)->not->toBeNull();
    expect($patient->patient_number)->not->toBeNull();

    $this->actingAs($user)->delete("/patients/{$patient->id}")->assertForbidden();
});
```

- [ ] **Step 2: Run to verify failure** → FAIL (no routes).

- [ ] **Step 3: Implement**

Routes (guards from 14-permissions matrix):

```php
Route::middleware(['auth', 'verified', 'permission:patients.view'])->get('/patients', [PatientsController::class, 'index'])->name('patients.index');
Route::middleware(['auth', 'verified', 'permission:patients.view'])->get('/patients/{patient}', [PatientsController::class, 'show'])->name('patients.show');
Route::middleware(['auth', 'verified', 'permission:patients.create'])->get('/patients/create', [PatientsController::class, 'create'])->name('patients.create');
Route::middleware(['auth', 'verified', 'permission:patients.create'])->post('/patients', [PatientsController::class, 'store'])->name('patients.store');
Route::middleware(['auth', 'verified', 'permission:patients.update'])->get('/patients/{patient}/edit', [PatientsController::class, 'edit'])->name('patients.edit');
Route::middleware(['auth', 'verified', 'permission:patients.update'])->patch('/patients/{patient}', [PatientsController::class, 'update'])->name('patients.update');
Route::middleware(['auth', 'verified', 'permission:patients.delete'])->delete('/patients/{patient}', [PatientsController::class, 'destroy'])->name('patients.destroy');
```

`PatientPolicy`: `view/create` → `$user->can('patients.view'/'patients.create')`; `update` → `patients.update`; `delete` → `patients.delete` **and** `$user->hasRole('Administrator')`.
Controller: `index` → `Inertia::render('Patients/Index', ['patients' => PatientRepository::search(request('search'))->withQueryString()])`; `store` → `RegisterPatientAction` → redirect + toast; `update` → `$request->validated()` + activity log; `destroy` → soft delete + activity log.
`StorePatientRequest`/`UpdatePatientRequest`: validate all 17 fields (birth_date `before:today`, contact_number `regex:/^[0-9+ -]{7,20}$/`, email `nullable|email`).

- [ ] **Step 4: Verify pass** — `./vendor/bin/pest tests/Feature/Patients` → PASS.

- [ ] **Step 5: Vue pages (manual verification)**

`Index.vue`: search input (debounced `router.get` with `preserveState`), TailAdmin table with avatar initials, age badge, patient number, row link → Show. `Create.vue`: single-column stacked form (tablet), sections Identity/Contact/Emergency, submit → toast. `Show.vue`: header card + tabs (Appointments, Chart, Treatments, Files, Consents — placeholder "coming in phase 2/3"). Verify: create → list → show → search flows in browser.

- [ ] **Step 6: Commit** — `git add -A && git commit -m "feat: patient CRUD pages + search"`.

---

### Task 8: Medical history (wizard step 2)

**Files:** migration `create_medical_histories_table` (blueprint `04-patients.md`), `MedicalHistory` model, `MedicalHistoriesController`, `StoreMedicalHistoryRequest`

- [ ] **Step 1: Write the failing feature test**

`tests/Feature/Patients/MedicalHistoryTest.php`:

```php
<?php

use App\Models\Patient;
use App\Models\User;

it('saves all ten screening questions for a patient', function () {
    $dentist = User::factory()->create()->assignRole('Dentist');
    $patient = Patient::factory()->create();

    $this->actingAs($dentist)->post("/patients/{$patient->id}/medical-history", [
        'hypertension' => 'yes', 'diabetes' => 'no', 'tuberculosis' => 'no',
        'heart_disease' => 'no', 'pregnancy' => 'not_applicable',
        'allergies' => 'yes', 'allergies_details' => 'Penicillin',
        'medications' => 'no', 'smoking_history' => 'no',
        'alcohol_consumption' => 'no', 'previous_surgeries' => 'no',
        'remarks' => null,
    ])->assertRedirect();

    expect($patient->medicalHistory->allergies_details)->toBe('Penicillin');
});

it('blocks receptionists from editing medical history', function () {
    $user = User::factory()->create()->assignRole('Receptionist');
    $patient = Patient::factory()->create();

    $this->actingAs($user)->post("/patients/{$patient->id}/medical-history", [
        'hypertension' => 'no', 'diabetes' => 'no', 'tuberculosis' => 'no',
        'heart_disease' => 'no', 'pregnancy' => 'no', 'allergies' => 'no',
        'medications' => 'no', 'smoking_history' => 'no',
        'alcohol_consumption' => 'no', 'previous_surgeries' => 'no',
    ])->assertForbidden();
});
```

- [ ] **Step 2: Run to verify failure** → FAIL.

- [ ] **Step 3: Implement**

Migration per blueprint (10 string columns + 5 details text columns, `patient_id` unique FK). Model `MedicalHistory` with `patient()` belongsTo + casts. Controller `updateOrCreate` keyed on `patient_id`, `recorded_by` = actor. Route:

```php
Route::middleware(['auth', 'verified', 'permission:medical-histories.create'])
    ->post('/patients/{patient}/medical-history', [MedicalHistoriesController::class, 'store'])
    ->name('medical-histories.store');
```

`StoreMedicalHistoryRequest`: each question `required|in:no,yes,not_applicable` (pregnancy only), details `nullable|string`.

- [ ] **Step 4: Verify pass + commit** — `./vendor/bin/pest tests/Feature/Patients/MedicalHistoryTest.php` → PASS; commit `feat: medical history module`.

---

### Task 9: Appointments — enum, state machine service, controller

**Files:** `app/Enums/AppointmentStatus.php`, migration `create_appointments_table` (blueprint `05-appointments.md`), `Appointment` model, `AppointmentService`, `InvalidTransitionException`, `StoreAppointmentRequest`, `RescheduleAppointmentRequest`, `AppointmentsController`, routes

- [ ] **Step 1: Write the failing unit test**

`tests/Unit/AppointmentStateMachineTest.php`:

```php
<?php

use App\Enums\AppointmentStatus;
use App\Models\Appointment;
use App\Models\Patient;
use App\Models\User;
use App\Services\AppointmentService;
use App\Services\InvalidTransitionException;

beforeEach(function () {
    $this->patient = Patient::factory()->create();
    $this->dentist = User::factory()->create()->assignRole('Dentist');
    $this->receptionist = User::factory()->create()->assignRole('Receptionist');
});

it('follows the spec transitions', function () {
    $appointment = Appointment::factory()->create(['status' => AppointmentStatus::Pending]);
    $service = app(AppointmentService::class);

    expect($service->confirm($appointment, $this->receptionist)->status)->toBe(AppointmentStatus::Confirmed);
    expect($service->markAttendance($appointment, true, $this->receptionist)->status)->toBe(AppointmentStatus::Completed);
});

it('rejects invalid transitions', function () {
    $appointment = Appointment::factory()->create(['status' => AppointmentStatus::Completed]);

    expect(fn () => app(AppointmentService::class)->cancel($appointment, 'late', $this->receptionist))
        ->toThrow(InvalidTransitionException::class);
});

it('blocks overlapping appointments for the same dentist', function () {
    $service = app(AppointmentService::class);
    $service->create([
        'patient_id' => $this->patient->id, 'dentist_id' => $this->dentist->id,
        'appointment_date' => '2026-08-10', 'start_time' => '09:00', 'end_time' => '09:30',
    ], $this->receptionist);

    expect(fn () => $service->create([
        'patient_id' => $this->patient->id, 'dentist_id' => $this->dentist->id,
        'appointment_date' => '2026-08-10', 'start_time' => '09:15', 'end_time' => '09:45',
    ], $this->receptionist))->toThrow(InvalidTransitionException::class);
});

it('moves rescheduled appointments back to pending', function () {
    $appointment = Appointment::factory()->create(['status' => AppointmentStatus::Confirmed]);
    $service = app(AppointmentService::class);

    expect($service->reschedule($appointment, ['appointment_date' => '2026-08-12', 'start_time' => '10:00', 'end_time' => '10:30'], $this->receptionist)->status)
        ->toBe(AppointmentStatus::Pending);
});
```

- [ ] **Step 2: Run to verify failure** → FAIL.

- [ ] **Step 3: Implement**

`AppointmentStatus` per blueprint (5 cases + `meta()` with status color tokens).
Migration per blueprint. `Appointment` model with casts + `isPending()` etc.
`InvalidTransitionException extends \RuntimeException`.
`AppointmentService` per blueprint (`TRANSITIONS`, `create`, `reschedule`, `confirm`, `cancel`, `markAttendance`, `overlaps`, all with `activity()` logs and transition guard).

```php
// core transition guard
private function transition(Appointment $appointment, string $event, User $actor, array $extra = []): Appointment
{
    $allowed = self::TRANSITIONS[$appointment->status->value] ?? [];
    throw_unless(in_array($event, $allowed, true), InvalidTransitionException::class,
        "Cannot {$event} an appointment with status {$appointment->status->value}.");

    $appointment->update([...$extra, 'status' => $event]);
    activity()->performedOn($appointment)->causedBy($actor)->log("appointment.{$event}");
    return $appointment;
}
```

- [ ] **Step 4: Verify pass** — `./vendor/bin/pest tests/Unit/AppointmentStateMachineTest.php` → PASS.

- [ ] **Step 5: Commit** — `git add -A && git commit -m "feat: appointment state machine + service"`.

---

### Task 10: Appointments — pages + feature tests

**Files:** `Pages/Appointments/Index.vue`, feature test

- [ ] **Step 1: Write the failing feature test**

`tests/Feature/Appointments/ManageAppointmentsTest.php`:

```php
<?php

use App\Models\Appointment;
use App\Models\Patient;
use App\Models\User;

it('renders the day view with today appointments', function () {
    $user = User::factory()->create()->assignRole('Receptionist');
    $patient = Patient::factory()->create();
    Appointment::factory()->create(['patient_id' => $patient->id, 'appointment_date' => now()->toDateString()]);

    $this->actingAs($user)->get('/appointments')
        ->assertOk()
        ->assertInertia(fn ($page) => $page->component('Appointments/Index')->has('appointments', 1));
});

it('creates an appointment through the store route', function () {
    $user = User::factory()->create()->assignRole('Receptionist');
    $patient = Patient::factory()->create();

    $this->actingAs($user)->post('/appointments', [
        'patient_id' => $patient->id, 'appointment_date' => '2026-08-10',
        'start_time' => '09:00', 'end_time' => '09:30', 'reason' => 'Check-up',
    ])->assertRedirect('/appointments');

    expect(Appointment::count())->toBe(1);
});

it('records attendance and marks no-show', function () {
    $user = User::factory()->create()->assignRole('Receptionist');
    $appointment = Appointment::factory()->create(['status' => 'confirmed']);

    $this->actingAs($user)->post("/appointments/{$appointment->id}/attendance", ['present' => false])
        ->assertRedirect();

    expect($appointment->fresh()->status->value)->toBe('no_show');
    expect($appointment->fresh()->attended_at)->not->toBeNull();
});
```

- [ ] **Step 2: Run to verify failure** → FAIL.

- [ ] **Step 3: Implement**

Routes per blueprint (view/create/update/cancel/attendance with permissions). `AppointmentsController::index` → day view data (`appointment_date` query param, default today) + per-status counts for the widget. Store/attendance/cancel delegate to `AppointmentService`. `StoreAppointmentRequest`: patient_id exists, date `after_or_equal:today`, time range, `appointment.overlap` check via `AppointmentService::overlaps`.

- [ ] **Step 4: Verify pass** — `./vendor/bin/pest tests/Feature/Appointments` → PASS.

- [ ] **Step 5: Vue page (manual verification)**

`Index.vue`: date navigator (chevrons ≥44px), timeline list (patient name, time, status badge), tap → detail sheet with state-aware buttons (Confirm/Cancel+reason/Attended/No-show/Reschedule — rendered from `can` props). Verify full lifecycle in browser as Receptionist.

- [ ] **Step 6: Commit** — `git add -A && git commit -m "feat: appointment day view + lifecycle"`.

---

### Task 11: Dashboard widgets

**Files:** `DashboardController`, `Pages/Dashboard/Index.vue`, feature test

- [ ] **Step 1: Write the failing feature test**

`tests/Feature/DashboardTest.php`:

```php
<?php

use App\Models\Appointment;
use App\Models\Patient;
use App\Models\User;

it('renders dashboard widgets for any role', function () {
    $user = User::factory()->create()->assignRole('Receptionist');
    Patient::factory()->count(3)->create();
    Appointment::factory()->count(2)->create(['appointment_date' => now()->toDateString()]);

    $this->actingAs($user)->get('/dashboard')
        ->assertOk()
        ->assertInertia(fn ($page) => $page
            ->component('Dashboard/Index')
            ->has('todayAppointments', 2)
            ->has('recentPatients', 3)
            ->has('monthlyStats'));
});
```

- [ ] **Step 2: Run to verify failure** → FAIL.

- [ ] **Step 3: Implement**

`DashboardController` queries (blueprint `11-dashboard-reports-settings.md` widget table): today's appointments (pending/confirmed), recent patients (10), pending procedures (`treatments where signed_at null` — Phase 2 data; pass `0`-safe query now), monthly stats (counts), follow-ups (next 7 days `is_follow_up`). Add `is_follow_up` boolean to the appointments migration (blueprint Q11 default).

- [ ] **Step 4: Verify pass + commit** — PASS; `git commit -m "feat: dashboard widgets"`.

---

### Task 12: Phase 1 hardening pass

- [ ] **Step 1: Browser smoke test on tablet viewport**

Run: `npm run build && php artisan serve`, then in a 1024×768 (≥10″ tablet) viewport walk: login → dashboard → register patient → search → create appointment → confirm → attend → create user (admin). Verify ≥44px touch targets, no horizontal scroll.

- [ ] **Step 2: Full test suite**

Run: `./vendor/bin/pest`
Expected: all green (auth feature tests from Breeze + our suites).

- [ ] **Step 3: Pint + commit**

```bash
./vendor/bin/pint
git add -A && git commit -m "chore: phase 1 hardening"
```

**Phase 1 DONE** — working, tested: auth (4 roles), patients + medical history, appointments state machine, dashboard, admin user management.

---

## Phase 2 Outline — Dental Chart, Consultations, Treatments

> Produce `docs/superpowers/plans/YYYY-MM-DD-dcprs-phase2.md` using this skill before executing. Task-level plan:
>
> **PDA form alignment (2026-08-01):** The clinic's real PDA dental chart is the authoritative paper source — `docs/reference/pda-dental-chart.md` (restored from Task 10 research). Validate every Phase 2 design against it. Key implications folded in below.

1. **Consultations** — migration/model/service/policy (author-scoped edit), pages. Reference: `docs/dental-emr/06-consultations.md`. PDA alignment: add `PDA_EXTRA_EXAM` fields to the consultations form — periodontal screening (gingivitis/early/moderate/advanced periodontitis), occlusion (class molar, overjet, overbite, midline deviation, crossbite), appliances (orthodontic, stayplate, others), TMD (clenching, clicking, trismus, muscle spasm) — as nullable string columns via the consultations migration (PDA Page 3 sections).
2. **ToothChart SVG component** — twin-arch rendering, 5 surface zones, whole-tooth click, FDI ranges adult 11–48 / primary 51–85 (FDI CONFIRMED by PDA form: 18–11|21–28, 48–41|31–38; primary 55–51|61–65, 85–81|71–75); unit-test geometry helpers.
3. **Dental chart service + endpoint** — `DentalChartService::currentState()/history()` projection (blueprint `07-dental-chart.md`), append-only `dental_chart_entries`, `POST /dental-chart/entries` + `GET /patients/{id}/chart?as_of=`, history-as-of-date UI.
   - **ToothCondition enum MUST be extended to the PDA legend** (updates blueprint 07's 8-condition list — approved deviation): `caries` (D), `missing_caries` (M), `missing_other` (MO), `impacted` (Im), `supernumerary` (Sp), `root_fragment` (Rf), `unerupted` (Un), `present` (✓ — used to mark a healthy tooth explicitly). Extraction is expressed via `missing_caries`/`missing_other` (PDA surgery codes X/XO) — add `extracted` meta flag if needed for the legend.
   - **Restorations/prosthetics extended** (currently collapsed into `filling`): `filling_amalgam` (Am), `filling_composite` (Co), `crown` (JC), `abutment` (Ab), `attachment` (Att), `pontic` (P), `inlay` (In), `implant` (Imp), `sealant` (S), `removable_denture` (Rm). Decide in Phase 2: keep as separate enum cases or a `restoration_type` column alongside `condition` — prefer `condition` stays the PDA condition code and add `restoration_type` (nullable, string + enum) on `dental_chart_entries` so a tooth can hold both (e.g. filling on a root-canal tooth).
   - Extend the OKLCH color map (`02-tech-stack.md` condition tokens) for every new condition; keep `missing_caries`/`missing_other` visually distinct (M vs MO).
   - X-ray types from PDA Page 3 (periapical/panoramic/cephalometric/occlusal) map to Phase 3 attachment categories — wire in Phase 3.
4. **Medical history PDA expansion** (approved deviation — blueprint Q5's fixed-columns decision is replaced for these fields). New migration adds to `medical_histories` (all nullable so existing rows survive): `good_health`, `under_medical_treatment`, `hospitalized` (string no/yes + details reuse existing `surgeries_details`-style pattern → new `medical_treatment_details`, `hospitalization_details`), `nursing`, `birth_control_pills` (string no/yes — pregnancy already exists), `bleeding_time` (string), `blood_type` (string enum A/B/AB/O + Rh), `blood_pressure` (string, free text e.g. "120/80"), `conditions_checklist` (JSON array of the 36 PDA medical-condition keys — store as JSON column, not 36 booleans), `physician_name`, `physician_specialty`, `physician_address`, `physician_phone`, `dental_history_previous_dentist`, `dental_history_last_visit` (date nullable), `referral_source` (string). PDA Q7 "alcohol, cocaine, or dangerous drugs": keep `alcohol_consumption` and add `drug_use` (string no/yes + details). UI: extend the Phase 1 segmented-pill questionnaire with the new groups; condition checklist renders as multi-select chips.
   - **Patients table PDA additions** (new migration, nullable columns): `religion`, `nickname`, `home_phone`, `office_phone`, `fax_number` (keep `contact_number` = mobile), `dental_insurance` (string), `effective_date` (date nullable — defaults to registration date), `guardian_name` + `guardian_occupation` (nullable; PDA "For minors" section — complements consent guardian capture).
5. **Treatments** — migration/model/service (create + `sign()` with SVG storage stub), list/sign UI. Reference: `docs/dental-emr/08-treatments.md`. PDA alignment: Page 4 treatment record confirmed (date/tooth/procedure/dentist). Billing columns (Amount Charged/Paid/Balance) REMAIN OUT OF SCOPE (Q8 default — the PDA form has them but the clinic decision stands; revisit if client asks).
6. **Wizard container** — 7-step stepper (steps 1–2 exist; 3 waiver/signature is Phase 3 — wire the first 2 + consultation + chart + treatment steps), per-step persistence + Pinia progress (blueprint `17-process-flows.md` Flow 1).

## Phase 3 Outline — Signatures, Uploads, Reports

1. **SignatureStorageService** — SVG sanitization (libxml parse, strip scripts), storage to `storage/app/signatures/`, unit tests.
2. **Consents** — migration/model/`ConsentService` (draft → patient sign → dentist sign, minor-guardian rule, IP/UA capture), waiver screen with `vue-signature-pad` (blueprint `10-consents.md`).
   - **PDA per-section initials (OPEN DECISION, default = match the PDA form):** the PDA Page 2 consent has 10 sections each requiring a patient initial (treatment, drugs/medications, changes in treatment plan, radiographs, removal of teeth, crowns/caps/bridges, endodontics, periodontal disease, fillings, dentures) + acknowledgment + authorization. Default: add `consent_sections` table (`consent_form_id`, `key` (snake of section name), `label`, `initial_svg_path` nullable, `initialed_at` nullable) — the tablet shows each section's text with a small signature/initial pad. Fallback (if clinic prefers the idea.md unified text): keep single text snapshot as built. ASK THE CLINIC which consent template is authoritative (PDA form vs idea.md §12).
3. **Treatment signing** — wire `treatments.sign` + signature pad overlay.
4. **Attachments** — migration/model/`AttachmentService` (multipart with `onUploadProgress`), category chips, X-ray viewer (blueprint `09-attachments.md`). PDA alignment: extend `AttachmentCategory` with the PDA X-ray types — `xray_periapical`, `xray_panoramic`, `xray_cephalometric`, `xray_occlusal` (or keep `xray` + add `xray_type` column; prefer the column so existing 'xray' category stays).
5. **Reports** — `ReportRepository` (5 queries), ApexCharts pages + CSV/print export (blueprint `11-…md`, Q12/Q13 resolved: ApexCharts).

## Phase 4 Outline — Backup & Archiving

1. **spatie/laravel-backup** — DB + `local` disk → S3, retention schedule (30d/12m/3y), restore runbook.
2. **Archival job** — inactivity-based archive (default 5y), full-record export → archive bucket, then hard delete; audit log entries.

---

## Self-Review

- **Spec coverage:** Every blueprint Phase 1 module maps to a task — auth (3,4,5), patients (6,7), medical history (8), appointments (9,10), dashboard (11), RBAC catalogue (3), design tokens (2). Phases 2–4 are outlined with their blueprint references; each gets a detailed plan before execution.
- **Placeholders:** none in Phase 1 tasks — all migrations/models/tests contain concrete code; phases 2–4 are intentionally task-level (separate plans), not "TBD" filler.
- **Type consistency:** `RegisterPatientAction::handle(array, User): Patient`, `PatientRepository::nextPatientNumber(int): string`, `AppointmentService` transitions, `Activity::forSubject` naming — consistent across tasks 6–10 and matching blueprint docs. `AppointmentStatus` enum cases match migration `default('pending')`.
- **Decision flag:** Phase 1 contains no ambiguous UI decisions — TailAdmin components, tokens, and page structures are specified; remaining client questions live in blueprint 18-open-questions and must be answered before the phases that depend on them (Q1 numbering → Phase 2 chart — RESOLVED: FDI confirmed by PDA form; Q9 sizes → Phase 3 uploads).
- **PDA alignment (2026-08-01):** clinic's real PDA chart restored as `docs/reference/pda-dental-chart.md`; Phase 2/3 outlines now carry the PDA-aligned schema changes (condition/restoration taxonomy, medical-history expansion, patients PDA fields, consultation exam fields, consent per-section initials decision). Billing (PDA Page 4 Amount Charged/Paid/Balance) intentionally remains out of scope per Q8.
