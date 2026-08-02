<?php

namespace App\Services;

use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Str;

final class SignatureStorageService
{
    /**
     * Store an SVG signature string on the local disk.
     * Basic guard in Phase 2; full sanitization (libxml parse, script strip) lands in Phase 3.
     *
     * @return string relative path (e.g. signatures/treatments/1.svg)
     */
    public function store(string $svg, string $path): string
    {
        abort_unless(
            Str::startsWith(trim($svg), '<svg'),
            422,
            'Invalid signature payload.'
        );
        abort_unless(
            ! str_contains($svg, '<script') && ! str_contains($svg, 'onload'),
            422,
            'Signature payload contains disallowed content.'
        );

        Storage::disk('local')->put($path, $svg);

        return $path;
    }
}
