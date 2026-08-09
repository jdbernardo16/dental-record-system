# Time Range Field Component — Design Spec

**Date:** 2026-08-09
**Status:** Approved by user (verbal; Option B chosen — combined `TimeRangeField`)
**Branch:** feat/odontogram-revamp

## Problem

Appointment forms (create + reschedule modals in `Appointments/Index.vue`) use a bare `<TextInput type="time">` (native browser clock) for Start and End in four places. The user wants a proper, reusable time picker component built from the same source as the date picker — reka-ui. Reka UI ships `TimeField` and `TimeRangeField` (same `@internationalized/date` ecosystem as the `Calendar` used by `Fields/DateField.vue`). The combined range variant was chosen.

## Requirements

- New reusable `Fields/TimeRangeField.vue` wrapping reka-ui `TimeRangeField` (`TimeRangeFieldRoot` + `TimeRangeFieldInput`).
- API mirrors `Fields/DateField.vue`: `label`, `required`, `error`, `hint`, `id`, `disabled`.
- Value contract: two v-model bindings — `v-model:start` and `v-model:end`, each `String` (`HH:mm`) or `null`.
- Wire format unchanged → `StoreAppointmentRequest` / `RescheduleAppointmentRequest` validation (`start_time` required `date_format:H:i`; `end_time` nullable `date_format:H:i` `after:start_time`) and the `appointments` table (`time` columns, `end_time` nullable) are untouched. No backend changes.
- 24-hour cycle, minute granularity (matches `date_format:H:i`).
- Single bordered control (h-11, consistent with DateField/TextInput styling): start segment – end segment, clock icon, Clear (X) button when either value is set. No hex codes / arbitrary Tailwind values.

## Changes

### New: `resources/js/Components/Fields/TimeRangeField.vue`

- Props: `start` (String|null, default null), `end` (String|null, default null), `label`, `error`, `hint`, `required` (Boolean, applies to start), `id`, `disabled`. Emits: `update:start`, `update:end`.
- Internal model: reka-ui `TimeRangeValue` (`{ start: Time | null, end: Time | null }`) via `@internationalized/date` `Time`.
  - `toTime('HH:mm')`: split on `:`, `new Time(hour, minute)`; empty/invalid → null.
  - `toString()` round-trip yields zero-padded `HH:mm` (24h) — matches `date_format:H:i`.
- `TimeRangeFieldRoot` props: `granularity="minute"`, `hourCycle=24`, `disabled`; `TimeRangeFieldInput` inside the bordered control with a dash separator between the start/end segment groups; `aria-invalid`/error styling wired to `error`.
- Clear button (X, lucide) shown when `start` or `end` is set; resets both to null (mirrors DateField's clear affordance).
- Label/error/hint markup copied from DateField conventions (Label component, `status-cancelled` error text, `fieldId` via `useId`).

### Hybrid time selector (popover picker) — rev. 2

The reka-ui `TimeRangeField` is type-in only (no built-in selector popup). Per user decision (Option A), add a click-to-select popover on top of the segments:

- Wrap the field in `PopoverRoot` (same pattern as DateField): the **clock icon becomes a `PopoverTrigger` button** (`aria-label="Pick time"`, `type="button"`, disabled when the field is disabled) next to the Clear button.
- `PopoverContent` portaled below the field, reusing DateField's popover classes (`z-50 rounded-md border bg-popover shadow-md`, side offset 6, animation classes).
- Content: two side-by-side columns with small **"Start" / "End"** captions. Each column has a **scrollable hour list (00–23)** and a **scrollable minute list (00–55, 5-minute steps)** (max-height, overflow-y-auto, clickable buttons; selected value highlighted with the brand accent).
- Clicking a value updates that side via the same `rangeValue` model (segments update live); the popover **stays open** after selections (so both sides can be set), closes on outside click / Escape.
- Typing in segments and picking in the popover both work and stay in sync.

### `resources/js/Pages/Appointments/Index.vue`

- **Create modal**: replace the `grid-cols-1 sm:grid-cols-3` block containing DateField + Start TextInput + End TextInput with `grid-cols-1 sm:grid-cols-2` containing DateField + TimeRangeField:
  ```vue
  <TimeRangeField
      v-model:start="createForm.start_time"
      v-model:end="createForm.end_time"
      label="Time"
      required
      :error="createForm.errors.start_time ?? createForm.errors.end_time"
  />
  ```
- **Reschedule modal**: replace the `grid-cols-2` Start/End pair with a single full-width TimeRangeField (same binding pattern with `rescheduleForm`).
- Import the component; remove the now-unused `TextInput type="time"` usages (keep TextInput import if still used elsewhere on the page — check).

## Testing

- **Vitest** — `tests/js/TimeRangeField.spec.js` (mirror `tests/js/DateField.spec.js` conventions; happy-dom, `@` alias):
  - renders label + required star + error text when provided,
  - shows "Clear" only when start or end is set; clicking it emits `update:start`/`update:end` with null,
  - binds `HH:mm` strings into the internal Time values and emits `HH:mm` strings on change,
  - rejects `HH:mm:ss` / out-of-range values as null, pads `9:5` → `09:05` (rev. 2 hardening),
  - **hybrid picker (rev. 2):** clock button opens the popover; clicking hour + minute buttons emits the matching `update:start`/`update:end`; both columns reflect the current values; popover stays open after a selection; trigger hidden when disabled.
- **Browser check (manual):** open `/appointments` → New appointment in a real browser; verify typing in segments AND picking from the popover both produce the same `start_time`/`end_time` payload.
- **Pest** — existing appointment feature tests must stay green (wire format unchanged); no new backend tests needed.

## Out of scope

Standalone single-time `TimeField`, seconds/AM-PM modes, backend/validation changes, other pages (Dashboard/Patients only display times).
