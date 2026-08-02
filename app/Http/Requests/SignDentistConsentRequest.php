<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;

class SignDentistConsentRequest extends FormRequest
{
    /**
     * @return array<string, array<int, mixed>>
     */
    public function rules(): array
    {
        return [
            'signature_svg' => ['required', 'string'],
        ];
    }
}
