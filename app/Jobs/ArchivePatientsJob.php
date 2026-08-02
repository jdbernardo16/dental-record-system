<?php

namespace App\Jobs;

use App\Services\ArchiveService;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Foundation\Queue\Queueable;

class ArchivePatientsJob implements ShouldQueue
{
    use Queueable;

    public function handle(ArchiveService $service): void
    {
        $service->run();
    }
}
