<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;

class StoreMedicalHistoryRequest extends FormRequest
{
    /**
     * @return array<string, array<int, string>>
     */
    public function rules(): array
    {
        return [
            'hypertension' => ['required', 'in:no,yes,not_applicable'],
            'diabetes' => ['required', 'in:no,yes,not_applicable'],
            'tuberculosis' => ['required', 'in:no,yes,not_applicable'],
            'heart_disease' => ['required', 'in:no,yes,not_applicable'],
            'pregnancy' => ['required', 'in:no,yes,not_applicable'],
            'allergies' => ['required', 'in:no,yes,not_applicable'],
            'medications' => ['required', 'in:no,yes,not_applicable'],
            'smoking_history' => ['required', 'in:no,yes,not_applicable'],
            'alcohol_consumption' => ['required', 'in:no,yes,not_applicable'],
            'previous_surgeries' => ['required', 'in:no,yes,not_applicable'],
            'allergies_details' => ['nullable', 'string', 'max:2000'],
            'medications_details' => ['nullable', 'string', 'max:2000'],
            'smoking_details' => ['nullable', 'string', 'max:2000'],
            'alcohol_details' => ['nullable', 'string', 'max:2000'],
            'surgeries_details' => ['nullable', 'string', 'max:2000'],
            'remarks' => ['nullable', 'string', 'max:2000'],
            'good_health' => ['nullable', 'in:no,yes'],
            'under_medical_treatment' => ['nullable', 'in:no,yes'],
            'medical_treatment_details' => ['nullable', 'string', 'max:1000'],
            'hospitalized' => ['nullable', 'in:no,yes'],
            'hospitalization_details' => ['nullable', 'string', 'max:1000'],
            'nursing' => ['nullable', 'in:no,yes'],
            'birth_control_pills' => ['nullable', 'in:no,yes'],
            'bleeding_time' => ['nullable', 'string', 'max:100'],
            'blood_type' => ['nullable', 'in:A+,A-,B+,B-,AB+,AB-,O+,O-'],
            'blood_pressure' => ['nullable', 'string', 'max:50'],
            'conditions_checklist' => ['nullable', 'array'],
            'conditions_checklist.*' => ['string', 'in:high_blood_pressure,low_blood_pressure,epilepsy,aids_hiv,sexually_transmitted_disease,stomach_ulcers,fainting_seizure,rapid_weight_loss,radiation_therapy,joint_replacement,heart_surgery,heart_attack,thyroid_problem,heart_disease,heart_murmur,hepatitis_liver_disease,rheumatic_fever,hay_fever,respiratory_problems,hepatitis_jaundice,tuberculosis,swollen_ankles,kidney_disease,diabetes,chest_pain,stroke,cancer_tumors,anemia,angina,asthma,emphysema,bleeding_disorders,blood_diseases,head_injuries,arthritis,others'],
            'physician_name' => ['nullable', 'string', 'max:255'],
            'physician_specialty' => ['nullable', 'string', 'max:255'],
            'physician_address' => ['nullable', 'string', 'max:255'],
            'physician_phone' => ['nullable', 'string', 'max:50'],
            'dental_history_previous_dentist' => ['nullable', 'string', 'max:255'],
            'dental_history_last_visit' => ['nullable', 'date'],
            'referral_source' => ['nullable', 'string', 'max:255'],
            'drug_use' => ['nullable', 'in:no,yes'],
            'drug_use_details' => ['nullable', 'string', 'max:1000'],
        ];
    }
}
