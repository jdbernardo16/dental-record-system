<?php

namespace App\Models;

use Database\Factories\ConsultationFactory;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Spatie\Activitylog\Models\Concerns\LogsActivity;
use Spatie\Activitylog\Support\LogOptions;

class Consultation extends Model
{
    /** @use HasFactory<ConsultationFactory> */
    use HasFactory, LogsActivity;

    protected $guarded = [];

    public function getActivitylogOptions(): LogOptions
    {
        return LogOptions::defaults()
            ->logOnlyDirty()
            ->useLogName('consultations');
    }

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
