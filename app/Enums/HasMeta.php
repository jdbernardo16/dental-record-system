<?php

namespace App\Enums;

trait HasMeta
{
    /**
     * @return array<string, array<string, mixed>> keyed by enum value
     */
    abstract public static function meta(): array;

    /**
     * @return array<string, string>
     */
    public static function labels(): array
    {
        return array_map(fn (array $meta) => $meta['label'], static::meta());
    }

    public static function label(string $value): string
    {
        return static::meta()[$value]['label'] ?? $value;
    }
}
