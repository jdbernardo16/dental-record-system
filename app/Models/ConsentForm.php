<?php

namespace App\Models;

use App\Enums\ConsentStatus;
use Database\Factories\ConsentFormFactory;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Spatie\Activitylog\Models\Concerns\LogsActivity;
use Spatie\Activitylog\Support\LogOptions;

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
     * @return array<string, class-string|string>
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

    /**
     * @return BelongsTo<Patient, $this>
     */
    public function patient(): BelongsTo
    {
        return $this->belongsTo(Patient::class);
    }

    /**
     * @return BelongsTo<User, $this>
     */
    public function dentist(): BelongsTo
    {
        return $this->belongsTo(User::class, 'dentist_id');
    }

    /**
     * @return HasMany<ConsentSection, $this>
     */
    public function sections(): HasMany
    {
        return $this->hasMany(ConsentSection::class);
    }

    public function isPatientSigned(): bool
    {
        return in_array($this->status, [ConsentStatus::PatientSigned, ConsentStatus::Signed], true);
    }
}
