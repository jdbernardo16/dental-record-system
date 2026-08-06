<?php

use App\Models\Patient;
use App\Models\Treatment;
use App\Models\User;
use Database\Seeders\RolePermissionSeeder;
use Illuminate\Foundation\Testing\RefreshDatabase;

uses(RefreshDatabase::class);

beforeEach(function () {
    $this->seed(RolePermissionSeeder::class);
});

it('renders the patient index with paginated results', function () {
    Patient::factory()->count(25)->create();
    $user = User::factory()->create()->assignRole('Receptionist');

    $this->actingAs($user)->get('/patients?search=')
        ->assertOk()
        ->assertInertia(fn ($page) => $page
            ->component('Patients/Index')
            ->has('patients.data', 20)
            ->has('patients.links'));
});

it('searches patients through the index', function () {
    Patient::factory()->create(['last_name' => 'Bautista']);
    $user = User::factory()->create()->assignRole('Receptionist');

    $this->actingAs($user)->get('/patients?search=Bautista')
        ->assertInertia(fn ($page) => $page->has('patients.data', 1));
});

it('lets receptionists create patients but not delete them', function () {
    $user = User::factory()->create()->assignRole('Receptionist');

    $this->actingAs($user)->post('/patients', [
        'first_name' => 'Liza', 'last_name' => 'Reyes', 'sex' => 'female',
        'birth_date' => '1995-05-05', 'civil_status' => 'married', 'nationality' => 'Filipino',
        'contact_number' => '09171234567', 'address' => 'Quezon City',
        'emergency_contact_person' => 'John', 'emergency_contact_number' => '09179876543',
    ])->assertRedirect();

    $patient = Patient::where('last_name', 'Reyes')->first();
    expect($patient)->not->toBeNull();
    expect($patient->patient_number)->not->toBeNull();

    $this->actingAs($user)->delete("/patients/{$patient->id}")->assertForbidden();
});

it('lets admin view, edit and soft-delete a patient', function () {
    $admin = User::factory()->create()->assignRole('Administrator');
    $patient = Patient::factory()->create();

    $this->actingAs($admin)->get("/patients/{$patient->id}")->assertOk()->assertInertia(fn ($page) => $page->component('Patients/Show'));
    $this->actingAs($admin)->patch("/patients/{$patient->id}", ['first_name' => 'Updated'])->assertRedirect();
    expect($patient->fresh()->first_name)->toBe('Updated');
    $this->actingAs($admin)->delete("/patients/{$patient->id}")->assertRedirect();
    expect($patient->fresh()->trashed())->toBeTrue();
});

it('paginates the record lists on the patient show page', function () {
    $admin = User::factory()->create()->assignRole('Administrator');
    $patient = Patient::factory()->create();
    Treatment::factory()->count(12)->for($patient)->create();

    $this->actingAs($admin)->get("/patients/{$patient->id}")
        ->assertOk()
        ->assertInertia(fn ($page) => $page
            ->component('Patients/Show')
            ->has('treatments.data', 10)
            ->where('treatments.current_page', 1)
            ->where('treatments.last_page', 2)
            ->where('treatments.total', 12));
});

it('returns the requested treatments page on the patient show page', function () {
    $admin = User::factory()->create()->assignRole('Administrator');
    $patient = Patient::factory()->create();
    Treatment::factory()->count(12)->for($patient)->create();

    $this->actingAs($admin)->get("/patients/{$patient->id}?tab=treatments&treatments_page=2")
        ->assertOk()
        ->assertInertia(fn ($page) => $page
            ->component('Patients/Show')
            ->has('treatments.data', 2)
            ->where('treatments.current_page', 2)
            ->where('treatments.total', 12));
});
