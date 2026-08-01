<?php

use App\Actions\RegisterPatientAction;
use App\Models\Patient;
use App\Models\User;
use App\Repositories\PatientRepository;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Spatie\Activitylog\Models\Activity;
use Tests\TestCase;

uses(TestCase::class, RefreshDatabase::class);

it('computes age from birth date', function () {
    $patient = Patient::factory()->create(['birth_date' => now()->startOfYear()->subYears(25)]);

    expect($patient->age)->toBe(25);
});

it('generates sequential zero-padded numbers per year', function () {
    Patient::factory()->create(['created_at' => now()->startOfYear()]);

    $repo = app(PatientRepository::class);

    expect($repo->nextPatientNumber(now()->year))->toBe(now()->format('Y').'-0002');
});

it('registers a patient, assigns a number, and logs activity', function () {
    $actor = User::factory()->create();

    $patient = app(RegisterPatientAction::class)->handle([
        'first_name' => 'Juan',
        'last_name' => 'Dela Cruz',
        'sex' => 'male',
        'birth_date' => '2000-01-01',
        'civil_status' => 'single',
        'nationality' => 'Filipino',
        'contact_number' => '09171234567',
        'address' => 'Manila',
        'emergency_contact_person' => 'Maria',
        'emergency_contact_number' => '09179876543',
    ], $actor);

    expect($patient->patient_number)->toMatch('/^\d{4}-\d{4}$/');
    expect(Activity::where('subject_type', Patient::class)->where('subject_id', $patient->id)->count())->toBe(1);
});

it('searches patients by name, number, or contact', function () {
    Patient::factory()->create(['first_name' => 'Ana', 'last_name' => 'Santos', 'contact_number' => '09171234567']);

    expect(app(PatientRepository::class)->search('Santos')->total())->toBe(1);
    expect(app(PatientRepository::class)->search('09171234567')->total())->toBe(1);
});
