<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;

class SignPatientConsentRequest extends FormRequest
{
    /**
     * @return array<string, array<int, mixed>>
     */
    public function rules(): array
    {
        return [
            'signature_svg' => ['required', 'string'],
            'guardian_name' => ['nullable', 'string', 'max:255'],
            'guardian_svg' => ['nullable', 'string'],
        ];
    }
}
