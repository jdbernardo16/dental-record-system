<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Spatie\Permission\Models\Permission;
use Spatie\Permission\Models\Role;

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
                'appointments.view',
                'consultations.view', 'consultations.create', 'consultations.update',
                'dental-chart.view', 'dental-chart.update',
                'treatments.view', 'treatments.create', 'treatments.update', 'treatments.sign',
                'attachments.view', 'attachments.upload',
                'consents.view', 'consents.create', 'consents.sign-patient', 'consents.sign-dentist',
            ],
            'Assistant' => [
                'patients.view', 'patients.update',
                'appointments.view', 'appointments.create', 'appointments.update',
                'appointments.cancel', 'appointments.attendance',
                'dental-chart.view',
                'attachments.view', 'attachments.upload',
                'consents.view', 'consents.create', 'consents.sign-patient',
            ],
            'Receptionist' => [
                'patients.view', 'patients.create',
                'appointments.view', 'appointments.create', 'appointments.update',
                'appointments.cancel', 'appointments.attendance',
            ],
        ];

        foreach ($rolePermissions as $name => $permissions) {
            Role::firstOrCreate(['name' => $name])->syncPermissions($permissions);
        }
    }
}
