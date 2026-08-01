<?php

namespace Database\Factories;

use App\Enums\CivilStatus;
use App\Enums\Sex;
use App\Models\Patient;
use Illuminate\Database\Eloquent\Factories\Factory;

/**
 * @extends Factory<Patient>
 */
class PatientFactory extends Factory
{
    /**
     * Define the model's default state.
     *
     * @return array<string, mixed>
     */
    public function definition(): array
    {
        return [
            'patient_number' => fake()->unique()->numerify(now()->year.'-####'),
            'first_name' => fake()->firstName(),
            'middle_name' => fake()->optional(0.5)->lastName(),
            'last_name' => fake()->lastName(),
            'sex' => fake()->randomElement([Sex::Male->value, Sex::Female->value]),
            'birth_date' => fake()->dateTimeBetween(now()->subYears(90), now()->subYear())->format('Y-m-d'),
            'civil_status' => fake()->randomElement(array_map(fn (CivilStatus $status) => $status->value, CivilStatus::cases())),
            'nationality' => 'Filipino',
            'occupation' => fake()->jobTitle(),
            'contact_number' => fake()->numerify('09#########'),
            'address' => fake()->address(),
            'email_address' => fake()->optional(0.7)->safeEmail(),
            'emergency_contact_person' => fake()->name(),
            'emergency_contact_number' => fake()->numerify('09#########'),
            'created_by' => null,
        ];
    }
}
