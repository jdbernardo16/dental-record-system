# DCPRS — Backup & Restore Runbook

> Operator guide for the nightly backup pipeline and patient archival. Read before touching
> production data. Retention defaults follow blueprint Q15 (30 daily / 12 monthly / 3 yearly).

## 1. What is backed up

| Source | Path / DB | Contents |
|---|---|---|
| Database | `mysql` (default connection) | all tables |
| Files | `storage/app/public/` | `uploads/{patient_id}/` (attachments, X-rays), `signatures/` (consents, treatments) |

Backups land on the `backups` disk, nested under the backup name:
`storage/app/backups/dcprs-backup/<timestamp>.zip` locally (S3 in production via
`BACKUP_DESTINATION=s3` + S3 env vars). Archive exports land on the `archive` disk
(`storage/app/archive/` locally; `ARCHIVE_DISK=s3` in production).

**Excluded from backups:** `storage/app/backups` and `storage/app/archive` (no backup-of-backups).

## 2. Schedule (Laravel scheduler)

| Time | Command | Effect |
|---|---|---|
| Daily 02:00 | `php artisan backup:run` | full backup + automatic cleanup (retention 30 days / 12 months / 3 years) |
| Daily 03:00 | `php artisan patients:archive` | archival pipeline (below) |

The scheduler must be running: add `* * * * * cd /path/to/dental-record-system && php artisan schedule:run >> /dev/null 2>&1` to the server crontab.

## 3. Manual backup

```bash
php artisan backup:run            # full backup now
php artisan backup:clean          # apply retention now (cleanup also runs automatically after each backup)
```

## 4. Restore

### From a backup zip
1. List backups: `php artisan backup:list`
2. Restore (spatie v10): `php artisan backup:restore --backup=dcprs-backup/2026-08-02-02-00-00.zip --no-interaction`
   (or `--backup=latest`). This restores the database dump and files.
3. Manual fallback:
   ```bash
   unzip -l storage/app/backups/dcprs-backup/<zip>    # inspect contents
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
(no UI in v1 — edit via seeder or `SettingsService`); for testing, `ARCHIVE_GRACE_DAYS`
shortens the grace window (e.g. `ARCHIVE_GRACE_DAYS=0` purges eligible patients immediately).

## 6. Troubleshooting

| Symptom | Action |
|---|---|
| `backup:run` fails on permissions | ensure `storage/app/backups` is writable; check `storage/logs/laravel.log` |
| Zip too large for local disk | switch `BACKUP_DESTINATION` to S3; check `attachment.max_size_mb` |
| Scheduler not running | verify crontab entry; `php artisan schedule:list` shows the two jobs |
| Archive export missing a patient | run `php artisan patients:archive` manually; check audit log for `patient.archived` |
