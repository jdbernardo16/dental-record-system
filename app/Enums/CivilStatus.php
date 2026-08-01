<?php

namespace App\Enums;

enum CivilStatus: string
{
    use HasMeta;

    case Single = 'single';
    case Married = 'married';
    case Widowed = 'widowed';
    case Separated = 'separated';
    case Divorced = 'divorced';
    case Annulled = 'annulled';
    case Other = 'other';

    /**
     * @return array<string, array<string, string>>
     */
    public static function meta(): array
    {
        return [
            'single' => ['label' => 'Single'],
            'married' => ['label' => 'Married'],
            'widowed' => ['label' => 'Widowed'],
            'separated' => ['label' => 'Separated'],
            'divorced' => ['label' => 'Divorced'],
            'annulled' => ['label' => 'Annulled'],
            'other' => ['label' => 'Other'],
        ];
    }
}
