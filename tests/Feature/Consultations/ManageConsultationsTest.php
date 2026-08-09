<?php

use App\Models\Consultation;
use App\Models\Patient;
use App\Models\User;
use Database\Seeders\RolePermissionSeeder;
use Illuminate\Foundation\Testing\RefreshDatabase;

uses(RefreshDatabase::class);

beforeEach(function () {
    $this->seed(RolePermissionSeeder::class);
});

it('lets a dentist create a consultation with PDA exam fields', function () {
    $dentist = User::factory()->create()->assignRole('Dentist');
    $patient = Patient::factory()->create();

    $this->actingAs($dentist)->post("/patients/{$patient->id}/consultations", [
        'consultation_date' => now()->toDateString(),
        'chief_complaint' => 'Toothache on upper right',
        'examination_findings' => 'Caries on 16',
        'diagnosis' => 'Dental caries',
        'treatment_plan' => 'Composite restoration',
        'recommendations' => 'Return in 2 weeks',
        'notes' => null,
        'periodontal_screening' => 'gingivitis',
        'occlusion_class' => 'class_i',
        'overjet' => '2mm',
        'overbite' => '1mm',
        'midline_deviation' => 'none',
        'crossbite' => null,
        'appliances' => ['orthodontic'],
        'tmd_findings' => ['clicking'],
    ])->assertRedirect();

    $consultation = Consultation::where('patient_id', $patient->id)->first();
    expect($consultation)->not->toBeNull();
    expect($consultation->dentist_id)->toBe($dentist->id);
    expect($consultation->periodontal_screening)->toBe('gingivitis');
    expect($consultation->appliances)->toBe(['orthodontic']);
    expect($consultation->tmd_findings)->toBe(['clicking']);
});

it('requires chief complaint and validates exam fields', function () {
    $dentist = User::factory()->create()->assignRole('Dentist');
    $patient = Patient::factory()->create();

    $this->actingAs($dentist)
        ->post("/patients/{$patient->id}/consultations", ['consultation_date' => now()->toDateString()])
        ->assertSessionHasErrors(['chief_complaint']);

    $this->actingAs($dentist)->post("/patients/{$patient->id}/consultations", [
        'consultation_date' => now()->toDateString(),
        'chief_complaint' => 'X',
        'periodontal_screening' => 'not-a-real-value',
    ])->assertSessionHasErrors(['periodontal_screening']);
});

it('blocks receptionists from creating consultations', function () {
    $user = User::factory()->create()->assignRole('Assistant');
    $patient = Patient::factory()->create();

    $this->actingAs($user)->post("/patients/{$patient->id}/consultations", [
        'consultation_date' => now()->toDateString(),
        'chief_complaint' => 'X',
    ])->assertForbidden();
});

it('allows only the authoring dentist or admin to edit a consultation', function () {
    $dentist = User::factory()->create()->assignRole('Dentist');
    $otherDentist = User::factory()->create()->assignRole('Dentist');
    $admin = User::factory()->create()->assignRole('Administrator');
    $consultation = Consultation::factory()->create(['dentist_id' => $dentist->id]);

    $this->actingAs($otherDentist)->patch("/consultations/{$consultation->id}", [
        'chief_complaint' => 'Changed',
    ])->assertForbidden();

    $this->actingAs($dentist)->patch("/consultations/{$consultation->id}", [
        'chief_complaint' => 'Changed by author',
    ])->assertRedirect();

    expect($consultation->fresh()->chief_complaint)->toBe('Changed by author');

    $this->actingAs($admin)->patch("/consultations/{$consultation->id}", [
        'chief_complaint' => 'Changed by admin',
    ])->assertRedirect();
});
