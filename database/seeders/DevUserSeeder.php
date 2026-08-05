<?php

namespace Database\Seeders;

use App\Models\User;
use Illuminate\Database\Seeder;

class DevUserSeeder extends Seeder
{
    /**
     * Development accounts — username / password (change before production).
     */
    public function run(): void
    {
        $users = [
            ['username' => 'admin', 'name' => 'Administrator', 'email' => 'admin@test.com', 'role' => 'Administrator'],
            ['username' => 'dentist', 'name' => 'Dr. Ana Reyes', 'email' => 'dentist@test.com', 'role' => 'Dentist'],
            ['username' => 'assistant', 'name' => 'Mia Santos', 'email' => 'assistant@test.com', 'role' => 'Assistant'],
            ['username' => 'receptionist', 'name' => 'Joy Cruz', 'email' => 'receptionist@test.com', 'role' => 'Receptionist'],
        ];

        foreach ($users as $data) {
            $user = User::firstOrCreate(
                ['username' => $data['username']],
                ['name' => $data['name'], 'email' => $data['email'], 'password' => bcrypt('password')],
            );
            $user->syncRoles($data['role']);
        }
    }
}
