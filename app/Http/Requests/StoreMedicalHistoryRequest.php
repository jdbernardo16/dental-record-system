<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;

class StoreMedicalHistoryRequest extends FormRequest
{
    /**
     * @return array<string, array<int, string>>
     */
    public function rules(): array
    {
        return [
            'hypertension' => ['required', 'in:no,yes,not_applicable'],
            'diabetes' => ['required', 'in:no,yes,not_applicable'],
            'tuberculosis' => ['required', 'in:no,yes,not_applicable'],
            'heart_disease' => ['required', 'in:no,yes,not_applicable'],
            'pregnancy' => ['required', 'in:no,yes,not_applicable'],
            'allergies' => ['required', 'in:no,yes,not_applicable'],
            'medications' => ['required', 'in:no,yes,not_applicable'],
            'smoking_history' => ['required', 'in:no,yes,not_applicable'],
            'alcohol_consumption' => ['required', 'in:no,yes,not_applicable'],
            'previous_surgeries' => ['required', 'in:no,yes,not_applicable'],
            'allergies_details' => ['nullable', 'string', 'max:2000'],
            'medications_details' => ['nullable', 'string', 'max:2000'],
            'smoking_details' => ['nullable', 'string', 'max:2000'],
            'alcohol_details' => ['nullable', 'string', 'max:2000'],
            'surgeries_details' => ['nullable', 'string', 'max:2000'],
            'remarks' => ['nullable', 'string', 'max:2000'],
        ];
    }
}
