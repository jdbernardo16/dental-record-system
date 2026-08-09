<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Spatie\Permission\Models\Permission;
use Spatie\Permission\Models\Role;
use App\Models\User;

class RolePermissionSeeder extends Seeder
{
    public function run(): void
    {
        foreach (array_merge(...array_values(config('permissions'))) as $name) {
            Permission::firstOrCreate(['name' => $name]);
        }

        $rolePermissions = [
            'Administrator' => Permission::all()->pluck('name'),
            'Dentist' => [
                'patients.view', 'patients.create', 'patients.update',
                'medical-histories.view', 'medical-histories.create', 'medical-histories.update',
                'appointments.view', 'appointments.update', 'appointments.cancel', 'appointments.attendance',
                'consultations.view', 'consultations.create', 'consultations.update',
                'dental-chart.view', 'dental-chart.update',
                'treatments.view', 'treatments.create', 'treatments.update', 'treatments.sign',
                'attachments.view', 'attachments.upload',
                'consents.view', 'consents.create', 'consents.sign-patient', 'consents.sign-dentist',
            ],
            // Assistant = merged Receptionist + Assistant permissions (one
            // front-desk account type).
            'Assistant' => [
                'patients.view', 'patients.create', 'patients.update',
                'medical-histories.create',
                'appointments.view', 'appointments.create', 'appointments.update',
                'appointments.cancel', 'appointments.attendance',
                'dental-chart.view',
                'attachments.view', 'attachments.upload',
                'consents.view', 'consents.create', 'consents.sign-patient',
            ],
        ];

        foreach ($rolePermissions as $name => $permissions) {
            Role::firstOrCreate(['name' => $name])->syncPermissions($permissions);
        }

        // Receptionist was merged into Assistant — reassign existing users,
        // then drop the role (applies on re-seed to dev databases). Guarded:
        // User::role() throws when the role name does not exist (fresh DBs).
        if (Role::where('name', 'Receptionist')->exists()) {
            foreach (User::role('Receptionist')->get() as $user) {
                $user->assignRole('Assistant');
            }
            Role::where('name', 'Receptionist')->delete();
        }
    }
}
