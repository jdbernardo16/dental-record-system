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

it('renders dashboard widgets for any role', function () {
    $user = User::factory()->create()->assignRole('Assistant');
    $patients = Patient::factory()->count(3)->create();
    Appointment::factory()->count(2)->create([
        'patient_id' => $patients->first()->id,
        'appointment_date' => now()->toDateString(),
        'status' => 'confirmed',
    ]);

    $this->actingAs($user)->get('/dashboard')
        ->assertOk()
        ->assertInertia(fn ($page) => $page
            ->component('Dashboard/Index')
            ->has('todayAppointments', 2)
            ->has('recentPatients', 3)
            ->has('monthlyStats'));
});

it('gates follow-ups and pending procedures behind permissions', function () {
    $user = User::factory()->create()->assignRole('Assistant');

    $this->actingAs($user)->get('/dashboard')
        ->assertOk()
        ->assertInertia(fn ($page) => $page
            ->has('followUps')
            ->has('pendingProcedures.count'));
});
