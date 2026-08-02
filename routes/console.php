<?php

use Illuminate\Foundation\Inspiring;
use Illuminate\Support\Facades\Artisan;
use Illuminate\Support\Facades\Schedule;

Artisan::command('inspire', function () {
    $this->comment(Inspiring::quote());
})->purpose('Display an inspiring quote');

// Nightly full backup (database + storage/app/public) with 30d/12m/3y retention.
Schedule::command('backup:run')->dailyAt('02:00');

// Nightly patient archival (soft delete inactive, purge past grace).
Schedule::command('patients:archive')->dailyAt('03:00');
