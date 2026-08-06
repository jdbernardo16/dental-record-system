# DCPRS — Hostinger Deployment Runbook

> Live deployment setup: `main` branch + GitHub Actions + SSH into Hostinger shared
> hosting. Read `backup-restore.md` before touching production data.

## 0. How updates reach the live site

1. Merge `develop` → `main` and push.
2. GitHub Actions (`deploy.yml`) builds assets, commits fresh `public/build` back to
   `main` (`[skip ci]` — no re-trigger loop), then SSHes into Hostinger.
3. On the server: `git pull origin main` + `bash deploy.sh` (composer install, caches,
   migrate, storage link, permissions).
4. The workflow health-checks the public URL. Watch it at GitHub → Actions → "Deploy to
   Hostinger".

## 1. GitHub one-time setup

1. Generate a deploy SSH key (no passphrase):

   ```bash
   ssh-keygen -t ed25519 -C "dcprs-hostinger" -f ~/.ssh/dcprs_hostinger
   ```

2. Add repo secrets (Settings → Secrets and variables → Actions):

   | Secret | Value |
   |---|---|
   | `SSH_KEY` | contents of `~/.ssh/dcprs_hostinger` (private key, BEGIN/END lines included) |
   | `SSH_HOST` | Hostinger SSH host from hPanel (Advanced → SSH Access) |
   | `SSH_USER` | Hostinger SSH username (e.g. `u847362951`) |
   | `SSH_PORT` | Hostinger SSH port (e.g. `65002`) |
   | `DEPLOY_PATH` | full server path of the app root, e.g. `/home/u847362951/domains/example.com/public_html/dental` |
   | `SITE_URL` | `https://example.com` |

3. Add a read-only **deploy key** (Settings → Deploy keys) with the **public** key
   `~/.ssh/dcprs_hostinger.pub` so the server can `git pull` from GitHub.

4. Recommended: enable branch protection on `main` requiring a PR from `develop`
   (Settings → Branches). This keeps "never commit to main" enforced. **Important:** when
   you enable the PR requirement, also add **GitHub Actions** under "Allow specified
   actors to bypass the required pull request" — otherwise the workflow's build-commit
   push to `main` is rejected with `GH006: Protected branch update failed`.

## 2. Hostinger one-time setup

1. hPanel → Advanced → SSH Access → enable. Note host, user, port.
2. hPanel → Advanced → SSH Access → SSH Keys → add the public key from step 1 above.
3. hPanel → Websites → your site → set PHP version **8.4** (the committed `composer.lock`
   pins Symfony v8.1 packages that require PHP ≥ 8.4.1 — 8.2/8.3 will fail
   `composer install`).
4. Verify the **SSH CLI** PHP version (deploy.sh calls bare `php`; Hostinger's CLI can
   differ from the site version — `composer install` needs 8.4+):
   `ssh -p <PORT> <USER>@<HOST> "php -v"` — if it reports < 8.4, set the CLI version in
   hPanel (Advanced → SSH Access) or use the full path to a newer `php` binary in
   `deploy.sh`.
5. Create a MySQL database + user in hPanel (MySQL Databases); note name, user, password.
6. SSH in and clone the repo using the GitHub deploy key:

   Note: if `~/.ssh/config` already has a `Host github.com` block, edit that block
   instead (ssh uses the first match) — do not append a duplicate.

   ```bash
   mkdir -p ~/.ssh
   cat >> ~/.ssh/config <<'EOF'
   Host github.com
     HostName github.com
     User git
     IdentityFile ~/.ssh/dcprs_github
   EOF
   ```

   ```bash
   # from your local machine — copy the private half of the keypair from §1.1 to the server
   scp -P <PORT> ~/.ssh/dcprs_hostinger <USER>@<HOST>:~/.ssh/dcprs_github
   # then on the server
   chmod 600 ~/.ssh/dcprs_github
   ```

   then:

   ```bash
   cd ~/domains/example.com/public_html
   git clone git@github.com:jdbernardo16/dental-record-system.git dental
   cd dental
   git checkout main
   cp .env.example .env
   php artisan key:generate
   ```

7. Edit `.env` (nano): `APP_ENV=production`, `APP_DEBUG=false`,
   `APP_URL=https://example.com`, `SESSION_SECURE_COOKIE=true`, `DB_*` from step 5,
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
git checkout main && git pull
git merge develop
git push origin main       # everything after this is automatic
```

If you enabled branch protection (§1.4), don't push `main` directly — open a pull
request from `develop` → `main` in the GitHub UI and merge it there instead.

Watch GitHub → Actions → "Deploy to Hostinger". When the run is green, verify the site
(login, one record, one upload). A failed health check marks the run failed even if the
files deployed — SSH in and check `storage/logs/laravel.log`.

## 4. Manual deploy fallback (action down)

```bash
ssh -p <PORT> <USER>@<HOST>
cd <app>
git pull origin main
bash deploy.sh
```

The repo always contains fresh `public/build`, so a manual `git pull` + `deploy.sh`
deploys correctly without GitHub Actions.

## 5. Rollback

- **Code:** `git revert -m 1` the bad merge on `main` and push — the workflow deploys the
  previous code automatically.
- **Schema:** `git revert` does not undo migrations. SSH in and run
  `php artisan migrate:rollback --step=N` (take a backup first:
  `php artisan backup:run`, or restore per `docs/ops/backup-restore.md`).
- **Backups:** the nightly scheduler writes zips to `storage/app/backups` (gitignored);
  download them regularly via hPanel File Manager. Optional later: switch
  `BACKUP_DESTINATION` to `s3`.

## 6. Troubleshooting

| Symptom | Fix |
|---|---|
| `Permission denied (publickey)` in the workflow | Re-add the public key in hPanel SSH Keys; make sure `SSH_KEY` secret has the full private key |
| `Connection refused` / timeout | Wrong `SSH_PORT` or host; SSH not enabled; if Hostinger SSH IP restrictions are on, allow GitHub runner ranges or disable restrictions in hPanel → Advanced → SSH Access |
| `composer: command not found` | Hostinger may expose it as `php composer.phar`; adjust the `composer` call in `deploy.sh` or install composer into `~/bin` |
| Workflow fails at `git pull origin main` on server | Server deploy key missing/mismatched (`~/.ssh/dcprs_github`); server clone not on `main` (run `git checkout main`) |
| `GH006: Protected branch update failed` | Add GitHub Actions to the branch-protection bypass actors (see §1.4) |
| Site is 500 after a green run | SSH in: `php artisan config:cache` (a stale cache survives deploys when `.env` changed) and tail `storage/logs/laravel.log` |
| Build commit loop | Build commits carry `[skip ci]`; if someone removes it, the "Commit build assets" step is a no-op when unchanged, so the loop terminates |
| Cron jobs not firing | Use the full PHP path (`which php`); confirm the cron line has no `~` (use absolute paths) |
