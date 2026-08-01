<?php

namespace Database\Factories;

use App\Enums\AppointmentStatus;
use App\Models\Appointment;
use App\Models\Patient;
use App\Models\User;
use Carbon\Carbon;
use Illuminate\Database\Eloquent\Factories\Factory;

/**
 * @extends Factory<Appointment>
 */
class AppointmentFactory extends Factory
{
    /**
     * Define the model's default state.
     *
     * @return array<string, mixed>
     */
    public function definition(): array
    {
        return [
            'patient_id' => Patient::factory(),
            'dentist_id' => User::factory(),
            'appointment_date' => fake()->dateTimeBetween('-1 month', '+1 month')->format('Y-m-d'),
            'start_time' => fake()->time('H:i'),
            'end_time' => fn (array $attributes) => Carbon::parse($attributes['start_time'])->addMinutes(30)->format('H:i'),
            'reason' => fake()->sentence(),
            'status' => fake()->randomElement(array_map(fn (AppointmentStatus $status) => $status->value, AppointmentStatus::cases())),
            'notes' => null,
            'created_by' => null,
        ];
    }
}
