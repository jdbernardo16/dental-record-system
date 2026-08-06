<?php

use App\Models\ConsentForm;
use App\Models\Patient;
use App\Models\User;
use Database\Seeders\RolePermissionSeeder;
use Illuminate\Foundation\Testing\RefreshDatabase;

uses(RefreshDatabase::class);

beforeEach(function () {
    $this->seed(RolePermissionSeeder::class);
});

it('creates a draft with the 10 PDA sections and records initials', function () {
    $assistant = User::factory()->create()->assignRole('Assistant');
    $patient = Patient::factory()->create(['birth_date' => now()->subYears(25)]);

    $svg = '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 100 50"><path d="M5 25 L 95 25" stroke="black" fill="none"/></svg>';

    $this->actingAs($assistant)->post('/consents', [
        'patient_id' => $patient->id,
        'initials' => [
            'treatment_to_be_done' => $svg,
            'drugs_and_medications' => $svg,
            'fillings' => $svg,
        ],
    ])->assertRedirect();

    $form = ConsentForm::where('patient_id', $patient->id)->first();
    expect($form)->not->toBeNull();
    expect($form->sections)->toHaveCount(10);
    expect($form->sections()->whereNull('initial_svg_path')->count())->toBe(7);
    expect($form->sections()->where('key', 'fillings')->first()->initial_svg_path)->not->toBeNull();
    expect($form->status->value)->toBe('unsigned');
});

it('requires guardian signature for minors', function () {
    $assistant = User::factory()->create()->assignRole('Assistant');
    $minor = Patient::factory()->create(['birth_date' => now()->subYears(12)]);
    $form = ConsentForm::factory()->create(['patient_id' => $minor->id, 'dentist_id' => $assistant->id]);

    $svg = '<svg xmlns="http://www.w3.org/2000/svg"><path d="M0 0" fill="none"/></svg>';

    // The service aborts 422 when a minor has no guardian signature.
    $this->actingAs($assistant)->post("/consents/{$form->id}/patient-sign", [
        'signature_svg' => $svg,
    ])->assertStatus(422);

    $this->actingAs($assistant)->post("/consents/{$form->id}/patient-sign", [
        'signature_svg' => $svg,
        'guardian_name' => 'Maria Santos',
        'guardian_svg' => $svg,
    ])->assertRedirect();

    expect($form->fresh()->status->value)->toBe('patient_signed');
    expect($form->fresh()->guardian_name)->toBe('Maria Santos');
});

it('lets the dentist countersign a patient-signed form', function () {
    $dentist = User::factory()->create()->assignRole('Dentist');
    $patient = Patient::factory()->create(['birth_date' => now()->subYears(25)]);
    $form = ConsentForm::factory()->create([
        'patient_id' => $patient->id,
        'dentist_id' => $dentist->id,
        'status' => 'patient_signed',
    ]);

    $svg = '<svg xmlns="http://www.w3.org/2000/svg"><path d="M0 0" fill="none"/></svg>';

    $this->actingAs($dentist)->post("/consents/{$form->id}/dentist-sign", ['signature_svg' => $svg])
        ->assertRedirect();

    expect($form->fresh()->status->value)->toBe('signed');
    expect($form->fresh()->dentist_signed_at)->not->toBeNull();
});

it('blocks dentist countersign before patient signs', function () {
    $dentist = User::factory()->create()->assignRole('Dentist');
    $form = ConsentForm::factory()->create(['dentist_id' => $dentist->id, 'status' => 'unsigned']);

    $this->actingAs($dentist)->post("/consents/{$form->id}/dentist-sign", [
        'signature_svg' => '<svg xmlns="http://www.w3.org/2000/svg"/>',
    ])->assertStatus(409);
});

it('blocks receptionists from consent actions', function () {
    $user = User::factory()->create()->assignRole('Receptionist');
    $patient = Patient::factory()->create();

    $this->actingAs($user)->post('/consents', ['patient_id' => $patient->id, 'initials' => []])
        ->assertForbidden();
});

it('voids a previous unsigned draft when a new waiver is saved', function () {
    $assistant = User::factory()->create()->assignRole('Assistant');
    $patient = Patient::factory()->create(['birth_date' => now()->subYears(25)]);
    $svg = '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 100 50"><path d="M5 25 L 95 25" stroke="black" fill="none"/></svg>';

    $this->actingAs($assistant)->post('/consents', [
        'patient_id' => $patient->id,
        'initials' => ['treatment_to_be_done' => $svg],
    ])->assertRedirect();

    $first = ConsentForm::where('patient_id', $patient->id)->first();
    expect($first->status->value)->toBe('unsigned');

    // Re-saving the waiver starts a fresh consent session
    $this->actingAs($assistant)->post('/consents', [
        'patient_id' => $patient->id,
        'initials' => ['treatment_to_be_done' => $svg],
    ])->assertRedirect();

    expect($first->fresh()->status->value)->toBe('voided');
    expect(ConsentForm::where('patient_id', $patient->id)->where('status', 'unsigned')->count())->toBe(1);
});
