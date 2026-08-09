<?php

namespace App\Http\Requests;

use App\Models\User;
use Illuminate\Foundation\Http\FormRequest;

class StoreAppointmentRequest extends FormRequest
{
    /**
     * @return array<string, array<int, mixed>>
     */
    public function rules(): array
    {
        return [
            'patient_id' => ['required', 'exists:patients,id'],
            'dentist_id' => [
                'nullable',
                'exists:users,id',
                function (string $attribute, mixed $value, callable $fail): void {
                    if ($value !== null && ! User::whereKey($value)
                        ->whereHas('roles', fn ($query) => $query->where('name', 'Dentist'))
                        ->exists()) {
                        $fail('The selected dentist must have the Dentist role.');
                    }
                },
            ],
            'appointment_date' => ['required', 'date', 'after_or_equal:today'],
            'start_time' => ['required', 'date_format:H:i'],
            'end_time' => ['nullable', 'date_format:H:i', 'after:start_time'],
            'reason' => ['nullable', 'string', 'max:255'],
            'is_follow_up' => ['sometimes', 'boolean'],
        ];
    }
}
