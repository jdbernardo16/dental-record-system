<?php

namespace App\Enums;

enum DentitionType: string
{
    use HasMeta;

    case Adult = 'adult';
    case Primary = 'primary';

    /** Quadrant ranges [first, last] per arch row, mirroring the PDA chart. */
    private const RANGES = [
        'adult' => [[11, 18], [21, 28], [41, 48], [31, 38]],
        'primary' => [[51, 55], [61, 65], [81, 85], [71, 75]],
    ];

    public static function meta(): array
    {
        return [
            'adult' => ['label' => 'Adult', 'teeth' => array_merge(...array_map(fn ($r) => range($r[0], $r[1]), self::RANGES['adult']))],
            'primary' => ['label' => 'Primary', 'teeth' => array_merge(...array_map(fn ($r) => range($r[0], $r[1]), self::RANGES['primary']))],
        ];
    }

    /** @return array<int, array{0: int, 1: int}> */
    public static function ranges(string $dentition): array
    {
        return self::RANGES[$dentition] ?? [];
    }

    public static function isValidTooth(int $tooth, string $dentition): bool
    {
        foreach (self::RANGES[$dentition] ?? [] as [$first, $last]) {
            if ($tooth >= $first && $tooth <= $last) {
                return true;
            }
        }

        return false;
    }

    public static function teeth(string $dentition): array
    {
        return self::meta()[$dentition]['teeth'];
    }
}
