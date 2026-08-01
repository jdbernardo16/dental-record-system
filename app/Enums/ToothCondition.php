<?php

namespace App\Enums;

enum ToothCondition: string
{
    use HasMeta;

    case Present = 'present';               // ✓ healthy tooth marked explicitly
    case Caries = 'caries';                 // D decayed
    case MissingCaries = 'missing_caries';  // M missing due to caries
    case MissingOther = 'missing_other';    // MO missing due to other causes
    case Impacted = 'impacted';             // Im
    case Supernumerary = 'supernumerary';   // Sp
    case RootFragment = 'root_fragment';    // Rf
    case Unerupted = 'unerupted';           // Un

    /** Whole-tooth only conditions (surfaces must be null). */
    public static function wholeToothOnly(): array
    {
        return [self::MissingCaries->value, self::MissingOther->value, self::Impacted->value, self::Supernumerary->value, self::Unerupted->value];
    }

    public static function meta(): array
    {
        return [
            'present' => ['label' => 'Present (✓)', 'code' => '✓', 'color' => 'cond-present', 'render' => 'check'],
            'caries' => ['label' => 'Decayed (D)', 'code' => 'D', 'color' => 'cond-caries', 'render' => 'solid'],
            'missing_caries' => ['label' => 'Missing — caries (M)', 'code' => 'M', 'color' => 'cond-missing-caries', 'render' => 'missing'],
            'missing_other' => ['label' => 'Missing — other (MO)', 'code' => 'MO', 'color' => 'cond-missing-other', 'render' => 'missing'],
            'impacted' => ['label' => 'Impacted (Im)', 'code' => 'Im', 'color' => 'cond-impacted', 'render' => 'dashed'],
            'supernumerary' => ['label' => 'Supernumerary (Sp)', 'code' => 'Sp', 'color' => 'cond-supernumerary', 'render' => 'solid'],
            'root_fragment' => ['label' => 'Root fragment (Rf)', 'code' => 'Rf', 'color' => 'cond-root-fragment', 'render' => 'solid'],
            'unerupted' => ['label' => 'Unerupted (Un)', 'code' => 'Un', 'color' => 'cond-unerupted', 'render' => 'dashed'],
        ];
    }
}
