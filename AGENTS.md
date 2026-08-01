# Dental Clinic Patient Record System (DCPRS) — Agent Conventions

## Stack

- **Laravel 12** (PHP 8.4) + **Vue 3** + **Inertia.js**
  - Server package is `inertiajs/inertia-laravel` **v3** — v3 APIs only.
    - Use `Inertia::optional()` for deferred props. `Inertia::lazy()` was removed in v3 — do NOT use it.
    - Client is `@inertiajs/vue3` v2; routes via `ziggy-js`.
- **Tailwind CSS v4**
  - CSS-first config: `@import "tailwindcss"` + `@theme { ... }` tokens in `resources/css/app.css`.
  - There is **no `tailwind.config.js` / `postcss.config.js`** (deleted in the v4 switch).
  - The `@tailwindcss/vite` plugin is registered in `vite.config.js`.
- **MySQL/MariaDB** — local DB `dental_record_system`; see `.env` for credentials (never commit real secrets; `.env.example` holds placeholders only).
- **Pest 3** — run with `./vendor/bin/pest` or `php artisan test`. Breeze feature tests must keep passing.

## Git Workflow

- Work on the `develop` branch. Never commit to `main`.
- Commit messages follow **Conventional Commits**: `feat:`, `fix:`, `chore:`, etc.

## Reference Docs

- `docs/dental-emr/` — backend blueprint (do not modify).
- `docs/superpowers/plans/` — implementation plan (reference only).

## Frontend Style

- **No hex codes** in classes or components.
- **No arbitrary Tailwind values** (`text-[#71717A]`, `gap-[5px]`, …) unless no standard utility exists.
- Colors are **OKLCH tokens** defined in `@theme` in `resources/css/app.css`; use the semantic utility classes derived from them.
