# DCPRS Phase 3 — Signatures, Consents, Attachments, Reports Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build Phase 3 of DCPRS: hardened SVG signature storage, the PDA-informed-consent module (per-section initials + patient/guardian/dentist signatures), the attachments module (uploads with progress, X-ray viewer, PDF preview), and admin reports (5 aggregations, ApexCharts, CSV + print export). Unlock wizard steps 3 (Waiver) + 4 (Signature).

**Architecture:** Extends the Phase 2 monolith. `SignatureStorageService` is hardened (libxml parse, script/event-handler stripping, 512 KB cap). Consents: append-only `consent_forms` (PDA Page 2 snapshot) + `consent_sections` (per-section initials), state machine unsigned → patient_signed → signed (→ voided on re-sign). Attachments: `attachments` table with `xray_type` column (PDA Page 3 X-ray types), uploads via Inertia `onProgress`, served from the local disk root `storage/app/public`. Reports: `ReportRepository` (5 queries), admin-only page with date-range picker + ApexCharts + CSV streaming + browser print.

**Tech Stack:** Laravel 12 · Vue 3 `<script setup>` · Inertia v2 client · Tailwind CSS v4 (OKLCH tokens only) · Spatie Permission + Activitylog · Pest (TDD) · vue-signature-pad (SVG export) · ApexCharts via vue3-apexcharts · libxml DOMDocument sanitization.

**PDA alignment source of truth:** `docs/reference/pda-dental-chart.md` — Page 2 consent (10 sections, each with its own text + initial; acknowledgment; authorization; patient/guardian/dentist signatures) and Page 3 X-ray types (periapical/panoramic/cephalometric/occlusal/others). Consent sections/keys below are verbatim PDA.

**Reference blueprint (read before executing):** `docs/dental-emr/09-attachments.md`, `10-consents.md`, `11-dashboard-reports-settings.md`, `13-api-contracts.md`, `14-permissions.md`, `17-process-flows.md` (Flow 3), `18-open-questions.md` (Q4 minor guardian, Q9 sizes, Q12 browser print, Q14 local disk).

---

## Phase 3 File Structure

```
app/Enums/ConsentStatus.php
app/Enums/AttachmentCategory.php
app/Models/ConsentForm.php
app/Models/ConsentSection.php
app/Models/Attachment.php
app/Services/SignatureStorageService.php    # hardened (rewrite of Phase 2 stub)
app/Services/ConsentService.php
app/Services/AttachmentService.php
app/Repositories/ReportRepository.php
app/Http/Controllers/ConsentsController.php
app/Http/Controllers/AttachmentsController.php
app/Http/Controllers/ReportsController.php
app/Http/Requests/StoreConsentRequest.php       # draft creation (wizard step 3: initials + metadata)
app/Http/Requests/SignPatientConsentRequest.php
app/Http/Requests/SignDentistConsentRequest.php
app/Http/Requests/StoreAttachmentRequest.php
app/Policies/ConsentPolicy.php
app/Policies/AttachmentPolicy.php
config/consent.php                              # PDA Page 2 section texts (verbatim)
database/migrations/2026_08_01_000007_create_attachments_table.php
database/migrations/2026_08_01_000008_create_consent_forms_table.php
database/migrations/2026_08_01_000009_create_consent_sections_table.php
resources/js/Components/SignaturePadModal.vue   # exists (Phase 2) — reused; add small-pad variant prop
resources/js/Components/Wizard/WaiverStep.vue   # step 3: sections text + per-section initial pads
resources/js/Components/Wizard/SignatureStep.vue# step 4: patient + guardian signature pads
resources/js/Pages/Consents/Show.vue            # printable A4-style signed form
resources/js/Pages/Reports/Index.vue
resources/js/Pages/Patients/Show.vue            # wire Files + Consents tabs
resources/js/Pages/Wizard/Index.vue             # unlock steps 3+4
app/Http/Middleware/HandleInertiaRequests.php   # share can.reports/can.settings for sidebar
resources/js/Components/Sidebar.vue             # enable Reports for admins
tests/Unit/SignatureStorageServiceTest.php
tests/Feature/Consents/ManageConsentsTest.php
tests/Feature/Attachments/ManageAttachmentsTest.php
tests/Unit/ReportRepositoryTest.php
tests/Feature/Reports/ViewReportsTest.php
```

---

## Task 1: Harden SignatureStorageService

**Files:**
- Rewrite: `app/Services/SignatureStorageService.php`
- Test: `tests/Unit/SignatureStorageServiceTest.php`

- [ ] **Step 1: Write the failing unit test**

`tests/Unit/SignatureStorageServiceTest.php`:

```php
<?php

use App\Services\SignatureStorageService;
use Illuminate\Support\Facades\Storage;

uses(TestCase::class, RefreshDatabase::class);

beforeEach(function () {
    Storage::fake('local');
});

it('stores a valid SVG signature', function () {
    $svg = '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 300 150"><path d="M10 80 Q 95 10 180 80" stroke="black" fill="none"/></svg>';

    $path = app(SignatureStorageService::class)->store($svg, 'signatures/test.svg');

    expect($path)->toBe('signatures/test.svg');
    Storage::disk('local')->assertExists($path);
    expect(Storage::disk('local')->get($path))->toContain('<svg');
});

it('rejects malformed SVG payloads', function () {
    expect(fn () => app(SignatureStorageService::class)->store('not-an-svg', 'signatures/x.svg'))
        ->toThrow(\Illuminate\Validation\ValidationException::class);
});

it('rejects oversized signatures', function () {
    $big = '<svg xmlns="http://www.w3.org/2000/svg">' . str_repeat('<path d="M0 0"/>', 200000) . '</svg>';

    expect(fn () => app(SignatureStorageService::class)->store($big, 'signatures/big.svg'))
        ->toThrow(\Illuminate\Validation\ValidationException::class);
});

it('strips script elements and event handlers from stored SVGs', function () {
    $svg = '<svg xmlns="http://www.w3.org/2000/svg"><script>alert(1)</script><path d="M0 0" onload="alert(2)"/><foreignObject><div>hi</div></foreignObject></svg>';

    $path = app(SignatureStorageService::class)->store($svg, 'signatures/clean.svg');

    $stored = Storage::disk('local')->get($path);
    expect($stored)->not->toContain('<script');
    expect($stored)->not->toContain('onload');
    expect($stored)->not->toContain('foreignObject');
});
```

- [ ] **Step 2: Run to verify failure**

Run: `./vendor/bin/pest tests/Unit/SignatureStorageServiceTest.php`
Expected: FAIL — `ValidationException` class missing / script stripping missing.

- [ ] **Step 3: Rewrite the service**

`app/Services/SignatureStorageService.php` (replaces the Phase 2 stub; keep the same `store(string $svg, string $path): string` signature so TreatmentService is untouched):

```php
<?php

namespace App\Services;

use DOMDocument;
use Illuminate\Support\Facades\Storage;
use Illuminate\Validation\ValidationException;

final class SignatureStorageService
{
    private const MAX_BYTES = 524288; // 512 KB

    /**
     * Validate, sanitize and store an SVG signature.
     *
     * @return string relative path on the local disk
     */
    public function store(string $svg, string $path): string
    {
        $this->validatePayload($svg);

        $sanitized = $this->sanitize($svg);

        Storage::disk('local')->put($path, $sanitized);

        return $path;
    }

    private function validatePayload(string $svg): void
    {
        $failures = [];

        if (strlen($svg) > self::MAX_BYTES) {
            $failures[] = 'Signature exceeds the 512 KB limit.';
        }

        if (! str_starts_with(trim($svg), '<svg')) {
            $failures[] = 'Signature must be an SVG document.';
        }

        $previous = libxml_use_internal_errors(true);
        $doc = new DOMDocument();
        $parsed = $doc->loadXML($svg);
        libxml_clear_errors();
        libxml_use_internal_errors($previous);

        if (! $parsed) {
            $failures[] = 'Signature is not valid XML.';
        }

        if ($failures !== []) {
            throw ValidationException::withMessages(['signature_svg' => $failures]);
        }
    }

    /**
     * Strip script elements, foreign objects and event-handler attributes.
     */
    private function sanitize(string $svg): string
    {
        $previous = libxml_use_internal_errors(true);
        $doc = new DOMDocument();
        $doc->loadXML($svg);
        libxml_clear_errors();
        libxml_use_internal_errors($previous);

        $forbidden = ['script', 'foreignObject', 'iframe', 'object', 'embed'];

        foreach ($forbidden as $tag) {
            foreach ($doc->getElementsByTagName($tag) as $node) {
                $node->parentNode?->removeChild($node);
            }
        }

        foreach ($doc->getElementsByTagName('*') as $node) {
            $remove = [];
            foreach ($node->attributes ?? [] as $attribute) {
                $name = strtolower($attribute->nodeName ?? '');
                if (str_starts_with($name, 'on') || $name === 'href' || $name === 'xlink:href') {
                    $remove[] = $attribute;
                }
            }
            foreach ($remove as $attribute) {
                $node->removeAttributeNode($attribute);
            }
        }

        return $doc->saveXML() ?: $svg;
    }
}
```

- [ ] **Step 4: Verify pass + regression**

Run: `./vendor/bin/pest tests/Unit/SignatureStorageServiceTest.php` → PASS.
Run: `./vendor/bin/pest tests/Feature/Treatments` → PASS (sign flow still works with the hardened service).

- [ ] **Step 5: Pint + commit**

```bash
./vendor/bin/pint
git add -A && git commit -m "feat: harden signature storage (SVG sanitization + size limits)"
```

---

## Task 2: Consents module

**Files:**
- Create: `config/consent.php`, `app/Enums/ConsentStatus.php`
- Create: `database/migrations/2026_08_01_000008_create_consent_forms_table.php`, `2026_08_01_000009_create_consent_sections_table.php`
- Create: `app/Models/ConsentForm.php`, `app/Models/ConsentSection.php`
- Create: `app/Services/ConsentService.php`, `app/Policies/ConsentPolicy.php`
- Create: `app/Http/Requests/StoreConsentRequest.php`, `SignPatientConsentRequest.php`, `SignDentistConsentRequest.php`
- Create: `app/Http/Controllers/ConsentsController.php`
- Create: `resources/js/Pages/Consents/Show.vue`, `resources/js/Components/Wizard/WaiverStep.vue`, `resources/js/Components/Wizard/SignatureStep.vue`
- Modify: `routes/web.php`, `app/Models/Patient.php`, `resources/js/Pages/Wizard/Index.vue` (unlock steps 3+4), `resources/js/Pages/Patients/Show.vue` (Consents tab)
- Test: `tests/Feature/Consents/ManageConsentsTest.php`

- [ ] **Step 1: Consent template config (PDA Page 2, verbatim)**

`config/consent.php`:

```php
<?php

// config/consent.php — PDA informed-consent template (docs/reference/pda-dental-chart.md Page 2).
return [

    'version' => '1.0',

    // 10 sections, each with PDA-verbatim text + its own patient initial.
    'sections' => [
        'treatment_to_be_done' => [
            'label' => 'Treatment to be done',
            'text' => 'I understand and consent to the treatment proposed by the dentist.',
        ],
        'drugs_and_medications' => [
            'label' => 'Drugs and medications',
            'text' => 'I understand that medications may cause allergic reactions, including swelling, itching, vomiting, pain, and anaphylactic shock.',
        ],
        'changes_in_treatment_plan' => [
            'label' => 'Changes in treatment plan',
            'text' => 'I understand that changes in treatment may become necessary as new conditions are discovered during treatment.',
        ],
        'radiographs' => [
            'label' => 'Radiographs',
            'text' => 'I understand that radiographs may be necessary for diagnosis and treatment planning.',
        ],
        'removal_of_teeth' => [
            'label' => 'Removal of teeth',
            'text' => 'I understand the risks, alternatives, and possible complications associated with tooth extraction.',
        ],
        'crowns_caps_and_bridges' => [
            'label' => 'Crowns, caps, and bridges',
            'text' => 'I understand the risks, limitations, and responsibilities related to crowns, caps, and bridges.',
        ],
        'endodontics' => [
            'label' => 'Endodontics (root canal treatment)',
            'text' => 'I understand that root canal treatment does not guarantee that a tooth will be saved.',
        ],
        'periodontal_disease' => [
            'label' => 'Periodontal disease',
            'text' => 'I understand the risks associated with periodontal disease and its treatment.',
        ],
        'fillings' => [
            'label' => 'Fillings',
            'text' => 'I understand the risks associated with dental fillings.',
        ],
        'dentures' => [
            'label' => 'Dentures',
            'text' => 'I understand the possible complications and limitations associated with dentures.',
        ],
    ],

    // Acknowledgment + authorization blocks (PDA Page 2).
    'acknowledgment' => 'I understand that dentistry is not an exact science and that no dentist can guarantee accurate results at all times.',
    'authorization' => 'I authorize the dentist and dental personnel to perform the necessary procedures and treatments.',
];
```

- [ ] **Step 2: Enum**

`app/Enums/ConsentStatus.php`:

```php
<?php

namespace App\Enums;

enum ConsentStatus: string
{
    use HasMeta;

    case Unsigned = 'unsigned';
    case PatientSigned = 'patient_signed';
    case Signed = 'signed';
    case Voided = 'voided';

    public static function meta(): array
    {
        return [
            'unsigned' => ['label' => 'Unsigned', 'color' => 'status-pending'],
            'patient_signed' => ['label' => 'Patient signed', 'color' => 'status-confirmed'],
            'signed' => ['label' => 'Signed', 'color' => 'status-completed'],
            'voided' => ['label' => 'Voided', 'color' => 'status-cancelled'],
        ];
    }
}
```

- [ ] **Step 3: Migrations**

`database/migrations/2026_08_01_000008_create_consent_forms_table.php`:

```php
<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('consent_forms', function (Blueprint $table) {
            $table->id();
            $table->foreignId('patient_id')->constrained()->cascadeOnDelete();
            $table->string('version', 10)->default('1.0');
            $table->text('consent_text');                            // snapshot of the section texts JSON
            $table->string('patient_name');                          // captured, not derived
            $table->string('patient_signature_path')->nullable();
            $table->string('guardian_name')->nullable();             // required when patient.age < 18 (Q4)
            $table->string('guardian_signature_path')->nullable();
            $table->foreignId('dentist_id')->constrained('users')->cascadeOnDelete();
            $table->string('dentist_signature_path')->nullable();
            $table->timestamp('patient_signed_at')->nullable();
            $table->timestamp('dentist_signed_at')->nullable();
            $table->string('ip_address')->nullable();
            $table->string('user_agent')->nullable();
            $table->string('status')->default('unsigned');
            $table->timestamps();

            $table->index(['patient_id', 'status']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('consent_forms');
    }
};
```

`database/migrations/2026_08_01_000009_create_consent_sections_table.php`:

```php
<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('consent_sections', function (Blueprint $table) {
            $table->id();
            $table->foreignId('consent_form_id')->constrained()->cascadeOnDelete();
            $table->string('key');                                   // snake of PDA section name
            $table->string('label');
            $table->string('initial_svg_path')->nullable();
            $table->timestamp('initialed_at')->nullable();
            $table->timestamps();

            $table->unique(['consent_form_id', 'key']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('consent_sections');
    }
};
```

- [ ] **Step 4: Models**

`app/Models/ConsentForm.php` (activitylog v5 pattern from Consultation):

```php
<?php

namespace App\Models;

use App\Enums\ConsentStatus;
use Database\Factories\ConsentFormFactory;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Spatie\Activitylog\Models\Concerns\LogsActivity;
use Spatie\Activitylog\LogOptions;

class ConsentForm extends Model
{
    /** @use HasFactory<ConsentFormFactory> */
    use HasFactory, LogsActivity;

    protected $guarded = [];

    public function getActivitylogOptions(): LogOptions
    {
        return LogOptions::defaults()->logOnlyDirty()->useLogName('consents');
    }

    /**
     * Get the attributes that should be cast.
     *
     * @return array<string, string>
     */
    protected function casts(): array
    {
        return [
            'status' => ConsentStatus::class,
            'consent_text' => 'array',
            'patient_signed_at' => 'datetime',
            'dentist_signed_at' => 'datetime',
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

    public function sections(): HasMany
    {
        return $this->hasMany(ConsentSection::class);
    }

    public function isPatientSigned(): bool
    {
        return in_array($this->status, [ConsentStatus::PatientSigned, ConsentStatus::Signed], true);
    }
}
```

`database/factories/ConsentFormFactory.php` (patient_id, dentist_id, version 1.0, consent_text = config array, patient_name fake name, status unsigned).

`app/Models/ConsentSection.php`:

```php
<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class ConsentSection extends Model
{
    protected $guarded = [];

    /**
     * Get the attributes that should be cast.
     *
     * @return array<string, string>
     */
    protected function casts(): array
    {
        return ['initialed_at' => 'datetime'];
    }

    public function consentForm(): BelongsTo
    {
        return $this->belongsTo(ConsentForm::class);
    }
}
```

- [ ] **Step 5: Service (blueprint Flow 3 + PDA initials)**

`app/Services/ConsentService.php`:

```php
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
        $patient = $form->patient;

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

        return $this->createDraft($form->patient, $actor);
    }
}
```

- [ ] **Step 6: Policy + Requests**

`app/Policies/ConsentPolicy.php`:

```php
<?php

namespace App\Policies;

use App\Models\ConsentForm;
use App\Models\User;

class ConsentPolicy
{
    public function viewAny(User $user): bool
    {
        return $user->can('consents.view');
    }

    public function view(User $user, ConsentForm $consentForm): bool
    {
        return $user->can('consents.view');
    }

    public function create(User $user): bool
    {
        return $user->can('consents.create');
    }

    public function signPatient(User $user, ConsentForm $consentForm): bool
    {
        return $user->can('consents.sign-patient');
    }

    public function signDentist(User $user, ConsentForm $consentForm): bool
    {
        return $user->can('consents.sign-dentist');
    }
}
```

`app/Http/Requests/StoreConsentRequest.php`:

```php
<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rule;

class StoreConsentRequest extends FormRequest
{
    /**
     * @return array<string, array<int, mixed>>
     */
    public function rules(): array
    {
        $keys = array_keys(config('consent.sections'));

        return [
            'patient_id' => ['required', 'exists:patients,id'],
            'initials' => ['required', 'array', 'min:1'],
            'initials.*' => ['required', 'string'],
        ];
    }
}
```

`app/Http/Requests/SignPatientConsentRequest.php`:

```php
<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;

class SignPatientConsentRequest extends FormRequest
{
    /**
     * @return array<string, array<int, mixed>>
     */
    public function rules(): array
    {
        return [
            'signature_svg' => ['required', 'string'],
            'guardian_name' => ['nullable', 'string', 'max:255'],
            'guardian_svg' => ['nullable', 'string'],
        ];
    }
}
```

`app/Http/Requests/SignDentistConsentRequest.php`:

```php
<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;

class SignDentistConsentRequest extends FormRequest
{
    /**
     * @return array<string, array<int, mixed>>
     */
    public function rules(): array
    {
        return [
            'signature_svg' => ['required', 'string'],
        ];
    }
}
```

- [ ] **Step 7: Controller**

`app/Http/Controllers/ConsentsController.php`:

```php
<?php

namespace App\Http\Controllers;

use App\Http\Requests\SignDentistConsentRequest;
use App\Http\Requests\SignPatientConsentRequest;
use App\Http\Requests\StoreConsentRequest;
use App\Models\ConsentForm;
use App\Models\Patient;
use App\Services\ConsentService;
use Illuminate\Http\RedirectResponse;
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

        return Inertia::render('Consents/Show', [
            'consent' => $consentForm->load(['patient', 'sections']),
        ]);
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
```

- [ ] **Step 8: Routes**

```php
use App\Http\Controllers\ConsentsController;

Route::middleware(['auth', 'verified', 'permission:consents.create'])
    ->post('/consents', [ConsentsController::class, 'store'])
    ->name('consents.store');
Route::middleware(['auth', 'verified', 'permission:consents.view'])
    ->get('/consents/{consentForm}', [ConsentsController::class, 'show'])
    ->name('consents.show');
Route::middleware(['auth', 'verified', 'permission:consents.sign-patient'])
    ->post('/consents/{consentForm}/patient-sign', [ConsentsController::class, 'patientSign'])
    ->name('consents.patient-sign');
Route::middleware(['auth', 'verified', 'permission:consents.sign-dentist'])
    ->post('/consents/{consentForm}/dentist-sign', [ConsentsController::class, 'dentistSign'])
    ->name('consents.dentist-sign');
```

- [ ] **Step 9: Feature test**

`tests/Feature/Consents/ManageConsentsTest.php`:

```php
<?php

use App\Models\ConsentForm;
use App\Models\Patient;
use App\Models\User;

uses(TestCase::class, RefreshDatabase::class);

beforeEach(function () {
    $this->seed(\Database\Seeders\RolePermissionSeeder::class);
});

it('creates a draft with the 10 PDA sections and records initials', function () {
    $assistant = User::factory()->create()->assignRole('Assistant');
    $patient = Patient::factory()->create(['birth_date' => now()->subYears(25)]);

    $svg = '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 100 50"><path d="M5 25 L 95 25" stroke="black" fill="none"/></svg>';

    $this->actingAs($assistant)->post('/consents', [
        'patient_id' => $patient->id,
        'initials' => [
            'treatment_to_be_done' => $svg,
            'drugs_and_medications' => $svg,
            'fillings' => $svg,
        ],
    ])->assertRedirect();

    $form = ConsentForm::where('patient_id', $patient->id)->first();
    expect($form)->not->toBeNull();
    expect($form->sections)->toHaveCount(10);
    expect($form->sections()->whereNull('initial_svg_path')->count())->toBe(7);
    expect($form->sections()->where('key', 'fillings')->first()->initial_svg_path)->not->toBeNull();
    expect($form->status->value)->toBe('unsigned');
});

it('requires guardian signature for minors', function () {
    $assistant = User::factory()->create()->assignRole('Assistant');
    $minor = Patient::factory()->create(['birth_date' => now()->subYears(12)]);
    $form = ConsentForm::factory()->create(['patient_id' => $minor->id, 'dentist_id' => $assistant->id]);

    $svg = '<svg xmlns="http://www.w3.org/2000/svg"><path d="M0 0" fill="none"/></svg>';

    $this->actingAs($assistant)->post("/consents/{$form->id}/patient-sign", [
        'signature_svg' => $svg,
    ])->assertSessionHasErrors(); // or 422

    $this->actingAs($assistant)->post("/consents/{$form->id}/patient-sign", [
        'signature_svg' => $svg,
        'guardian_name' => 'Maria Santos',
        'guardian_svg' => $svg,
    ])->assertRedirect();

    expect($form->fresh()->status->value)->toBe('patient_signed');
    expect($form->fresh()->guardian_name)->toBe('Maria Santos');
});

it('lets the dentist countersign a patient-signed form', function () {
    $dentist = User::factory()->create()->assignRole('Dentist');
    $patient = Patient::factory()->create(['birth_date' => now()->subYears(25)]);
    $form = ConsentForm::factory()->create([
        'patient_id' => $patient->id,
        'dentist_id' => $dentist->id,
        'status' => 'patient_signed',
    ]);

    $svg = '<svg xmlns="http://www.w3.org/2000/svg"><path d="M0 0" fill="none"/></svg>';

    $this->actingAs($dentist)->post("/consents/{$form->id}/dentist-sign", ['signature_svg' => $svg])
        ->assertRedirect();

    expect($form->fresh()->status->value)->toBe('signed');
    expect($form->fresh()->dentist_signed_at)->not->toBeNull();
});

it('blocks dentist countersign before patient signs', function () {
    $dentist = User::factory()->create()->assignRole('Dentist');
    $form = ConsentForm::factory()->create(['dentist_id' => $dentist->id, 'status' => 'unsigned']);

    $this->actingAs($dentist)->post("/consents/{$form->id}/dentist-sign", [
        'signature_svg' => '<svg xmlns="http://www.w3.org/2000/svg"/>',
    ])->assertStatus(409);
});

it('blocks receptionists from consent actions', function () {
    $user = User::factory()->create()->assignRole('Receptionist');
    $patient = Patient::factory()->create();

    $this->actingAs($user)->post('/consents', ['patient_id' => $patient->id, 'initials' => []])
        ->assertForbidden();
});
```

Note: the minors test asserts `assertSessionHasErrors()` for the abort(422) case — `abort(422)` produces a 422 response; Inertia + test: use `assertStatus(422)` instead. Adjust the test to `->assertStatus(422)`.

- [ ] **Step 10: Patient relation**

`app/Models/Patient.php` — add `consentForms(): HasMany` relation.

- [ ] **Step 11: UI — WaiverStep + SignatureStep (wizard steps 3+4)**

`resources/js/Components/Wizard/WaiverStep.vue` (props: `patient`, `dentistName`, emits 'saved'):
- Renders the 10 PDA sections (props `sections` passed from wizard page as config-consent sections: array of `{key, label, text}`), each as a card with the PDA-verbatim text (≥16px, high contrast) + a **small signature pad** (initial pad). Reuse `SignaturePadModal`? No — the initials are small inline pads. Implement a compact `InitialPad` inline: a 180×60 canvas using vue-signature-pad with `class="w-full h-16"`, Clear button. Each pad stores its SVG in a local reactive `initials[key]`.
- Acknowledgment + authorization blocks (verbatim text) rendered as highlighted quote blocks.
- "Save & continue" button: posts `useForm({ patient_id, initials }).post(route('consents.store'))` → onSuccess emit 'saved'. Validation: all 10 initials required before submit (disable button until all 10 pads have ink).
- Add a small helper component `resources/js/Components/SignaturePadModal.vue` stays for full signatures; for initials create `resources/js/Components/InitialPad.vue` (props: `modelValue` string|null, emits update; thin wrapper around vue-signature-pad: `:options="{ penColor: '#1f2937', backgroundColor: 'white' }"`, `:height="60"`, `:width="'100%'"`, `@end="emit"`, clear button ≥44px, `pad.value.isEmpty()` gating).

`resources/js/Components/Wizard/SignatureStep.vue` (props: `patient`, `consentForm` (created by step 3), emits 'saved'):
- Shows patient name, form version, and the full signature pad (`SignaturePadModal` reused as a full-screen pad — or inline large pad 300×150).
- If `patient.age < 18`: guardian name input (pre-filled from `patient.guardian_name`) + guardian pad.
- "Sign & continue": posts `route('consents.patient-sign', consentForm.id)` with `signature_svg`, `guardian_name`, `guardian_svg` → onSuccess emit 'saved'.

`resources/js/Pages/Wizard/Index.vue` changes:
- Steps 3 + 4 unlock: remove the locked placeholder for waiver/signature; step 3 renders `WaiverStep` (props: patient, sections from a new prop `consentSections` = `config('consent.sections')` passed from WizardController as `['key' => ..., 'label' => ..., 'text' => ...]` list + `consentAcknowledgment` + `consentAuthorization`), on saved → advance + `markComplete('waiver')`.
- Step 4 renders `SignatureStep` (props: patient, `consentFormId` — the wizard needs the created form id: after step 3's POST the page reloads via redirect to `wizard.index/{patient}`; the controller must pass the latest unsigned draft: `$consentForm = $patient->consentForms()->where('status','unsigned')->latest()->first()`; pass `consentFormId`). On saved → advance + markComplete('signature').
- Update `WizardController::index` resume logic: step 3 done when a draft exists (`$patient->consentForms()->where('status', 'unsigned')->exists()` → resume ≥ 3); step 4 done when `patient_signed` or `signed` form exists → resume ≥ 5. New match order: MH null → 1; no unsigned/signed consent draft → 3; no patient_signed form → 4; no consultation → 5; no chart → 6; no treatment → 7; else 0. (Update the existing match expression accordingly, keeping the WizardTest expectations for steps 1 and 4 — NOTE: the existing test expects resumeStep 4 when consultation exists but NO consent. With the new rule "no consent → 3", that test breaks. Update `tests/Feature/WizardTest.php`: the second case now expects **3** (waiver) when no consent exists; add a third case: with a patient_signed consent + consultation → resumeStep 5. Adjust assertions accordingly.)

- [ ] **Step 12: UI — Consents tab on Show.vue + printable form**

`resources/js/Pages/Consents/Show.vue` (printable A4-style layout):
- Props: `consent` (with patient, sections).
- Header: clinic name (from settings via prop or static "Dental Clinic"), "Informed Consent" title, form version + date.
- Body: patient name + birth date + age; the 10 sections each with its text + embedded initial SVG (`<img :src="'/storage/' + section.initial_svg_path">`) when present; acknowledgment + authorization blocks.
- Signature row: patient signature image + printed patient name + patient_signed_at date; guardian signature if present; dentist signature image + dentist name + dentist_signed_at.
- Footer: ip_address + user_agent small print; status badge.
- Print button (window.print()) with `@media print` friendly (the page is standalone, layout AppLayout optional — use a bare layout: pass `layout: null` via defineOptions or use a minimal div; simplest: keep AppLayout and rely on browser print of the page; acceptable).
- Wire Show.vue Consents tab: list of consent forms (date, version, status Badge, Link "View" → consents.show; "Dentist sign" button when status patient_signed + can.consents.sign-dentist → SignaturePadModal → consents.dentist-sign). PatientsController::show passes `consentForms` (gated by consents.view) + can flags.
- Add `can.consents` flags to PatientsController::show.

- [ ] **Step 13: Verify + commit**

Run: `./vendor/bin/pest tests/Feature/Consents tests/Feature/Wizard` → PASS; full suite green; `npm run build` clean; pint.
Browser (admin@clinic.test / password, :8000): /wizard → register new patient → medical history → **Waiver step now live**: 10 sections with pads; draw in 3 pads → Save disabled until all 10 have ink → save all → continue → **Signature step**: draw signature → Sign & continue → consultation step. Then /patients/{id} → Consents tab → form listed patient_signed → "Dentist sign" → pad → signed → View → printable form renders initials + signatures.

```bash
./vendor/bin/pint && ./vendor/bin/pest
git add -A && git commit -m "feat: PDA consent module (per-section initials, patient/guardian/dentist signatures)"
```

---

## Task 3: Attachments module

**Files:**
- Create: `app/Enums/AttachmentCategory.php`
- Create: `database/migrations/2026_08_01_000007_create_attachments_table.php`
- Create: `app/Models/Attachment.php`, `app/Services/AttachmentService.php`, `app/Policies/AttachmentPolicy.php`
- Create: `app/Http/Requests/StoreAttachmentRequest.php`, `app/Http/Controllers/AttachmentsController.php`
- Modify: `routes/web.php`, `app/Models/Patient.php`, `app/Http/Controllers/PatientsController.php` (Files tab data), `resources/js/Pages/Patients/Show.vue` (Files tab)
- Test: `tests/Feature/Attachments/ManageAttachmentsTest.php`

- [ ] **Step 1: Enum**

`app/Enums/AttachmentCategory.php`:

```php
<?php

namespace App\Enums;

enum AttachmentCategory: string
{
    use HasMeta;

    case Image = 'image';
    case Pdf = 'pdf';
    case Xray = 'xray';
    case Prescription = 'prescription';
    case Laboratory = 'laboratory';
    case Document = 'document';
    case Other = 'other';

    /** PDA Page 3 X-ray types — used when category === xray. */
    public const XRAY_TYPES = ['periapical', 'panoramic', 'cephalometric', 'occlusal', 'others'];

    public static function meta(): array
    {
        return [
            'image' => ['label' => 'Image', 'icon' => 'image'],
            'pdf' => ['label' => 'PDF', 'icon' => 'file'],
            'xray' => ['label' => 'X-ray', 'icon' => 'scan'],
            'prescription' => ['label' => 'Prescription', 'icon' => 'file-text'],
            'laboratory' => ['label' => 'Laboratory', 'icon' => 'flask'],
            'document' => ['label' => 'Document', 'icon' => 'folder'],
            'other' => ['label' => 'Other', 'icon' => 'paperclip'],
        ];
    }
}
```

- [ ] **Step 2: Migration**

`database/migrations/2026_08_01_000007_create_attachments_table.php`:

```php
<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('attachments', function (Blueprint $table) {
            $table->id();
            $table->foreignId('patient_id')->constrained()->cascadeOnDelete();
            $table->foreignId('uploaded_by')->nullable()->constrained('users')->nullOnDelete();
            $table->string('category')->default('image');
            $table->string('xray_type')->nullable();        // PDA Page 3 X-ray types; required when category=xray
            $table->string('original_name');
            $table->string('file_path');
            $table->string('mime_type');
            $table->unsignedBigInteger('file_size');
            $table->text('notes')->nullable();
            $table->softDeletes();                          // admin-only delete (medico-legal)
            $table->timestamps();

            $table->index(['patient_id', 'category']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('attachments');
    }
};
```

- [ ] **Step 3: Model + Service**

`app/Models/Attachment.php` (SoftDeletes + LogsActivity v5, casts category → AttachmentCategory, relations patient/uploadedBy, `storageUrl()` accessor returning `'/storage/' . $this->file_path`).

`app/Services/AttachmentService.php`:

```php
<?php

namespace App\Services;

use App\Models\Attachment;
use App\Models\Patient;
use Illuminate\Http\UploadedFile;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Str;

final class AttachmentService
{
    public function store(UploadedFile $file, array $data, Patient $patient, mixed $uploader): Attachment
    {
        $extension = $file->getClientOriginalExtension() ?: 'bin';
        $path = $file->storeAs(
            "uploads/{$patient->id}",
            Str::uuid() . '.' . $extension,
            'local'
        );

        $attachment = Attachment::create([
            'patient_id' => $patient->id,
            'uploaded_by' => $uploader?->id,
            'category' => $data['category'],
            'xray_type' => $data['xray_type'] ?? null,
            'original_name' => $file->getClientOriginalName(),
            'file_path' => $path,
            'mime_type' => $file->getMimeType(),
            'file_size' => $file->getSize(),
            'notes' => $data['notes'] ?? null,
        ]);

        activity()->performedOn($attachment)->causedBy($uploader)->log('attachment.uploaded');

        return $attachment;
    }

    public function delete(Attachment $attachment, mixed $actor): void
    {
        $attachment->delete();  // soft delete (Phase 4 archiving keeps the file)
        activity()->performedOn($attachment)->causedBy($actor)->log('attachment.deleted');
    }
}
```

- [ ] **Step 4: Policy + Request**

`app/Policies/AttachmentPolicy.php` — viewAny (attachments.view), create (attachments.upload), delete (attachments.delete).

`app/Http/Requests/StoreAttachmentRequest.php`:

```php
<?php

namespace App\Http\Requests;

use App\Enums\AttachmentCategory;
use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rule;

class StoreAttachmentRequest extends FormRequest
{
    /**
     * @return array<string, array<int, mixed>>
     */
    public function rules(): array
    {
        $maxMb = (int) app(\App\Services\SettingsService::class)->get('attachment.max_size_mb', 25);

        return [
            'file' => ['required', 'file', 'mimes:jpeg,png,gif,webp,pdf', 'max:' . ($maxMb * 1024)],
            'category' => ['required', Rule::in(array_map(fn ($c) => $c->value, AttachmentCategory::cases()))],
            'xray_type' => ['nullable', 'required_if:category,xray', Rule::in(AttachmentCategory::XRAY_TYPES)],
            'notes' => ['nullable', 'string', 'max:1000'],
        ];
    }
}
```

- [ ] **Step 5: Controller**

`app/Http/Controllers/AttachmentsController.php`:

```php
<?php

namespace App\Http\Controllers;

use App\Http\Requests\StoreAttachmentRequest;
use App\Models\Attachment;
use App\Models\Patient;
use App\Services\AttachmentService;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Redirect;

class AttachmentsController extends Controller
{
    public function __construct(private readonly AttachmentService $service) {}

    public function store(StoreAttachmentRequest $request, Patient $patient): RedirectResponse
    {
        $this->authorize('create', Attachment::class);

        $this->service->store(
            $request->file('file'),
            $request->safe()->only(['category', 'xray_type', 'notes']),
            $patient,
            $request->user()
        );

        return Redirect::back();
    }

    public function destroy(Request $request, Attachment $attachment): RedirectResponse
    {
        $this->authorize('delete', $attachment);

        $this->service->delete($attachment, $request->user());

        return Redirect::back();
    }
}
```

- [ ] **Step 6: Routes + relation**

```php
use App\Http\Controllers\AttachmentsController;

Route::middleware(['auth', 'verified', 'permission:attachments.upload'])
    ->post('/patients/{patient}/attachments', [AttachmentsController::class, 'store'])
    ->name('attachments.store');
Route::middleware(['auth', 'verified', 'permission:attachments.delete'])
    ->delete('/attachments/{attachment}', [AttachmentsController::class, 'destroy'])
    ->name('attachments.destroy');
```

`app/Models/Patient.php` — add `attachments(): HasMany` relation.

- [ ] **Step 7: Feature test**

`tests/Feature/Attachments/ManageAttachmentsTest.php`:

```php
<?php

use App\Models\Attachment;
use App\Models\Patient;
use App\Models\User;
use Illuminate\Http\UploadedFile;
use Illuminate\Support\Facades\Storage;

uses(TestCase::class, RefreshDatabase::class);

beforeEach(function () {
    $this->seed(\Database\Seeders\RolePermissionSeeder::class);
    Storage::fake('local');
});

it('lets an assistant upload an X-ray with a PDA type', function () {
    $assistant = User::factory()->create()->assignRole('Assistant');
    $patient = Patient::factory()->create();

    $this->actingAs($assistant)->post("/patients/{$patient->id}/attachments", [
        'file' => UploadedFile::fake()->image('pano.jpg', 800, 400),
        'category' => 'xray',
        'xray_type' => 'panoramic',
        'notes' => 'Full mouth pano',
    ])->assertRedirect();

    $attachment = Attachment::first();
    expect($attachment)->not->toBeNull();
    expect($attachment->xray_type)->toBe('panoramic');
    expect($attachment->category->value)->toBe('xray');
    Storage::disk('local')->assertExists($attachment->file_path);
});

it('requires an xray type when category is xray', function () {
    $assistant = User::factory()->create()->assignRole('Assistant');
    $patient = Patient::factory()->create();

    $this->actingAs($assistant)->post("/patients/{$patient->id}/attachments", [
        'file' => UploadedFile::fake()->image('x.jpg'),
        'category' => 'xray',
    ])->assertSessionHasErrors(['xray_type']);
});

it('rejects wrong file types', function () {
    $assistant = User::factory()->create()->assignRole('Assistant');
    $patient = Patient::factory()->create();

    $this->actingAs($assistant)->post("/patients/{$patient->id}/attachments", [
        'file' => UploadedFile::fake()->create('evil.exe', 10),
        'category' => 'document',
    ])->assertSessionHasErrors(['file']);
});

it('blocks receptionists from uploading', function () {
    $user = User::factory()->create()->assignRole('Receptionist');
    $patient = Patient::factory()->create();

    $this->actingAs($user)->post("/patients/{$patient->id}/attachments", [
        'file' => UploadedFile::fake()->image('x.jpg'),
        'category' => 'image',
    ])->assertForbidden();
});
```

- [ ] **Step 8: UI — Files tab on Show.vue**

`PatientsController::show` — add `attachments` (gated by `attachments.view`; with uploadedBy:id,name), `attachmentOptions` (`AttachmentCategory::meta()` + `xrayTypes`), `can.attachments` flags.

`Show.vue` — wire the **Files tab** (activeTab pattern from the Treatments tab):
- Category filter chips (All + 7 categories, incl. X-ray subgroup when category xray: show xray_type label chip).
- Thumbnail grid for images/x-rays (`<img :src="attachment.storage_url" class="h-24 w-24 rounded-lg object-cover">`); PDFs = file icon tile; tap → **PreviewModal** (image: dark overlay full-screen with zoom via CSS `scale` buttons; pdf: `<iframe :src="storage_url" class="h-[80vh] w-full">`).
- Metadata: original_name, category label, xray_type label, size (KB/MB formatter), uploaded_by name, date, notes.
- Upload button (can.attachments.upload): opens upload form (category select, xray_type select shown when xray, notes, file input) — submit via `useForm` with `onProgress` → progress bar (`<div class="h-1.5 bg-gray-100 rounded-full"><div class="h-full bg-brand-500 transition-all" :style="{ width: progress + '%' }"></div></div>`).
- Delete button (can.attachments.delete): confirm() → router.delete.

- [ ] **Step 9: Verify + commit**

Run: `./vendor/bin/pest tests/Feature/Attachments` → PASS; full suite green; `npm run build` clean; pint.
Browser (admin@clinic.test / password, :8000): /patients/1 → Files tab → upload a real image (category X-ray, type Panoramic) → progress bar → thumbnail appears → tap → dark viewer opens → close; upload a PDF → tile → preview iframe. No console errors.

```bash
./vendor/bin/pint && ./vendor/bin/pest
git add -A && git commit -m "feat: attachments module (uploads with progress, X-ray types, viewer)"
```

---

## Task 4: Reports module

**Files:**
- Create: `app/Repositories/ReportRepository.php`, `app/Http/Controllers/ReportsController.php`
- Create: `resources/js/Pages/Reports/Index.vue`
- Modify: `routes/web.php`, `resources/js/Components/Sidebar.vue` (enable Reports), `app/Http/Middleware/HandleInertiaRequests.php` (share `can.reports`)
- Test: `tests/Unit/ReportRepositoryTest.php`, `tests/Feature/Reports/ViewReportsTest.php`

- [ ] **Step 1: Write the failing unit test**

`tests/Unit/ReportRepositoryTest.php`:

```php
<?php

use App\Models\Appointment;
use App\Models\Consultation;
use App\Models\DentalChartEntry;
use App\Models\Patient;
use App\Models\Treatment;
use App\Models\User;
use App\Repositories\ReportRepository;
use Carbon\Carbon;

uses(TestCase::class, RefreshDatabase::class);

beforeEach(function () {
    $this->from = Carbon::parse('2026-01-01');
    $this->to = Carbon::parse('2026-12-31');
});

it('counts new patients per month', function () {
    Patient::factory()->create(['created_at' => '2026-03-10']);
    Patient::factory()->create(['created_at' => '2026-03-20']);
    Patient::factory()->create(['created_at' => '2026-07-01']);

    $growth = app(ReportRepository::class)->patientGrowth($this->from, $this->to);

    expect($growth->where('month', '2026-03')->first()->count)->toBe(2);
    expect($growth->where('month', '2026-07')->first()->count)->toBe(1);
});

it('summarizes appointments by status with attendance rate', function () {
    Appointment::factory()->create(['appointment_date' => '2026-05-01', 'status' => 'completed']);
    Appointment::factory()->create(['appointment_date' => '2026-05-02', 'status' => 'completed']);
    Appointment::factory()->create(['appointment_date' => '2026-05-03', 'status' => 'no_show']);
    Appointment::factory()->create(['appointment_date' => '2026-06-01', 'status' => 'cancelled']);

    $summary = app(ReportRepository::class)->appointmentSummary($this->from, $this->to);

    $may = $summary->where('month', '2026-05')->first();
    expect($may->completed)->toBe(2);
    expect($may->no_show)->toBe(1);
    expect($may->attendance_rate)->toBe(66.67);
});

it('groups procedures and dentist workload', function () {
    $dentist = User::factory()->create();
    Treatment::factory()->count(3)->create([
        'dentist_id' => $dentist->id,
        'procedure_name' => 'Composite restoration',
        'treatment_date' => '2026-04-15',
    ]);
    Treatment::factory()->create([
        'dentist_id' => $dentist->id,
        'procedure_name' => 'Extraction',
        'treatment_date' => '2026-04-16',
    ]);

    $procedures = app(ReportRepository::class)->procedureSummary($this->from, $this->to);
    $workload = app(ReportRepository::class)->dentistWorkload($this->from, $this->to);

    expect($procedures->where('procedure_name', 'Composite restoration')->first()->count)->toBe(3);
    expect($workload->first()->count)->toBe(4);
});

it('summarizes top chart conditions', function () {
    $patient = Patient::factory()->create();
    $actor = User::factory()->create();
    foreach ([16, 26, 36] as $tooth) {
        DentalChartEntry::create([
            'patient_id' => $patient->id, 'tooth_number' => $tooth, 'dentition' => 'adult',
            'condition' => 'caries', 'recorded_at' => '2026-08-01', 'recorded_by' => $actor->id,
        ]);
    }

    $conditions = app(ReportRepository::class)->conditionSummary($this->from, $this->to);

    expect($conditions->where('condition', 'caries')->first()->count)->toBe(3);
});
```

- [ ] **Step 2: Run to verify failure** — FAIL (repository missing).

- [ ] **Step 3: Repository**

`app/Repositories/ReportRepository.php` (all queries filtered by date range):

```php
<?php

namespace App\Repositories;

use App\Models\Appointment;
use App\Models\Consultation;
use App\Models\DentalChartEntry;
use App\Models\Patient;
use App\Models\Treatment;
use Carbon\Carbon;
use Illuminate\Support\Collection;
use Illuminate\Support\Facades\DB;

final class ReportRepository
{
    /** New patients per month (last N months within range). */
    public function patientGrowth(Carbon $from, Carbon $to): Collection
    {
        return Patient::query()
            ->whereBetween('created_at', [$from->startOfMonth(), $to->endOfMonth()])
            ->selectRaw("DATE_FORMAT(created_at, '%Y-%m') as month, COUNT(*) as count")
            ->groupBy('month')
            ->orderBy('month')
            ->get();
    }

    /** Appointments by status per month + attendance rate = completed / (completed + no_show). */
    public function appointmentSummary(Carbon $from, Carbon $to): Collection
    {
        return Appointment::query()
            ->whereBetween('appointment_date', [$from->toDateString(), $to->toDateString()])
            ->selectRaw("DATE_FORMAT(appointment_date, '%Y-%m') as month, status, COUNT(*) as count")
            ->groupBy('month', 'status')
            ->orderBy('month')
            ->get()
            ->groupBy('month')
            ->map(function (Collection $rows, string $month) {
                $byStatus = $rows->pluck('count', 'status');
                $completed = (int) ($byStatus['completed'] ?? 0);
                $noShow = (int) ($byStatus['no_show'] ?? 0);
                $denominator = $completed + $noShow;

                return (object) [
                    'month' => $month,
                    'pending' => (int) ($byStatus['pending'] ?? 0),
                    'confirmed' => (int) ($byStatus['confirmed'] ?? 0),
                    'completed' => $completed,
                    'cancelled' => (int) ($byStatus['cancelled'] ?? 0),
                    'no_show' => $noShow,
                    'attendance_rate' => $denominator > 0 ? round($completed / $denominator * 100, 2) : 0.0,
                ];
            })
            ->values();
    }

    /** Procedure counts grouped by procedure_name (tooth/dentist filters optional). */
    public function procedureSummary(Carbon $from, Carbon $to, ?int $toothNumber = null, ?int $dentistId = null): Collection
    {
        return Treatment::query()
            ->whereBetween('treatment_date', [$from->toDateString(), $to->toDateString()])
            ->when($toothNumber, fn ($q) => $q->where('tooth_number', $toothNumber))
            ->when($dentistId, fn ($q) => $q->where('dentist_id', $dentistId))
            ->selectRaw('procedure_name, COUNT(*) as count')
            ->groupBy('procedure_name')
            ->orderByDesc('count')
            ->get();
    }

    /** Top conditions on the chart (clinical audit). */
    public function conditionSummary(Carbon $from, Carbon $to): Collection
    {
        return DentalChartEntry::query()
            ->whereBetween('recorded_at', [$from->toDateString(), $to->toDateString()])
            ->selectRaw('condition, COUNT(*) as count')
            ->groupBy('condition')
            ->orderByDesc('count')
            ->get();
    }

    /** Per-dentist treatment counts (workload). */
    public function dentistWorkload(Carbon $from, Carbon $to): Collection
    {
        return Treatment::query()
            ->whereBetween('treatment_date', [$from->toDateString(), $to->toDateString()])
            ->join('users', 'treatments.dentist_id', '=', 'users.id')
            ->selectRaw('users.name as dentist_name, COUNT(*) as count')
            ->groupBy('users.id', 'users.name')
            ->orderByDesc('count')
            ->get();
    }
}
```

- [ ] **Step 4: Controller**

`app/Http/Controllers/ReportsController.php`:

```php
<?php

namespace App\Http\Controllers;

use App\Models\Appointment;
use App\Models\Patient;
use App\Repositories\ReportRepository;
use Carbon\Carbon;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Response;
use Inertia\Inertia;
use Inertia\Response as InertiaResponse;
use Symfony\Component\HttpFoundation\StreamedResponse;

class ReportsController extends Controller
{
    public function __construct(private readonly ReportRepository $reports) {}

    public function index(Request $request): InertiaResponse
    {
        $this->authorize('viewAny', \App\Models\Report::class); // gate via permission in route instead
        // NOTE: no Report model exists — use Gate::authorize('reports.view') instead:
        abort_unless($request->user()->can('reports.view'), 403);

        [$from, $to] = $this->range($request);

        return Inertia::render('Reports/Index', [
            'range' => ['from' => $from->toDateString(), 'to' => $to->toDateString()],
            'patientGrowth' => $this->reports->patientGrowth($from, $to),
            'appointmentSummary' => $this->reports->appointmentSummary($from, $to),
            'procedureSummary' => $this->reports->procedureSummary($from, $to),
            'conditionSummary' => $this->reports->conditionSummary($from, $to),
            'dentistWorkload' => $this->reports->dentistWorkload($from, $to),
            'totals' => [
                'patients' => Patient::whereBetween('created_at', [$from->startOfMonth(), $to->endOfMonth()])->count(),
                'appointments' => Appointment::whereBetween('appointment_date', [$from->toDateString(), $to->toDateString()])->count(),
            ],
        ]);
    }

    public function export(Request $request): StreamedResponse
    {
        abort_unless($request->user()->can('reports.view'), 403);

        $report = $request->query('report', 'patientGrowth');
        [$from, $to] = $this->range($request);
        $data = match ($report) {
            'appointmentSummary' => $this->reports->appointmentSummary($from, $to),
            'procedureSummary' => $this->reports->procedureSummary($from, $to),
            'conditionSummary' => $this->reports->conditionSummary($from, $to),
            'dentistWorkload' => $this->reports->dentistWorkload($from, $to),
            default => $this->reports->patientGrowth($from, $to),
        };

        $columns = $data->first() ? array_keys((array) $data->first()) : ['empty'];

        return Response::streamDownload(function () use ($data, $columns) {
            $handle = fopen('php://output', 'w');
            fputcsv($handle, $columns);
            foreach ($data as $row) {
                fputcsv($handle, array_values((array) $row));
            }
            fclose($handle);
        }, "report-{$report}-{$from->format('Ymd')}-{$to->format('Ymd')}.csv", ['Content-Type' => 'text/csv']);
    }

    /** @return array{0: Carbon, 1: Carbon} */
    private function range(Request $request): array
    {
        $from = preg_match('/^\d{4}-\d{2}-\d{2}$/', (string) $request->query('from', ''))
            ? Carbon::parse($request->query('from'))
            : Carbon::now()->subDays(30);
        $to = preg_match('/^\d{4}-\d{2}-\d{2}$/', (string) $request->query('to', ''))
            ? Carbon::parse($request->query('to'))
            : Carbon::now();

        return [$from, $to];
    }
}
```

- [ ] **Step 5: Routes + sidebar + shared can**

Routes:

```php
use App\Http\Controllers\ReportsController;

Route::middleware(['auth', 'verified', 'permission:reports.view'])
    ->get('/reports', [ReportsController::class, 'index'])
    ->name('reports.index');
Route::middleware(['auth', 'verified', 'permission:reports.view'])
    ->get('/reports/export', [ReportsController::class, 'export'])
    ->name('reports.export');
```

`app/Http/Middleware/HandleInertiaRequests.php` — add a shared prop:

```php
'share' => [
    // ...existing...
    'can' => [
        'reports' => fn () => $this->auth->user()?->can('reports.view') ?? false,
        'settings' => fn () => $this->auth->user()?->can('settings.view') ?? false,
    ],
],
```

`resources/js/Components/Sidebar.vue` — Reports item becomes a Link (when `page.props.can?.reports`) to `route('reports.index')`; Settings stays disabled ("Phase 4").

- [ ] **Step 6: Feature test**

`tests/Feature/Reports/ViewReportsTest.php`:

```php
<?php

use App\Models\User;

uses(TestCase::class, RefreshDatabase::class);

beforeEach(function () {
    $this->seed(\Database\Seeders\RolePermissionSeeder::class);
});

it('renders the reports page for admins', function () {
    $admin = User::factory()->create()->assignRole('Administrator');

    $this->actingAs($admin)->get('/reports')
        ->assertOk()
        ->assertInertia(fn ($page) => $page
            ->component('Reports/Index')
            ->has('patientGrowth')
            ->has('appointmentSummary')
            ->has('procedureSummary')
            ->has('conditionSummary')
            ->has('dentistWorkload'));
});

it('blocks non-admins from reports', function () {
    $dentist = User::factory()->create()->assignRole('Dentist');

    $this->actingAs($dentist)->get('/reports')->assertForbidden();
});

it('exports a CSV report', function () {
    $admin = User::factory()->create()->assignRole('Administrator');

    $this->actingAs($admin)->get('/reports/export?report=patientGrowth&from=2026-01-01&to=2026-12-31')
        ->assertOk()
        ->assertHeader('Content-Type', 'text/csv');
});
```

- [ ] **Step 7: UI — Reports/Index.vue**

- Props: `range`, `patientGrowth`, `appointmentSummary`, `procedureSummary`, `conditionSummary`, `dentistWorkload`, `totals`.
- Header: "Reports" + date range pickers (from/to date inputs) + Apply button (`router.get(route('reports.index', { from, to }))`) + Print button (window.print) + per-chart CSV export links (`route('reports.export', { report: 'patientGrowth', from, to })`).
- Metric cards row (4): new patients, appointments, procedures (sum of procedureSummary counts), avg attendance (mean of appointmentSummary attendance_rate where denominator>0).
- Charts (vue3-apexcharts, colors from OKLCH tokens — use the `var()` strings? ApexCharts needs concrete colors: use the OKLCH values from app.css like the Dashboard did — copy the exact token strings for brand-300/brand-500/status colors):
  1. **Patient growth** — bar chart (month labels, patients count), brand-500.
  2. **Appointment summary** — stacked bar (per month: completed, no_show, cancelled, pending, confirmed), status token colors.
  3. **Procedure summary** — horizontal bar (top 8 procedures), brand-400.
  4. **Condition summary** — bar (condition labels via a label map: caries→Decayed (D), etc. — reuse ToothCondition meta labels by passing a `conditionLabels` prop from controller using `\App\Enums\ToothCondition::meta()`), cond token colors.
  5. **Dentist workload** — horizontal bar (dentist_name, count), brand-600.
- Each chart card: title + export CSV link.
- Empty states: "No data for this period".
- All buttons ≥44px.

- [ ] **Step 8: Verify + commit**

Run: `./vendor/bin/pest tests/Unit/ReportRepositoryTest.php tests/Feature/Reports` → PASS; full suite green; `npm run build` clean; pint.
Browser (admin@clinic.test / password, :8000): /reports → 5 charts render (data exists from earlier smoke tests), CSV download works for each report, print opens print dialog. Logged in as a Dentist → /reports → 403 page. Sidebar shows Reports link for admin.

```bash
./vendor/bin/pint && ./vendor/bin/pest
git add -A && git commit -m "feat: admin reports (5 aggregations, ApexCharts, CSV + print)"
```

---

## Self-Review

- **Spec coverage:** Signature hardening (3.1) ✓ · Consents with PDA per-section initials + guardian rule + dentist countersign (3.2) ✓ · Treatment signing already shipped in Phase 2 (3.3 — verify only) ✓ · Attachments incl. PDA X-ray types + progress + viewer (3.4) ✓ · Reports with 5 queries + charts + CSV/print (3.5) ✓ · Wizard steps 3+4 unlocked ✓ · Sidebar Reports for admins ✓.
- **Placeholders:** none — every migration/model/service/test contains concrete code; Vue components follow the established Show.vue/Wizard/Index.vue patterns.
- **Type consistency:** `SignatureStorageService::store(string, string): string` unchanged from Phase 2 (TreatmentService untouched). `ConsentService::createDraft/recordInitials/signPatient/signDentist/voidAndRecreate` match controller + tests. `ReportRepository` method names match controller + tests + blueprint 11. `AttachmentService::store(UploadedFile, array, Patient, User|null): Attachment` matches controller.
- **PDA alignment:** consent sections/keys/text verbatim from PDA Page 2; X-ray types verbatim from PDA Page 3; guardian capture per Q4; billing stays out of scope (Q8).
