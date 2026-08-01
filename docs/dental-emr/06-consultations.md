# 06 — Consultations

## Purpose

Capture clinical findings per visit (spec §8). Wizard step 5. Created by Dentist only.

## Database — `consultations`

```php
// 2026_01_01_000006_create_consultations_table.php
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
    $table->timestamps();

    $table->index(['patient_id', 'consultation_date']);
});
```

## Model

```php
class Consultation extends Model
{
    use HasActivity;

    protected $guarded = [];

    protected function casts(): array
    {
        return ['consultation_date' => 'date'];
    }

    public function patient(): BelongsTo { ... }
    public function dentist(): BelongsTo { return $this->belongsTo(User::class, 'dentist_id'); }
    public function treatments(): HasMany { ... }   // treatments planned/executed from this consultation
}
```

## Service / Policy

```php
final class ConsultationService
{
    public function create(array $data, User $dentist): Consultation
    {
        DB::transaction(fn () =>
            Consultation::create([...$data, 'dentist_id' => $dentist->id])
        );
    }
}
```

- `ConsultationPolicy::update` → only the **authoring dentist** (or Administrator) may edit.
- Append-only philosophy: corrections create a new consultation rather than silent edits; policy exception above covers typos (activitylog records the diff).

## Permissions

| Permission | Roles |
|---|---|
| `consultations.view` | administrator, dentist |
| `consultations.create` | administrator, dentist |
| `consultations.update` | administrator, dentist |

## UI Elements (improvised)

- **Consultation form**: labeled textareas for all 6 spec fields; chief complaint required; auto-suggests treatments from the consultation (`/consultations/{id}/treatments/create`).
- Wizard step 5: single-column form, large textareas, "Save & continue to chart" primary action.
- Patient timeline: consultations listed newest-first with date chips.
