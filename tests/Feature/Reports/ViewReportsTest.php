<?php

use App\Models\User;
use Database\Seeders\RolePermissionSeeder;
use Illuminate\Foundation\Testing\RefreshDatabase;

uses(RefreshDatabase::class);

beforeEach(function () {
    $this->seed(RolePermissionSeeder::class);
});

it('renders the reports page for admins', function () {
    $admin = User::factory()->create()->assignRole('Administrator');

    $this->actingAs($admin)->get('/reports')
        ->assertOk()
        ->assertInertia(fn ($page) => $page
            ->component('Reports/Index')
            ->has('patientGrowth')
            ->has('appointmentSummary')
            ->has('procedureSummary')
            ->has('conditionSummary')
            ->has('dentistWorkload'));
});

it('blocks non-admins from reports', function () {
    $dentist = User::factory()->create()->assignRole('Dentist');

    $this->actingAs($dentist)->get('/reports')->assertForbidden();
});

it('exports a CSV report', function () {
    $admin = User::factory()->create()->assignRole('Administrator');

    $this->actingAs($admin)->get('/reports/export?report=patientGrowth&from=2026-01-01&to=2026-12-31')
        ->assertOk()
        ->assertHeader('Content-Type', 'text/csv; charset=utf-8');
});
