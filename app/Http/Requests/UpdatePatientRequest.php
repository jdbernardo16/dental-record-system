<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;

class UpdatePatientRequest extends FormRequest
{
    /**
     * @return array<string, array<int, string>>
     */
    public function rules(): array
    {
        return [
            'first_name' => ['sometimes', 'required', 'string', 'max:255'],
            'middle_name' => ['sometimes', 'nullable', 'string', 'max:255'],
            'last_name' => ['sometimes', 'required', 'string', 'max:255'],
            'sex' => ['sometimes', 'required', 'in:male,female'],
            'birth_date' => ['sometimes', 'required', 'date', 'before:today'],
            'civil_status' => ['sometimes', 'required', 'in:single,married,widowed,separated,divorced,annulled,other'],
            'nationality' => ['sometimes', 'required', 'string', 'max:100'],
            'occupation' => ['sometimes', 'nullable', 'string', 'max:255'],
            'contact_number' => ['sometimes', 'required', 'string', 'regex:/^[0-9+ -]{7,20}$/'],
            'address' => ['sometimes', 'required', 'string', 'max:500'],
            'email_address' => ['sometimes', 'nullable', 'email', 'max:255'],
            'emergency_contact_person' => ['sometimes', 'required', 'string', 'max:255'],
            'emergency_contact_number' => ['sometimes', 'required', 'string', 'regex:/^[0-9+ -]{7,20}$/'],
            'religion' => ['sometimes', 'nullable', 'string', 'max:100'],
            'nickname' => ['sometimes', 'nullable', 'string', 'max:100'],
            'home_phone' => ['sometimes', 'nullable', 'string', 'max:30'],
            'office_phone' => ['sometimes', 'nullable', 'string', 'max:30'],
            'fax_number' => ['sometimes', 'nullable', 'string', 'max:30'],
            'dental_insurance' => ['sometimes', 'nullable', 'string', 'max:255'],
            'effective_date' => ['sometimes', 'nullable', 'date'],
            'guardian_name' => ['sometimes', 'nullable', 'string', 'max:255'],
            'guardian_occupation' => ['sometimes', 'nullable', 'string', 'max:255'],
        ];
    }
}
