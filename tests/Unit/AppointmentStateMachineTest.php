<?php

use App\Enums\AppointmentStatus;
use App\Models\Appointment;
use App\Models\Patient;
use App\Models\User;
use App\Services\AppointmentService;
use App\Services\InvalidTransitionException;
use Database\Seeders\RolePermissionSeeder;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Spatie\Activitylog\Models\Activity;
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

it('cannot reschedule into an occupied slot', function () {
    $service = app(AppointmentService::class);
    $service->create([
        'patient_id' => $this->patient->id, 'dentist_id' => $this->dentist->id,
        'appointment_date' => '2026-08-10', 'start_time' => '09:00', 'end_time' => '09:30',
    ], $this->receptionist);

    $blocked = $service->create([
        'patient_id' => $this->patient->id, 'dentist_id' => $this->dentist->id,
        'appointment_date' => '2026-08-10', 'start_time' => '10:00', 'end_time' => '10:30',
    ], $this->receptionist);
    $service->confirm($blocked, $this->receptionist);

    expect(fn () => $service->reschedule($blocked, [
        'appointment_date' => '2026-08-10', 'start_time' => '09:00', 'end_time' => '09:30',
    ], $this->receptionist))->toThrow(InvalidTransitionException::class);
});

it('requires a reason to cancel', function () {
    $appointment = Appointment::factory()->create(['status' => AppointmentStatus::Pending]);

    expect(fn () => app(AppointmentService::class)->cancel($appointment, '', $this->receptionist))
        ->toThrow(InvalidTransitionException::class);
});

it('keeps the existing end time when rescheduling omits it', function () {
    $appointment = Appointment::factory()->create(['status' => AppointmentStatus::Confirmed, 'start_time' => '10:00', 'end_time' => '10:30']);
    $service = app(AppointmentService::class);

    $service->reschedule($appointment, ['appointment_date' => '2026-08-12', 'start_time' => '11:00'], $this->receptionist);

    expect($appointment->fresh()->end_time->format('H:i'))->toBe('10:30');
});

it('logs the cancellation reason in the audit trail', function () {
    $appointment = Appointment::factory()->create(['status' => AppointmentStatus::Pending]);
    $service = app(AppointmentService::class);

    $service->cancel($appointment, 'patient moved abroad', $this->receptionist);

    $activity = Activity::where('subject_type', Appointment::class)
        ->where('subject_id', $appointment->id)
        ->latest()
        ->first();

    expect($activity)->not->toBeNull();
    expect($activity->properties->get('reason'))->toBe('patient moved abroad');
});
