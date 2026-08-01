<?php

namespace App\Enums;

enum Sex: string
{
    use HasMeta;

    case Male = 'male';
    case Female = 'female';

    /**
     * @return array<string, array<string, string>>
     */
    public static function meta(): array
    {
        return [
            'male' => ['label' => 'Male'],
            'female' => ['label' => 'Female'],
        ];
    }
}
