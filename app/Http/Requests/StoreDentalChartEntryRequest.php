<?php

namespace App\Http\Requests;

use App\Enums\DentitionType;
use App\Enums\RestorationType;
use App\Enums\ToothCondition;
use App\Enums\ToothSurface;
use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rule;

class StoreDentalChartEntryRequest extends FormRequest
{
    /**
     * @return array<string, array<int, mixed>>
     */
    public function rules(): array
    {
        $conditions = array_map(fn (ToothCondition $c) => $c->value, ToothCondition::cases());
        $surfaces = array_map(fn (ToothSurface $s) => $s->value, ToothSurface::cases());
        $restorations = array_map(fn (RestorationType $r) => $r->value, RestorationType::cases());
        $dentitions = array_map(fn (DentitionType $d) => $d->value, DentitionType::cases());

        return [
            'patient_id' => ['required', 'exists:patients,id'],
            'tooth_number' => ['required', 'integer', 'min:11', 'max:85'],
            'dentition' => ['required', Rule::in($dentitions)],
            'condition' => ['required', Rule::in($conditions)],
            'surface' => ['nullable', Rule::in($surfaces)],
            'restoration_type' => ['nullable', Rule::in($restorations)],
            'recorded_at' => ['required', 'date'],
            'notes' => ['nullable', 'string', 'max:1000'],
        ];
    }
}
