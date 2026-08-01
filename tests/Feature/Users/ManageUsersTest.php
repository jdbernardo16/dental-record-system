<?php

use App\Models\User;
use Database\Seeders\RolePermissionSeeder;
use Illuminate\Foundation\Testing\RefreshDatabase;

uses(RefreshDatabase::class);

beforeEach(function () {
    $this->seed(RolePermissionSeeder::class);
});

it('lets an administrator create a user with a role', function () {
    $admin = User::factory()->create()->assignRole('Administrator');

    $this->actingAs($admin)->post('/users', [
        'name' => 'Dra. Cruz', 'email' => 'cruz@clinic.test', 'password' => 'password', 'role' => 'Dentist',
    ])->assertRedirect('/users');

    $user = User::where('email', 'cruz@clinic.test')->first();
    expect($user)->not->toBeNull();
    expect($user->hasRole('Dentist'))->toBeTrue();
});

it('blocks non-admins from managing users', function () {
    $receptionist = User::factory()->create()->assignRole('Receptionist');

    $this->actingAs($receptionist)->get('/users')->assertForbidden();
    $this->actingAs($receptionist)->post('/users', [
        'name' => 'X', 'email' => 'x@clinic.test', 'password' => 'password', 'role' => 'Dentist',
    ])->assertForbidden();
});

it('locks out deactivated users', function () {
    $user = User::factory()->create(['is_active' => false])->assignRole('Assistant');

    $this->actingAs($user)->get('/dashboard')->assertForbidden();
});
