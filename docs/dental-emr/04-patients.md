# 04 — Patients (+ Medical History)

## Purpose

Central patient registry — every other module hangs off `patients`. Medical history is the pre-treatment screening captured in the wizard step 2.

## Database — `patients` (all 17 fields from spec §5)

```php
// 2026_01_01_000003_create_patients_table.php
Schema::create('patients', function (Blueprint $table) {
    $table->id();
    $table->string('patient_number', 20)->unique();          // e.g. 2026-0001 (see Q3)
    $table->string('first_name');
    $table->string('middle_name')->nullable();
    $table->string('last_name');
    $table->string('sex');                                    // Sex enum (male/female — see Q2)
    $table->date('birth_date');
    $table->string('civil_status')->default('single');        // CivilStatus enum
    $table->string('nationality')->default('Filipino');
    $table->string('occupation')->nullable();
    $table->string('contact_number');
    $table->string('address');
    $table->string('email_address')->nullable();
    $table->string('emergency_contact_person');
    $table->string('emergency_contact_number');
    $table->foreignId('created_by')->nullable()->constrained('users')->nullOnDelete();
    $table->softDeletes();                                    // Phase 4 archiving
    $table->timestamps();

    $table->index(['last_name', 'first_name']);
    $table->index('birth_date');
});
```

Age is **computed** (`$patient->age` accessor from `birth_date`) — never stored.

## Database — `medical_histories` (all 10 questions from spec §6)

```php
// 2026_01_01_000004_create_medical_histories_table.php
Schema::create('medical_histories', function (Blueprint $table) {
    $table->id();
    $table->foreignId('patient_id')->unique()->constrained()->cascadeOnDelete();
    // 10 screening questions (string = 'no' | 'yes' + details per item)
    $table->string('hypertension')->default('no');
    $table->string('diabetes')->default('no');
    $table->string('tuberculosis')->default('no');
    $table->string('heart_disease')->default('no');
    $table->string('pregnancy')->default('no');              // 'not_applicable' allowed for male/minor
    $table->string('allergies')->default('no');              // + allergies_details
    $table->string('medications')->default('no');            // + medications_details
    $table->string('smoking_history')->default('no');        // + smoking_details
    $table->string('alcohol_consumption')->default('no');    // + alcohol_details
    $table->string('previous_surgeries')->default('no');     // + surgeries_details
    // free-text details for each 'yes'
    $table->text('allergies_details')->nullable();
    $table->text('medications_details')->nullable();
    $table->text('smoking_details')->nullable();
    $table->text('alcohol_details')->nullable();
    $table->text('surgeries_details')->nullable();
    $table->text('remarks')->nullable();
    $table->foreignId('recorded_by')->nullable()->constrained('users')->nullOnDelete();
    $table->timestamps();
});
```

> Decision: fixed columns matching the spec exactly (simplest for the wizard). Dynamic question-bank design is deferred — see Q5.

## Enums

```php
enum Sex: string { case Male = 'male'; case Female = 'female'; /* meta() */ }

enum CivilStatus: string {
    case Single = 'single';
    case Married = 'married';
    case Widowed = 'widowed';
    case Separated = 'separated';
    case Divorced = 'divorced';
    case Annulled = 'annulled';
    case Other = 'other';
    // meta(): label, icon
}
```

Both extend `BaseEnum` (abstract class providing `labels()`, `meta()`, `fromMeta()`).

## Model

```php
class Patient extends Model
{
    use SoftDeletes, HasActivity;

    protected $guarded = [];

    protected function casts(): array
    {
        return ['birth_date' => 'date', 'sex' => Sex::class, 'civil_status' => CivilStatus::class];
    }

    public function getAgeAttribute(): int
    {
        return $this->birth_date->age;
    }

    public function fullName(): string
    {
        return trim("{$this->first_name} {$this->middle_name} {$this->last_name}");
    }

    public function scopeSearch($q, string $term): Builder   // name/number/contact
    {
        return $q->where('patient_number', 'like', "%$term%")
                 ->orWhere('last_name', 'like', "%$term%")
                 ->orWhere('first_name', 'like', "%$term%")
                 ->orWhere('contact_number', 'like', "%$term%");
    }

    public function medicalHistory(): HasOne { ... }
    public function appointments(): HasMany { ... }
    public function consultations(): HasMany { ... }
    public function chartEntries(): HasMany { ... }
    public function treatments(): HasMany { ... }
    public function attachments(): HasMany { ... }
    public function consentForms(): HasMany { ... }
}
```

## Service / Action

```php
final class RegisterPatientAction
{
    public function __construct(private PatientRepository $patients) {}

    public function handle(array $data, User $actor): Patient
    {
        DB::transaction(function () use ($data, $actor, &$patient) {
            $number = $this->patients->nextPatientNumber(now()->year);  // 2026-0001 ...
            $patient = Patient::create([...$data, 'patient_number' => $number, 'created_by' => $actor->id]);
            activity()->performedOn($patient)->causedBy($actor)->log('patient.registered');
        });
        return $patient;
    }
}
```

`PatientRepository::search(term, filters)` → paginated Inertia props; `nextPatientNumber(year)` → zero-padded sequence (`patients` count for year + 1 — see Q3 for format).

## Permissions

| Permission | Roles |
|---|---|
| `patients.view` | administrator, dentist, assistant, receptionist |
| `patients.create` | administrator, dentist, receptionist |
| `patients.update` | administrator, dentist, assistant |
| `patients.delete` | administrator (soft) |
| `medical-histories.view` | administrator, dentist |
| `medical-histories.create` | administrator, dentist |
| `medical-histories.update` | administrator, dentist |

## UI Elements (improvised — wizard step 1 & 2)

- **Step 1 — Patient form**: single-column stacked inputs (thumb-reachable), grouped: Identity / Contact / Emergency. "Register patient" primary button.
- **Step 2 — Medical history**: 10 yes/no segmented toggles with conditional "details" textarea appearing on *yes*; auto-skips to step 3.
- **Patient list** (`/patients`): search bar (name/number/contact), table rows ≥56px, tap → record view.
- **Record view** (`/patients/{id}`): summary header (avatar initials, age badge, patient number), tabbed sections (History, Appointments, Chart, Treatments, Files, Consents), each tab lazy-loads via Inertia partial reload.
