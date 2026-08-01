# DCPRS Phase 2 — Consultations, Dental Chart, Treatments, Wizard Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build Phase 2 of DCPRS: consultations (with PDA Page 3 exam fields), the twin-arch dental chart (append-only log, PDA legend, SVG ToothChart component), treatments (with dentist e-signature stub), the PDA medical-history/patient field expansions, and the 7-step intake wizard container.

**Architecture:** Extends the Laravel 12 + Vue 3 + Inertia monolith from Phase 1. All clinical data is append-only (chart entries immutable). Backend: enums + migrations + services/actions + policies per blueprint. Frontend: SVG ToothChart component with 5-surface zones, legend palette, history-as-of drawer; wizard stepper with per-step persistence (Pinia progress store). Steps 3 (Waiver) + 4 (Signature) of the wizard render as locked placeholders — they unlock in Phase 3.

**Tech Stack:** Laravel 12 · Vue 3 `<script setup>` · Inertia v2 client (@inertiajs/vue3 v2) · Tailwind CSS v4 (OKLCH tokens only — no hex, no arbitrary values) · Spatie Permission + Activitylog · Pest (TDD) · vue-signature-pad (treatments sign overlay).

**PDA alignment source of truth:** `docs/reference/pda-dental-chart.md`. FDI numbering confirmed: permanent 18–11 | 21–28 and 48–41 | 31–38; primary 55–51 | 61–65 and 85–81 | 71–75. Condition codes: ✓ D M MO Im Sp Rf Un. Restoration codes: Am Co JC Ab Att P In Imp S Rm. Billing columns remain OUT OF SCOPE (Q8).

**Reference blueprint (read before executing):** `docs/dental-emr/06-consultations.md`, `07-dental-chart.md`, `08-treatments.md`, `04-patients.md`, `14-permissions.md`, `15-migration-order.md`, `17-process-flows.md`, `02-tech-stack.md` (tokens), `18-open-questions.md`.

---

## Phase 2 File Structure

```
app/Enums/DentitionType.php              # adult/primary + teeth ranges (FDI)
app/Enums/ToothCondition.php             # PDA legend: present, caries, missing_caries, missing_other, impacted, supernumerary, root_fragment, unerupted
app/Enums/ToothSurface.php               # occlusal/buccal/lingual/mesial/distal
app/Enums/RestorationType.php            # PDA: filling_amalgam, filling_composite, crown, abutment, attachment, pontic, inlay, implant, sealant, removable_denture
app/Models/Consultation.php
app/Models/DentalChartEntry.php
app/Models/Treatment.php
app/Services/DentalChartService.php      # currentState / stateAsOf / history projection
app/Services/ConsultationService.php
app/Services/TreatmentService.php
app/Services/SignatureStorageService.php # minimal store() in 2.5; hardened in Phase 3.1
app/Actions/RecordToothConditionAction.php
app/Http/Controllers/ConsultationsController.php
app/Http/Controllers/DentalChartController.php
app/Http/Controllers/TreatmentsController.php
app/Http/Controllers/WizardController.php
app/Http/Requests/StoreConsultationRequest.php
app/Http/Requests/StoreDentalChartEntryRequest.php
app/Http/Requests/StoreTreatmentRequest.php
app/Policies/ConsultationPolicy.php
app/Policies/TreatmentPolicy.php
app/Policies/DentalChartEntryPolicy.php
database/migrations/2026_08_01_000002_create_consultations_table.php
database/migrations/2026_08_01_000003_create_dental_chart_entries_table.php
database/migrations/2026_08_01_000004_extend_medical_histories_for_pda.php
database/migrations/2026_08_01_000005_extend_patients_for_pda.php
database/migrations/2026_08_01_000006_create_treatments_table.php
resources/css/app.css                    # + cond-* and rest-* tokens
resources/js/Components/ToothChart.vue
resources/js/Components/SignaturePadModal.vue
resources/js/Pages/Patients/Chart.vue
resources/js/Pages/Patients/Show.vue     # wire Chart/Treatments/Appointments tabs + consultations section
resources/js/Pages/Wizard/Index.vue
resources/js/Stores/wizard.js            # pinia: step progress
resources/js/Components/Wizard/ConsultationForm.vue
resources/js/Components/Wizard/TreatmentForm.vue
tests/Feature/Consultations/ManageConsultationsTest.php
tests/Feature/Chart/ManageDentalChartTest.php
tests/Unit/DentalChartServiceTest.php
tests/Feature/Treatments/ManageTreatmentsTest.php
tests/Feature/Patients/PdaFieldsTest.php
tests/Feature/WizardTest.php
```

---

## Task 1: Consultations module

**Files:**
- Create: `database/migrations/2026_08_01_000002_create_consultations_table.php`
- Create: `app/Models/Consultation.php`
- Create: `app/Services/ConsultationService.php`
- Create: `app/Policies/ConsultationPolicy.php`
- Create: `app/Http/Requests/StoreConsultationRequest.php`
- Create: `app/Http/Controllers/ConsultationsController.php`
- Create: `resources/js/Components/Wizard/ConsultationForm.vue`
- Modify: `routes/web.php`, `app/Models/Patient.php`, `resources/js/Pages/Patients/Show.vue`
- Test: `tests/Feature/Consultations/ManageConsultationsTest.php`

- [ ] **Step 1: Write the failing feature test**

`tests/Feature/Consultations/ManageConsultationsTest.php`:

```php
<?php

use App\Models\Consultation;
use App\Models\Patient;
use App\Models\User;

uses(RefreshDatabase::class);

beforeEach(function () {
    $this->seed(\Database\Seeders\RolePermissionSeeder::class);
});

it('lets a dentist create a consultation with PDA exam fields', function () {
    $dentist = User::factory()->create()->assignRole('Dentist');
    $patient = Patient::factory()->create();

    $this->actingAs($dentist)->post("/patients/{$patient->id}/consultations", [
        'consultation_date' => now()->toDateString(),
        'chief_complaint' => 'Toothache on upper right',
        'examination_findings' => 'Caries on 16',
        'diagnosis' => 'Dental caries',
        'treatment_plan' => 'Composite restoration',
        'recommendations' => 'Return in 2 weeks',
        'notes' => null,
        'periodontal_screening' => 'gingivitis',
        'occlusion_class' => 'class_i',
        'overjet' => '2mm',
        'overbite' => '1mm',
        'midline_deviation' => 'none',
        'crossbite' => null,
        'appliances' => ['orthodontic'],
        'tmd_findings' => ['clicking'],
    ])->assertRedirect();

    $consultation = Consultation::where('patient_id', $patient->id)->first();
    expect($consultation)->not->toBeNull();
    expect($consultation->dentist_id)->toBe($dentist->id);
    expect($consultation->periodontal_screening)->toBe('gingivitis');
    expect($consultation->appliances)->toBe(['orthodontic']);
    expect($consultation->tmd_findings)->toBe(['clicking']);
});

it('requires chief complaint and validates exam fields', function () {
    $dentist = User::factory()->create()->assignRole('Dentist');
    $patient = Patient::factory()->create();

    $this->actingAs($dentist)
        ->post("/patients/{$patient->id}/consultations", ['consultation_date' => now()->toDateString()])
        ->assertSessionHasErrors(['chief_complaint']);

    $this->actingAs($dentist)->post("/patients/{$patient->id}/consultations", [
        'consultation_date' => now()->toDateString(),
        'chief_complaint' => 'X',
        'periodontal_screening' => 'not-a-real-value',
    ])->assertSessionHasErrors(['periodontal_screening']);
});

it('blocks receptionists from creating consultations', function () {
    $user = User::factory()->create()->assignRole('Receptionist');
    $patient = Patient::factory()->create();

    $this->actingAs($user)->post("/patients/{$patient->id}/consultations", [
        'consultation_date' => now()->toDateString(),
        'chief_complaint' => 'X',
    ])->assertForbidden();
});

it('allows only the authoring dentist or admin to edit a consultation', function () {
    $dentist = User::factory()->create()->assignRole('Dentist');
    $otherDentist = User::factory()->create()->assignRole('Dentist');
    $admin = User::factory()->create()->assignRole('Administrator');
    $consultation = Consultation::factory()->create(['dentist_id' => $dentist->id]);

    $this->actingAs($otherDentist)->patch("/consultations/{$consultation->id}", [
        'chief_complaint' => 'Changed',
    ])->assertForbidden();

    $this->actingAs($dentist)->patch("/consultations/{$consultation->id}", [
        'chief_complaint' => 'Changed by author',
    ])->assertRedirect();

    expect($consultation->fresh()->chief_complaint)->toBe('Changed by author');

    $this->actingAs($admin)->patch("/consultations/{$consultation->id}", [
        'chief_complaint' => 'Changed by admin',
    ])->assertRedirect();
});
```

- [ ] **Step 2: Run to verify failure**

Run: `./vendor/bin/pest tests/Feature/Consultations`
Expected: FAIL — routes 404 / `Consultation` not found.

- [ ] **Step 3: Migration (blueprint 06 + PDA Page 3 exam fields)**

`database/migrations/2026_08_01_000002_create_consultations_table.php`:

```php
<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('consultations', function (Blueprint $table) {
            $table->id();
            $table->foreignId('patient_id')->constrained()->cascadeOnDelete();
            $table->foreignId('dentist_id')->constrained('users')->cascadeOnDelete();
            $table->date('consultation_date');
            $table->text('chief_complaint');
            $table->text('examination_findings')->nullable();
            $table->text('diagnosis')->nullable();
            $table->text('treatment_plan')->nullable();
            $table->text('recommendations')->nullable();
            $table->text('notes')->nullable();
            // PDA Page 3 — Intraoral Examination (all nullable, string single-select or free text)
            $table->string('periodontal_screening')->nullable();   // gingivitis|early_periodontitis|moderate_periodontitis|advanced_periodontitis
            $table->string('occlusion_class')->nullable();         // class_i|class_ii|class_iii
            $table->string('overjet')->nullable();                 // free text e.g. "2mm"
            $table->string('overbite')->nullable();                // free text
            $table->string('midline_deviation')->nullable();       // free text
            $table->string('crossbite')->nullable();               // free text
            $table->json('appliances')->nullable();                // array of orthodontic|stayplate|others
            $table->json('tmd_findings')->nullable();              // array of clenching|clicking|trismus|muscle_spasm
            $table->timestamps();

            $table->index(['patient_id', 'consultation_date']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('consultations');
    }
};
```

- [ ] **Step 4: Factory**

`database/factories/ConsultationFactory.php`:

```php
<?php

namespace Database\Factories;

use App\Models\Consultation;
use App\Models\Patient;
use App\Models\User;
use Illuminate\Database\Eloquent\Factories\Factory;

/**
 * @extends Factory<Consultation>
 */
class ConsultationFactory extends Factory
{
    public function definition(): array
    {
        return [
            'patient_id' => Patient::factory(),
            'dentist_id' => User::factory(),
            'consultation_date' => fake()->dateTimeBetween('-1 year', 'now')->format('Y-m-d'),
            'chief_complaint' => fake()->sentence(5),
            'examination_findings' => fake()->optional()->sentence(8),
            'diagnosis' => fake()->optional()->sentence(4),
            'treatment_plan' => fake()->optional()->sentence(8),
            'recommendations' => fake()->optional()->sentence(6),
            'notes' => fake()->optional()->sentence(),
        ];
    }
}
```

- [ ] **Step 5: Model + enum meta constants**

`app/Models/Consultation.php`:

```php
<?php

namespace App\Models;

use Database\Factories\ConsultationFactory;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Spatie\Activitylog\Traits\LogsActivity;

class Consultation extends Model
{
    /** @use HasFactory<ConsultationFactory> */
    use HasFactory, LogsActivity;

    protected $guarded = [];

    protected static $logOnlyDirty = true;

    protected static $logName = 'consultations';

    /**
     * Get the attributes that should be cast.
     *
     * @return array<string, string>
     */
    protected function casts(): array
    {
        return [
            'consultation_date' => 'date:Y-m-d',
            'appliances' => 'array',
            'tmd_findings' => 'array',
        ];
    }

    public function patient(): BelongsTo
    {
        return $this->belongsTo(Patient::class);
    }

    public function dentist(): BelongsTo
    {
        return $this->belongsTo(User::class, 'dentist_id');
    }

    public function treatments(): HasMany
    {
        return $this->hasMany(Treatment::class);
    }

    /** PDA exam option lists (single source for forms + validation) */
    public static function periodontalOptions(): array
    {
        return [
            'gingivitis' => 'Gingivitis',
            'early_periodontitis' => 'Early periodontitis',
            'moderate_periodontitis' => 'Moderate periodontitis',
            'advanced_periodontitis' => 'Advanced periodontitis',
        ];
    }

    public static function occlusionOptions(): array
    {
        return ['class_i' => 'Class I', 'class_ii' => 'Class II', 'class_iii' => 'Class III'];
    }

    public static function applianceOptions(): array
    {
        return ['orthodontic' => 'Orthodontic', 'stayplate' => 'Stayplate', 'others' => 'Others'];
    }

    public static function tmdOptions(): array
    {
        return ['clenching' => 'Clenching', 'clicking' => 'Clicking', 'trismus' => 'Trismus', 'muscle_spasm' => 'Muscle spasm'];
    }
}
```

- [ ] **Step 6: Service**

`app/Services/ConsultationService.php`:

```php
<?php

namespace App\Services;

use App\Models\Consultation;
use App\Models\User;
use Illuminate\Support\Facades\DB;

final class ConsultationService
{
    public function create(array $data, User $dentist): Consultation
    {
        return DB::transaction(function () use ($data, $dentist) {
            $consultation = Consultation::create([...$data, 'dentist_id' => $dentist->id]);
            activity()->performedOn($consultation)->causedBy($dentist)->log('consultation.created');

            return $consultation;
        });
    }

    public function update(Consultation $consultation, array $data, User $actor): Consultation
    {
        $consultation->update($data);
        activity()->performedOn($consultation)->causedBy($actor)->log('consultation.updated');

        return $consultation;
    }
}
```

- [ ] **Step 7: Policy**

`app/Policies/ConsultationPolicy.php`:

```php
<?php

namespace App\Policies;

use App\Models\Consultation;
use App\Models\User;

class ConsultationPolicy
{
    public function viewAny(User $user): bool
    {
        return $user->can('consultations.view');
    }

    public function view(User $user, Consultation $consultation): bool
    {
        return $user->can('consultations.view');
    }

    public function create(User $user): bool
    {
        return $user->can('consultations.create');
    }

    /** Only the authoring dentist (or Administrator) may edit (blueprint 06). */
    public function update(User $user, Consultation $consultation): bool
    {
        return $user->can('consultations.update')
            && ($user->hasRole('Administrator') || $consultation->dentist_id === $user->id);
    }
}
```

- [ ] **Step 8: Request**

`app/Http/Requests/StoreConsultationRequest.php`:

```php
<?php

namespace App\Http\Requests;

use App\Models\Consultation;
use Illuminate\Foundation\Http\FormRequest;

class StoreConsultationRequest extends FormRequest
{
    /**
     * @return array<string, array<int, mixed>>
     */
    public function rules(): array
    {
        $periodontal = array_keys(Consultation::periodontalOptions());
        $occlusion = array_keys(Consultation::occlusionOptions());
        $appliances = array_keys(Consultation::applianceOptions());
        $tmd = array_keys(Consultation::tmdOptions());

        return [
            'consultation_date' => ['required', 'date'],
            'chief_complaint' => ['required', 'string', 'max:2000'],
            'examination_findings' => ['nullable', 'string', 'max:4000'],
            'diagnosis' => ['nullable', 'string', 'max:2000'],
            'treatment_plan' => ['nullable', 'string', 'max:4000'],
            'recommendations' => ['nullable', 'string', 'max:2000'],
            'notes' => ['nullable', 'string', 'max:2000'],
            'periodontal_screening' => ['nullable', 'string', 'in:' . implode(',', $periodontal)],
            'occlusion_class' => ['nullable', 'string', 'in:' . implode(',', $occlusion)],
            'overjet' => ['nullable', 'string', 'max:100'],
            'overbite' => ['nullable', 'string', 'max:100'],
            'midline_deviation' => ['nullable', 'string', 'max:100'],
            'crossbite' => ['nullable', 'string', 'max:100'],
            'appliances' => ['nullable', 'array'],
            'appliances.*' => ['string', 'in:' . implode(',', $appliances)],
            'tmd_findings' => ['nullable', 'array'],
            'tmd_findings.*' => ['string', 'in:' . implode(',', $tmd)],
        ];
    }
}
```

- [ ] **Step 9: Controller**

`app/Http/Controllers/ConsultationsController.php`:

```php
<?php

namespace App\Http\Controllers;

use App\Http\Requests\StoreConsultationRequest;
use App\Models\Consultation;
use App\Models\Patient;
use App\Services\ConsultationService;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Redirect;

class ConsultationsController extends Controller
{
    public function __construct(private readonly ConsultationService $service) {}

    public function store(StoreConsultationRequest $request, Patient $patient): RedirectResponse
    {
        $this->authorize('create', Consultation::class);

        $this->service->create([...$request->validated(), 'patient_id' => $patient->id], $request->user());

        return Redirect::back();
    }

    public function update(StoreConsultationRequest $request, Consultation $consultation): RedirectResponse
    {
        $this->authorize('update', $consultation);

        $this->service->update($consultation, $request->validated(), $request->user());

        return Redirect::back();
    }
}
```

- [ ] **Step 10: Routes**

In `routes/web.php`, add:

```php
use App\Http\Controllers\ConsultationsController;

Route::middleware(['auth', 'verified', 'permission:consultations.create'])
    ->post('/patients/{patient}/consultations', [ConsultationsController::class, 'store'])
    ->name('consultations.store');
Route::middleware(['auth', 'verified', 'permission:consultations.update'])
    ->patch('/consultations/{consultation}', [ConsultationsController::class, 'update'])
    ->name('consultations.update');
```

- [ ] **Step 11: Wire patient show page**

Modify `app/Models/Patient.php` — add relation:

```php
public function consultations(): HasMany
{
    return $this->hasMany(Consultation::class);
}
```

Modify `PatientsController::show` to load `consultations` (newest first, with dentist) + `can` flags, and pass `consultationOptions` (periodontal/occlusion/appliance/tmd lists from `Consultation` model). Then in `resources/js/Pages/Patients/Show.vue`, add a **Consultations** card between the Medical history card and the tabs block:

- Header: "Consultations" + count + "Add consultation" button (visible when `can.consultations?.create`).
- List: newest-first rows — date chip, chief complaint, dentist name, diagnosis badge; tap row to expand (show findings/plan/recommendations + PDA exam fields as labeled rows: Periodontal screening, Occlusion class, Overjet, Overbite, Midline deviation, Crossbite, Appliances, TMD).
- Create form (inline, same pattern as medical history editor): fields chief_complaint (required textarea), consultation_date (date input, default today), examination_findings, diagnosis, treatment_plan, recommendations, notes textareas; PDA section "Intraoral examination": periodontal screening select (4 options), occlusion class select (3), overjet/overbite/midline_deviation/crossbite text inputs, appliances checkboxes (3), TMD checkboxes (4). Submit via `useForm().post(route('consultations.store', patient.id))` with `preserveScroll: true` + toast. On success close editor.
- Reuse the same form component in the wizard (Task 6) — build `resources/js/Components/Wizard/ConsultationForm.vue` (props: `patientId`, `options`, `editing` mode off; emits nothing; self-contained useForm) and use it inline in Show.vue too.

Follow the Show.vue medical-history editor pattern exactly (segmented pills / textareas / error text in `text-status-cancelled`). All classes from the existing file — no hex, no arbitrary values.

- [ ] **Step 12: Verify pass**

Run: `./vendor/bin/pest tests/Feature/Consultations`
Expected: PASS.

- [ ] **Step 13: Pint + commit**

```bash
./vendor/bin/pint && ./vendor/bin/pest
git add -A && git commit -m "feat: consultations module with PDA exam fields"
```

---

## Task 2: Dental chart backend — enums, migration, model, service, action, endpoints

**Files:**
- Create: `app/Enums/DentitionType.php`, `app/Enums/ToothCondition.php`, `app/Enums/ToothSurface.php`, `app/Enums/RestorationType.php`
- Create: `database/migrations/2026_08_01_000003_create_dental_chart_entries_table.php`
- Create: `app/Models/DentalChartEntry.php`
- Create: `app/Services/DentalChartService.php`
- Create: `app/Actions/RecordToothConditionAction.php`
- Create: `app/Policies/DentalChartEntryPolicy.php`
- Create: `app/Http/Requests/StoreDentalChartEntryRequest.php`
- Create: `app/Http/Controllers/DentalChartController.php`
- Modify: `resources/css/app.css`, `routes/web.php`
- Test: `tests/Unit/DentalChartServiceTest.php`, `tests/Feature/Chart/ManageDentalChartTest.php`

- [ ] **Step 1: Write the failing unit test**

`tests/Unit/DentalChartServiceTest.php`:

```php
<?php

use App\Enums\DentitionType;
use App\Models\DentalChartEntry;
use App\Models\Patient;
use App\Models\User;
use App\Services\DentalChartService;

uses(RefreshDatabase::class);

it('projects the latest entry per tooth and surface', function () {
    $patient = Patient::factory()->create();
    DentalChartEntry::create([
        'patient_id' => $patient->id, 'tooth_number' => 16, 'dentition' => 'adult',
        'condition' => 'caries', 'surface' => 'occlusal', 'recorded_at' => now()->toDateString(),
        'recorded_by' => User::factory()->create()->id,
    ]);
    DentalChartEntry::create([
        'patient_id' => $patient->id, 'tooth_number' => 16, 'dentition' => 'adult',
        'condition' => 'caries', 'surface' => null, 'restoration_type' => 'filling_composite',
        'recorded_at' => now()->toDateString(), 'recorded_by' => User::factory()->create()->id,
    ]);

    $state = app(DentalChartService::class)->currentState($patient->id, 'adult');

    expect($state[16]['whole']['condition'])->toBe('caries');
    expect($state[16]['whole']['restoration'])->toBe('filling_composite');
    expect($state[16]['surfaces']['occlusal']['condition'])->toBe('caries');
    expect($state[16]['surfaces']['occlusal']['restoration'])->toBeNull();
});

it('supersedes by recency (latest recorded_at wins)', function () {
    $patient = Patient::factory()->create();
    $actor = User::factory()->create();
    DentalChartEntry::create([
        'patient_id' => $patient->id, 'tooth_number' => 11, 'dentition' => 'adult',
        'condition' => 'caries', 'surface' => null, 'recorded_at' => '2026-07-01', 'recorded_by' => $actor->id,
    ]);
    DentalChartEntry::create([
        'patient_id' => $patient->id, 'tooth_number' => 11, 'dentition' => 'adult',
        'condition' => 'missing_caries', 'surface' => null, 'recorded_at' => '2026-07-15', 'recorded_by' => $actor->id,
    ]);

    $state = app(DentalChartService::class)->currentState($patient->id, 'adult');

    expect($state[11]['whole']['condition'])->toBe('missing_caries');
});

it('returns state as of a past date and a full history log', function () {
    $patient = Patient::factory()->create();
    $actor = User::factory()->create();
    DentalChartEntry::create([
        'patient_id' => $patient->id, 'tooth_number' => 21, 'dentition' => 'adult',
        'condition' => 'caries', 'surface' => null, 'recorded_at' => '2026-07-01', 'recorded_by' => $actor->id,
    ]);
    DentalChartEntry::create([
        'patient_id' => $patient->id, 'tooth_number' => 21, 'dentition' => 'adult',
        'condition' => 'missing_caries', 'surface' => null, 'recorded_at' => '2026-07-15', 'recorded_by' => $actor->id,
    ]);

    $service = app(DentalChartService::class);
    $asOf = $service->stateAsOf($patient->id, 'adult', Carbon::parse('2026-07-10'));

    expect($asOf[21]['whole']['condition'])->toBe('caries');

    $history = $service->history($patient->id);
    expect($history)->toHaveCount(2);
    expect($history->first()->tooth_number)->toBe(21);
});

it('validates FDI tooth ranges per dentition', function () {
    expect(DentitionType::isValidTooth(16, 'adult'))->toBeTrue();
    expect(DentitionType::isValidTooth(51, 'adult'))->toBeFalse();
    expect(DentitionType::isValidTooth(55, 'primary'))->toBeTrue();
    expect(DentitionType::isValidTooth(11, 'primary'))->toBeFalse();
    expect(DentitionType::isValidTooth(65, 'primary'))->toBeTrue();
});
```

- [ ] **Step 2: Run to verify failure**

Run: `./vendor/bin/pest tests/Unit/DentalChartServiceTest.php`
Expected: FAIL — classes not found.

- [ ] **Step 3: Enums**

`app/Enums/DentitionType.php`:

```php
<?php

namespace App\Enums;

enum DentitionType: string
{
    use HasMeta;

    case Adult = 'adult';
    case Primary = 'primary';

    /** Quadrant ranges [first, last] per arch row, mirroring the PDA chart. */
    private const RANGES = [
        'adult' => [[11, 18], [21, 28], [41, 48], [31, 38]],
        'primary' => [[51, 55], [61, 65], [81, 85], [71, 75]],
    ];

    public static function meta(): array
    {
        return [
            'adult' => ['label' => 'Adult', 'teeth' => array_merge(...array_map(fn ($r) => range($r[0], $r[1]), self::RANGES['adult']))],
            'primary' => ['label' => 'Primary', 'teeth' => array_merge(...array_map(fn ($r) => range($r[0], $r[1]), self::RANGES['primary']))],
        ];
    }

    /** @return array<int, array{0: int, 1: int}> */
    public static function ranges(string $dentition): array
    {
        return self::RANGES[$dentition] ?? [];
    }

    public static function isValidTooth(int $tooth, string $dentition): bool
    {
        foreach (self::RANGES[$dentition] ?? [] as [$first, $last]) {
            if ($tooth >= $first && $tooth <= $last) {
                return true;
            }
        }

        return false;
    }

    public static function teeth(string $dentition): array
    {
        return self::meta()[$dentition]['teeth'];
    }
}
```

`app/Enums/ToothCondition.php` (PDA legend — 8 codes):

```php
<?php

namespace App\Enums;

enum ToothCondition: string
{
    use HasMeta;

    case Present = 'present';               // ✓ healthy tooth marked explicitly
    case Caries = 'caries';                 // D decayed
    case MissingCaries = 'missing_caries';  // M missing due to caries
    case MissingOther = 'missing_other';    // MO missing due to other causes
    case Impacted = 'impacted';             // Im
    case Supernumerary = 'supernumerary';   // Sp
    case RootFragment = 'root_fragment';    // Rf
    case Unerupted = 'unerupted';           // Un

    /** Whole-tooth only conditions (surfaces must be null). */
    public static function wholeToothOnly(): array
    {
        return [self::MissingCaries->value, self::MissingOther->value, self::Impacted->value, self::Supernumerary->value, self::Unerupted->value];
    }

    public static function meta(): array
    {
        return [
            'present' => ['label' => 'Present (✓)', 'code' => '✓', 'color' => 'cond-present', 'render' => 'check'],
            'caries' => ['label' => 'Decayed (D)', 'code' => 'D', 'color' => 'cond-caries', 'render' => 'solid'],
            'missing_caries' => ['label' => 'Missing — caries (M)', 'code' => 'M', 'color' => 'cond-missing-caries', 'render' => 'missing'],
            'missing_other' => ['label' => 'Missing — other (MO)', 'code' => 'MO', 'color' => 'cond-missing-other', 'render' => 'missing'],
            'impacted' => ['label' => 'Impacted (Im)', 'code' => 'Im', 'color' => 'cond-impacted', 'render' => 'dashed'],
            'supernumerary' => ['label' => 'Supernumerary (Sp)', 'code' => 'Sp', 'color' => 'cond-supernumerary', 'render' => 'solid'],
            'root_fragment' => ['label' => 'Root fragment (Rf)', 'code' => 'Rf', 'color' => 'cond-root-fragment', 'render' => 'solid'],
            'unerupted' => ['label' => 'Unerupted (Un)', 'code' => 'Un', 'color' => 'cond-unerupted', 'render' => 'dashed'],
        ];
    }
}
```

`app/Enums/ToothSurface.php`:

```php
<?php

namespace App\Enums;

enum ToothSurface: string
{
    use HasMeta;

    case Occlusal = 'occlusal';
    case Buccal = 'buccal';
    case Lingual = 'lingual';
    case Mesial = 'mesial';
    case Distal = 'distal';

    public static function meta(): array
    {
        return [
            'occlusal' => ['label' => 'Occlusal (O)', 'zone' => 'top'],
            'buccal' => ['label' => 'Buccal (B)', 'zone' => 'bottom-left'],
            'lingual' => ['label' => 'Lingual (L)', 'zone' => 'bottom-right'],
            'mesial' => ['label' => 'Mesial (M)', 'zone' => 'left'],
            'distal' => ['label' => 'Distal (D)', 'zone' => 'right'],
        ];
    }
}
```

`app/Enums/RestorationType.php` (PDA — 10 codes):

```php
<?php

namespace App\Enums;

enum RestorationType: string
{
    use HasMeta;

    case Amalgam = 'filling_amalgam';           // Am
    case Composite = 'filling_composite';       // Co
    case Crown = 'crown';                       // JC
    case Abutment = 'abutment';                 // Ab
    case Attachment = 'attachment';             // Att
    case Pontic = 'pontic';                     // P
    case Inlay = 'inlay';                       // In
    case Implant = 'implant';                   // Imp
    case Sealant = 'sealant';                   // S
    case RemovableDenture = 'removable_denture';// Rm

    public static function meta(): array
    {
        return [
            'filling_amalgam' => ['label' => 'Amalgam (Am)', 'code' => 'Am', 'color' => 'rest-amalgam', 'render' => 'solid'],
            'filling_composite' => ['label' => 'Composite (Co)', 'code' => 'Co', 'color' => 'rest-composite', 'render' => 'solid'],
            'crown' => ['label' => 'Jacket crown (JC)', 'code' => 'JC', 'color' => 'rest-crown', 'render' => 'outline'],
            'abutment' => ['label' => 'Abutment (Ab)', 'code' => 'Ab', 'color' => 'rest-abutment', 'render' => 'solid'],
            'attachment' => ['label' => 'Attachment (Att)', 'code' => 'Att', 'color' => 'rest-attachment', 'render' => 'solid'],
            'pontic' => ['label' => 'Pontic (P)', 'code' => 'P', 'color' => 'rest-pontic', 'render' => 'outline'],
            'inlay' => ['label' => 'Inlay (In)', 'code' => 'In', 'color' => 'rest-inlay', 'render' => 'solid'],
            'implant' => ['label' => 'Implant (Imp)', 'code' => 'Imp', 'color' => 'rest-implant', 'render' => 'solid'],
            'sealant' => ['label' => 'Sealant (S)', 'code' => 'S', 'color' => 'rest-sealant', 'render' => 'solid'],
            'removable_denture' => ['label' => 'Removable denture (Rm)', 'code' => 'Rm', 'color' => 'rest-removable', 'render' => 'outline'],
        ];
    }
}
```

- [ ] **Step 4: Color tokens in `resources/css/app.css`**

Add inside the existing `@theme { ... }` block:

```css
  /* Tooth condition palette (PDA legend) */
  --color-cond-caries:          oklch(0.64 0.24 25);
  --color-cond-missing-caries:  oklch(0.42 0.01 280);
  --color-cond-missing-other:   oklch(0.58 0.02 280);
  --color-cond-impacted:        oklch(0.71 0.16 85);
  --color-cond-supernumerary:   oklch(0.55 0.16 190);
  --color-cond-root-fragment:   oklch(0.60 0.14 45);
  --color-cond-unerupted:       oklch(0.82 0.02 280);
  --color-cond-present:         oklch(0.93 0.04 200);

  /* Restoration palette (PDA) */
  --color-rest-amalgam:         oklch(0.55 0.09 280);
  --color-rest-composite:       oklch(0.88 0.03 90);
  --color-rest-crown:           oklch(0.54 0.28 293);
  --color-rest-abutment:        oklch(0.60 0.10 200);
  --color-rest-attachment:      oklch(0.65 0.20 320);
  --color-rest-pontic:          oklch(0.55 0.16 190);
  --color-rest-inlay:           oklch(0.71 0.16 85);
  --color-rest-implant:         oklch(0.35 0.03 280);
  --color-rest-sealant:         oklch(0.65 0.24 152);
  --color-rest-removable:       oklch(0.70 0.15 10);
```

- [ ] **Step 5: Migration**

`database/migrations/2026_08_01_000003_create_dental_chart_entries_table.php`:

```php
<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('dental_chart_entries', function (Blueprint $table) {
            $table->id();
            $table->foreignId('patient_id')->constrained()->cascadeOnDelete();
            $table->unsignedTinyInteger('tooth_number');               // FDI: adult 11–48, primary 51–85
            $table->string('dentition')->default('adult');             // DentitionType
            $table->string('condition');                               // ToothCondition (PDA legend)
            $table->string('restoration_type')->nullable();            // RestorationType (PDA codes)
            $table->string('surface')->nullable();                     // ToothSurface; null = whole tooth
            $table->string('color_code', 32)->nullable();              // denorm snapshot of condition color token
            $table->text('notes')->nullable();
            $table->date('recorded_at');                               // clinical date
            $table->foreignId('recorded_by')->constrained('users')->cascadeOnDelete();
            $table->timestamps();

            $table->index(['patient_id', 'tooth_number', 'surface', 'recorded_at']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('dental_chart_entries');
    }
};
```

- [ ] **Step 6: Model**

`app/Models/DentalChartEntry.php`:

```php
<?php

namespace App\Models;

use App\Enums\DentitionType;
use App\Enums\RestorationType;
use App\Enums\ToothCondition;
use App\Enums\ToothSurface;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Spatie\Activitylog\Traits\LogsActivity;

class DentalChartEntry extends Model
{
    use LogsActivity;

    protected $guarded = [];

    protected static $logName = 'dental_chart_entries';

    /**
     * Get the attributes that should be cast.
     *
     * @return array<string, string>
     */
    protected function casts(): array
    {
        return [
            'dentition' => DentitionType::class,
            'condition' => ToothCondition::class,
            'restoration_type' => RestorationType::class,
            'surface' => ToothSurface::class,
            'recorded_at' => 'date:Y-m-d',
        ];
    }

    public function patient(): BelongsTo
    {
        return $this->belongsTo(Patient::class);
    }

    public function recordedBy(): BelongsTo
    {
        return $this->belongsTo(User::class, 'recorded_by');
    }
}
```

- [ ] **Step 7: Service (projection)**

`app/Services/DentalChartService.php`:

```php
<?php

namespace App\Services;

use App\Models\DentalChartEntry;
use Carbon\Carbon;
use Illuminate\Database\Eloquent\Collection;

final class DentalChartService
{
    /**
     * Latest state per (tooth, surface) — the rendered chart.
     * Keyed by tooth_number → ['whole' => ['condition' => ?string, 'restoration' => ?string], 'surfaces' => [surface => same]].
     *
     * @return array<int, array{whole: array{condition: ?string, restoration: ?string}, surfaces: array<string, array{condition: ?string, restoration: ?string}>}>
     */
    public function currentState(int $patientId, string $dentition): array
    {
        return $this->project(
            DentalChartEntry::where('patient_id', $patientId)
                ->where('dentition', $dentition)
                ->orderBy('recorded_at')
                ->orderBy('id')
                ->get()
        );
    }

    /**
     * Same projection but only entries recorded on or before the given date.
     *
     * @return array<int, array{whole: array{condition: ?string, restoration: ?string}, surfaces: array<string, array{condition: ?string, restoration: ?string}>}>
     */
    public function stateAsOf(int $patientId, string $dentition, Carbon $asOf): array
    {
        return $this->project(
            DentalChartEntry::where('patient_id', $patientId)
                ->where('dentition', $dentition)
                ->where('recorded_at', '<=', $asOf->toDateString())
                ->orderBy('recorded_at')
                ->orderBy('id')
                ->get()
        );
    }

    /**
     * Full immutable log, newest first.
     */
    public function history(int $patientId, ?int $toothNumber = null, ?string $from = null): Collection
    {
        return DentalChartEntry::with('recordedBy:id,name')
            ->where('patient_id', $patientId)
            ->when($toothNumber !== null, fn ($q) => $q->where('tooth_number', $toothNumber))
            ->when($from !== null, fn ($q) => $q->where('recorded_at', '>=', $from))
            ->orderByDesc('recorded_at')
            ->orderByDesc('id')
            ->get();
    }

    /**
     * @param  Collection<int, DentalChartEntry>  $rows  ordered by recorded_at, id ascending
     * @return array<int, array{whole: array{condition: ?string, restoration: ?string}, surfaces: array<string, array{condition: ?string, restoration: ?string}>}>
     */
    private function project(Collection $rows): array
    {
        $state = [];

        foreach ($rows as $row) {
            $tooth = $row->tooth_number;
            $slot = $row->surface?->value ?? 'whole';

            $state[$tooth]['whole'] ??= ['condition' => null, 'restoration' => null];
            $state[$tooth]['surfaces'] ??= [];

            $target = &$state[$tooth][$slot === 'whole' ? 'whole' : 'surfaces'][$slot];

            if ($row->condition) {
                $target['condition'] = $row->condition->value;
            }
            if ($row->restoration_type) {
                $target['restoration'] = $row->restoration_type->value;
            }

            unset($target);
        }

        return $state;
    }
}
```

- [ ] **Step 8: Action**

`app/Actions/RecordToothConditionAction.php`:

```php
<?php

namespace App\Actions;

use App\Enums\DentitionType;
use App\Enums\ToothCondition;
use App\Models\DentalChartEntry;
use App\Models\Patient;
use App\Models\User;

final class RecordToothConditionAction
{
    public function handle(
        Patient $patient,
        int $tooth,
        string $dentition,
        string $condition,
        ?string $surface,
        ?string $restoration,
        string $recordedAt,
        ?string $notes,
        User $actor
    ): DentalChartEntry {
        abort_unless($actor->can('dental-chart.update'), 403);
        abort_unless(
            DentitionType::isValidTooth($tooth, $dentition),
            422,
            "Tooth {$tooth} is not valid for the {$dentition} dentition."
        );

        if ($surface === null && in_array($condition, ToothCondition::wholeToothOnly(), true) === false) {
            // fine — surface-null entries are whole-tooth marks
        }

        $entry = DentalChartEntry::create([
            'patient_id' => $patient->id,
            'tooth_number' => $tooth,
            'dentition' => $dentition,
            'condition' => $condition,
            'surface' => $surface,
            'restoration_type' => $restoration,
            'color_code' => ToothCondition::meta()[$condition]['color'] ?? null,
            'notes' => $notes,
            'recorded_at' => $recordedAt,
            'recorded_by' => $actor->id,
        ]);

        activity()->performedOn($entry)->causedBy($actor)->log('chart.updated');

        return $entry;
    }
}
```

- [ ] **Step 9: Policy + Request**

`app/Policies/DentalChartEntryPolicy.php`:

```php
<?php

namespace App\Policies;

use App\Models\User;

class DentalChartEntryPolicy
{
    public function viewAny(User $user): bool
    {
        return $user->can('dental-chart.view');
    }

    public function create(User $user): bool
    {
        return $user->can('dental-chart.update');
    }
}
```

`app/Http/Requests/StoreDentalChartEntryRequest.php`:

```php
<?php

namespace App\Http\Requests;

use App\Enums\DentitionType;
use App\Enums\RestorationType;
use App\Enums\ToothCondition;
use App\Enums\ToothSurface;
use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rule;

class StoreDentalChartEntryRequest extends FormRequest
{
    /**
     * @return array<string, array<int, mixed>>
     */
    public function rules(): array
    {
        $conditions = array_map(fn (ToothCondition $c) => $c->value, ToothCondition::cases());
        $surfaces = array_map(fn (ToothSurface $s) => $s->value, ToothSurface::cases());
        $restorations = array_map(fn (RestorationType $r) => $r->value, RestorationType::cases());
        $dentitions = array_map(fn (DentitionType $d) => $d->value, DentitionType::cases());

        return [
            'patient_id' => ['required', 'exists:patients,id'],
            'tooth_number' => ['required', 'integer', 'min:11', 'max:85'],
            'dentition' => ['required', Rule::in($dentitions)],
            'condition' => ['required', Rule::in($conditions)],
            'surface' => ['nullable', Rule::in($surfaces)],
            'restoration_type' => ['nullable', Rule::in($restorations)],
            'recorded_at' => ['required', 'date'],
            'notes' => ['nullable', 'string', 'max:1000'],
        ];
    }
}
```

- [ ] **Step 10: Controller**

`app/Http/Controllers/DentalChartController.php`:

```php
<?php

namespace App\Http\Controllers;

use App\Actions\RecordToothConditionAction;
use App\Enums\DentitionType;
use App\Enums\RestorationType;
use App\Enums\ToothCondition;
use App\Enums\ToothSurface;
use App\Http\Requests\StoreDentalChartEntryRequest;
use App\Models\DentalChartEntry;
use App\Models\Patient;
use App\Services\DentalChartService;
use Carbon\Carbon;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Redirect;
use Inertia\Inertia;
use Inertia\Response;

class DentalChartController extends Controller
{
    public function __construct(
        private readonly DentalChartService $service,
        private readonly RecordToothConditionAction $record
    ) {}

    public function show(Request $request, Patient $patient): Response
    {
        $this->authorize('viewAny', DentalChartEntry::class);

        $dentition = in_array($request->query('dentition', 'adult'), ['adult', 'primary'], true)
            ? $request->query('dentition')
            : 'adult';
        $asOf = preg_match('/^\d{4}-\d{2}-\d{2}$/', (string) $request->query('as_of', ''))
            ? Carbon::parse($request->query('as_of'))
            : null;

        return Inertia::render('Patients/Chart', [
            'patient' => $patient,
            'dentition' => $dentition,
            'state' => $asOf
                ? $this->service->stateAsOf($patient->id, $dentition, $asOf)
                : $this->service->currentState($patient->id, $dentition),
            'asOf' => $asOf?->toDateString(),
            'history' => $this->service->history($patient->id),
            'options' => [
                'conditions' => ToothCondition::meta(),
                'restorations' => RestorationType::meta(),
                'surfaces' => ToothSurface::meta(),
                'dentitions' => DentitionType::meta(),
            ],
            'can' => [
                'update' => $request->user()->can('dental-chart.update'),
            ],
        ]);
    }

    public function store(StoreDentalChartEntryRequest $request): RedirectResponse
    {
        $this->authorize('create', DentalChartEntry::class);

        $data = $request->validated();
        $patient = Patient::findOrFail($data['patient_id']);

        $this->record->handle(
            patient: $patient,
            tooth: (int) $data['tooth_number'],
            dentition: $data['dentition'],
            condition: $data['condition'],
            surface: $data['surface'],
            restoration: $data['restoration_type'],
            recordedAt: $data['recorded_at'],
            notes: $data['notes'] ?? null,
            actor: $request->user(),
        );

        return Redirect::back();
    }
}
```

- [ ] **Step 11: Routes**

In `routes/web.php`:

```php
use App\Http\Controllers\DentalChartController;

Route::middleware(['auth', 'verified', 'permission:dental-chart.view'])
    ->get('/patients/{patient}/chart', [DentalChartController::class, 'show'])
    ->name('patients.chart');
Route::middleware(['auth', 'verified', 'permission:dental-chart.update'])
    ->post('/dental-chart/entries', [DentalChartController::class, 'store'])
    ->name('dental-chart.store');
```

- [ ] **Step 12: Feature test**

`tests/Feature/Chart/ManageDentalChartTest.php`:

```php
<?php

use App\Models\DentalChartEntry;
use App\Models\Patient;
use App\Models\User;

uses(RefreshDatabase::class);

beforeEach(function () {
    $this->seed(\Database\Seeders\RolePermissionSeeder::class);
});

it('renders the chart page with the projected state', function () {
    $dentist = User::factory()->create()->assignRole('Dentist');
    $patient = Patient::factory()->create();
    DentalChartEntry::create([
        'patient_id' => $patient->id, 'tooth_number' => 26, 'dentition' => 'adult',
        'condition' => 'caries', 'surface' => 'occlusal', 'recorded_at' => now()->toDateString(),
        'recorded_by' => $dentist->id,
    ]);

    $this->actingAs($dentist)->get("/patients/{$patient->id}/chart")
        ->assertOk()
        ->assertInertia(fn ($page) => $page
            ->component('Patients/Chart')
            ->has('state.26.surfaces.occlusal')
            ->has('history', 1));
});

it('records an immutable chart entry', function () {
    $dentist = User::factory()->create()->assignRole('Dentist');
    $patient = Patient::factory()->create();

    $this->actingAs($dentist)->post('/dental-chart/entries', [
        'patient_id' => $patient->id, 'tooth_number' => 16, 'dentition' => 'adult',
        'condition' => 'caries', 'surface' => 'occlusal', 'restoration_type' => null,
        'recorded_at' => now()->toDateString(),
    ])->assertRedirect();

    expect(DentalChartEntry::count())->toBe(1);
    expect($patient->chartEntries()->first()->condition->value)->toBe('caries');
});

it('rejects out-of-range teeth and missing conditions', function () {
    $dentist = User::factory()->create()->assignRole('Dentist');
    $patient = Patient::factory()->create();

    $this->actingAs($dentist)->post('/dental-chart/entries', [
        'patient_id' => $patient->id, 'tooth_number' => 99, 'dentition' => 'adult',
        'condition' => 'caries', 'recorded_at' => now()->toDateString(),
    ])->assertSessionHasErrors(['tooth_number']);

    $this->actingAs($dentist)->post('/dental-chart/entries', [
        'patient_id' => $patient->id, 'tooth_number' => 16, 'dentition' => 'adult',
        'recorded_at' => now()->toDateString(),
    ])->assertSessionHasErrors(['condition']);
});

it('blocks assistants from updating the chart', function () {
    $assistant = User::factory()->create()->assignRole('Assistant');
    $patient = Patient::factory()->create();

    $this->actingAs($assistant)->post('/dental-chart/entries', [
        'patient_id' => $patient->id, 'tooth_number' => 16, 'dentition' => 'adult',
        'condition' => 'caries', 'recorded_at' => now()->toDateString(),
    ])->assertForbidden();
});
```

Also add the missing relation in `app/Models/Patient.php`:

```php
public function chartEntries(): HasMany
{
    return $this->hasMany(DentalChartEntry::class);
}
```

- [ ] **Step 13: Verify pass**

Run: `./vendor/bin/pest tests/Unit/DentalChartServiceTest.php tests/Feature/Chart`
Expected: PASS.

- [ ] **Step 14: Pint + commit**

```bash
./vendor/bin/pint && ./vendor/bin/pest
git add -A && git commit -m "feat: dental chart backend (PDA legend enums, append-only log, projection service)"
```

---

## Task 3: ToothChart SVG component + chart page

**Files:**
- Create: `resources/js/Components/ToothChart.vue`
- Create: `resources/js/Pages/Patients/Chart.vue`
- Modify: `resources/js/Pages/Patients/Show.vue` (wire Chart tab), `resources/js/Components/Sidebar.vue` (nothing — no new nav item)
- Test: geometry helper unit test in `tests/Unit/ToothChartGeometryTest.php` (JS — use Vitest? NOT INSTALLED — instead assert geometry in the component's exported pure helpers via a tiny node script in the test suite? See note below.)

- [ ] **Step 1: ToothChart component**

`resources/js/Components/ToothChart.vue` — twin-arch SVG per the PDA layout. Key spec:

**Props:**
- `state: Object` (required) — keyed by tooth number: `{ [tooth]: { whole: {condition, restoration}, surfaces: { [surface]: {condition, restoration} } } }`
- `dentition: String` — `'adult' | 'primary'`
- `readonly: Boolean` (default false) — disables clicks (history as-of mode)
- `selectedCondition: String|null`, `selectedRestoration: String|null` — current palette tool (only when not readonly)
- `options: Object` — `{ conditions, restorations, surfaces, dentitions }` meta maps from the page props

**Emits:** `apply-tooth` with payload `{ tooth, surface }` (surface `null` = whole tooth).

**Layout (PDA mirror layout):**
- Upper arch row, two groups separated by a gap (midline):
  - Adult upper: left group `18 17 16 15 14 13 12 11`, right group `21 22 23 24 25 26 27 28`
  - Primary upper: `55 54 53 52 51 | 61 62 63 64 65`
- Lower arch row, mirrored:
  - Adult lower: `48 47 46 45 44 43 42 41 | 31 32 33 34 35 36 37 38`
  - Primary lower: `85 84 83 82 81 | 71 72 73 74 75`
- Tooth order derived from `DentitionType::ranges()` data passed via `options.dentitions` (each meta entry has `teeth` array). The component renders each row from the meta `teeth` list in PDA reading order: for adult the upper row is `[11..18] reversed → 18..11` then `[21..28]`, lower is `[41..48] reversed → 48..41` then `[31..38]`. Implement pure helper functions exported for testability:

```js
// Pure geometry helpers (export for unit testing)
export const rowToothLists = (dentition) => {
  // returns { upper: [ [18..11], [21..28] ], lower: [ [48..41], [31..38] ] } for adult
  // and { upper: [ [55..51], [61..65] ], lower: [ [85..81], [71..75] ] } for primary
}

export const surfaceZones = () => ({
  // 5 zones per tooth in a 48x56 viewBox
  // 'occlusal' => top strip  (x:4,y:4,w:40,h:14)
  // 'mesial'   => left strip (x:4,y:4,w:10,h:48)
  // 'distal'   => right strip(x:34,y:4,w:10,h:48)
  // 'buccal'   => bottom-left half  (x:4,y:32,w:20,h:20)
  // 'lingual'  => bottom-right half (x:24,y:32,w:20,h:20)
  // whole tooth rect: x:4,y:4,w:40,h:48 (plus root nubs)
})
```

**Tooth rendering (one `<g>` per tooth, translated to grid position):**
- Tooth body: rounded rect (rx 6) 40×48 + two root nubs at the bottom (upper teeth) / top (lower teeth) using simple paths, fill `#fff`-equivalent → use `fill="currentColor"` with `text-gray-50`-ish… **IMPORTANT:** SVG fills cannot use Tailwind classes — use the CSS custom properties directly: `fill: var(--color-cond-caries)` via inline `:style`. The tokens are defined on `:root` via `@theme`, so `var(--color-cond-caries)` resolves. This keeps no-hex rule.
- Whole-tooth slot: fill body with condition/restoration color per meta `color` token; missing conditions draw a diagonal X (two `<line>`s); `present` draws a check mark; `dashed` conditions (impacted/unerupted) use dashed stroke + light fill; `outline` restorations (crown/pontic/removable_denture) draw a thick ring stroke.
- Surface zones: 5 `<path>`s per tooth, clickable (except readonly), `pointer-events` on each; each filled when state has a condition/restoration on that surface (same render rules). Zones show a subtle hover ring (`stroke` gray on hover via CSS class `hover:stroke-gray-300` on the SVG path — classes work on SVG elements in Vue/Tailwind).
- Whole tooth click: clicking the body rect (behind zones) emits `{ tooth, surface: null }`. Zones sit above the body and capture their own clicks.
- Tooth number label: small `<text>` under each tooth (font-size 9, gray-400).
- Selected state: when `selectedCondition`/`selectedRestoration` set, the NEXT click on a zone/body applies that tool — visual affordance: cursor-crosshair on the chart; the component itself only emits; the page handles POST.

**Interaction gating (whole-tooth-only conditions):** when `selectedCondition` is one of `missing_caries, missing_other, impacted, supernumerary, unerupted`, disable surface zones (pointer-events-none + reduced opacity) so only whole-tooth clicks apply. `present` and `caries` allow surfaces.

- [ ] **Step 2: Chart page**

`resources/js/Pages/Patients/Chart.vue`:

```vue
<script setup>
import { ref, watch } from 'vue'
import { Head, router } from '@inertiajs/vue3'
import { History, X } from 'lucide-vue-next'
import { route } from '../../../../vendor/tightenco/ziggy'
import AppLayout from '@/Layouts/AppLayout.vue'
import Badge from '@/Components/Badge.vue'
import Button from '@/Components/Button.vue'
import ToothChart from '@/Components/ToothChart.vue'
import { useToastStore } from '@/Stores/toast'

defineOptions({ layout: AppLayout })

const props = defineProps({
    patient: { type: Object, required: true },
    dentition: { type: String, default: 'adult' },
    state: { type: Object, required: true },
    asOf: { type: String, default: null },
    history: { type: Array, default: () => [] },
    options: { type: Object, required: true },
    can: { type: Object, default: () => ({}) },
})

const toastStore = useToastStore()

const selectedCondition = ref(null)
const selectedRestoration = ref(null)
const showHistory = ref(false)

// reset tools when dentition or as-of changes
watch(() => [props.dentition, props.asOf], () => {
    selectedCondition.value = null
    selectedRestoration.value = null
})

const pickTool = (kind, key) => {
    if (!props.can.update) return
    if (kind === 'condition') {
        selectedCondition.value = selectedCondition.value === key ? null : key
        selectedRestoration.value = null
    } else {
        selectedRestoration.value = selectedRestoration.value === key ? null : key
        selectedCondition.value = null
    }
}

const applying = ref(false)

const applyTooth = ({ tooth, surface }) => {
    if (applying.value) return
    const tool = selectedRestoration.value ? { restoration_type: selectedRestoration.value } : { condition: selectedCondition.value }
    if (!tool.condition && !tool.restoration_type) return

    applying.value = true
    router.post(route('dental-chart.store'), {
        patient_id: props.patient.id,
        tooth_number: tooth,
        dentition: props.dentition,
        surface,
        recorded_at: new Date().toISOString().slice(0, 10),
        ...tool,
    }, {
        preserveScroll: true,
        onSuccess: () => toastStore.show(`Tooth ${tooth} updated.`),
        onFinish: () => (applying.value = false),
    })
}

const viewAsOf = (date) => {
    router.get(route('patients.chart', [props.patient.id, { as_of: date }]), {}, { preserveState: true })
}

const clearAsOf = () => {
    router.get(route('patients.chart', props.patient.id), {}, { preserveState: true })
}

const conditionLabel = (key) => props.options.conditions[key]?.label ?? key
const restorationLabel = (key) => props.options.restorations[key]?.label ?? key
</script>
```

Template structure (all Tailwind standard classes, brand/gray/status tokens only):
- Header: patient name + patient number + badge "Chart" + dentition segmented control (`Adult`/`Primary` via `router.get(route('patients.chart', [patient.id, { dentition }]))` with preserveState) + history toggle button (`History` icon) + "As of" chip when `asOf` set (with clear button).
- History drawer (right side slide-over or bottom sheet on tablet): list of `history` entries (date, tooth number, condition label, restoration label, recordedBy name); each row's date is a button → `viewAsOf(entry.recorded_at)`. Mark rows after `asOf` with reduced opacity. When `asOf` is set show a banner "Showing state as of {date}" with "Back to current" button.
- ToothChart with legend: two groups of chips — **Conditions** (8 chips: color swatch from `options.conditions[key].color` token + label) and **Restorations** (10 chips). Chip = button ≥44px, rounded, border; selected = brand ring + bg-brand-50. Tooltip on chips shows PDA code (e.g. "D").
- "Clear selection" happens by tapping the selected chip again (toggle behavior in `pickTool`).
- A hint bar when `can.update`: "Tap a condition or restoration, then tap a tooth (or its surface) to record it. Changes are saved instantly."
- When `!can.update`: chart renders readonly (assistant view).

- [ ] **Step 3: Wire Show.vue Chart tab**

In `resources/js/Pages/Patients/Show.vue`, replace the tab block (`tabs` array + disabled buttons) with:

- Keep tabs array but mark which are wired: `Appointments` (wired — section below), `Chart` (wired — link out), `Treatments` (wired — link out or section, Task 5), `Files` (Phase 3), `Consents` (Phase 3).
- Chart tab → becomes a real `<Link :href="route('patients.chart', patient.id)">` styled as the other tabs; Files/Consents stay disabled.
- Appointments tab → renders an inline list: query in `PatientsController::show` → `'appointments' => $patient->appointments()->with(['dentist:id,name'])->orderByDesc('appointment_date')->limit(5)->get()`, rows: date, time, dentist, status Badge; link "View all" → `route('appointments.index')`.
- The empty-state panel below tabs: only shown when all wired sections are empty.

- [ ] **Step 4: Manual verification**

Run: `npm run build` — no errors. Then in browser (logged in as admin@clinic.test / password, app on :8000): open `/patients/1/chart`, verify: twin arch renders (adult default), both rows + tooth numbers visible; click condition "Decayed (D)" then tooth 16 occlusal zone → POST succeeds, toast appears, zone fills red; click tooth 26 whole → fills red; switch dentition to Primary → 20 teeth render; open history drawer → entry listed; select a restoration (Am) → tooth fills. Verify no console errors, no horizontal scroll at 1024px.

- [ ] **Step 5: Commit**

```bash
git add -A && git commit -m "feat: tooth chart SVG component + chart page (twin arch, 5-surface zones, legend, history)"
```

---

## Task 4: PDA expansion — medical histories + patients fields

**Files:**
- Create: `database/migrations/2026_08_01_000004_extend_medical_histories_for_pda.php`
- Create: `database/migrations/2026_08_01_000005_extend_patients_for_pda.php`
- Modify: `app/Models/MedicalHistory.php`, `app/Models/Patient.php`, `app/Http/Requests/StoreMedicalHistoryRequest.php`, `app/Http/Requests/StorePatientRequest.php`, `app/Http/Requests/UpdatePatientRequest.php`, `resources/js/Pages/Patients/Show.vue`, `resources/js/Pages/Patients/Create.vue`, `resources/js/Pages/Patients/Edit.vue`, `app/Http/Controllers/PatientsController.php`, `app/Http/Controllers/MedicalHistoriesController.php`
- Test: `tests/Feature/Patients/PdaFieldsTest.php`

- [ ] **Step 1: Write the failing feature test**

`tests/Feature/Patients/PdaFieldsTest.php`:

```php
<?php

use App\Models\Patient;
use App\Models\User;

uses(RefreshDatabase::class);

beforeEach(function () {
    $this->seed(\Database\Seeders\RolePermissionSeeder::class);
});

it('stores the PDA medical history expansion fields', function () {
    $dentist = User::factory()->create()->assignRole('Dentist');
    $patient = Patient::factory()->create();

    $this->actingAs($dentist)->post("/patients/{$patient->id}/medical-history", [
        'hypertension' => 'no', 'diabetes' => 'no', 'tuberculosis' => 'no',
        'heart_disease' => 'no', 'pregnancy' => 'no', 'allergies' => 'no',
        'medications' => 'no', 'smoking_history' => 'no', 'alcohol_consumption' => 'no',
        'previous_surgeries' => 'no',
        'good_health' => 'yes',
        'under_medical_treatment' => 'yes', 'medical_treatment_details' => 'Lisinopril 10mg',
        'hospitalized' => 'no',
        'nursing' => 'no',
        'birth_control_pills' => 'no',
        'bleeding_time' => 'normal',
        'blood_type' => 'O+',
        'blood_pressure' => '120/80',
        'conditions_checklist' => ['high_blood_pressure', 'diabetes'],
        'physician_name' => 'Dr. Reyes',
        'physician_specialty' => 'Cardiology',
        'physician_address' => 'St. Luke\'s',
        'physician_phone' => '0917-555-1234',
        'dental_history_previous_dentist' => 'Dr. Santos',
        'dental_history_last_visit' => '2025-12-01',
        'referral_source' => 'Friend',
        'drug_use' => 'no',
    ])->assertRedirect();

    $history = $patient->medicalHistory->fresh();
    expect($history->good_health)->toBe('yes');
    expect($history->medical_treatment_details)->toBe('Lisinopril 10mg');
    expect($history->blood_type)->toBe('O+');
    expect($history->conditions_checklist)->toBe(['high_blood_pressure', 'diabetes']);
    expect($history->dental_history_last_visit)->not->toBeNull();
    expect($history->referral_source)->toBe('Friend');
});

it('keeps existing rows when the expansion columns are null', function () {
    $dentist = User::factory()->create()->assignRole('Dentist');
    $patient = Patient::factory()->create();

    $this->actingAs($dentist)->post("/patients/{$patient->id}/medical-history", [
        'hypertension' => 'yes', 'diabetes' => 'no', 'tuberculosis' => 'no',
        'heart_disease' => 'no', 'pregnancy' => 'no', 'allergies' => 'no',
        'medications' => 'no', 'smoking_history' => 'no', 'alcohol_consumption' => 'no',
        'previous_surgeries' => 'no',
    ])->assertRedirect();

    $history = $patient->medicalHistory->fresh();
    expect($history->hypertension)->toBe('yes');
    expect($history->good_health)->toBeNull();
});

it('stores the PDA patient fields', function () {
    $receptionist = User::factory()->create()->assignRole('Receptionist');

    $this->actingAs($receptionist)->post('/patients', [
        'first_name' => 'Liza', 'last_name' => 'Reyes', 'sex' => 'female',
        'birth_date' => '1995-05-05', 'civil_status' => 'married', 'nationality' => 'Filipino',
        'contact_number' => '09171234567', 'address' => 'QC',
        'emergency_contact_person' => 'John', 'emergency_contact_number' => '09179876543',
        'religion' => 'Roman Catholic',
        'nickname' => 'Liz',
        'home_phone' => '02-8123-4567',
        'office_phone' => '02-8765-4321',
        'fax_number' => null,
        'dental_insurance' => 'PhilHealth',
        'effective_date' => '2026-01-01',
        'guardian_name' => null,
        'guardian_occupation' => null,
    ])->assertRedirect();

    $patient = Patient::where('last_name', 'Reyes')->first();
    expect($patient->religion)->toBe('Roman Catholic');
    expect($patient->nickname)->toBe('Liz');
    expect($patient->dental_insurance)->toBe('PhilHealth');
    expect($patient->effective_date)->not->toBeNull();
});
```

- [ ] **Step 2: Run to verify failure**

Run: `./vendor/bin/pest tests/Feature/Patients/PdaFieldsTest.php`
Expected: FAIL — columns missing (unknown column errors).

- [ ] **Step 3: Migration — medical histories**

`database/migrations/2026_08_01_000004_extend_medical_histories_for_pda.php` (all nullable so existing rows survive):

```php
<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('medical_histories', function (Blueprint $table) {
            $table->string('good_health')->nullable();                       // no/yes
            $table->string('under_medical_treatment')->nullable();           // no/yes
            $table->text('medical_treatment_details')->nullable();
            $table->string('hospitalized')->nullable();                      // no/yes
            $table->text('hospitalization_details')->nullable();
            $table->string('nursing')->nullable();                           // no/yes (women only)
            $table->string('birth_control_pills')->nullable();               // no/yes (women only)
            $table->string('bleeding_time')->nullable();                     // free text
            $table->string('blood_type')->nullable();                        // A+ A- B+ B- AB+ AB- O+ O-
            $table->string('blood_pressure')->nullable();                    // free text e.g. "120/80"
            $table->json('conditions_checklist')->nullable();                // array of PDA 36 condition keys
            $table->string('physician_name')->nullable();
            $table->string('physician_specialty')->nullable();
            $table->string('physician_address')->nullable();
            $table->string('physician_phone')->nullable();
            $table->string('dental_history_previous_dentist')->nullable();
            $table->date('dental_history_last_visit')->nullable();
            $table->string('referral_source')->nullable();
            $table->string('drug_use')->nullable();                          // no/yes (PDA Q7)
            $table->text('drug_use_details')->nullable();
        });
    }

    public function down(): void
    {
        Schema::table('medical_histories', function (Blueprint $table) {
            $table->dropColumn([
                'good_health', 'under_medical_treatment', 'medical_treatment_details',
                'hospitalized', 'hospitalization_details', 'nursing', 'birth_control_pills',
                'bleeding_time', 'blood_type', 'blood_pressure', 'conditions_checklist',
                'physician_name', 'physician_specialty', 'physician_address', 'physician_phone',
                'dental_history_previous_dentist', 'dental_history_last_visit',
                'referral_source', 'drug_use', 'drug_use_details',
            ]);
        });
    }
};
```

- [ ] **Step 4: Migration — patients**

`database/migrations/2026_08_01_000005_extend_patients_for_pda.php`:

```php
<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('patients', function (Blueprint $table) {
            $table->string('religion')->nullable();
            $table->string('nickname')->nullable();
            $table->string('home_phone')->nullable();
            $table->string('office_phone')->nullable();
            $table->string('fax_number')->nullable();
            $table->string('dental_insurance')->nullable();
            $table->date('effective_date')->nullable();
            $table->string('guardian_name')->nullable();
            $table->string('guardian_occupation')->nullable();
        });
    }

    public function down(): void
    {
        Schema::table('patients', function (Blueprint $table) {
            $table->dropColumn([
                'religion', 'nickname', 'home_phone', 'office_phone', 'fax_number',
                'dental_insurance', 'effective_date', 'guardian_name', 'guardian_occupation',
            ]);
        });
    }
};
```

- [ ] **Step 5: Models**

`app/Models/MedicalHistory.php` — add to casts: `'conditions_checklist' => 'array'`, `'dental_history_last_visit' => 'date:Y-m-d'`.

`app/Models/Patient.php` — add to casts: `'effective_date' => 'date:Y-m-d'`. Also add the PDA condition-key list as a public constant for form options:

```php
/** PDA Page 1 Q13 medical conditions (36 keys). */
public const MEDICAL_CONDITION_KEYS = [
    'high_blood_pressure', 'low_blood_pressure', 'epilepsy', 'aids_hiv', 'sexually_transmitted_disease',
    'stomach_ulcers', 'fainting_seizure', 'rapid_weight_loss', 'radiation_therapy', 'joint_replacement',
    'heart_surgery', 'heart_attack', 'thyroid_problem', 'heart_disease', 'heart_murmur',
    'hepatitis_liver_disease', 'rheumatic_fever', 'hay_fever', 'respiratory_problems',
    'hepatitis_jaundice', 'tuberculosis', 'swollen_ankles', 'kidney_disease', 'diabetes',
    'chest_pain', 'stroke', 'cancer_tumors', 'anemia', 'angina', 'asthma', 'emphysema',
    'bleeding_disorders', 'blood_diseases', 'head_injuries', 'arthritis', 'others',
];
```

- [ ] **Step 6: Requests**

`StoreMedicalHistoryRequest` — add the new nullable rules:

```php
'good_health' => ['nullable', 'in:no,yes'],
'under_medical_treatment' => ['nullable', 'in:no,yes'],
'medical_treatment_details' => ['nullable', 'string', 'max:1000'],
'hospitalized' => ['nullable', 'in:no,yes'],
'hospitalization_details' => ['nullable', 'string', 'max:1000'],
'nursing' => ['nullable', 'in:no,yes'],
'birth_control_pills' => ['nullable', 'in:no,yes'],
'bleeding_time' => ['nullable', 'string', 'max:100'],
'blood_type' => ['nullable', 'in:A+,A-,B+,B-,AB+,AB-,O+,O-'],
'blood_pressure' => ['nullable', 'string', 'max:50'],
'conditions_checklist' => ['nullable', 'array'],
'conditions_checklist.*' => ['string', 'in:high_blood_pressure,low_blood_pressure,epilepsy,aids_hiv,sexually_transmitted_disease,stomach_ulcers,fainting_seizure,rapid_weight_loss,radiation_therapy,joint_replacement,heart_surgery,heart_attack,thyroid_problem,heart_disease,heart_murmur,hepatitis_liver_disease,rheumatic_fever,hay_fever,respiratory_problems,hepatitis_jaundice,tuberculosis,swollen_ankles,kidney_disease,diabetes,chest_pain,stroke,cancer_tumors,anemia,angina,asthma,emphysema,bleeding_disorders,blood_diseases,head_injuries,arthritis,others'],
'physician_name' => ['nullable', 'string', 'max:255'],
'physician_specialty' => ['nullable', 'string', 'max:255'],
'physician_address' => ['nullable', 'string', 'max:255'],
'physician_phone' => ['nullable', 'string', 'max:50'],
'dental_history_previous_dentist' => ['nullable', 'string', 'max:255'],
'dental_history_last_visit' => ['nullable', 'date'],
'referral_source' => ['nullable', 'string', 'max:255'],
'drug_use' => ['nullable', 'in:no,yes'],
'drug_use_details' => ['nullable', 'string', 'max:1000'],
```

`StorePatientRequest` / `UpdatePatientRequest` — add:

```php
'religion' => ['nullable', 'string', 'max:100'],
'nickname' => ['nullable', 'string', 'max:100'],
'home_phone' => ['nullable', 'string', 'max:30'],
'office_phone' => ['nullable', 'string', 'max:30'],
'fax_number' => ['nullable', 'string', 'max:30'],
'dental_insurance' => ['nullable', 'string', 'max:255'],
'effective_date' => ['nullable', 'date'],
'guardian_name' => ['nullable', 'string', 'max:255'],
'guardian_occupation' => ['nullable', 'string', 'max:255'],
```

- [ ] **Step 7: Controllers**

`MedicalHistoriesController::store` — pass through validated data as-is (already uses `$request->validated()`); ensure `updateOrCreate` handles the new columns (no change needed — guarded model). `PatientsController` — no change (requests validate + `RegisterPatientAction` uses validated data).

- [ ] **Step 8: UI — Create.vue / Edit.vue**

Add optional sections to the patient forms (all optional, order after "Emergency contact"): **PDA additional details** with fields: Religion, Nickname, Home phone, Office phone, Fax number, Dental insurance, Effective date (date input), Guardian name, Guardian occupation. Use the same Input component pattern as the existing form.

- [ ] **Step 9: UI — Show.vue medical history editor**

Extend the medical history form in `Show.vue`:

- Keep the existing 10 questions.
- Add a **PDA expansion** section rendered as collapsible `<details>` groups (tablet-friendly):
  1. **General health**: good_health (No/Yes pills), under_medical_treatment (pills + conditional details textarea), hospitalized (pills + conditional details), bleeding_time (text), blood_type (select of 8), blood_pressure (text), drug_use (pills + conditional details).
  2. **Physician**: physician_name, physician_specialty, physician_address, physician_phone (4 text inputs).
  3. **Dental history**: dental_history_previous_dentist (text), dental_history_last_visit (date input), referral_source (text).
  4. **For women only**: nursing (pills), birth_control_pills (pills).
  5. **Medical conditions checklist**: 36 chips (multi-select) rendered as wrap grid of toggle buttons (≥44px, selected = bg-brand-50 + border-brand-500 text-brand-700), bound to `form.conditions_checklist` array.
- Display mode (non-editing): show the new fields when present — condition chips as small badges, physician info rows, etc.
- The `form` in Show.vue needs the new keys initialized; the `openEditor` must hydrate them from `medicalHistory`.
- Add a `PDA condition label map` constant in the component (36 keys → display labels, e.g. `high_blood_pressure → 'High blood pressure'`, `aids_hiv → 'AIDS or HIV infection'`, `sexually_transmitted_disease → 'Sexually transmitted disease'`, `hepatitis_liver_disease → 'Hepatitis or liver disease'`, `hepatitis_jaundice → 'Hepatitis or jaundice'`, `cancer_tumors → 'Cancer or tumors'` — match PDA Page 1 Q13 wording).

- [ ] **Step 10: Verify pass**

Run: `./vendor/bin/pest tests/Feature/Patients/PdaFieldsTest.php` and the full suite.
Expected: PASS.

- [ ] **Step 11: Pint + commit**

```bash
./vendor/bin/pint && ./vendor/bin/pest
git add -A && git commit -m "feat: PDA medical history + patient field expansion"
```

---

## Task 5: Treatments module + e-signature stub

**Files:**
- Create: `database/migrations/2026_08_01_000006_create_treatments_table.php`
- Create: `app/Models/Treatment.php`, `database/factories/TreatmentFactory.php`
- Create: `app/Services/TreatmentService.php`, `app/Services/SignatureStorageService.php` (minimal store())
- Create: `app/Policies/TreatmentPolicy.php`
- Create: `app/Http/Requests/StoreTreatmentRequest.php`
- Create: `app/Http/Controllers/TreatmentsController.php`
- Create: `resources/js/Components/SignaturePadModal.vue`, `resources/js/Components/Wizard/TreatmentForm.vue`
- Modify: `routes/web.php`, `app/Models/Patient.php`, `resources/js/Pages/Patients/Show.vue` (Treatments tab + sign flow)
- Test: `tests/Feature/Treatments/ManageTreatmentsTest.php`

- [ ] **Step 1: Write the failing feature test**

`tests/Feature/Treatments/ManageTreatmentsTest.php`:

```php
<?php

use App\Models\Patient;
use App\Models\Treatment;
use App\Models\User;

uses(RefreshDatabase::class);

beforeEach(function () {
    $this->seed(\Database\Seeders\RolePermissionSeeder::class);
});

it('lets a dentist create a treatment', function () {
    $dentist = User::factory()->create()->assignRole('Dentist');
    $patient = Patient::factory()->create();

    $this->actingAs($dentist)->post("/patients/{$patient->id}/treatments", [
        'treatment_date' => now()->toDateString(),
        'tooth_number' => 16,
        'procedure_name' => 'Composite restoration',
        'description' => 'Class II composite on 16',
        'notes' => null,
    ])->assertRedirect();

    $treatment = Treatment::where('patient_id', $patient->id)->first();
    expect($treatment)->not->toBeNull();
    expect($treatment->dentist_id)->toBe($dentist->id);
    expect($treatment->isSigned())->toBeFalse();
});

it('signs a treatment with an SVG signature', function () {
    $dentist = User::factory()->create()->assignRole('Dentist');
    $patient = Patient::factory()->create();
    $treatment = Treatment::factory()->create([
        'patient_id' => $patient->id,
        'dentist_id' => $dentist->id,
    ]);

    $svg = '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 300 150"><path d="M10 80 Q 95 10 180 80 T 290 80" stroke="black" stroke-width="2" fill="none"/></svg>';

    $this->actingAs($dentist)->post("/treatments/{$treatment->id}/sign", [
        'signature_svg' => $svg,
    ])->assertRedirect();

    expect($treatment->fresh()->isSigned())->toBeTrue();
    expect($treatment->fresh()->signature_path)->not->toBeNull();
    expect(Storage::disk('local')->exists($treatment->fresh()->signature_path))->toBeTrue();
});

it('blocks a different dentist from signing', function () {
    $dentist = User::factory()->create()->assignRole('Dentist');
    $other = User::factory()->create()->assignRole('Dentist');
    $treatment = Treatment::factory()->create(['dentist_id' => $dentist->id]);

    $this->actingAs($other)->post("/treatments/{$treatment->id}/sign", ['signature_svg' => '<svg/>'])
        ->assertForbidden();
});

it('blocks receptionists from creating treatments', function () {
    $user = User::factory()->create()->assignRole('Receptionist');
    $patient = Patient::factory()->create();

    $this->actingAs($user)->post("/patients/{$patient->id}/treatments", [
        'treatment_date' => now()->toDateString(),
        'procedure_name' => 'X',
    ])->assertForbidden();
});
```

- [ ] **Step 2: Run to verify failure**

Run: `./vendor/bin/pest tests/Feature/Treatments`
Expected: FAIL — routes 404.

- [ ] **Step 3: Migration**

`database/migrations/2026_08_01_000006_create_treatments_table.php` (blueprint 08):

```php
<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('treatments', function (Blueprint $table) {
            $table->id();
            $table->foreignId('patient_id')->constrained()->cascadeOnDelete();
            $table->foreignId('consultation_id')->nullable()->constrained()->nullOnDelete();
            $table->unsignedTinyInteger('tooth_number')->nullable();   // FDI; null = non-tooth procedure
            $table->string('procedure_name');
            $table->text('description')->nullable();
            $table->text('notes')->nullable();
            $table->foreignId('dentist_id')->constrained('users')->cascadeOnDelete();
            $table->date('treatment_date');
            $table->string('signature_path')->nullable();
            $table->timestamp('signed_at')->nullable();
            $table->timestamps();

            $table->index(['patient_id', 'treatment_date']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('treatments');
    }
};
```

- [ ] **Step 4: Model + factory**

`app/Models/Treatment.php`:

```php
<?php

namespace App\Models;

use Database\Factories\TreatmentFactory;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Spatie\Activitylog\Traits\LogsActivity;

class Treatment extends Model
{
    /** @use HasFactory<TreatmentFactory> */
    use HasFactory, LogsActivity;

    protected $guarded = [];

    protected static $logOnlyDirty = true;

    protected static $logName = 'treatments';

    /**
     * Get the attributes that should be cast.
     *
     * @return array<string, string>
     */
    protected function casts(): array
    {
        return [
            'treatment_date' => 'date:Y-m-d',
            'signed_at' => 'datetime',
        ];
    }

    public function patient(): BelongsTo
    {
        return $this->belongsTo(Patient::class);
    }

    public function consultation(): BelongsTo
    {
        return $this->belongsTo(Consultation::class);
    }

    public function dentist(): BelongsTo
    {
        return $this->belongsTo(User::class, 'dentist_id');
    }

    public function isSigned(): bool
    {
        return $this->signed_at !== null;
    }
}
```

`database/factories/TreatmentFactory.php`:

```php
<?php

namespace Database\Factories;

use App\Models\Patient;
use App\Models\Treatment;
use App\Models\User;
use Illuminate\Database\Eloquent\Factories\Factory;

/**
 * @extends Factory<Treatment>
 */
class TreatmentFactory extends Factory
{
    public function definition(): array
    {
        return [
            'patient_id' => Patient::factory(),
            'consultation_id' => null,
            'tooth_number' => fake()->randomElement([16, 17, 26, 36, 46, null]),
            'procedure_name' => fake()->randomElement(['Composite restoration', 'Scaling and polishing', 'Extraction', 'Root canal treatment', 'Crown placement']),
            'description' => fake()->optional()->sentence(6),
            'notes' => fake()->optional()->sentence(),
            'dentist_id' => User::factory(),
            'treatment_date' => fake()->dateTimeBetween('-6 months', 'now')->format('Y-m-d'),
            'signature_path' => null,
            'signed_at' => null,
        ];
    }
}
```

- [ ] **Step 5: SignatureStorageService (minimal — hardened in Phase 3.1)**

`app/Services/SignatureStorageService.php`:

```php
<?php

namespace App\Services;

use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Str;

final class SignatureStorageService
{
    /**
     * Store an SVG signature string on the local disk.
     * Basic guard in Phase 2; full sanitization (libxml parse, script strip) lands in Phase 3.
     *
     * @return string relative path (e.g. signatures/treatments/1.svg)
     */
    public function store(string $svg, string $path): string
    {
        abort_unless(
            Str::startsWith(trim($svg), '<svg'),
            422,
            'Invalid signature payload.'
        );
        abort_unless(
            ! str_contains($svg, '<script') && ! str_contains($svg, 'onload'),
            422,
            'Signature payload contains disallowed content.'
        );

        Storage::disk('local')->put($path, $svg);

        return $path;
    }
}
```

- [ ] **Step 6: Service**

`app/Services/TreatmentService.php`:

```php
<?php

namespace App\Services;

use App\Models\Treatment;
use App\Models\User;

final class TreatmentService
{
    public function __construct(private readonly SignatureStorageService $signatures) {}

    public function create(array $data, User $dentist): Treatment
    {
        $treatment = Treatment::create([...$data, 'dentist_id' => $dentist->id]);
        activity()->performedOn($treatment)->causedBy($dentist)->log('treatment.created');

        return $treatment;
    }

    public function sign(Treatment $treatment, string $signatureSvg, User $dentist): Treatment
    {
        $path = $this->signatures->store($signatureSvg, "signatures/treatments/{$treatment->id}.svg");
        $treatment->update(['signature_path' => $path, 'signed_at' => now()]);
        activity()->performedOn($treatment)->causedBy($dentist)->log('treatment.signed');

        return $treatment;
    }
}
```

- [ ] **Step 7: Policy**

`app/Policies/TreatmentPolicy.php`:

```php
<?php

namespace App\Policies;

use App\Models\Treatment;
use App\Models\User;

class TreatmentPolicy
{
    public function viewAny(User $user): bool
    {
        return $user->can('treatments.view');
    }

    public function view(User $user, Treatment $treatment): bool
    {
        return $user->can('treatments.view');
    }

    public function create(User $user): bool
    {
        return $user->can('treatments.create');
    }

    /** Authoring dentist or admin only (blueprint 08). */
    public function update(User $user, Treatment $treatment): bool
    {
        return $user->can('treatments.update')
            && ($user->hasRole('Administrator') || $treatment->dentist_id === $user->id);
    }

    /** Authoring dentist or admin only. */
    public function sign(User $user, Treatment $treatment): bool
    {
        return $user->can('treatments.sign')
            && ($user->hasRole('Administrator') || $treatment->dentist_id === $user->id);
    }
}
```

- [ ] **Step 8: Request**

`app/Http/Requests/StoreTreatmentRequest.php`:

```php
<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;

class StoreTreatmentRequest extends FormRequest
{
    /**
     * @return array<string, array<int, mixed>>
     */
    public function rules(): array
    {
        return [
            'treatment_date' => ['required', 'date'],
            'tooth_number' => ['nullable', 'integer', 'min:11', 'max:85'],
            'procedure_name' => ['required', 'string', 'max:255'],
            'description' => ['nullable', 'string', 'max:2000'],
            'notes' => ['nullable', 'string', 'max:1000'],
            'consultation_id' => ['nullable', 'exists:consultations,id'],
        ];
    }
}
```

- [ ] **Step 9: Controller**

`app/Http/Controllers/TreatmentsController.php`:

```php
<?php

namespace App\Http\Controllers;

use App\Http\Requests\StoreTreatmentRequest;
use App\Models\Patient;
use App\Models\Treatment;
use App\Services\TreatmentService;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Redirect;

class TreatmentsController extends Controller
{
    public function __construct(private readonly TreatmentService $service) {}

    public function store(StoreTreatmentRequest $request, Patient $patient): RedirectResponse
    {
        $this->authorize('create', Treatment::class);

        $this->service->create([...$request->validated(), 'patient_id' => $patient->id], $request->user());

        return Redirect::back();
    }

    public function sign(Request $request, Treatment $treatment): RedirectResponse
    {
        $this->authorize('sign', $treatment);

        $request->validate([
            'signature_svg' => ['required', 'string'],
        ]);

        $this->service->sign($treatment, $request->string('signature_svg'), $request->user());

        return Redirect::back();
    }
}
```

- [ ] **Step 10: Routes**

```php
use App\Http\Controllers\TreatmentsController;

Route::middleware(['auth', 'verified', 'permission:treatments.create'])
    ->post('/patients/{patient}/treatments', [TreatmentsController::class, 'store'])
    ->name('treatments.store');
Route::middleware(['auth', 'verified', 'permission:treatments.sign'])
    ->post('/treatments/{treatment}/sign', [TreatmentsController::class, 'sign'])
    ->name('treatments.sign');
```

- [ ] **Step 11: SignaturePadModal component**

`resources/js/Components/SignaturePadModal.vue`:

- Props: `show: Boolean`, `title: String`, `confirmLabel: String` (default 'Accept signature').
- Emits: `close`, `confirm(svg)`.
- Uses `vue-signature-pad` (installed). Wraps it in the project `Modal` component.
- Canvas config: `:height="150"`, `:width="300"` minimum, responsive (`class="w-full"`), options `{ penColor: '#1f2937', backgroundColor: 'white' }` — the pen color is a canvas drawing color (not a CSS class/hex-in-class; this is a JS config value, allowed).
- Buttons ≥44px: "Clear" (outline) + "Accept signature" (primary). Disabled until canvas has ink (`isEmpty()` on the pad ref, computed via a `hasInk` ref updated on `@end` / `@clear` events).
- Export: `pad.value.saveSignature()` (returns SVG data URL string); strip the `data:image/svg+xml;utf8,` prefix and `decodeURIComponent` before emitting — the backend expects a raw SVG string starting with `<svg`.

- [ ] **Step 12: TreatmentForm + Show.vue Treatments tab**

`resources/js/Components/Wizard/TreatmentForm.vue` (reused in Show.vue and wizard):
- Props: `patientId`, `consultations` (for optional link select), `dentalOptions` (tooth datalist 11–85 + null option "Non-tooth procedure").
- Fields: treatment_date (date, default today), tooth_number (select with options: '' non-tooth, 11..85 from `DentitionType::meta()['adult']['teeth']` — page passes `toothOptions` array), procedure_name (input with datalist of common procedures: Scaling and polishing, Composite restoration, Amalgam filling, Extraction, Root canal treatment, Crown placement, Denture fitting, Sealant application), description/notes textareas.
- Submit → `useForm().post(route('treatments.store', patientId))` + toast + reset.

Modify `PatientsController::show` to pass `treatments` (with dentist + consultation) and `toothOptions`. In `Show.vue`:
- Treatments tab (wired): inline list — date, procedure_name, tooth number badge, dentist, signed Badge (`success` "Signed" / `warning` "Pending"); row tap → detail (description/notes + embedded signature SVG via `<img :src="'/storage/' + signature_path">` when signed — create the storage symlink with `php artisan storage:link`); "Add treatment" button when `can.treatments?.create` opens inline form (TreatmentForm component); "Sign" button when `can.treatments?.sign` and treatment not signed → opens SignaturePadModal → on confirm `useForm().post(route('treatments.sign', id), { signature_svg: svg })` + toast.

- [ ] **Step 13: Verify pass + storage link**

Run: `./vendor/bin/pest tests/Feature/Treatments` → PASS. Run `php artisan storage:link` (idempotent).

- [ ] **Step 14: Pint + commit**

```bash
./vendor/bin/pint && ./vendor/bin/pest
git add -A && git commit -m "feat: treatments module with dentist e-signature (SVG)"
```

---

## Task 6: Wizard container (7-step stepper)

**Files:**
- Create: `resources/js/Pages/Wizard/Index.vue`, `resources/js/Stores/wizard.js`
- Create: `app/Http/Controllers/WizardController.php`
- Modify: `routes/web.php`, `resources/js/Components/Sidebar.vue` (add Wizard nav item)
- Test: `tests/Feature/WizardTest.php`

- [ ] **Step 1: Write the failing feature test**

`tests/Feature/WizardTest.php`:

```php
<?php

use App\Models\Consultation;
use App\Models\Patient;
use App\Models\User;

uses(RefreshDatabase::class);

beforeEach(function () {
    $this->seed(\Database\Seeders\RolePermissionSeeder::class);
});

it('renders the wizard for receptionists with a fresh patient step', function () {
    $user = User::factory()->create()->assignRole('Receptionist');

    $this->actingAs($user)->get('/wizard')
        ->assertOk()
        ->assertInertia(fn ($page) => $page
            ->component('Wizard/Index')
            ->has('patient')
            ->has('steps', 7));
});

it('resumes an existing patient at the first incomplete step', function () {
    $dentist = User::factory()->create()->assignRole('Dentist');
    $patient = Patient::factory()->create();

    $this->actingAs($dentist)->get("/wizard/{$patient->id}")
        ->assertOk()
        ->assertInertia(fn ($page) => $page
            ->component('Wizard/Index')
            ->where('patient.id', $patient->id)
            ->where('resumeStep', 1)); // step index: 0 patient, 1 medical history, ...

    // After saving a consultation, resume should land on the chart step
    Consultation::factory()->create(['patient_id' => $patient->id, 'dentist_id' => $dentist->id]);

    $this->actingAs($dentist)->get("/wizard/{$patient->id}")
        ->assertInertia(fn ($page) => $page->where('resumeStep', 4)); // 4 = dental chart
});
```

- [ ] **Step 2: Run to verify failure**

Run: `./vendor/bin/pest tests/Feature/WizardTest.php`
Expected: FAIL — route 404.

- [ ] **Step 3: Controller**

`app/Http/Controllers/WizardController.php`:

```php
<?php

namespace App\Http\Controllers;

use App\Models\Patient;
use Illuminate\Http\Request;
use Inertia\Inertia;
use Inertia\Response;

class WizardController extends Controller
{
    /** Steps per blueprint Flow 1 (spec tail): patient, medical history, waiver, signature, consultation, dental chart, treatment. */
    public const STEPS = [
        ['key' => 'patient', 'label' => 'Patient'],
        ['key' => 'medical_history', 'label' => 'Medical history'],
        ['key' => 'waiver', 'label' => 'Waiver'],
        ['key' => 'signature', 'label' => 'Signature'],
        ['key' => 'consultation', 'label' => 'Consultation'],
        ['key' => 'dental_chart', 'label' => 'Dental chart'],
        ['key' => 'treatment', 'label' => 'Treatment'],
    ];

    public function index(Request $request, ?Patient $patient = null): Response
    {
        if ($patient === null) {
            return Inertia::render('Wizard/Index', [
                'patient' => null,
                'steps' => self::STEPS,
                'resumeStep' => 0,
                'sexOptions' => \App\Enums\Sex::meta(),
                'civilStatusOptions' => \App\Enums\CivilStatus::meta(),
                'consultationOptions' => [
                    'periodontal' => \App\Models\Consultation::periodontalOptions(),
                    'occlusion' => \App\Models\Consultation::occlusionOptions(),
                    'appliances' => \App\Models\Consultation::applianceOptions(),
                    'tmd' => \App\Models\Consultation::tmdOptions(),
                ],
                'toothOptions' => \App\Enums\DentitionType::meta()['adult']['teeth'],
                'statusOptions' => \App\Enums\AppointmentStatus::meta(),
            ]);
        }

        $medicalHistory = $patient->medicalHistory;
        $hasConsultation = $patient->consultations()->exists();
        $hasChart = $patient->chartEntries()->exists();
        $hasTreatment = $patient->treatments()->exists();

        $resumeStep = match (true) {
            $medicalHistory === null => 1,
            ! $hasConsultation => 4,
            ! $hasChart => 5,
            ! $hasTreatment => 6,
            default => 0,
        };

        return Inertia::render('Wizard/Index', [
            'patient' => $patient,
            'steps' => self::STEPS,
            'resumeStep' => $resumeStep,
            'medicalHistory' => $medicalHistory,
            'sexOptions' => \App\Enums\Sex::meta(),
            'civilStatusOptions' => \App\Enums\CivilStatus::meta(),
            'consultationOptions' => [
                'periodontal' => \App\Models\Consultation::periodontalOptions(),
                'occlusion' => \App\Models\Consultation::occlusionOptions(),
                'appliances' => \App\Models\Consultation::applianceOptions(),
                'tmd' => \App\Models\Consultation::tmdOptions(),
            ],
            'toothOptions' => \App\Enums\DentitionType::meta()['adult']['teeth'],
            'statusOptions' => \App\Enums\AppointmentStatus::meta(),
        ]);
    }
}
```

- [ ] **Step 4: Route**

```php
use App\Http\Controllers\WizardController;

Route::middleware(['auth', 'verified'])->get('/wizard/{patient?}', [WizardController::class, 'index'])->name('wizard.index');
```

(No single permission — each step's POST is gated by its own permission; the wizard page itself renders for any logged-in staff. Add `->whereNumber('patient')` constraint.)

- [ ] **Step 5: Pinia store**

`resources/js/Stores/wizard.js`:

```js
import { defineStore } from 'pinia'

export const useWizardStore = defineStore('wizard', {
    state: () => ({
        step: 0,
        patientId: null,
        completed: {}, // stepKey -> true
    }),
    actions: {
        start(patientId, resumeStep) {
            this.patientId = patientId
            this.step = resumeStep
            this.completed = {}
        },
        go(step) {
            this.step = step
        },
        markComplete(stepKey) {
            this.completed[stepKey] = true
        },
        reset() {
            this.step = 0
            this.patientId = null
            this.completed = {}
        },
    },
})
```

- [ ] **Step 6: Wizard page**

`resources/js/Pages/Wizard/Index.vue` — structure:

- `defineOptions({ layout: AppLayout })`, props: `patient`, `steps`, `resumeStep`, `medicalHistory`, `sexOptions`, `civilStatusOptions`, `consultationOptions`, `toothOptions`, `statusOptions`.
- On mount: `wizardStore.start(patient?.id ?? null, resumeStep)`.
- **Stepper header**: 7 numbered circles (≥44px) with labels under; completed steps = brand fill + check icon; current = ring; locked (waiver/signature) = gray + lock icon (label "Phase 3"); tap a completed/current step to navigate (locked steps do nothing).
- **Step content** (keep-alive not needed; each step is a component block with `v-show` on `wizardStore.step`):
  1. **Patient**: if `patient` exists show summary card (name, number, Edit link) + "Continue" button; else the patient form (reuse the Create.vue form fields inline — first_name/middle_name/last_name/sex/birth_date/civil_status/nationality/occupation/contact_number/address/email/emergency fields) → `useForm().post(route('patients.store'))` with `onSuccess: (page) => { wizardStore.patientId = page.props.patient.id; advance() }` — the patients.store route redirects to `patients.show` by default; for the wizard, pass `?wizard=1`? **Simpler:** add `'wizard' => 1` to the POST body is not in the request rules (extra fields are ignored by `validated()`), then in `PatientsController::store`, `if ($request->boolean('wizard')) return Redirect::route('wizard.index', $patient);` — apply this one-line change.
  2. **Medical history**: reuse the medical-history editor (pills) from Show.vue — extract to `resources/js/Components/Wizard/MedicalHistoryForm.vue` (props `patientId`, `medicalHistory`, `withPda: true`) and use it in both Show.vue and the wizard; on success `wizardStore.markComplete('medical_history')` + advance.
  3. **Waiver**: locked placeholder card ("Informed consent & waiver arrive in Phase 3").
  4. **Signature**: locked placeholder.
  5. **Consultation**: `Wizard/ConsultationForm.vue` (from Task 1) with consultationOptions; on success markComplete + advance.
  6. **Dental chart**: embed `ToothChart.vue` + condition/restoration legend (readonly=false when `dental-chart.update`, else readonly) — reuse the chart page's interaction logic (POST entries per click); "Continue to treatment" button (only enabled when at least one entry exists? no — allow skip; chart may legitimately be empty) → advance.
  7. **Treatment**: `Wizard/TreatmentForm.vue` (Task 5); after creating the first treatment show "Treatment record created" + optional "Sign now" (opens SignaturePadModal inline, same as Show.vue) + "Finish" button → `wizardStore.reset()` + `router.visit(route('patients.show', patient.id))`.
- **Progress persistence**: the store derives nothing from the server except `resumeStep` on mount; server-side entities are the source of truth (each step's entity row).
- Navigation bar: "Back" (outline, disabled on step 0) + "Next" (primary; label "Save & continue") — Next on steps 1/2/5/7 submits the current step's form (each form exposes submit via a shared submit function or the page triggers the child's form post via exposed method `defineExpose({ submit })`). Keep it simple: each step component renders its own Save & continue button; the page shows Back + step indicator.

- [ ] **Step 7: Sidebar**

In `resources/js/Components/Sidebar.vue`, add a nav item "New intake" (icon `ClipboardPlus` from lucide-vue-next) linking `route('wizard.index')` — visible to all logged-in staff (permission-free route). Place above Patients. Follow the existing nav item markup/classes.

- [ ] **Step 8: Verify pass + browser check**

Run: `./vendor/bin/pest tests/Feature/WizardTest.php` → PASS. `npm run build` → clean.
Browser (admin@clinic.test / password): `/wizard` → stepper renders 7 steps, steps 3-4 locked; register a new patient through step 1 → lands on step 2; save medical history → step 5; save consultation → step 6; click a condition + tooth on the chart; create treatment → finish → patient record. Verify no console errors, no horizontal scroll at 1024×768.

- [ ] **Step 9: Pint + commit**

```bash
./vendor/bin/pint && ./vendor/bin/pest
git add -A && git commit -m "feat: 7-step intake wizard container with per-step persistence"
```

---

## Self-Review

- **Spec coverage:** Consultations (blueprint 06 + PDA Page 3 exam fields) ✓ · ToothChart SVG (blueprint 07 rendering rules, PDA mirror layout) ✓ · Dental chart backend (append-only entries, projection service, history-as-of) ✓ · PDA legend/restoration enums (approved deviation) ✓ · Medical history + patients PDA expansion (master plan §4) ✓ · Treatments (blueprint 08, sign stub) ✓ · Wizard container (Flow 1, steps 1-2 + 5-7 wired, 3-4 locked) ✓.
- **Placeholders:** none — all migrations/models/tests contain concrete code; Vue pages reference existing patterns (Show.vue medical-history editor, Appointments/Index.vue modal usage).
- **Type consistency:** `DentalChartService::currentState(int, string): array` shape `[tooth => ['whole' => {condition, restoration}, 'surfaces' => [surface => {condition, restoration}]]]` used by controller, page, and ToothChart props identically. `ToothCondition::meta()['caries']['color']` = `cond-caries` token (app.css). `RecordToothConditionAction::handle(patient, tooth, dentition, condition, surface, restoration, recordedAt, notes, actor)` matches controller call. Wizard resume order matches Flow 1 step order.
- **PDA alignment:** FDI ranges from `docs/reference/pda-dental-chart.md` enforced in `DentitionType::isValidTooth`; condition/restoration codes match the PDA legend verbatim; medical history + patient columns match PDA Page 1; consultation exam fields match PDA Page 3; billing columns remain out of scope (Q8).
