<?php

use App\Models\Consultation;
use App\Models\DentalChartEntry;
use App\Models\Patient;
use App\Models\Treatment;
use App\Models\User;
use Database\Seeders\RolePermissionSeeder;
use Illuminate\Foundation\Testing\RefreshDatabase;

uses(RefreshDatabase::class);

beforeEach(function () {
    $this->seed(RolePermissionSeeder::class);
});

it('renders the export page with the full record for a dentist', function () {
    $dentist = User::factory()->create()->assignRole('Dentist');
    $patient = Patient::factory()->create();
    Consultation::factory()->create(['patient_id' => $patient->id, 'dentist_id' => $dentist->id]);
    Treatment::factory()->create(['patient_id' => $patient->id, 'dentist_id' => $dentist->id]);

    $this->actingAs($dentist)->get("/patients/{$patient->id}/export")
        ->assertOk()
        ->assertInertia(fn ($page) => $page
            ->component('Patients/Export')
            ->has('patient')
            ->has('consultations', 1)
            ->has('treatments', 1)
            ->has('chartState.adult')
            ->has('consentForms')
            ->has('attachments')
            ->has('clinic.name')
            ->has('exportedAt'));
});

it('gates clinical sections by permission for assistants', function () {
    $assistant = User::factory()->create()->assignRole('Assistant');
    $patient = Patient::factory()->create();

    // The merged Assistant role can view the dental chart (dental-chart.view)
    // but not medical histories or treatments.
    $this->actingAs($assistant)->get("/patients/{$patient->id}/export")
        ->assertOk()
        ->assertInertia(fn ($page) => $page
            ->where('medicalHistory', null)
            ->where('canViewClinical.medical-history', false)
            ->where('canViewClinical.treatments', false)
            ->whereNotNull('chartState'));
});

it('includes chart history and consent sections for the dentist', function () {
    $dentist = User::factory()->create()->assignRole('Dentist');
    $patient = Patient::factory()->create();
    DentalChartEntry::create([
        'patient_id' => $patient->id, 'tooth_number' => 16, 'dentition' => 'adult',
        'condition' => 'caries', 'surface' => 'occlusal', 'recorded_at' => now()->toDateString(),
        'recorded_by' => $dentist->id,
    ]);

    $this->actingAs($dentist)->get("/patients/{$patient->id}/export")
        ->assertInertia(fn ($page) => $page->has('chartHistory', 1));
});

it('blocks guests from the export page', function () {
    $patient = Patient::factory()->create();

    $this->get("/patients/{$patient->id}/export")->assertRedirect('/login');
});
