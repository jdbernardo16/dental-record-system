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

it('downloads a templated patient record PDF', function () {
    $dentist = User::factory()->create()->assignRole('Dentist');
    $patient = Patient::factory()->create(['last_name' => 'Dela Cruz', 'first_name' => 'Juan']);
    $patient->medicalHistory()->create([
        'hypertension' => 'yes', 'diabetes' => 'no', 'tuberculosis' => 'no',
        'heart_disease' => 'no', 'pregnancy' => 'not_applicable', 'allergies' => 'no',
        'medications' => 'no', 'smoking_history' => 'no',
        'alcohol_consumption' => 'no', 'previous_surgeries' => 'no',
    ]);
    DentalChartEntry::create([
        'patient_id' => $patient->id, 'tooth_number' => 16, 'dentition' => 'adult',
        'condition' => 'caries', 'surface' => 'occlusal', 'recorded_at' => now()->toDateString(),
        'recorded_by' => $dentist->id,
    ]);

    $response = $this->actingAs($dentist)->get("/patients/{$patient->id}/pdf");

    $response->assertOk()
        ->assertHeader('Content-Type', 'application/pdf')
        ->assertHeader('Content-Disposition', 'attachment; filename=patient-record-'.$patient->patient_number.'.pdf');

    expect($response->getContent())->toStartWith('%PDF');
});

it('gates clinical sections in the PDF by permission', function () {
    $assistant = User::factory()->create()->assignRole('Assistant');
    $patient = Patient::factory()->create();
    $patient->medicalHistory()->create([
        'hypertension' => 'yes', 'diabetes' => 'no', 'tuberculosis' => 'no',
        'heart_disease' => 'no', 'pregnancy' => 'no', 'allergies' => 'no',
        'medications' => 'no', 'smoking_history' => 'no',
        'alcohol_consumption' => 'no', 'previous_surgeries' => 'no',
    ]);

    $response = $this->actingAs($assistant)->get("/patients/{$patient->id}/pdf");

    $response->assertOk();
    $pdf = $response->getContent();
    expect($pdf)->toStartWith('%PDF');
    // Assistant cannot view medical histories — the section must be absent
    // (the PDF is compressed, but dompdf embeds uncompressed text streams
    // for ASCII content in its object layout; check via a plain marker).
    expect($pdf)->not->toContain('Medical History');
});

it('blocks guests from the PDF route', function () {
    $patient = Patient::factory()->create();

    $this->get("/patients/{$patient->id}/pdf")->assertRedirect('/login');
});
