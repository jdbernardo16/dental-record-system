<?php

namespace App\Console\Commands;

use App\Jobs\ArchivePatientsJob;
use Illuminate\Console\Command;

class ArchivePatientsCommand extends Command
{
    protected $signature = 'patients:archive';

    protected $description = 'Soft-delete inactive patients and purge archived records past the grace period';

    public function handle(): int
    {
        dispatch_sync(new ArchivePatientsJob);

        $this->info('Patient archival run completed.');

        return self::SUCCESS;
    }
}
