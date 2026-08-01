<?php

use App\Enums\AppointmentStatus;
use App\Models\Appointment;
use App\Models\Patient;
use App\Models\User;
use App\Services\AppointmentService;
use App\Services\InvalidTransitionException;
use Database\Seeders\RolePermissionSeeder;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

uses(TestCase::class, RefreshDatabase::class);

beforeEach(function () {
    $this->seed(RolePermissionSeeder::class);

    $this->patient = Patient::factory()->create();
    $this->dentist = User::factory()->create()->assignRole('Dentist');
    $this->receptionist = User::factory()->create()->assignRole('Receptionist');
});

it('follows the spec transitions', function () {
    $appointment = Appointment::factory()->create(['status' => AppointmentStatus::Pending]);
    $service = app(AppointmentService::class);

    expect($service->confirm($appointment, $this->receptionist)->status)->toBe(AppointmentStatus::Confirmed);
    expect($service->markAttendance($appointment, true, $this->receptionist)->status)->toBe(AppointmentStatus::Completed);
});

it('rejects invalid transitions', function () {
    $appointment = Appointment::factory()->create(['status' => AppointmentStatus::Completed]);

    expect(fn () => app(AppointmentService::class)->cancel($appointment, 'late', $this->receptionist))
        ->toThrow(InvalidTransitionException::class);
});

it('blocks overlapping appointments for the same dentist', function () {
    $service = app(AppointmentService::class);
    $service->create([
        'patient_id' => $this->patient->id, 'dentist_id' => $this->dentist->id,
        'appointment_date' => '2026-08-10', 'start_time' => '09:00', 'end_time' => '09:30',
    ], $this->receptionist);

    expect(fn () => $service->create([
        'patient_id' => $this->patient->id, 'dentist_id' => $this->dentist->id,
        'appointment_date' => '2026-08-10', 'start_time' => '09:15', 'end_time' => '09:45',
    ], $this->receptionist))->toThrow(InvalidTransitionException::class);
});

it('moves rescheduled appointments back to pending', function () {
    $appointment = Appointment::factory()->create(['status' => AppointmentStatus::Confirmed]);
    $service = app(AppointmentService::class);

    expect($service->reschedule($appointment, ['appointment_date' => '2026-08-12', 'start_time' => '10:00', 'end_time' => '10:30'], $this->receptionist)->status)
        ->toBe(AppointmentStatus::Pending);
});
