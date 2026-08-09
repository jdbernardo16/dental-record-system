<?php

use App\Models\Patient;
use App\Models\User;
use Database\Seeders\RolePermissionSeeder;
use Illuminate\Foundation\Testing\RefreshDatabase;

uses(RefreshDatabase::class);

beforeEach(function () {
    $this->seed(RolePermissionSeeder::class);
});

it('stores the PDA medical history expansion fields', function () {
    $dentist = User::factory()->create()->assignRole('Dentist');
    $patient = Patient::factory()->create();

    $this->actingAs($dentist)->post("/patients/{$patient->id}/medical-history", [
        'hypertension' => 'no', 'diabetes' => 'no', 'tuberculosis' => 'no',
        'heart_disease' => 'no', 'pregnancy' => 'no', 'allergies' => 'no',
        'medications' => 'no', 'smoking_history' => 'no', 'alcohol_consumption' => 'no',
        'previous_surgeries' => 'no',
        'good_health' => 'yes',
        'under_medical_treatment' => 'yes', 'medical_treatment_details' => 'Lisinopril 10mg',
        'hospitalized' => 'no',
        'nursing' => 'no',
        'birth_control_pills' => 'no',
        'bleeding_time' => 'normal',
        'blood_type' => 'O+',
        'blood_pressure' => '120/80',
        'conditions_checklist' => ['high_blood_pressure', 'diabetes'],
        'physician_name' => 'Dr. Reyes',
        'physician_specialty' => 'Cardiology',
        'physician_address' => 'St. Luke\'s',
        'physician_phone' => '0917-555-1234',
        'dental_history_previous_dentist' => 'Dr. Santos',
        'dental_history_last_visit' => '2025-12-01',
        'referral_source' => 'Friend',
        'drug_use' => 'no',
    ])->assertRedirect();

    $history = $patient->medicalHistory->fresh();
    expect($history->good_health)->toBe('yes');
    expect($history->medical_treatment_details)->toBe('Lisinopril 10mg');
    expect($history->blood_type)->toBe('O+');
    expect($history->conditions_checklist)->toBe(['high_blood_pressure', 'diabetes']);
    expect($history->dental_history_last_visit)->not->toBeNull();
    expect($history->referral_source)->toBe('Friend');
});

it('keeps existing rows when the expansion columns are null', function () {
    $dentist = User::factory()->create()->assignRole('Dentist');
    $patient = Patient::factory()->create();

    $this->actingAs($dentist)->post("/patients/{$patient->id}/medical-history", [
        'hypertension' => 'yes', 'diabetes' => 'no', 'tuberculosis' => 'no',
        'heart_disease' => 'no', 'pregnancy' => 'no', 'allergies' => 'no',
        'medications' => 'no', 'smoking_history' => 'no', 'alcohol_consumption' => 'no',
        'previous_surgeries' => 'no',
    ])->assertRedirect();

    $history = $patient->medicalHistory->fresh();
    expect($history->hypertension)->toBe('yes');
    expect($history->good_health)->toBeNull();
});

it('stores the PDA patient fields', function () {
    $receptionist = User::factory()->create()->assignRole('Assistant');

    $this->actingAs($receptionist)->post('/patients', [
        'first_name' => 'Liza', 'last_name' => 'Reyes', 'sex' => 'female',
        'birth_date' => '1995-05-05', 'civil_status' => 'married', 'nationality' => 'Filipino',
        'contact_number' => '09171234567', 'address' => 'QC',
        'emergency_contact_person' => 'John', 'emergency_contact_number' => '09179876543',
        'religion' => 'Roman Catholic',
        'nickname' => 'Liz',
        'home_phone' => '02-8123-4567',
        'office_phone' => '02-8765-4321',
        'fax_number' => null,
        'dental_insurance' => 'PhilHealth',
        'effective_date' => '2026-01-01',
        'guardian_name' => null,
        'guardian_occupation' => null,
    ])->assertRedirect();

    $patient = Patient::where('last_name', 'Reyes')->first();
    expect($patient->religion)->toBe('Roman Catholic');
    expect($patient->nickname)->toBe('Liz');
    expect($patient->dental_insurance)->toBe('PhilHealth');
    expect($patient->effective_date)->not->toBeNull();
});
