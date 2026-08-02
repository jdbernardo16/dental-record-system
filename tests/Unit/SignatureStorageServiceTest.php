<?php

use App\Services\SignatureStorageService;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\Storage;
use Illuminate\Validation\ValidationException;
use Tests\TestCase;

uses(TestCase::class, RefreshDatabase::class);

beforeEach(function () {
    Storage::fake('local');
});

it('stores a valid SVG signature', function () {
    $svg = '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 300 150"><path d="M10 80 Q 95 10 180 80" stroke="black" fill="none"/></svg>';

    $path = app(SignatureStorageService::class)->store($svg, 'signatures/test.svg');

    expect($path)->toBe('signatures/test.svg');
    Storage::disk('local')->assertExists($path);
    expect(Storage::disk('local')->get($path))->toContain('<svg');
});

it('rejects malformed SVG payloads', function () {
    expect(fn () => app(SignatureStorageService::class)->store('not-an-svg', 'signatures/x.svg'))
        ->toThrow(ValidationException::class);
});

it('rejects oversized signatures', function () {
    $big = '<svg xmlns="http://www.w3.org/2000/svg">'.str_repeat('<path d="M0 0"/>', 200000).'</svg>';

    expect(fn () => app(SignatureStorageService::class)->store($big, 'signatures/big.svg'))
        ->toThrow(ValidationException::class);
});

it('strips script elements and event handlers from stored SVGs', function () {
    $svg = '<svg xmlns="http://www.w3.org/2000/svg"><script>alert(1)</script><path d="M0 0" onload="alert(2)"/><foreignObject><div>hi</div></foreignObject></svg>';

    $path = app(SignatureStorageService::class)->store($svg, 'signatures/clean.svg');

    $stored = Storage::disk('local')->get($path);
    expect($stored)->not->toContain('<script');
    expect($stored)->not->toContain('onload');
    expect($stored)->not->toContain('foreignObject');
});
