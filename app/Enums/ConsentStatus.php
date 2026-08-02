<?php

namespace App\Enums;

enum ConsentStatus: string
{
    use HasMeta;

    case Unsigned = 'unsigned';
    case PatientSigned = 'patient_signed';
    case Signed = 'signed';
    case Voided = 'voided';

    /**
     * @return array<string, array<string, string>>
     */
    public static function meta(): array
    {
        return [
            'unsigned' => ['label' => 'Unsigned', 'color' => 'status-pending'],
            'patient_signed' => ['label' => 'Patient signed', 'color' => 'status-confirmed'],
            'signed' => ['label' => 'Signed', 'color' => 'status-completed'],
            'voided' => ['label' => 'Voided', 'color' => 'status-cancelled'],
        ];
    }
}
