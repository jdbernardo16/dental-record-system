<?php

namespace Database\Factories;

use App\Models\Consultation;
use App\Models\Patient;
use App\Models\User;
use Illuminate\Database\Eloquent\Factories\Factory;

/**
 * @extends Factory<Consultation>
 */
class ConsultationFactory extends Factory
{
    public function definition(): array
    {
        return [
            'patient_id' => Patient::factory(),
            'dentist_id' => User::factory(),
            'consultation_date' => fake()->dateTimeBetween('-1 year', 'now')->format('Y-m-d'),
            'chief_complaint' => fake()->sentence(5),
            'examination_findings' => fake()->optional()->sentence(8),
            'diagnosis' => fake()->optional()->sentence(4),
            'treatment_plan' => fake()->optional()->sentence(8),
            'recommendations' => fake()->optional()->sentence(6),
            'notes' => fake()->optional()->sentence(),
        ];
    }
}
