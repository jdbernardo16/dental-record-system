# DCPRS Phase 4 — Backup & Patient Archiving Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add nightly automated backups (database + file storage with 30d/12m/3y retention) and an inactivity-based patient archival pipeline (soft delete after N years, full-record export to an archive disk, then hard delete with audit logging), plus an operator runbook.

**Architecture:** `spatie/laravel-backup` v9 configured to back up the MySQL database + the `local` disk (uploads/signatures, root `storage/app/public`) into a `backups` disk with spatie's built-in tidy retention (30 daily / 12 monthly / 3 yearly). Archiving: `ArchivePatientsJob` (queued) orchestrated by an `ArchiveService` — stage 1 soft-deletes patients inactive for N years (default 5, setting `archive.inactivity_years`), stage 2 exports soft-deleted patients past a grace period (default 30 days) as JSON + copied files to an `archive` disk, then force-deletes the patient (DB cascade removes clinical rows) and removes their files. A `docs/ops/backup-restore.md` runbook documents schedule, retention, restore, and the monthly drill.

**Tech Stack:** Laravel 12 (PHP 8.4) · spatie/laravel-backup ^9 · spatie/laravel-activitylog v5 (existing) · Pest 3 (TDD) · Laravel scheduler (`routes/console.php`).

**Reference blueprint:** `docs/dental-emr/12-cross-cutting.md` (Backup & Archiving), `18-open-questions.md` (Q14 local disk default / S3-ready; Q15 retention defaults), master plan Phase 4 outline.

**Design decisions (locked):**
- Backup destination disk `backups` (local root `storage/app/backups`, S3-ready via env `BACKUP_DESTINATION`). Archive destination disk `archive` (local root `storage/app/archive`, S3-ready via env `ARCHIVE_DISK`).
- Files-source backup INCLUDES `storage/app/public` (uploads + signatures) and EXCLUDES `storage/app/backups` + `storage/app/archive` (no backup-of-backups).
- Notifications off in v1 (documented in runbook); single nightly full `backup:run` at 02:00; `patients:archive` at 03:00.
- Archive export layout per patient: `archive/{patient_number}-{patient_id}/patient.json` + `archive/{patient_number}-{patient_id}/files/{index}-{basename}` (file copies via driver-agnostic `get`/`put`).
- `patient.archived_soft_delete` and `patient.archived` activity events; hard delete uses `forceDelete()` — DB-level `cascadeOnDelete` FKs remove all clinical child rows; files are deleted explicitly before the force delete.
- The `ArchivePatientsJob` implements `ShouldQueue`; the artisan command `patients:archive` dispatches it (sync in tests).

---

## Phase 4 File Structure

```
config/backup.php                     # published spatie config (name dcprs-backup, db+files sources, backups dest, tidy 30/12/3)
config/archive.php                    # disk, inactivity_years, grace_days
config/filesystems.php                # + backups, archive disks
database/seeders/SettingsSeeder.php   # + archive.inactivity_years = 5
app/Jobs/ArchivePatientsJob.php       # ShouldQueue; runs ArchiveService::run()
app/Services/ArchiveService.php       # softDeleteInactive() / archiveSoftDeleted() / exportPatient() / deletePatientFiles()
app/Console/Commands/ArchivePatientsCommand.php  # patients:archive
routes/console.php                    # schedule backup:run 02:00, patients:archive 03:00
docs/ops/backup-restore.md            # runbook
tests/Unit/BackupConfigTest.php
tests/Feature/Archive/ArchivePatientsTest.php
```

---

## Task 1: Backup foundation — spatie/laravel-backup

**Files:**
- Modify: `composer.json` (via composer require), `config/backup.php` (published + edited), `config/filesystems.php`
- Test: `tests/Unit/BackupConfigTest.php`

- [ ] **Step 1: Install the package**

```bash
composer require spatie/laravel-backup
php artisan vendor:publish --provider="Spatie\Backup\BackupServiceProvider"
```

Expected: `config/backup.php` created, `Spatie\Backup\BackupServiceProvider` registered.

- [ ] **Step 2: Add the `backups` + `archive` disks**

In `config/filesystems.php`, inside the `'disks'` array, add:

```php
'backups' => [
    'driver' => 'local',
    'root' => storage_path('app/backups'),
    'throw' => false,
    'report' => false,
],

'archive' => [
    'driver' => 'local',
    'root' => storage_path('app/archive'),
    'throw' => false,
    'report' => false,
],
```

- [ ] **Step 3: Configure `config/backup.php`**

Edit the published config to match these values (keep the rest of the published file untouched unless noted):

```php
// 'backup' => [
//   'name' => env('APP_NAME', 'laravel-backup'),   → change to:
'name' => 'dcprs-backup',
```

```php
// 'source' => ['databases' => ['databases' => ['mysql']]]  → keep default ['mysql']
```

Files source — set include/exclude:

```php
'files' => [
    'include' => [
        storage_path('app/public'),
    ],
    'exclude' => [
        storage_path('app/backups'),
        storage_path('app/archive'),
    ],
    // 'follow_links' => false,
    // 'relative_path' => null,
],
```

Destination — backup to the local `backups` disk by default, S3-ready via env:

```php
'destination' => [
    'disks' => [
        env('BACKUP_DESTINATION', 'backups'),
    ],
    // 'filename_prefix' => '',
    // 'compression_method' => ZipArchive::CM_DEFLATE,
],
```

Tidy retention (blueprint Q15 defaults):

```php
'tidy' => [
    'daily' => 30,
    'weekly' => 0,
    'monthly' => 12,
    'yearly' => 3,
    // 'maximum_size' => ... leave default
],
```

Notifications — disable in v1 (runbook documents enabling mail/slack in production):

```php
'notifications' => [
    'notifications' => [
        // Spatie\Backup\Notifications\Notifications\BackupHasFailed::class => ['mail'],
        // ... leave the whole array commented out / empty
    ],
],
```

Leave `monitoring`, `cleanup`, `temporary` (set `'temporary' => ['base_path' => base_path('storage/app/backups/temp')]` if the default temp location is inside the excluded dir — default is `base_path('storage/app/backups/temp')`; since `storage/app/backups` is excluded from the files source this is safe).

- [ ] **Step 4: Write the config sanity test**

`tests/Unit/BackupConfigTest.php`:

```php
<?php

use Illuminate\Support\Facades\Storage;

it('configures the backup name, sources, destination and retention', function () {
    expect(config('backup.name'))->toBe('dcprs-backup');
    expect(config('backup.source.databases.databases'))->toContain('mysql');
    expect(config('backup.source.files.include'))->toContain(storage_path('app/public'));
    expect(config('backup.source.files.exclude'))->toContain(storage_path('app/backups'));
    expect(config('backup.destination.disks'))->toContain('backups');
    expect(config('backup.tidy.daily'))->toBe(30);
    expect(config('backup.tidy.monthly'))->toBe(12);
    expect(config('backup.tidy.yearly'))->toBe(3);
});

it('defines the backups and archive disks', function () {
    expect(Storage::disk('backups')->getConfig()->get('root'))->toBe(storage_path('app/backups'));
    expect(Storage::disk('archive')->getConfig()->get('root'))->toBe(storage_path('app/archive'));
});
```

Run: `./vendor/bin/pest tests/Unit/BackupConfigTest.php` → PASS.

- [ ] **Step 5: Manual backup smoke run**

```bash
php artisan backup:run
```

Expected: a zip like `dcprs-backup-2026-08-02-02-00-00.zip` (with the DB dump + `storage/app/public` contents) lands in `storage/app/backups/`. If it fails on permissions/directories, create `storage/app/backups` first (`mkdir -p storage/app/backups`) and retry. Then verify tidy retention works: `php artisan backup:clean` runs without error.

- [ ] **Step 6: Pint + commit**

```bash
./vendor/bin/pint
git add -A && git commit -m "feat: spatie/laravel-backup with local backups disk + 30/12/3 retention"
```

---

## Task 2: Patient archival pipeline

**Files:**
- Create: `config/archive.php`, `app/Services/ArchiveService.php`, `app/Jobs/ArchivePatientsJob.php`, `app/Console/Commands/ArchivePatientsCommand.php`
- Modify: `config/filesystems.php` (already has archive disk from Task 1 — skip if present), `database/seeders/SettingsSeeder.php`
- Test: `tests/Feature/Archive/ArchivePatientsTest.php`

- [ ] **Step 1: Write the failing feature test**

`tests/Feature/Archive/ArchivePatientsTest.php`:

```php
<?php

use App\Jobs\ArchivePatientsJob;
use App\Models\Attachment;
use App\Models\Consultation;
use App\Models\Patient;
use App\Models\User;
use Illuminate\Support\Facades\Storage;

uses(TestCase::class, RefreshDatabase::class);

beforeEach(function () {
    $this->seed(\Database\Seeders\RolePermissionSeeder::class);
    Storage::fake('local');
    Storage::fake('archive');
});

it('soft-deletes patients with no activity for the configured period', function () {
    config()->set('archive.inactivity_years', 5);
    $inactive = Patient::factory()->create(['created_at' => now()->subYears(6)]);
    $active = Patient::factory()->create([
        'created_at' => now()->subYears(6),
        'updated_at' => now()->subYears(6),
    ]);
    Consultation::factory()->create([
        'patient_id' => $active->id,
        'consultation_date' => now()->subMonths(6)->toDateString(),
        'created_at' => now()->subMonths(6),
    ]);

    (new ArchivePatientsJob())->handle();

    expect($inactive->fresh()->trashed())->toBeTrue();
    expect($active->fresh()->trashed())->toBeFalse();
});

it('keeps recently registered patients', function () {
    config()->set('archive.inactivity_years', 5);
    $recent = Patient::factory()->create(['created_at' => now()->subYear()]);

    (new ArchivePatientsJob())->handle();

    expect($recent->fresh()->trashed())->toBeFalse();
});

it('exports and hard-deletes archived patients past the grace period', function () {
    config()->set('archive.grace_days', 30);
    $actor = User::factory()->create();
    $patient = Patient::factory()->create(['patient_number' => '2020-0042']);
    $patient->delete();
    $patient->update(['deleted_at' => now()->subDays(60)]);

    $attachment = Attachment::factory()->create([
        'patient_id' => $patient->id,
        'file_path' => 'uploads/' . $patient->id . '/photo.jpg',
    ]);
    Storage::disk('local')->put($attachment->file_path, 'jpg-bytes');

    $treatment = \App\Models\Treatment::factory()->create([
        'patient_id' => $patient->id,
        'signature_path' => 'signatures/treatments/99.svg',
    ]);
    Storage::disk('local')->put($treatment->signature_path, '<svg/>');

    (new ArchivePatientsJob())->handle();

    $dir = "archive/{$patient->patient_number}-{$patient->id}";
    expect(Storage::disk('archive')->exists("{$dir}/patient.json"))->toBeTrue();
    expect(Storage::disk('archive')->exists("{$dir}/files/0-photo.jpg"))->toBeTrue();
    expect(Storage::disk('archive')->exists("{$dir}/files/1-99.svg"))->toBeTrue();
    expect(Storage::disk('local')->missing($attachment->file_path))->toBeTrue();
    expect(Storage::disk('local')->missing($treatment->signature_path))->toBeTrue();
    expect(Patient::withTrashed()->find($patient->id))->toBeNull();
    expect(Activity::forSubject($patient)->where('event', 'patient.archived')->exists())->toBeTrue();
});

it('does not purge patients within the grace period', function () {
    config()->set('archive.grace_days', 30);
    $patient = Patient::factory()->create();
    $patient->delete();
    $patient->update(['deleted_at' => now()->subDays(5)]);

    (new ArchivePatientsJob())->handle();

    expect(Patient::withTrashed()->find($patient->id))->not->toBeNull();
});
```

Add the missing import: `use Spatie\Activitylog\Models\Activity;` (the test uses `Activity::forSubject`).

Run: `./vendor/bin/pest tests/Feature/Archive` → FAIL (classes missing).

- [ ] **Step 2: Config**

`config/archive.php`:

```php
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
```

- [ ] **Step 3: Service**

`app/Services/ArchiveService.php`:

```php
<?php

namespace App\Services;

use App\Models\Patient;
use Carbon\Carbon;
use Illuminate\Support\Facades\Storage;
use Spatie\Activitylog\Models\Activity;

final class ArchiveService
{
    private const RELATIONS_WITH_ACTIVITY = ['consultations', 'treatments', 'appointments', 'chartEntries', 'attachments', 'consentForms'];

    /**
     * Run the full pipeline.
     *
     * @return array{soft_deleted: int, purged: int}
     */
    public function run(): array
    {
        $years = (int) app(SettingsService::class)->get('archive.inactivity_years', config('archive.inactivity_years', 5));

        return [
            'soft_deleted' => $this->softDeleteInactive(now()->subYears($years)),
            'purged' => $this->archiveSoftDeleted(now()->subDays((int) config('archive.grace_days', 30))),
        ];
    }

    /**
     * Soft-delete patients with no activity in any clinical module since $cutoff.
     */
    public function softDeleteInactive(Carbon $cutoff): int
    {
        $query = Patient::query()
            ->whereNull('deleted_at')
            ->where('created_at', '<', $cutoff);

        foreach (self::RELATIONS_WITH_ACTIVITY as $relation) {
            $query->whereDoesntHave($relation, fn ($q) => $q->where('created_at', '>=', $cutoff));
        }

        $count = 0;

        foreach ($query->get() as $patient) {
            $patient->delete(); // soft delete (audited by LogsActivity)
            activity()->performedOn($patient)->log('patient.archived_soft_delete');
            $count++;
        }

        return $count;
    }

    /**
     * Export and hard-delete patients whose soft delete is past the grace window.
     */
    public function archiveSoftDeleted(Carbon $graceCutoff): int
    {
        $count = 0;

        Patient::onlyTrashed()
            ->where('deleted_at', '<', $graceCutoff)
            ->get()
            ->each(function (Patient $patient) use (&$count): void {
                $this->exportPatient($patient);
                $this->deletePatientFiles($patient);
                activity()->performedOn($patient)->log('patient.archived');
                $patient->forceDelete(); // DB cascade removes clinical child rows
                $count++;
            });

        return $count;
    }

    /**
     * Export the full patient record (JSON + copied files) to the archive disk.
     *
     * @return string relative directory on the archive disk
     */
    public function exportPatient(Patient $patient): string
    {
        $dir = 'archive/' . $patient->patient_number . '-' . $patient->id;

        $payload = [
            'patient' => $patient->attributesToArray(),
            'medical_history' => $patient->medicalHistory?->attributesToArray(),
            'appointments' => $patient->appointments()->get()->toArray(),
            'consultations' => $patient->consultations()->get()->toArray(),
            'chart_entries' => $patient->chartEntries()->get()->toArray(),
            'treatments' => $patient->treatments()->get()->toArray(),
            'attachments' => $patient->attachments()->withTrashed()->get()->toArray(),
            'consent_forms' => $patient->consentForms()->with('sections')->get()->toArray(),
            'archived_at' => now()->toISOString(),
        ];

        Storage::disk(config('archive.disk'))->put(
            "{$dir}/patient.json",
            json_encode($payload, JSON_PRETTY_PRINT | JSON_UNESCAPED_SLASHES)
        );

        $index = 0;

        foreach ($this->patientFilePaths($patient) as $path) {
            if (! Storage::disk('local')->exists($path)) {
                continue;
            }
            Storage::disk(config('archive.disk'))->put(
                "{$dir}/files/{$index}-" . basename($path),
                Storage::disk('local')->get($path)
            );
            $index++;
        }

        return $dir;
    }

    /**
     * Delete the patient's files from the local disk (uploads dir + signature files).
     */
    public function deletePatientFiles(Patient $patient): void
    {
        Storage::disk('local')->deleteDirectory("uploads/{$patient->id}");

        foreach ($this->patientFilePaths($patient) as $path) {
            Storage::disk('local')->delete($path);
        }
    }

    /**
     * All file paths referenced by the patient's clinical rows.
     *
     * @return array<int, string>
     */
    private function patientFilePaths(Patient $patient): array
    {
        $paths = [];

        foreach ($patient->attachments()->withTrashed()->pluck('file_path') as $path) {
            $paths[] = $path;
        }
        foreach ($patient->treatments()->pluck('signature_path')->filter() as $path) {
            $paths[] = $path;
        }
        foreach ($patient->consentForms()->pluck('patient_signature_path')->filter() as $path) {
            $paths[] = $path;
        }
        foreach ($patient->consentForms()->pluck('guardian_signature_path')->filter() as $path) {
            $paths[] = $path;
        }
        foreach ($patient->consentForms()->pluck('dentist_signature_path')->filter() as $path) {
            $paths[] = $path;
        }
        foreach ($patient->consentForms()->with('sections')->get() as $form) {
            foreach ($form->sections->pluck('initial_svg_path')->filter() as $path) {
                $paths[] = $path;
            }
        }

        return array_values(array_unique($paths));
    }
}
```

- [ ] **Step 4: Job + command**

`app/Jobs/ArchivePatientsJob.php`:

```php
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
```

`app/Console/Commands/ArchivePatientsCommand.php`:

```php
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
        dispatch_sync(new ArchivePatientsJob());

        $this->info('Patient archival run completed.');

        return self::SUCCESS;
    }
}
```

- [ ] **Step 5: Seed setting**

In `database/seeders/SettingsSeeder.php` `run()`, add:

```php
$settings->set('archive.inactivity_years', '5');
```

- [ ] **Step 6: Verify pass**

Run: `./vendor/bin/pest tests/Feature/Archive` → PASS (all 4 tests).
Then full suite `./vendor/bin/pest` → green (106 + 4 + 2 config tests).

- [ ] **Step 7: Manual smoke**

```bash
php artisan patients:archive
```

Expected: `Patient archival run completed.` with no errors (no patients match). Also verify a soft-deleted patient is exported: use `php artisan tinker --execute="App\Models\Patient::factory()->create(['created_at' => now()->subYears(6)]);"` then `php artisan patients:archive` then confirm `storage/app/archive/archive/` contains the JSON.

- [ ] **Step 8: Pint + commit**

```bash
./vendor/bin/pint
git add -A && git commit -m "feat: patient archival pipeline (inactivity soft delete, export, purge)"
```

---

## Task 3: Scheduling + operator runbook

**Files:**
- Modify: `routes/console.php`
- Create: `docs/ops/backup-restore.md`

- [ ] **Step 1: Schedule the jobs**

Replace `routes/console.php` with:

```php
<?php

use Illuminate\Foundation\Inspiring;
use Illuminate\Support\Facades\Artisan;
use Illuminate\Support\Facades\Schedule;

Artisan::command('inspire', function () {
    $this->comment(Inspiring::quote());
})->purpose('Display an inspiring quote');

// Nightly full backup (database + storage/app/public) with 30d/12m/3y tidy retention.
Schedule::command('backup:run')->dailyAt('02:00');

// Nightly patient archival (soft delete inactive, purge past grace).
Schedule::command('patients:archive')->dailyAt('03:00');
```

- [ ] **Step 2: Write the runbook**

`docs/ops/backup-restore.md`:

```markdown
# DCPRS — Backup & Restore Runbook

> Operator guide for the nightly backup pipeline and patient archival. Read before touching
> production data. Retention defaults follow blueprint Q15 (30 daily / 12 monthly / 3 yearly).

## 1. What is backed up

| Source | Path / DB | Contents |
|---|---|---|
| Database | `mysql` (default connection) | all tables |
| Files | `storage/app/public/` | `uploads/{patient_id}/` (attachments, X-rays), `signatures/` (consents, treatments) |

Backups land on the `backups` disk (`storage/app/backups/` locally; S3 in production via
`BACKUP_DESTINATION=s3` + S3 env vars). Archive exports land on the `archive` disk
(`storage/app/archive/` locally; `ARCHIVE_DISK=s3` in production).

**Excluded from backups:** `storage/app/backups` and `storage/app/archive` (no backup-of-backups).

## 2. Schedule (Laravel scheduler)

| Time | Command | Effect |
|---|---|---|
| Daily 02:00 | `php artisan backup:run` | full backup + automatic tidy (retention 30d/12m/3y) |
| Daily 03:00 | `php artisan patients:archive` | archival pipeline (below) |

The scheduler must be running: add `* * * * * cd /path/to/dental-record-system && php artisan schedule:run >> /dev/null 2>&1` to the server crontab.

## 3. Manual backup

```bash
php artisan backup:run            # full backup now
php artisan backup:clean          # apply retention now
```

## 4. Restore

### From a backup zip
1. List backups: `php artisan backup:list`
2. Restore (spatie v9): `php artisan backup:restore --backup=dcprs-backup-2026-08-02-02-00-00.zip --no-interaction`
   (or `--backup=latest`). This restores the database dump and files.
3. Manual fallback:
   ```bash
   unzip -l storage/app/backups/<zip>            # inspect contents
   # database: gunzip the db-dump-*.gz inside the zip, then:
   mysql -u <user> -p dental_record_system < db-dump.sql
   # files: unzip the storage/app/public tree back into storage/app/public
   ```
4. Verify: `php artisan migrate:status`, log in, spot-check a patient record + attachment.

> **Monthly drill:** on the first Monday of every month, restore the latest backup to a staging
> copy of the DB and verify one patient's full record (chart, consents, attachments) round-trips.

## 5. Patient archival pipeline

1. **Soft delete** — patients with NO activity (consultations, treatments, appointments, chart
   entries, attachments, consent forms) for `archive.inactivity_years` (default 5; setting
   `archive.inactivity_years`) are soft-deleted nightly. Audit: `patient.archived_soft_delete`.
2. **Grace window** — soft-deleted patients are kept `archive.grace_days` (default 30) so admin
   mistakes can be reverted (`php artisan tinker` → restore `deleted_at = null`).
3. **Purge** — after the grace window, the full record is exported to the archive disk as
   `archive/{patient_number}-{patient_id}/patient.json` + `files/` (copies of attachments and
   signature SVGs), an audit entry `patient.archived` is written, then the patient is hard-deleted
   (DB cascade removes all clinical rows) and their files are removed from the local disk.

Manual run: `php artisan patients:archive`. Tune: settings key `archive.inactivity_years`
(no UI in v1 — edit via seeder or `SettingsService`).

## 6. Troubleshooting

| Symptom | Action |
|---|---|
| `backup:run` fails on permissions | ensure `storage/app/backups` writable; check `storage/logs/laravel.log` |
| Zip too large for local disk | switch `BACKUP_DESTINATION` to S3; check `attachment.max_size_mb` |
| Scheduler not running | verify crontab entry; `php artisan schedule:list` shows the two jobs |
| Archive export missing a patient | run `php artisan patients:archive` manually; check audit log for `patient.archived` |
```

- [ ] **Step 3: Verify + commit**

```bash
php artisan schedule:list   # shows both scheduled commands
./vendor/bin/pest           # full suite green
git add -A && git commit -m "docs: backup/restore runbook + nightly schedule"
```

---

## Self-Review

- **Spec coverage:** backup package + DB/files sources + retention (Task 1) ✓ · S3-ready destination disks via env (Task 1) ✓ · archival job with inactivity soft-delete, full-record export, hard delete, audit (Task 2) ✓ · nightly schedule + runbook with restore steps and monthly drill (Task 3) ✓.
- **Placeholders:** none — all code blocks complete; runbook is concrete.
- **Type consistency:** `ArchiveService::run(): array{soft_deleted, purged}`, `softDeleteInactive(Carbon): int`, `archiveSoftDeleted(Carbon): int`, `exportPatient(Patient): string`, `deletePatientFiles(Patient): void` — used identically by the job and tests. `ArchivePatientsJob::handle(ArchiveService)` matches dispatch. Disk names `backups`/`archive` consistent across filesystems.php, config, and tests.
- **Decisions flagged:** notifications off in v1 (runbook documents enabling); encryption noted as production S3 concern; archive file copy via driver-agnostic get/put (memory-bounded in v1).
