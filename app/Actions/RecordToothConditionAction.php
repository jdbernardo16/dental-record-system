<?php

namespace App\Actions;

use App\Enums\DentitionType;
use App\Enums\ToothCondition;
use App\Models\DentalChartEntry;
use App\Models\Patient;
use App\Models\User;

final class RecordToothConditionAction
{
    public function handle(
        Patient $patient,
        int $tooth,
        string $dentition,
        string $condition,
        ?string $surface,
        ?string $restoration,
        string $recordedAt,
        ?string $notes,
        User $actor
    ): DentalChartEntry {
        abort_unless($actor->can('dental-chart.update'), 403);
        abort_unless(
            DentitionType::isValidTooth($tooth, $dentition),
            422,
            "Tooth {$tooth} is not valid for the {$dentition} dentition."
        );

        $entry = DentalChartEntry::create([
            'patient_id' => $patient->id,
            'tooth_number' => $tooth,
            'dentition' => $dentition,
            'condition' => $condition,
            'surface' => $surface,
            'restoration_type' => $restoration,
            'color_code' => ToothCondition::meta()[$condition]['color'] ?? null,
            'notes' => $notes,
            'recorded_at' => $recordedAt,
            'recorded_by' => $actor->id,
        ]);

        activity()->performedOn($entry)->causedBy($actor)->log('chart.updated');

        return $entry;
    }
}
