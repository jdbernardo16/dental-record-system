<?php

use App\Support\SvgCodec;

it('decodes a base64-encoded SVG back to raw SVG', function () {
    $svg = '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 100 50"><path d="M5 25 L 95 25" stroke="black" fill="none"/></svg>';

    expect(SvgCodec::decode(base64_encode($svg)))->toBe($svg);
});

it('leaves a raw SVG string untouched (backwards compat)', function () {
    $svg = '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 100 50"><path d="M5 25 L 95 25"/></svg>';

    expect(SvgCodec::decode($svg))->toBe($svg);
});

it('leaves raw SVG untouched even with leading whitespace', function () {
    $svg = "  \n<svg xmlns=\"http://www.w3.org/2000/svg\"><path d=\"M0 0\"/></svg>";

    expect(SvgCodec::decode($svg))->toBe($svg);
});

it('leaves non-SVG garbage untouched (validation rejects it later)', function () {
    expect(SvgCodec::decode('abc'))->toBe('abc');
    expect(SvgCodec::decode('data:image/svg+xml;base64,PHN2Zz4='))->toBe('data:image/svg+xml;base64,PHN2Zz4=');
});

it('returns null for null and empty string for empty string', function () {
    expect(SvgCodec::decode(null))->toBeNull();
    expect(SvgCodec::decode(''))->toBe('');
});
