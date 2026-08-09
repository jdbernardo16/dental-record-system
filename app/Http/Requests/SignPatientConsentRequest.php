<?php

namespace App\Http\Requests;

use App\Support\SvgCodec;
use Illuminate\Foundation\Http\FormRequest;

class SignPatientConsentRequest extends FormRequest
{
    /**
     * Signatures arrive base64-encoded from the frontend (the CDN WAF rejects
     * the literal `<svg` tag in POST bodies). Decode before validation so the
     * stored format stays raw SVG.
     */
    public function prepareForValidation(): void
    {
        $this->merge([
            'signature_svg' => SvgCodec::decode($this->input('signature_svg')),
            'guardian_svg' => SvgCodec::decode($this->input('guardian_svg')),
        ]);
    }

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
