<?php

use App\Models\User;
use Database\Seeders\RolePermissionSeeder;
use Illuminate\Foundation\Testing\RefreshDatabase;

uses(RefreshDatabase::class);

beforeEach(function () {
    $this->seed(RolePermissionSeeder::class);
});

it('paginates the users index at 20 per page', function () {
    User::factory()->count(24)->create();
    $admin = User::factory()->create()->assignRole('Administrator');

    $this->actingAs($admin)->get('/users')
        ->assertOk()
        ->assertInertia(fn ($page) => $page
            ->component('Users/Index')
            ->has('users.data', 20)
            ->where('users.current_page', 1)
            ->where('users.last_page', 2));
});

it('follows the page query param on the users index', function () {
    User::factory()->count(24)->create();
    $admin = User::factory()->create()->assignRole('Administrator');

    $this->actingAs($admin)->get('/users?page=2')
        ->assertOk()
        ->assertInertia(fn ($page) => $page
            ->component('Users/Index')
            ->has('users.data', 5)
            ->where('users.current_page', 2));
});
