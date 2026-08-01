<?php

namespace App\Enums;

enum RestorationType: string
{
    use HasMeta;

    case Amalgam = 'filling_amalgam';           // Am
    case Composite = 'filling_composite';       // Co
    case Crown = 'crown';                       // JC
    case Abutment = 'abutment';                 // Ab
    case Attachment = 'attachment';             // Att
    case Pontic = 'pontic';                     // P
    case Inlay = 'inlay';                       // In
    case Implant = 'implant';                   // Imp
    case Sealant = 'sealant';                   // S
    case RemovableDenture = 'removable_denture'; // Rm

    public static function meta(): array
    {
        return [
            'filling_amalgam' => ['label' => 'Amalgam (Am)', 'code' => 'Am', 'color' => 'rest-amalgam', 'render' => 'solid'],
            'filling_composite' => ['label' => 'Composite (Co)', 'code' => 'Co', 'color' => 'rest-composite', 'render' => 'solid'],
            'crown' => ['label' => 'Jacket crown (JC)', 'code' => 'JC', 'color' => 'rest-crown', 'render' => 'outline'],
            'abutment' => ['label' => 'Abutment (Ab)', 'code' => 'Ab', 'color' => 'rest-abutment', 'render' => 'solid'],
            'attachment' => ['label' => 'Attachment (Att)', 'code' => 'Att', 'color' => 'rest-attachment', 'render' => 'solid'],
            'pontic' => ['label' => 'Pontic (P)', 'code' => 'P', 'color' => 'rest-pontic', 'render' => 'outline'],
            'inlay' => ['label' => 'Inlay (In)', 'code' => 'In', 'color' => 'rest-inlay', 'render' => 'solid'],
            'implant' => ['label' => 'Implant (Imp)', 'code' => 'Imp', 'color' => 'rest-implant', 'render' => 'solid'],
            'sealant' => ['label' => 'Sealant (S)', 'code' => 'S', 'color' => 'rest-sealant', 'render' => 'solid'],
            'removable_denture' => ['label' => 'Removable denture (Rm)', 'code' => 'Rm', 'color' => 'rest-removable', 'render' => 'outline'],
        ];
    }
}
