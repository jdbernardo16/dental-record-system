<?php

namespace App\Models;

use App\Enums\CivilStatus;
use App\Enums\Sex;
use Database\Factories\PatientFactory;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Database\Eloquent\Relations\HasOne;
use Illuminate\Database\Eloquent\SoftDeletes;

class Patient extends Model
{
    /** @use HasFactory<PatientFactory> */
    use HasFactory, SoftDeletes;

    protected $guarded = [];

    protected $appends = ['age'];

    /**
     * Get the attributes that should be cast.
     *
     * @return array<string, string>
     */
    protected function casts(): array
    {
        return [
            'birth_date' => 'date:Y-m-d',
            'sex' => Sex::class,
            'civil_status' => CivilStatus::class,
        ];
    }

    public function getAgeAttribute(): int
    {
        return max(0, $this->birth_date?->age ?? 0);
    }

    public function fullName(): string
    {
        return implode(' ', array_filter([$this->first_name, $this->middle_name, $this->last_name]));
    }

    public function scopeSearch(Builder $query, string $term): Builder
    {
        return $query->where(fn (Builder $q) => $q->where('patient_number', 'like', "%{$term}%")
            ->orWhere('last_name', 'like', "%{$term}%")
            ->orWhere('first_name', 'like', "%{$term}%")
            ->orWhere('contact_number', 'like', "%{$term}%"));
    }

    /**
     * @return HasOne<MedicalHistory, $this>
     */
    public function medicalHistory(): HasOne
    {
        return $this->hasOne(MedicalHistory::class);
    }

    /**
     * @return HasMany<Consultation, $this>
     */
    public function consultations(): HasMany
    {
        return $this->hasMany(Consultation::class);
    }

    /**
     * @return HasMany<DentalChartEntry, $this>
     */
    public function chartEntries(): HasMany
    {
        return $this->hasMany(DentalChartEntry::class);
    }
}
