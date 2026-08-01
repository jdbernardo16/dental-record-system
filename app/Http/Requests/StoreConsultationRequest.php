<?php

namespace App\Http\Requests;

use App\Models\Consultation;
use Illuminate\Foundation\Http\FormRequest;

class StoreConsultationRequest extends FormRequest
{
    /**
     * Authorization runs before validation so permission failures surface as 403.
     */
    public function authorize(): bool
    {
        if ($this->routeIs('consultations.update')) {
            return $this->user()->can('update', $this->route('consultation'));
        }

        return $this->user()->can('create', Consultation::class);
    }

    /**
     * @return array<string, array<int, mixed>>
     */
    public function rules(): array
    {
        $periodontal = array_keys(Consultation::periodontalOptions());
        $occlusion = array_keys(Consultation::occlusionOptions());
        $appliances = array_keys(Consultation::applianceOptions());
        $tmd = array_keys(Consultation::tmdOptions());

        // PATCH updates may be partial (the plan's edit test sends chief_complaint only).
        $required = $this->routeIs('consultations.update') ? 'sometimes' : 'required';

        return [
            'consultation_date' => [$required, 'date'],
            'chief_complaint' => [$required, 'string', 'max:2000'],
            'examination_findings' => ['nullable', 'string', 'max:4000'],
            'diagnosis' => ['nullable', 'string', 'max:2000'],
            'treatment_plan' => ['nullable', 'string', 'max:4000'],
            'recommendations' => ['nullable', 'string', 'max:2000'],
            'notes' => ['nullable', 'string', 'max:2000'],
            'periodontal_screening' => ['nullable', 'string', 'in:'.implode(',', $periodontal)],
            'occlusion_class' => ['nullable', 'string', 'in:'.implode(',', $occlusion)],
            'overjet' => ['nullable', 'string', 'max:100'],
            'overbite' => ['nullable', 'string', 'max:100'],
            'midline_deviation' => ['nullable', 'string', 'max:100'],
            'crossbite' => ['nullable', 'string', 'max:100'],
            'appliances' => ['nullable', 'array'],
            'appliances.*' => ['string', 'in:'.implode(',', $appliances)],
            'tmd_findings' => ['nullable', 'array'],
            'tmd_findings.*' => ['string', 'in:'.implode(',', $tmd)],
        ];
    }
}
