# DCPRS — Production Deployment Runbook

> Operator guide for deploying and maintaining the Dental Clinic Patient Record System
> (DCPRS) in production. Read `backup-restore.md` before touching production data.

## 1. Server requirements

| Component | Version / Notes |
|---|---|
| PHP | 8.4+ (extensions: `pdo_mysql`, `mbstring`, `xml`, `zip`, `gd`) |
| MySQL / MariaDB | MySQL 8.0+ (or MariaDB 10.6+) |
| Node.js | 20+ (build only — not needed at runtime) |
| Composer | 2.x |
| Web server | Nginx (or Apache) with document root pointed at `public/` |

## 2. Fresh install

```bash
git clone git@github.com:jdbernardo16/dental-record-system.git /var/www/dental-record-system
cd /var/www/dental-record-system
composer install --no-dev --optimize-autoloader
cp .env.example .env
php artisan key:generate
# edit .env: APP_ENV=production, APP_DEBUG=false, APP_URL, DB_*, MAIL_*, BACKUP_DESTINATION=s3, ARCHIVE_DISK=s3, AWS_*
npm ci && npm run build
php artisan migrate --force
php artisan storage:link
php artisan config:cache && php artisan route:cache && php artisan view:cache
```

## 3. Initial admin

Create the first administrator with a generated password:

```bash
php artisan tinker --execute="App\Models\User::updateOrCreate(['email' => 'admin@clinic.test'], ['name' => 'Administrator', 'password' => bcrypt(Str::password(16))])->assignRole('Administrator');"
```

> **Warning:** the password is printed by `Str::password(16)` — copy it once, sign in, and
> **immediately change it** from the profile page. Do not reuse a known/predictable password;
> the tinker one-liner with a generated password is the supported bootstrap path (the seeder
> is for local development, not production).

## 4. Scheduler + queue

Scheduler (nightly backups at 02:00, archival at 03:00) — add to the `www-data` (or app user) crontab:

```cron
* * * * * cd /var/www/dental-record-system && php artisan schedule:run >> /dev/null 2>&1
```

Queue worker (mail jobs) via supervisor — `/etc/supervisor/conf.d/dcprs-worker.conf`:

```ini
[program:dcprs-worker]
process_name=%(program_name)s_%(process_num)02d
command=php /var/www/dental-record-system/artisan queue:work --tries=3 --timeout=300
autostart=true
autorestart=true
numprocs=1
user=www-data
redirect_stderr=true
stdout_logfile=/var/www/dental-record-system/storage/logs/queue-worker.log
stopwaitsecs=3600
```

```bash
supervisorctl reread && supervisorctl update && supervisorctl start dcprs-worker:*
```

For a serverless/cron-only setup, `php artisan queue:work --once` (via the scheduler or a
dedicated cron line) processes one job per invocation instead of a long-running worker.

## 5. Backup verification checklist

After the first night (or a manual `php artisan backup:run`):

1. `php artisan backup:list` — confirm a zip exists for the current date under
   `dcprs-backup/` (S3 bucket in production).
2. Spot-check the zip contents (`unzip -l storage/app/backups/dcprs-backup/<zip>` locally;
   S3: download + inspect) — must contain the DB dump and the `storage/app/public` tree.
3. `php artisan patients:archive` — run the archival pipeline in a dry state and confirm it
   reports no unexpected deletions (it soft-deletes only patients inactive for
   `ARCHIVE_INACTIVITY_YEARS` years; soft-deleted rows sit in the grace window for
   `ARCHIVE_GRACE_DAYS` before purge).
4. Restore drill: follow `docs/ops/backup-restore.md` (monthly, restore the latest backup to a
   staging copy of the DB and verify one patient's full record round-trips).

## 6. Security checklist

- [ ] `APP_DEBUG=false` and `APP_ENV=production` in `.env` (and re-run `config:cache` after any change).
- [ ] HTTPS enforced: `APP_URL=https://...`, redirect HTTP → HTTPS in Nginx, and set
      `TRUSTED_PROXIES` (e.g. `*` or the LB/Cloudflare ranges) so Laravel generates HTTPS URLs.
- [ ] `storage/` and `.env` not web-accessible — Laravel's `public/` layout keeps them out of the
      document root; in Nginx also deny dotfiles explicitly:
      `location ~ /\. { deny all; }` (covers `.env` if the repo root ever gets served).
- [ ] `SESSION_SECURE_COOKIE=true` under HTTPS (add to `.env`).
- [ ] Files permissions: directories `775`, files `664`, owner/group `www-data` (web group)
      across `storage/` and `bootstrap/cache/`.
- [ ] Optional: fail2ban on the SSH and any exposed web endpoints; keep OS packages patched.
- [ ] `composer install --no-dev` (dev dependencies never present in production).
- [ ] Backup destination is S3 (`BACKUP_DESTINATION=s3`, `ARCHIVE_DISK=s3`) so a server loss
      does not lose the archives.

## 7. Update flow

```bash
cd /var/www/dental-record-system
git pull
composer install --no-dev -o
npm ci && npm run build
php artisan migrate --force
php artisan config:cache && php artisan route:cache && php artisan view:cache
php artisan queue:restart
```

Run `php artisan backup:run` after the migrate if the update touches schema you want to be able
to roll back to. Check `storage/logs/laravel.log` for post-deploy errors, then verify the
scheduler still fires (`tail` the backup log / `php artisan backup:list`).
