<?php

namespace App\Support;

final class PatientRules
{
    /**
     * Shared validation rules for patient demographics. Used by the store
     * form request and by CSV import row validation.
     *
     * @return array<string, array<int, string>>
     */
    public static function all(): array
    {
        return [
            'first_name' => ['required', 'string', 'max:255'],
            'middle_name' => ['nullable', 'string', 'max:255'],
            'last_name' => ['required', 'string', 'max:255'],
            'sex' => ['required', 'in:male,female'],
            'birth_date' => ['required', 'date', 'before:today'],
            'civil_status' => ['required', 'in:single,married,widowed,separated,divorced,annulled,other'],
            'nationality' => ['required', 'string', 'max:100'],
            'occupation' => ['nullable', 'string', 'max:255'],
            'contact_number' => ['required', 'string', 'regex:/^[0-9+ -]{7,20}$/'],
            'address' => ['required', 'string', 'max:500'],
            'email_address' => ['nullable', 'email', 'max:255'],
            'emergency_contact_person' => ['nullable', 'string', 'max:255'],
            'emergency_contact_number' => ['nullable', 'string', 'max:30'],
            'religion' => ['nullable', 'string', 'max:100'],
            'nickname' => ['nullable', 'string', 'max:100'],
            'home_phone' => ['nullable', 'string', 'max:30'],
            'office_phone' => ['nullable', 'string', 'max:30'],
            'fax_number' => ['nullable', 'string', 'max:30'],
            'dental_insurance' => ['nullable', 'string', 'max:255'],
            'effective_date' => ['nullable', 'date'],
            'guardian_name' => ['nullable', 'string', 'max:255'],
            'guardian_occupation' => ['nullable', 'string', 'max:255'],
        ];
    }
}
