<?php

use App\Models\Setting;
use App\Models\User;
use Database\Seeders\RolePermissionSeeder;
use Database\Seeders\SettingsSeeder;
use Illuminate\Foundation\Testing\RefreshDatabase;

uses(RefreshDatabase::class);

beforeEach(function () {
    $this->seed(RolePermissionSeeder::class);
    $this->seed(SettingsSeeder::class);
});

it('lets an administrator view the settings page', function () {
    $admin = User::factory()->create()->assignRole('Administrator');

    $this->actingAs($admin)->get('/settings')
        ->assertOk()
        ->assertInertia(fn ($page) => $page
            ->component('Settings/Index')
            ->has('settings'));
});

it('lets an administrator update settings', function () {
    $admin = User::factory()->create()->assignRole('Administrator');

    $this->actingAs($admin)->patch('/settings', [
        'clinic' => ['name' => 'Teeth & Co.', 'address' => '123 Rizal Ave'],
        'consent' => ['version' => '1.1'],
        'patient' => ['number' => ['prefix' => 'year']],
        'appointment' => ['overlap' => false],
        'attachment' => ['max_size_mb' => 40],
        'archive' => ['inactivity_years' => 5],
    ])->assertRedirect();

    expect(Setting::where('key', 'clinic.name')->value('value'))->toBe('Teeth & Co.');
    expect(Setting::where('key', 'appointment.overlap')->value('value'))->toBe('false');
});

it('blocks dentists from settings', function () {
    $dentist = User::factory()->create()->assignRole('Dentist');

    $this->actingAs($dentist)->get('/settings')->assertForbidden();
    $this->actingAs($dentist)->patch('/settings', ['clinic.name' => 'X'])->assertForbidden();
});

it('validates settings values', function () {
    $admin = User::factory()->create()->assignRole('Administrator');

    $this->actingAs($admin)->patch('/settings', [
        'clinic' => ['name' => ''],
        'consent' => ['version' => ''],
        'patient' => ['number' => ['prefix' => 'x']],
        'appointment' => ['overlap' => 'maybe'],
        'attachment' => ['max_size_mb' => 0],
        'archive' => ['inactivity_years' => 0],
    ])->assertSessionHasErrors(['clinic.name', 'consent.version', 'patient.number.prefix', 'appointment.overlap', 'attachment.max_size_mb', 'archive.inactivity_years']);
});
