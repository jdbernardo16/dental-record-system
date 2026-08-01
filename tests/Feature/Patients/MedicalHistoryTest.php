<?php

use App\Models\Patient;
use App\Models\User;
use Database\Seeders\RolePermissionSeeder;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\DB;

uses(RefreshDatabase::class);

beforeEach(function () {
    $this->seed(RolePermissionSeeder::class);
});

it('saves all ten screening questions for a patient', function () {
    $dentist = User::factory()->create()->assignRole('Dentist');
    $patient = Patient::factory()->create();

    $this->actingAs($dentist)->post("/patients/{$patient->id}/medical-history", [
        'hypertension' => 'yes', 'diabetes' => 'no', 'tuberculosis' => 'no',
        'heart_disease' => 'no', 'pregnancy' => 'not_applicable',
        'allergies' => 'yes', 'allergies_details' => 'Penicillin',
        'medications' => 'no', 'smoking_history' => 'no',
        'alcohol_consumption' => 'no', 'previous_surgeries' => 'no',
        'remarks' => null,
    ])->assertRedirect();

    expect($patient->medicalHistory->allergies_details)->toBe('Penicillin');
    expect($patient->medicalHistory->pregnancy)->toBe('not_applicable');
});

it('updates existing medical history instead of duplicating', function () {
    $dentist = User::factory()->create()->assignRole('Dentist');
    $patient = Patient::factory()->create();

    $payload = ['hypertension' => 'yes', 'diabetes' => 'no', 'tuberculosis' => 'no',
        'heart_disease' => 'no', 'pregnancy' => 'no', 'allergies' => 'no',
        'medications' => 'no', 'smoking_history' => 'no',
        'alcohol_consumption' => 'no', 'previous_surgeries' => 'no'];

    $this->actingAs($dentist)->post("/patients/{$patient->id}/medical-history", [...$payload, 'hypertension' => 'no']);
    $this->actingAs($dentist)->post("/patients/{$patient->id}/medical-history", [...$payload, 'hypertension' => 'yes']);

    expect(DB::table('medical_histories')->where('patient_id', $patient->id)->count())->toBe(1);
    expect($patient->medicalHistory->hypertension)->toBe('yes');
});

it('blocks receptionists from editing medical history', function () {
    $user = User::factory()->create()->assignRole('Receptionist');
    $patient = Patient::factory()->create();

    $this->actingAs($user)->post("/patients/{$patient->id}/medical-history", [
        'hypertension' => 'no', 'diabetes' => 'no', 'tuberculosis' => 'no',
        'heart_disease' => 'no', 'pregnancy' => 'no', 'allergies' => 'no',
        'medications' => 'no', 'smoking_history' => 'no',
        'alcohol_consumption' => 'no', 'previous_surgeries' => 'no',
    ])->assertForbidden();
});
