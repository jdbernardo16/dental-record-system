<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;

class UpdateSettingsRequest extends FormRequest
{
    /**
     * @return array<string, array<int, mixed>>
     */
    public function rules(): array
    {
        return [
            'clinic.name' => ['required', 'string', 'max:255'],
            'clinic.address' => ['nullable', 'string', 'max:500'],
            'consent.version' => ['required', 'string', 'max:10'],
            'patient.number.prefix' => ['required', 'in:year'],
            'appointment.overlap' => ['required', 'boolean'],
            'attachment.max_size_mb' => ['required', 'integer', 'min:1', 'max:512'],
            'archive.inactivity_years' => ['required', 'integer', 'min:1', 'max:20'],
        ];
    }
}
