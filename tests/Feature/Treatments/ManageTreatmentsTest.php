<?php

use App\Models\Patient;
use App\Models\Treatment;
use App\Models\User;
use Database\Seeders\RolePermissionSeeder;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\Storage;

uses(RefreshDatabase::class);

beforeEach(function () {
    $this->seed(RolePermissionSeeder::class);
});

it('lets a dentist create a treatment', function () {
    $dentist = User::factory()->create()->assignRole('Dentist');
    $patient = Patient::factory()->create();

    $this->actingAs($dentist)->post("/patients/{$patient->id}/treatments", [
        'treatment_date' => now()->toDateString(),
        'tooth_number' => 16,
        'procedure_name' => 'Composite restoration',
        'description' => 'Class II composite on 16',
        'notes' => null,
    ])->assertRedirect();

    $treatment = Treatment::where('patient_id', $patient->id)->first();
    expect($treatment)->not->toBeNull();
    expect($treatment->dentist_id)->toBe($dentist->id);
    expect($treatment->isSigned())->toBeFalse();
});

it('signs a treatment with an SVG signature', function () {
    $dentist = User::factory()->create()->assignRole('Dentist');
    $patient = Patient::factory()->create();
    $treatment = Treatment::factory()->create([
        'patient_id' => $patient->id,
        'dentist_id' => $dentist->id,
    ]);

    $svg = '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 300 150"><path d="M10 80 Q 95 10 180 80 T 290 80" stroke="black" stroke-width="2" fill="none"/></svg>';

    $this->actingAs($dentist)->post("/treatments/{$treatment->id}/sign", [
        'signature_svg' => $svg,
    ])->assertRedirect();

    expect($treatment->fresh()->isSigned())->toBeTrue();
    expect($treatment->fresh()->signature_path)->not->toBeNull();
    expect(Storage::disk('local')->exists($treatment->fresh()->signature_path))->toBeTrue();
});

it('accepts a base64-encoded signature (WAF bypass)', function () {
    $dentist = User::factory()->create()->assignRole('Dentist');
    $patient = Patient::factory()->create();
    $treatment = Treatment::factory()->create([
        'patient_id' => $patient->id,
        'dentist_id' => $dentist->id,
    ]);

    $svg = '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 300 150"><path d="M10 80 Q 95 10 180 80 T 290 80" stroke="black" stroke-width="2" fill="none"/></svg>';

    $this->actingAs($dentist)->post("/treatments/{$treatment->id}/sign", [
        'signature_svg' => base64_encode($svg),
    ])->assertRedirect();

    $treatment = $treatment->fresh();
    expect($treatment->isSigned())->toBeTrue();
    expect($treatment->signature_path)->not->toBeNull();
    // Stored raw (SignatureStorageService serializes with an XML declaration),
    // i.e. the base64 payload was decoded — the literal `<svg` proves it.
    expect(Storage::disk('local')->get($treatment->signature_path))->toContain('<svg');
});

it('blocks a different dentist from signing', function () {
    $dentist = User::factory()->create()->assignRole('Dentist');
    $other = User::factory()->create()->assignRole('Dentist');
    $treatment = Treatment::factory()->create(['dentist_id' => $dentist->id]);

    $this->actingAs($other)->post("/treatments/{$treatment->id}/sign", ['signature_svg' => '<svg/>'])
        ->assertForbidden();
});

it('blocks receptionists from creating treatments', function () {
    $user = User::factory()->create()->assignRole('Receptionist');
    $patient = Patient::factory()->create();

    $this->actingAs($user)->post("/patients/{$patient->id}/treatments", [
        'treatment_date' => now()->toDateString(),
        'procedure_name' => 'X',
    ])->assertForbidden();
});
