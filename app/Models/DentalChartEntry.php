<?php

namespace App\Models;

use App\Enums\DentitionType;
use App\Enums\RestorationType;
use App\Enums\ToothCondition;
use App\Enums\ToothSurface;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Spatie\Activitylog\Models\Concerns\LogsActivity;
use Spatie\Activitylog\Support\LogOptions;

class DentalChartEntry extends Model
{
    use LogsActivity;

    protected $guarded = [];

    public function getActivitylogOptions(): LogOptions
    {
        return LogOptions::defaults()
            ->logOnlyDirty()
            ->useLogName('dental_chart_entries');
    }

    /**
     * Get the attributes that should be cast.
     *
     * @return array<string, class-string|string>
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
