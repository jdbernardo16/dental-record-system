<?php

namespace App\Enums;

enum ToothSurface: string
{
    use HasMeta;

    case Occlusal = 'occlusal';
    case Buccal = 'buccal';
    case Lingual = 'lingual';
    case Mesial = 'mesial';
    case Distal = 'distal';

    public static function meta(): array
    {
        return [
            'occlusal' => ['label' => 'Occlusal (O)', 'zone' => 'top'],
            'buccal' => ['label' => 'Buccal (B)', 'zone' => 'bottom-left'],
            'lingual' => ['label' => 'Lingual (L)', 'zone' => 'bottom-right'],
            'mesial' => ['label' => 'Mesial (M)', 'zone' => 'left'],
            'distal' => ['label' => 'Distal (D)', 'zone' => 'right'],
        ];
    }
}
