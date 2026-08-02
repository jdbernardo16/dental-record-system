<?php

// config/archive.php — patient archival pipeline settings.
return [
    // Disk where exported patient records are stored (S3-ready via env).
    'disk' => env('ARCHIVE_DISK', 'archive'),

    // Patients with no activity for this many years are soft-deleted (Q15 default).
    'inactivity_years' => (int) env('ARCHIVE_INACTIVITY_YEARS', 5),

    // Days between soft delete and permanent purge (safety window for admin mistakes).
    'grace_days' => (int) env('ARCHIVE_GRACE_DAYS', 30),
];
