<?php

namespace App\Services;

use App\Models\Setting;
use Illuminate\Support\Facades\Cache;

final class SettingsService
{
    public function get(string $key, mixed $default = null): mixed
    {
        return Cache::remember("settings.{$key}", 60, fn () => Setting::where('key', $key)->value('value') ?? $default);
    }

    public function set(string $key, mixed $value, string $group = 'general'): Setting
    {
        Cache::forget("settings.{$key}");

        return Setting::updateOrCreate(['key' => $key], ['value' => $value, 'group' => $group]);
    }
}
