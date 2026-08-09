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

- **Vitest** — new `tests/js/TimeRangeField.spec.js` (mirror `tests/js/DateField.spec.js` conventions; happy-dom, `@` alias):
  - renders label + required star + error text when provided,
  - shows "Clear" only when start or end is set; clicking it emits `update:start`/`update:end` with null,
  - binds `HH:mm` strings into the internal Time values and emits `HH:mm` strings on change.
- **Pest** — existing appointment feature tests must stay green (wire format unchanged); no new backend tests needed.

## Out of scope

Standalone single-time `TimeField`, seconds/AM-PM modes, backend/validation changes, other pages (Dashboard/Patients only display times).
