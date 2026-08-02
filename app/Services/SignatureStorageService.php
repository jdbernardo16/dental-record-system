<?php

namespace App\Services;

use DOMDocument;
use Illuminate\Support\Facades\Storage;
use Illuminate\Validation\ValidationException;

final class SignatureStorageService
{
    private const MAX_BYTES = 524288; // 512 KB

    /**
     * Validate, sanitize and store an SVG signature.
     *
     * @return string relative path on the local disk
     */
    public function store(string $svg, string $path): string
    {
        $this->validatePayload($svg);

        $sanitized = $this->sanitize($svg);

        Storage::disk('local')->put($path, $sanitized);

        return $path;
    }

    private function validatePayload(string $svg): void
    {
        $failures = [];

        if (strlen($svg) > self::MAX_BYTES) {
            $failures[] = 'Signature exceeds the 512 KB limit.';
        }

        if (! str_starts_with(trim($svg), '<svg')) {
            $failures[] = 'Signature must be an SVG document.';
        }

        $previous = libxml_use_internal_errors(true);
        $doc = new DOMDocument;
        $parsed = $doc->loadXML($svg);
        libxml_clear_errors();
        libxml_use_internal_errors($previous);

        if (! $parsed) {
            $failures[] = 'Signature is not valid XML.';
        }

        if ($failures !== []) {
            throw ValidationException::withMessages(['signature_svg' => $failures]);
        }
    }

    /**
     * Strip script elements, foreign objects and event-handler attributes.
     */
    private function sanitize(string $svg): string
    {
        $previous = libxml_use_internal_errors(true);
        $doc = new DOMDocument;
        $doc->loadXML($svg);
        libxml_clear_errors();
        libxml_use_internal_errors($previous);

        $forbidden = ['script', 'foreignObject', 'iframe', 'object', 'embed'];

        foreach ($forbidden as $tag) {
            foreach ($doc->getElementsByTagName($tag) as $node) {
                $node->parentNode?->removeChild($node);
            }
        }

        foreach ($doc->getElementsByTagName('*') as $node) {
            $remove = [];
            foreach ($node->attributes ?? [] as $attribute) {
                $name = strtolower($attribute->nodeName ?? '');
                if (str_starts_with($name, 'on') || $name === 'href' || $name === 'xlink:href') {
                    $remove[] = $attribute;
                }
            }
            foreach ($remove as $attribute) {
                $node->removeAttributeNode($attribute);
            }
        }

        return $doc->saveXML() ?: $svg;
    }
}
