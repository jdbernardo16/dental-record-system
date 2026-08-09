<?php

namespace App\Http\Requests;

use App\Support\SvgCodec;
use Illuminate\Foundation\Http\FormRequest;

class StoreConsentRequest extends FormRequest
{
    /**
     * Initials arrive base64-encoded from the frontend (the CDN WAF rejects
     * the literal `<svg` tag in POST bodies). Decode before validation so the
     * stored format stays raw SVG.
     */
    public function prepareForValidation(): void
    {
        $initials = $this->input('initials');

        // A scalar `initials` is left untouched so the 'array' rule below
        // produces the clean 422 — array_map would TypeError into a 500.
        if (! is_array($initials)) {
            return;
        }

        $this->merge([
            'initials' => array_map(
                static fn (mixed $svg): ?string => SvgCodec::decode(is_string($svg) ? $svg : null),
                $initials,
            ),
        ]);
    }

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
