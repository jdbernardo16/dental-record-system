<?php

use App\Models\MedicalHistory;
use App\Models\Patient;
use App\Models\User;
use Database\Seeders\RolePermissionSeeder;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\DB;
use Spatie\Activitylog\Models\Activity;

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
    expect($patient->medicalHistory->recorded_by)->toBe($dentist->id);
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
    $user = User::factory()->create()->assignRole('Assistant');
    $patient = Patient::factory()->create();

    $this->actingAs($user)->post("/patients/{$patient->id}/medical-history", [
        'hypertension' => 'no', 'diabetes' => 'no', 'tuberculosis' => 'no',
        'heart_disease' => 'no', 'pregnancy' => 'no', 'allergies' => 'no',
        'medications' => 'no', 'smoking_history' => 'no',
        'alcohol_consumption' => 'no', 'previous_surgeries' => 'no',
    ])->assertForbidden();
});

it('rejects answer values outside the allowed set', function () {
    $dentist = User::factory()->create()->assignRole('Dentist');
    $patient = Patient::factory()->create();

    $this->actingAs($dentist)->post("/patients/{$patient->id}/medical-history", [
        'hypertension' => 'maybe', 'diabetes' => 'no', 'tuberculosis' => 'no',
        'heart_disease' => 'no', 'pregnancy' => 'no', 'allergies' => 'no',
        'medications' => 'no', 'smoking_history' => 'no',
        'alcohol_consumption' => 'no', 'previous_surgeries' => 'no',
    ])->assertInvalid('hypertension');

    expect(DB::table('medical_histories')->where('patient_id', $patient->id)->count())->toBe(0);
});

it('logs medical history saves with audit properties', function () {
    $dentist = User::factory()->create()->assignRole('Dentist');
    $patient = Patient::factory()->create();

    $this->actingAs($dentist)->post("/patients/{$patient->id}/medical-history", [
        'hypertension' => 'yes', 'diabetes' => 'no', 'tuberculosis' => 'no',
        'heart_disease' => 'no', 'pregnancy' => 'no', 'allergies' => 'no',
        'medications' => 'no', 'smoking_history' => 'no',
        'alcohol_consumption' => 'no', 'previous_surgeries' => 'no',
    ])->assertRedirect();

    $history = $patient->medicalHistory;

    $activity = Activity::where('subject_type', MedicalHistory::class)
        ->where('subject_id', $history->id)
        ->first();

    expect($activity)->not->toBeNull();
    expect($activity->description)->toBe('medical_history.saved');
    expect($activity->causer_id)->toBe($dentist->id);
    expect($activity->properties)->not->toBeEmpty();
    expect($activity->properties->get('recorded_by'))->toBe($dentist->id);
    expect($activity->properties->get('changes'))->toBeArray();
});

it('does not expose medical history data to roles without view permission', function () {
    $receptionist = User::factory()->create()->assignRole('Assistant');
    $patient = Patient::factory()->create();

    $this->actingAs($receptionist)->get("/patients/{$patient->id}")
        ->assertOk()
        ->assertInertia(fn ($page) => $page
            ->component('Patients/Show')
            ->missing('medicalHistory'));
});
