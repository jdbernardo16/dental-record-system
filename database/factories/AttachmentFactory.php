<?php

namespace Database\Factories;

use App\Enums\AttachmentCategory;
use App\Models\Attachment;
use App\Models\Patient;
use App\Models\User;
use Illuminate\Database\Eloquent\Factories\Factory;

/**
 * @extends Factory<Attachment>
 */
class AttachmentFactory extends Factory
{
    public function definition(): array
    {
        return [
            'patient_id' => Patient::factory(),
            'uploaded_by' => User::factory(),
            'category' => fake()->randomElement(AttachmentCategory::cases())->value,
            'xray_type' => null,
            'original_name' => fake()->word().'.jpg',
            'file_path' => 'uploads/'.fake()->uuid().'.jpg',
            'mime_type' => 'image/jpeg',
            'file_size' => fake()->numberBetween(1024, 5 * 1024 * 1024),
            'notes' => null,
        ];
    }
}
