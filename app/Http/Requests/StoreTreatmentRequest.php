<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;

class StoreTreatmentRequest extends FormRequest
{
    /**
     * @return array<string, array<int, mixed>>
     */
    public function rules(): array
    {
        return [
            'treatment_date' => ['required', 'date'],
            'tooth_number' => ['nullable', 'integer', 'min:11', 'max:85'],
            'procedure_name' => ['required', 'string', 'max:255'],
            'description' => ['nullable', 'string', 'max:2000'],
            'notes' => ['nullable', 'string', 'max:1000'],
            'consultation_id' => ['nullable', 'exists:consultations,id'],
        ];
    }
}
