# DCPRS — Hostinger Deployment Runbook

> Live deployment setup: `main` branch, build assets committed to the repo, manual
> `git pull` + `deploy.sh` over SSH into Hostinger shared hosting. Read
> `backup-restore.md` before touching production data.

## 0. How updates reach the live site

1. Build locally: `npm run build` (the `public/build` output is committed to the repo —
   the server never builds).
2. Merge the code + build files into `main` and push.
3. SSH into Hostinger and pull + deploy: `cd <app> && git pull origin main && bash deploy.sh`
   (deploy.sh runs composer install, caches, migrate, storage link, permissions).
4. Verify the live site.

There is no CI pipeline — the deploy step is always the same one command on the server.

## 1. GitHub one-time setup

1. Register a read-only **deploy key** (Settings → Deploy keys) with the **public** key
   generated on the server (§2.5) so the server can `git pull` from GitHub.
2. Recommended: enable branch protection on `main` requiring a PR from `develop`
   (Settings → Branches). This keeps "never commit to main" enforced; merge releases
   via the GitHub UI PR.

## 2. Hostinger one-time setup

1. hPanel → Advanced → SSH Access → enable. Note host, user, port. Make sure your own
   SSH key is registered in hPanel (Advanced → SSH Access → SSH Keys) so you can log in.
2. hPanel → Websites → your site → set PHP version **8.4** (the committed `composer.lock`
   pins Symfony v8.1 packages that require PHP ≥ 8.4.1 — 8.2/8.3 will fail
   `composer install`).
3. Verify the **SSH CLI** PHP version (deploy.sh calls bare `php`; Hostinger's CLI can
   differ from the site version — `composer install` needs 8.4+):
   `ssh -p <PORT> <USER>@<HOST> "php -v"` — if it reports < 8.4, set the CLI version in
   hPanel (Advanced → SSH Access) or use the full path to a newer `php` binary in
   `deploy.sh`.
4. Create a MySQL database + user in hPanel (MySQL Databases); note name, user, password.
5. Generate a **deploy key on the server** (no passphrase) and register its public half
   on GitHub (Settings → Deploy keys, read-only):

   ```bash
   ssh -p <PORT> <USER>@<HOST>
   mkdir -p ~/.ssh
   ssh-keygen -t ed25519 -C "dcprs-server" -f ~/.ssh/dcprs_github -N ""
   cat ~/.ssh/dcprs_github.pub   # copy this output into GitHub → Settings → Deploy keys
   ```

   Note: if `~/.ssh/config` already has a `Host github.com` block, edit that block
   instead (ssh uses the first match) — do not append a duplicate.

   ```bash
   cat >> ~/.ssh/config <<'EOF'
   Host github.com
     HostName github.com
     User git
     IdentityFile ~/.ssh/dcprs_github
   EOF
   chmod 600 ~/.ssh/dcprs_github
   ```

6. Clone the repo:

   ```bash
   cd ~/domains/example.com/public_html
   git clone git@github.com:jdbernardo16/dental-record-system.git dental
   cd dental
   git checkout main
   cp .env.example .env
   php artisan key:generate
   ```

7. Edit `.env` (nano): `APP_ENV=production`, `APP_DEBUG=false`,
   `APP_URL=https://example.com`, `SESSION_SECURE_COOKIE=true`, `DB_*` from step 4,
   `MAIL_MAILER=smtp` + Hostinger SMTP settings (hPanel → Emails → email account →
   SMTP details), keep `QUEUE_CONNECTION=database`, `CACHE_STORE=database`,
   `BACKUP_DESTINATION=backups`, `ARCHIVE_DISK=archive`.
8. Point the site at the Laravel public folder: hPanel → Websites → site → set the
   document root to `<app>/public` (e.g. `public_html/dental/public`). If your plan
   cannot set a document root, fall back to `.htaccess` in `public_html`:

   ```apache
   RewriteEngine On
   RewriteRule ^(.*)$ dental/public/$1 [L]
   ```

9. Enable free SSL (hPanel → SSL). Force HTTPS via `.htaccess` in `public/`.
10. Cron jobs — hPanel → Advanced → Cron Jobs (replace `<php>` with the full PHP path
    from `which php`, and `<app>` with the app path):

    ```cron
    * * * * * <php> <app>/artisan schedule:run >> /dev/null 2>&1
    * * * * * <php> <app>/artisan queue:work --stop-when-empty --tries=3 >> /dev/null 2>&1
    ```

    (Nightly backup at 02:00 and archival at 03:00 come from the scheduler; the queue
    worker drains mail jobs.)

11. Run the first deploy by hand to confirm the server is healthy:

    ```bash
    cd <app> && git pull origin main && bash deploy.sh
    ```

    Then log in, create the admin user (see "Initial admin" in `deploy.md`), and check
    `storage/logs/laravel.log`.

## 3. Release day flow

```bash
git checkout develop && git pull
./vendor/bin/pest          # release hygiene — run the full suite locally
npm run build              # fresh build assets — the server never builds
git add -A
git commit -m "chore: release <summary> with fresh build assets"
git checkout main && git pull
git merge develop
git push origin main
```

If you enabled branch protection (§1.2), don't push `main` directly — open a pull
request from `develop` → `main` in the GitHub UI and merge it there instead.

Then deploy on the server:

```bash
ssh -p <PORT> <USER>@<HOST>
cd <app>
git pull origin main
bash deploy.sh
exit
```

Verify the live site: log in, open one record, upload one file. Check
`storage/logs/laravel.log` if anything looks off.

## 4. Rollback

- **Code:** `git revert -m 1` the bad merge on `main` and push, then run the same
  `git pull origin main && bash deploy.sh` on the server — the previous code deploys.
- **Schema:** `git revert` does not undo migrations. SSH in and run
  `php artisan migrate:rollback --step=N` (take a backup first:
  `php artisan backup:run`, or restore per `docs/ops/backup-restore.md`).
- **Backups:** the nightly scheduler writes zips to `storage/app/backups` (gitignored);
  download them regularly via hPanel File Manager. Optional later: switch
  `BACKUP_DESTINATION` to `s3`.

## 5. Troubleshooting

| Symptom | Fix |
|---|---|
| `git pull` fails with `Permission denied (publickey)` on the server | Server deploy key missing/mismatched (`~/.ssh/dcprs_github` + GitHub deploy key); duplicate `Host github.com` block in `~/.ssh/config`; server clone not on `main` (run `git checkout main`) |
| `composer: command not found` on the server | Hostinger may expose it as `php composer.phar`; adjust the `composer` call in `deploy.sh` or install composer into `~/bin` (deploy.sh already puts `~/bin` on PATH) |
| `composer install` fails with "your php version does not satisfy" | Server CLI PHP is < 8.4 — see §2.3 (site PHP and CLI PHP are separate settings) |
| Site is 500 after a deploy | SSH in: `php artisan config:cache` (a stale cache survives deploys when `.env` changed) and tail `storage/logs/laravel.log` |
| Site looks unstyled / old JS after a deploy | You pushed without a fresh `npm run build` — rebuild locally and re-release, or the old hashed assets are cached by the browser (hard refresh) |
| Cron jobs not firing | Use the full PHP path (`which php`); confirm the cron line has no `~` (use absolute paths) |
