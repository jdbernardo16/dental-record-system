<?php

use App\Models\Appointment;
use App\Models\Patient;
use App\Models\User;
use Database\Seeders\RolePermissionSeeder;
use Illuminate\Foundation\Testing\RefreshDatabase;

uses(RefreshDatabase::class);

beforeEach(function () {
    $this->seed(RolePermissionSeeder::class);
});

it('renders the day view with today appointments', function () {
    $user = User::factory()->create()->assignRole('Receptionist');
    $patient = Patient::factory()->create();
    Appointment::factory()->create(['patient_id' => $patient->id, 'appointment_date' => now()->toDateString()]);

    $this->actingAs($user)->get('/appointments')
        ->assertOk()
        ->assertInertia(fn ($page) => $page->component('Appointments/Index')->has('appointments', 1));
});

it('creates an appointment through the store route', function () {
    $user = User::factory()->create()->assignRole('Receptionist');
    $patient = Patient::factory()->create();

    $this->actingAs($user)->post('/appointments', [
        'patient_id' => $patient->id, 'appointment_date' => '2026-08-10',
        'start_time' => '09:00', 'end_time' => '09:30', 'reason' => 'Check-up',
    ])->assertRedirect('/appointments?date=2026-08-10');

    expect(Appointment::count())->toBe(1);
    expect(Appointment::first()->status->value)->toBe('pending');
});

it('rejects a non-dentist user as the assigned dentist', function () {
    $user = User::factory()->create()->assignRole('Receptionist');
    $receptionist = User::factory()->create()->assignRole('Receptionist');
    $patient = Patient::factory()->create();

    $this->actingAs($user)->post('/appointments', [
        'patient_id' => $patient->id,
        'dentist_id' => $receptionist->id,
        'appointment_date' => '2026-08-10',
        'start_time' => '09:00',
        'end_time' => '09:30',
    ])->assertSessionHasErrors('dentist_id');

    expect(Appointment::count())->toBe(0);
});

it('confirms a pending appointment', function () {
    $user = User::factory()->create()->assignRole('Receptionist');
    $appointment = Appointment::factory()->create(['status' => 'pending']);

    $this->actingAs($user)->post("/appointments/{$appointment->id}/confirm")
        ->assertRedirect();

    expect($appointment->fresh()->status->value)->toBe('confirmed');
});

it('reschedules an appointment through the update route', function () {
    $user = User::factory()->create()->assignRole('Receptionist');
    $appointment = Appointment::factory()->create(['status' => 'confirmed']);

    $this->actingAs($user)->patch("/appointments/{$appointment->id}", [
        'appointment_date' => '2026-08-14', 'start_time' => '10:00', 'end_time' => '10:30',
    ])->assertRedirect();

    $appointment->refresh();
    expect($appointment->appointment_date->toDateString())->toBe('2026-08-14');
    expect($appointment->status->value)->toBe('pending');
});

it('records attendance and marks no-show', function () {
    $user = User::factory()->create()->assignRole('Receptionist');
    $appointment = Appointment::factory()->create(['status' => 'confirmed']);

    $this->actingAs($user)->post("/appointments/{$appointment->id}/attendance", ['present' => false])
        ->assertRedirect();

    expect($appointment->fresh()->status->value)->toBe('no_show');
    expect($appointment->fresh()->attended_at)->not->toBeNull();
});

it('marks attendance as completed when present', function () {
    $user = User::factory()->create()->assignRole('Receptionist');
    $appointment = Appointment::factory()->create(['status' => 'confirmed']);

    $this->actingAs($user)->post("/appointments/{$appointment->id}/attendance", ['present' => true])
        ->assertRedirect();

    expect($appointment->fresh()->status->value)->toBe('completed');
});

it('cancels an appointment with a reason', function () {
    $user = User::factory()->create()->assignRole('Receptionist');
    $appointment = Appointment::factory()->create(['status' => 'pending']);

    $this->actingAs($user)->post("/appointments/{$appointment->id}/cancel", ['reason' => 'Patient unavailable'])
        ->assertRedirect();

    expect($appointment->fresh()->status->value)->toBe('cancelled');
});

it('returns a session error when overlapping an existing appointment', function () {
    $user = User::factory()->create()->assignRole('Receptionist');
    $dentist = User::factory()->create()->assignRole('Dentist');
    $patient = Patient::factory()->create();
    Appointment::factory()->create([
        'patient_id' => $patient->id, 'dentist_id' => $dentist->id,
        'appointment_date' => '2026-08-10', 'start_time' => '09:00', 'end_time' => '09:30', 'status' => 'pending',
    ]);

    $this->actingAs($user)->post('/appointments', [
        'patient_id' => $patient->id, 'dentist_id' => $dentist->id,
        'appointment_date' => '2026-08-10', 'start_time' => '09:15', 'end_time' => '09:45',
    ])->assertSessionHasErrors('appointment');

    expect(Appointment::count())->toBe(1);
});

it('blocks users without the appointments.view permission', function () {
    $user = User::factory()->create();

    $this->actingAs($user)->get('/appointments')->assertForbidden();
});
