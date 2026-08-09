<?php

use App\Models\User;
use Database\Seeders\RolePermissionSeeder;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Spatie\Permission\Models\Role;

uses(RefreshDatabase::class);

it('seeds the three roles with the full permission catalogue', function () {
    $this->seed(RolePermissionSeeder::class);

    expect(Role::pluck('name')->all())->toContain('Administrator', 'Dentist', 'Assistant');
    expect(Role::pluck('name')->all())->not->toContain('Receptionist');
    expect(Role::where('name', 'Administrator')->first()->permissions)->toHaveCount(count(array_merge(...array_values(config('permissions')))));

    // Assistant carries the merged Assistant + Receptionist permission set
    $assistant = User::factory()->create()->assignRole('Assistant');
    expect($assistant->can('appointments.create'))->toBeTrue();
    expect($assistant->can('patients.create'))->toBeTrue();
    expect($assistant->can('patients.update'))->toBeTrue();
    expect($assistant->can('medical-histories.create'))->toBeTrue();
    expect($assistant->can('attachments.upload'))->toBeTrue();
    expect($assistant->can('patients.delete'))->toBeFalse();
    expect($assistant->can('medical-histories.view'))->toBeFalse();
});
