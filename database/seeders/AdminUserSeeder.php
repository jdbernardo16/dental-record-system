<?php

namespace Database\Seeders;

use App\Models\User;
use Illuminate\Database\Seeder;

class AdminUserSeeder extends Seeder
{
    public function run(): void
    {
        $admin = User::firstOrCreate(
            ['email' => 'admin@clinic.test'],
            ['name' => 'Administrator', 'password' => bcrypt('password')],
        );

        $admin->syncRoles('Administrator');
    }
}
