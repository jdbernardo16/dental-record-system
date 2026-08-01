<?php

namespace Database\Seeders;

use App\Services\SettingsService;
use Illuminate\Database\Seeder;

class SettingsSeeder extends Seeder
{
    public function run(): void
    {
        $settings = app(SettingsService::class);

        $settings->set('clinic.name', 'Dental Clinic');
        $settings->set('clinic.address', '');
        $settings->set('consent.version', '1.0');
        $settings->set('patient.number.prefix', 'year');
        $settings->set('appointment.overlap', 'false');
        $settings->set('attachment.max_size_mb', '25');
    }
}
