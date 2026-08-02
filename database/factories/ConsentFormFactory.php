<?php

namespace Database\Factories;

use App\Models\ConsentForm;
use App\Models\Patient;
use App\Models\User;
use Illuminate\Database\Eloquent\Factories\Factory;

/**
 * @extends Factory<ConsentForm>
 */
class ConsentFormFactory extends Factory
{
    public function definition(): array
    {
        return [
            'patient_id' => Patient::factory(),
            'version' => config('consent.version'),
            'consent_text' => [
                'acknowledgment' => config('consent.acknowledgment'),
                'authorization' => config('consent.authorization'),
                'sections' => config('consent.sections'),
            ],
            'patient_name' => fake()->name(),
            'patient_signature_path' => null,
            'guardian_name' => null,
            'guardian_signature_path' => null,
            'dentist_id' => User::factory(),
            'dentist_signature_path' => null,
            'patient_signed_at' => null,
            'dentist_signed_at' => null,
            'ip_address' => null,
            'user_agent' => null,
            'status' => 'unsigned',
        ];
    }
}
