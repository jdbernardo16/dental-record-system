<?php

use App\Models\User;
use Database\Seeders\RolePermissionSeeder;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Spatie\Permission\Models\Role;

uses(RefreshDatabase::class);

it('seeds the four roles with the full permission catalogue', function () {
    $this->seed(RolePermissionSeeder::class);

    expect(Role::pluck('name')->all())->toContain('Administrator', 'Dentist', 'Assistant', 'Receptionist');
    expect(Role::where('name', 'Administrator')->first()->permissions)->toHaveCount(count(array_merge(...array_values(config('permissions')))));

    $receptionist = User::factory()->create()->assignRole('Receptionist');
    expect($receptionist->can('appointments.create'))->toBeTrue();
    expect($receptionist->can('patients.delete'))->toBeFalse();
});
