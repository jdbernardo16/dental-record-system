<?php

namespace Database\Factories;

use App\Models\Patient;
use App\Models\Treatment;
use App\Models\User;
use Illuminate\Database\Eloquent\Factories\Factory;

/**
 * @extends Factory<Treatment>
 */
class TreatmentFactory extends Factory
{
    public function definition(): array
    {
        return [
            'patient_id' => Patient::factory(),
            'consultation_id' => null,
            'tooth_number' => fake()->randomElement([16, 17, 26, 36, 46, null]),
            'procedure_name' => fake()->randomElement(['Composite restoration', 'Scaling and polishing', 'Extraction', 'Root canal treatment', 'Crown placement']),
            'description' => fake()->optional()->sentence(6),
            'notes' => fake()->optional()->sentence(),
            'dentist_id' => User::factory(),
            'treatment_date' => fake()->dateTimeBetween('-6 months', 'now')->format('Y-m-d'),
            'signature_path' => null,
            'signed_at' => null,
        ];
    }
}
