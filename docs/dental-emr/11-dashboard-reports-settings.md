# 11 — Dashboard, Reports & Settings

## Purpose

Operational day-start screen (spec §4), admin-only reporting (spec §3), and key-value clinic settings.

## Dashboard Widgets (spec §4 — no dedicated tables; all read-model queries)

| Widget | Query | Roles |
|---|---|---|
| Today's appointments | `appointments` where date = today, ordered by start_time, status in (pending, confirmed) | all |
| Recent patients | latest 10 `patients` by created_at | all |
| Pending procedures | `treatments` where `signed_at IS NULL` count + list | dentist, admin |
| Monthly statistics | count: new patients / appointments / treatments / consents this month | admin, dentist |
| Follow-up appointments | `appointments` next 7 days, status confirmed, flagged follow-up | receptionist, assistant, dentist |

> Follow-up flag: `appointments.reason` free-text per spec — a dedicated `is_follow_up` boolean is added (Q11). Widget uses it.

## Reports (admin-only per spec §3)

`ReportRepository` — no tables, aggregation queries returning JSON consumed by Inertia pages:

```php
final class ReportRepository
{
    /** new patients per month (last 12 months) */
    public function patientGrowth(Carbon $from, Carbon $to): Collection
    /** appointments by status per month; attendance rate = completed / (completed+no_show) */
    public function appointmentSummary(Carbon $from, Carbon $to): Collection
    /** procedure counts grouped by procedure_name, optional tooth/dentist filter */
    public function procedureSummary(Carbon $from, Carbon $to): Collection
    /** top conditions on chart (caries, missing, rct...) — clinical audit */
    public function conditionSummary(Carbon $from, Carbon $to): Collection
    /** per-dentist treatment counts — workload */
    public function dentistWorkload(Carbon $from, Carbon $to): Collection
}
```

- Exports: CSV + printable PDF (browser print of a report view). PDF library (DomPDF) optional — default browser print, Q12.
- All reports filtered by date range; all admin-only.

## Settings

```php
// 2026_01_01_000011_create_settings_table.php
Schema::create('settings', function (Blueprint $table) {
    $table->id();
    $table->string('key')->unique();
    $table->text('value')->nullable();      // JSON-encoded where needed
    $table->string('group')->default('general');
    $table->timestamps();
});
```

| Seed key | Purpose |
|---|---|
| `clinic.name` | header / reports branding |
| `clinic.address` | consent form print footer |
| `consent.version` | current waiver template version |
| `patient.number.prefix` | patient number scheme (Q3) |
| `appointment.overlap` | allow overlapping appointments (`false` default) |
| `attachment.max_size_mb` | upload cap (default 25) |

`Settings` model with `SettingsService::get(key, default)` + cache (60s). Managed by Administrator (`settings.update`).

## Permissions

| Permission | Roles |
|---|---|
| `reports.view` | administrator |
| `settings.view` | administrator |
| `settings.update` | administrator |

## UI Elements (improvised)

- **Dashboard** (`/dashboard`): widget cards grid (2-col on tablet, 4-col desktop); each card = title + count + tap-to-drill.
- **Reports** (`/reports`): date range picker, metric cards, line/bar charts (chart.js or lightweight SVG — default `chart.js` + vue wrapper, Q13), export buttons.
- **Settings** (`/settings`): grouped form, key-value rows rendered by group, save button with toast.
