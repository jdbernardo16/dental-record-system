<?php

use App\Models\ConsentForm;
use App\Models\Consultation;
use App\Models\Patient;
use App\Models\User;
use Database\Seeders\RolePermissionSeeder;
use Illuminate\Foundation\Testing\RefreshDatabase;

uses(RefreshDatabase::class);

beforeEach(function () {
    $this->seed(RolePermissionSeeder::class);
});

it('renders the wizard for receptionists with a fresh patient step', function () {
    $user = User::factory()->create()->assignRole('Receptionist');

    $this->actingAs($user)->get('/wizard')
        ->assertOk()
        ->assertInertia(fn ($page) => $page
            ->component('Wizard/Index')
            ->has('patient')
            ->has('steps', 7));
});

it('resumes an existing patient at the first incomplete step', function () {
    $dentist = User::factory()->create()->assignRole('Dentist');
    $patient = Patient::factory()->create();

    $this->actingAs($dentist)->get("/wizard/{$patient->id}")
        ->assertOk()
        ->assertInertia(fn ($page) => $page
            ->component('Wizard/Index')
            ->where('patient.id', $patient->id)
            ->where('resumeStep', 1)); // step index: 0 patient, 1 medical history, ...

    // After medical history + consultation but no consent, resume at the consent step
    $this->actingAs($dentist)->post("/patients/{$patient->id}/medical-history", [
        'hypertension' => 'no',
        'diabetes' => 'no',
        'tuberculosis' => 'no',
        'heart_disease' => 'no',
        'pregnancy' => 'not_applicable',
        'allergies' => 'no',
        'medications' => 'no',
        'smoking_history' => 'no',
        'alcohol_consumption' => 'no',
        'previous_surgeries' => 'no',
    ])->assertRedirect();
    Consultation::factory()->create(['patient_id' => $patient->id, 'dentist_id' => $dentist->id]);

    $this->actingAs($dentist)->get("/wizard/{$patient->id}")
        ->assertInertia(fn ($page) => $page->where('resumeStep', 2)); // 2 = waiver (no consent started yet)

    // A patient-signed consent + consultation resumes at the dental chart step
    ConsentForm::factory()->create([
        'patient_id' => $patient->id,
        'dentist_id' => $dentist->id,
        'status' => 'patient_signed',
    ]);

    $this->actingAs($dentist)->get("/wizard/{$patient->id}")
        ->assertInertia(fn ($page) => $page->where('resumeStep', 5)); // 5 = dental chart
});
