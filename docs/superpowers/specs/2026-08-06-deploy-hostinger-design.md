# DCPRS — GitHub → Hostinger Automated Deployment (Design)

Date: 2026-08-06
Status: Approved by user (build local / auto-build via Actions, SSH auto-deploy, tests dropped)

## 1. Goal

Push the Dental Clinic Patient Record System to live on Hostinger shared hosting, with
"update the live website via GitHub" as the only release mechanism. The user has SSH
access on Hostinger (Premium plan), so `composer install` and `artisan` run on the server.

## 2. Decisions (confirmed with user)

| Decision | Choice |
|---|---|
| Live branch | `main` — merge `develop` → `main` to release (existing "never commit to main" rule means no dev work on main, not no merges) |
| Build files in GitHub | Yes — `/public/build` un-ignored and committed |
| Who builds | GitHub Actions auto-builds and commits fresh `public/build` back to `main` on every push (`[skip ci]` to avoid re-trigger loops) |
| Server-side steps | GitHub Action SSHes into Hostinger, runs `git pull` + `deploy.sh` automatically |
| Tests in pipeline | Dropped (user: keep minimal) |
| File sync | `git pull` on the server (not rsync) — can never touch untracked server-only files (`.env`, uploaded patient files in `storage/`) |

## 3. Target flow

```
develop ──merge──▶ main ──▶ GitHub Actions (push to main) ──▶ Hostinger
                             1. npm ci && npm run build
                             2. commit public/build back to main [skip ci]
                             3. ssh: cd <app> && git pull origin main
                             4. ssh: bash deploy.sh
                             5. health check: curl -f the APP_URL
```

- `workflow_dispatch` allows manual re-deploy from the Actions tab.
- `[skip ci]` in the build commit prevents the workflow from re-triggering on its own
  commit (no infinite loop, no double deploy).
- Hostinger's built-in Git integration (hPanel → Advanced → Git) is **not used**; the
  action drives the whole deploy over SSH.

## 4. Repo changes

| File | Change |
|---|---|
| `.gitignore` | Remove `/public/build` (build files are now tracked) |
| `deploy.sh` | New. Idempotent post-pull script run on the server: `composer install --no-dev --optimize-autoloader`, `php artisan migrate --force`, `config:cache`, `route:cache`, `view:cache`, `storage:link` if missing, fix `storage/` + `bootstrap/cache/` permissions, report app version/commit |
| `.github/workflows/deploy.yml` | New. Pipeline in §3 |
| `docs/ops/deploy-hostinger.md` | New runbook: one-time server setup, GitHub setup, release day steps, rollback, troubleshooting |
| `docs/ops/deploy.md` | Keep as VPS reference; add a note that the live setup is Hostinger (see deploy-hostinger.md) |

Notes:
- `routes/*.php` contain no closures — `route:cache` is safe (verified).
- `public/hot` stays ignored; `vendor/`, `node_modules/`, `.env`, `storage/app/*` stay ignored.
- `.env` and `storage/app/public` uploads are untracked on the server — `git pull` and the
  workflow never touch them.

## 5. GitHub one-time setup (documented in runbook)

1. Generate an ed25519 key pair locally (`dcprs-hostinger`): private key → repo secret
   `SSH_KEY`; public key → Hostinger (Advanced → SSH Access → SSH Keys).
2. Repo secrets: `SSH_HOST`, `SSH_USER`, `SSH_PORT` (65002 shared hosting / as shown in
   hPanel), `SSH_KEY`, `DEPLOY_PATH` (server path to the app root).
3. Deploy key (repo → Settings → Deploy keys, read-only): lets the server `git pull`
   from GitHub (server `~/.ssh/config` maps `github.com` to this key).
4. Optional: branch protection on `main` (require PRs; tests run locally pre-merge).

## 6. Hostinger one-time setup (documented in runbook)

1. hPanel → Advanced → SSH Access: enable; note host/user/port.
2. Add the action's public key under SSH Keys.
3. hPanel → Websites → site: set PHP version 8.2+ (project requires ^8.2).
4. SSH: `git clone` the repo to `<public_html>/dental` (e.g.
   `~/domains/<domain>/public_html/dental`) using the deploy key.
5. Point the site's document root at `<app>/public` (hPanel setting; fallback:
   `.htaccess` rewrite in `public_html`).
6. Create `.env` from `.env.example`: `APP_ENV=production`, `APP_DEBUG=false`,
   `APP_URL=https://…`, `APP_KEY` (generated), `DB_*` (Hostinger MySQL database created
   in hPanel), `MAIL_*` (Hostinger SMTP), `SESSION_SECURE_COOKIE=true`,
   `BACKUP_DESTINATION=backups`, `ARCHIVE_DISK=archive` (local disks; S3 optional later).
7. `php artisan storage:link` (or rely on deploy.sh which creates it if missing).
8. hPanel → Advanced → Cron Jobs (2 entries, path from `which php`):
   - `* * * * *` → `php <app>/artisan schedule:run` (nightly backup 02:00, archival 03:00)
   - `* * * * *` → `php <app>/artisan queue:work --stop-when-empty` (mail jobs)
9. Enable free SSL in hPanel.

## 7. Release day flow

```
git checkout develop && git pull
# (run tests locally: ./vendor/bin/pest — release hygiene)
git checkout main && git pull
git merge develop
git push origin main        # ← everything else is automatic
```

Watch progress in GitHub → Actions → Deploy. Verify the site.

## 8. Rollback

- Code: `git revert` the bad merge on `main` and push — the action auto-deploys the
  previous code.
- Schema: if the release added migrations, `git revert` does not undo them — SSH in and
  run `php artisan migrate:rollback --step=N` manually; take a backup first
  (`php artisan backup:run` or restore from the nightly backup — see
  `docs/ops/backup-restore.md`).
- Manual fallback: the repo contains build files, so an SSH `git pull` + `bash deploy.sh`
  works even if the action is down.

## 9. Out of scope

- Tests in the pipeline (dropped per user).
- Hostinger Git integration (not used).
- S3 backup/archive destination (documented as optional).
- Multi-environment (staging) deploys.
