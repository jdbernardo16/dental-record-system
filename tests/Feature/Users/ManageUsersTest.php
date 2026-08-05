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
        'name' => 'Dra. Cruz', 'username' => 'cruz', 'email' => 'cruz@clinic.test', 'password' => 'password', 'role' => 'Dentist',
    ])->assertRedirect('/users');

    $user = User::where('email', 'cruz@clinic.test')->first();
    expect($user)->not->toBeNull();
    expect($user->username)->toBe('cruz');
    expect($user->hasRole('Dentist'))->toBeTrue();
});

it('blocks non-admins from managing users', function () {
    $receptionist = User::factory()->create()->assignRole('Receptionist');

    $this->actingAs($receptionist)->get('/users')->assertForbidden();
    $this->actingAs($receptionist)->post('/users', [
        'name' => 'X', 'username' => 'xuser', 'email' => 'x@clinic.test', 'password' => 'password', 'role' => 'Dentist',
    ])->assertForbidden();
});

it('locks out deactivated users', function () {
    $user = User::factory()->create(['is_active' => false])->assignRole('Assistant');

    $this->actingAs($user)->get('/dashboard')->assertForbidden();
});

it('gates the create and edit pages by their action permissions', function () {
    $viewer = User::factory()->create()->givePermissionTo('users.view');

    $this->actingAs($viewer)->get('/users')->assertOk();
    $this->actingAs($viewer)->get('/users/create')->assertForbidden();
    $this->actingAs($viewer)->get('/users/1/edit')->assertForbidden();
});

it('prevents an administrator from deactivating their own account', function () {
    $admin = User::factory()->create()->assignRole('Administrator');

    $this->actingAs($admin)->patch("/users/{$admin->id}", [
        'name' => $admin->name,
        'username' => $admin->username,
        'email' => $admin->email,
        'password' => '',
        'role' => 'Administrator',
        'is_active' => false,
    ])->assertForbidden();

    expect($admin->fresh()->is_active)->toBeTrue();
});
