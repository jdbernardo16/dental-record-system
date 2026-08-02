<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;

class StoreConsentRequest extends FormRequest
{
    /**
     * @return array<string, array<int, mixed>>
     */
    public function rules(): array
    {
        $keys = array_keys(config('consent.sections'));

        return [
            'patient_id' => ['required', 'exists:patients,id'],
            'initials' => ['required', 'array', 'min:1'],
            'initials.*' => ['required', 'string'],
        ];
    }
}
