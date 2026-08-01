<?php

use App\Models\DentalChartEntry;
use App\Models\Patient;
use App\Models\User;
use Database\Seeders\RolePermissionSeeder;
use Illuminate\Foundation\Testing\RefreshDatabase;

uses(RefreshDatabase::class);

beforeEach(function () {
    $this->seed(RolePermissionSeeder::class);
});

it('renders the chart page with the projected state', function () {
    $dentist = User::factory()->create()->assignRole('Dentist');
    $patient = Patient::factory()->create();
    DentalChartEntry::create([
        'patient_id' => $patient->id, 'tooth_number' => 26, 'dentition' => 'adult',
        'condition' => 'caries', 'surface' => 'occlusal', 'recorded_at' => now()->toDateString(),
        'recorded_by' => $dentist->id,
    ]);

    $this->actingAs($dentist)->get("/patients/{$patient->id}/chart")
        ->assertOk()
        ->assertInertia(fn ($page) => $page
            ->component('Patients/Chart', false)
            ->has('state.26.surfaces.occlusal')
            ->has('history', 1));
});

it('records an immutable chart entry', function () {
    $dentist = User::factory()->create()->assignRole('Dentist');
    $patient = Patient::factory()->create();

    $this->actingAs($dentist)->post('/dental-chart/entries', [
        'patient_id' => $patient->id, 'tooth_number' => 16, 'dentition' => 'adult',
        'condition' => 'caries', 'surface' => 'occlusal', 'restoration_type' => null,
        'recorded_at' => now()->toDateString(),
    ])->assertRedirect();

    expect(DentalChartEntry::count())->toBe(1);
    expect($patient->chartEntries()->first()->condition->value)->toBe('caries');
});

it('rejects out-of-range teeth and missing conditions', function () {
    $dentist = User::factory()->create()->assignRole('Dentist');
    $patient = Patient::factory()->create();

    $this->actingAs($dentist)->post('/dental-chart/entries', [
        'patient_id' => $patient->id, 'tooth_number' => 99, 'dentition' => 'adult',
        'condition' => 'caries', 'recorded_at' => now()->toDateString(),
    ])->assertSessionHasErrors(['tooth_number']);

    $this->actingAs($dentist)->post('/dental-chart/entries', [
        'patient_id' => $patient->id, 'tooth_number' => 16, 'dentition' => 'adult',
        'recorded_at' => now()->toDateString(),
    ])->assertSessionHasErrors(['condition']);
});

it('blocks assistants from updating the chart', function () {
    $assistant = User::factory()->create()->assignRole('Assistant');
    $patient = Patient::factory()->create();

    $this->actingAs($assistant)->post('/dental-chart/entries', [
        'patient_id' => $patient->id, 'tooth_number' => 16, 'dentition' => 'adult',
        'condition' => 'caries', 'recorded_at' => now()->toDateString(),
    ])->assertForbidden();
});
