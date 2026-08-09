<?php

namespace App\Support;

/**
 * Decode SVG payloads that were base64-encoded on the wire.
 *
 * The hosting CDN WAF rejects any POST body containing the literal `<svg`
 * tag (false-positive XSS rule), so the frontend base64-encodes signature
 * payloads before submitting. This codec runs before validation/storage.
 *
 * Lenient by design: raw `<svg` payloads pass through unchanged (keeps local
 * development and pre-WAF clients working), and non-SVG garbage is returned
 * untouched so the normal validation pipeline rejects it later.
 */
final class SvgCodec
{
    public static function decode(?string $value): ?string
    {
        if ($value === null || $value === '') {
            return $value;
        }

        if (str_starts_with(ltrim($value), '<svg')) {
            return $value; // raw passthrough (backwards compat)
        }

        $decoded = base64_decode($value, true);
        if ($decoded !== false && str_starts_with(ltrim($decoded), '<svg')) {
            return $decoded;
        }

        return $value; // not svg → validation rejects later
    }
}
