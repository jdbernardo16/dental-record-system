# Dashboard Cards Redesign — Design Spec

Date: 2026-08-06
Status: Approved (both design sections)
Scope: `resources/js/Pages/Dashboard/Index.vue` — frontend only

## Problem

The four dashboard cards ("Today's appointments", "Recent patients", "Pending procedures", "Follow-ups") have a misaligned "View all" action:

1. **Buttons don't align across the row.** Cards are not `flex flex-col`; the button sits right after a list whose height varies (Follow-ups shows 5 rows, others 4; empty states are shorter). Buttons land at different vertical positions.
2. **Redundant content.** Each card mixes a big count number with a truncated list, which reads confusingly when the count exceeds the visible rows.
3. **Inconsistent implementation.** Hand-rolled `<section>` markup instead of the existing shadcn `ui/card` primitives; "Pending procedures" uses a disabled-looking gray block instead of a real button.
4. **Heavy button styling.** Full-width filled `bg-brand-50` block competes with content; no focus-visible states.

## Decisions

- **Keep the hybrid card** (big count + short list) — the user explicitly chose to preserve the current content model.
- **Approach A: pinned footer button** — cards become flex columns; the footer (divider + full-width soft-brand button) is glued to the card bottom via `mt-auto`. Chosen over header action link (B) and footer text link (C) via visual mockup comparison.

## Card anatomy

All four cards use the shadcn `ui/card` primitives already in the codebase:

| Part | Primitive | Notes |
|------|-----------|-------|
| Root | `Card` | Already `flex flex-col`; rounded-xl border shadow-sm |
| Header | `CardHeader` (title + icon circle) | Title left, icon circle right — same look as today (`bg-brand-50` circle, brand icon) |
| Body | `CardContent` | Big count (`text-3xl font-semibold text-gray-800`) + list |
| Footer | `CardFooter` + `mt-auto` | Divider `border-t` above it; holds the action |

The `mt-auto` on the footer is the alignment fix: the list area flexes, so footers sit flush at the card bottom in every state (empty, 1 row, 4+ rows).

## Content rules

- Every list caps at **4 rows** (Follow-ups currently shows 5 — the sneaky alignment breaker).
- Rows keep `min-h-11`, `truncate` on names, and the existing status `Badge`s.
- Empty states stay ("No appointments today.", "No patients yet.", etc.); the footer button still renders so all four footers align.
- "View all" becomes the real `Button` component (`as-child` + `Link`) styled as a full-width soft-brand button: `bg-brand-50 text-brand-500 hover:bg-brand-100` — same colors as today, but with proper focus-visible ring and disabled handling.
- Arrow icon (`ArrowRight`, `size-4`) stays inside the button.

## Edge cases

1. **Pending procedures** — treatments page ships in Phase 2. Card keeps its aligned footer; button renders **disabled** (`bg-gray-100 text-gray-400`, `cursor-not-allowed`, no link). Swapping to a real `Link` later is a one-line change.
2. **Monthly statistics card** — no "View all", but migrates to the same Card primitives (Card / CardHeader with title + icon circle / CardContent with the two mini-stats and Apex chart) for one design language across the page. Apex `chartOptions` keep their existing OKLCH colors (established pattern — ApexCharts needs concrete color values).
3. **Permission guards** — `can.viewTreatments` / `can.viewAppointments` behavior unchanged; cards still hide for users without access.

## Scope

- One file touched: `resources/js/Pages/Dashboard/Index.vue`.
- No controller changes, no backend changes, no new components, no new dependencies.
- Imports updated: add `Button`, `Card`, `CardContent`, `CardFooter`, `CardHeader`, `CardTitle`; keep `Badge`, `ArrowRight`, chart imports. `CardDescription` is NOT used — the chart card's mini-stats render as labeled stat blocks inside `CardContent`.

## Verification

1. `npm run build` — compiles clean.
2. `./vendor/bin/pest` — Breeze feature tests stay green.
3. Visual check of `/dashboard` at three widths:
   - `xl` (4-col grid): all four "View all" buttons aligned on the same baseline.
   - `sm` (2-col grid): buttons aligned within each row pair.
   - mobile (1-col): footer pinned to card bottom, no stray spacing.
4. Spot-check empty-state and disabled-button rendering.
