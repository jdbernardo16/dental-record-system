<?php

use Illuminate\Contracts\Filesystem\Filesystem;
use Illuminate\Support\Facades\Storage;
use Tests\TestCase;

uses(TestCase::class);

it('configures the backup name, sources, destination and retention', function () {
    // spatie/laravel-backup v10 wraps the backup settings under the top-level
    // 'backup' key, so config paths are backup.backup.*.
    expect(config('backup.backup.name'))->toBe('dcprs-backup');
    expect(config('backup.backup.source.databases'))->toContain(config('database.default'));
    expect(config('backup.backup.source.files.include'))->toContain(storage_path('app/public'));
    expect(config('backup.backup.source.files.exclude'))->toContain(storage_path('app/backups'));
    expect(config('backup.backup.source.files.exclude'))->toContain(storage_path('app/archive'));
    expect(config('backup.backup.destination.disks'))->toContain('backups');

    // v10 retention lives in the top-level cleanup.default_strategy
    // (plan values: 30 daily / 0 weekly / 12 monthly / 3 yearly).
    expect(config('backup.cleanup.default_strategy.keep_all_backups_for_days'))->toBe(30);
    expect(config('backup.cleanup.default_strategy.keep_weekly_backups_for_weeks'))->toBe(0);
    expect(config('backup.cleanup.default_strategy.keep_monthly_backups_for_months'))->toBe(12);
    expect(config('backup.cleanup.default_strategy.keep_yearly_backups_for_years'))->toBe(3);
});

it('defines the backups and archive disks', function () {
    expect(Storage::disk('backups'))->toBeInstanceOf(Filesystem::class);
    expect(config('filesystems.disks.backups.root'))->toBe(storage_path('app/backups'));
    expect(Storage::disk('archive'))->toBeInstanceOf(Filesystem::class);
    expect(config('filesystems.disks.archive.root'))->toBe(storage_path('app/archive'));
});
