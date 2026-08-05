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
     * @return array<string, class-string|string>
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
