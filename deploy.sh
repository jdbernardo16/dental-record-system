#!/usr/bin/env bash
#
# DCPRS post-pull deploy script — runs on the Hostinger server after `git pull`.
# Idempotent: safe to run repeatedly. Invoked by .github/workflows/deploy.yml and
# by hand over SSH:  cd <app> && bash deploy.sh
set -euo pipefail

APP_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$APP_DIR"

COMMIT="$(git rev-parse --short HEAD 2>/dev/null || echo 'no-git')"
echo "==> Deploying DCPRS @ ${COMMIT}"

# 1. Dependencies (no dev packages in production)
echo "==> composer install --no-dev"
composer install --no-dev --optimize-autoloader --no-interaction

# 2. Schema (no-op when there are no pending migrations)
echo "==> php artisan migrate --force"
php artisan migrate --force

# 3. Caches — config first, then routes and views
echo "==> config:cache / route:cache / view:cache"
php artisan config:cache
php artisan route:cache
php artisan view:cache

# 4. Storage symlink — uploads + signature SVGs are served from storage/app/public
if [ ! -L public/storage ]; then
    echo "==> php artisan storage:link"
    php artisan storage:link
else
    echo "==> storage:link already in place"
fi

# 5. Writable dirs (shared hosting: group-writable, no suhosin surprises)
echo "==> permissions on storage/ and bootstrap/cache/"
find storage bootstrap/cache -type d -exec chmod 775 {} +
find storage bootstrap/cache -type f -exec chmod 664 {} +

echo "==> Deploy complete @ ${COMMIT}"
