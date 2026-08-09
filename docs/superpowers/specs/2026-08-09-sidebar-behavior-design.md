# Sidebar Behavior — Design Spec

**Date:** 2026-08-09
**Status:** Approved by user (verbal)
**Branch:** feat/odontogram-revamp

## Problem

The app sidebar has two behaviors the user wants removed/changed:

1. **Desktop "auto open/close"**: at `lg+` the sidebar auto-collapses to a 96px icon-only rail (`lg:w-24`) and expands on hover (`@mouseenter`/`@mouseleave`). The user wants it to simply stay open — no rail mode.
2. **Mobile drawer stays open after navigation**: on mobile (<lg) the off-canvas drawer does not close when a nav item is tapped; the user must close it manually. It must auto-close on navigation.

## Requirements

- Desktop (`lg+`): sidebar **always expanded** (`w-72`, labels visible). No collapse/rail state, no hover-expand.
- Mobile (<lg): sidebar **closed by default**; opens via header hamburger; closes on backdrop click (existing behavior kept).
- Mobile: tapping any nav link **navigates and closes the drawer**.
- Hamburger toggle: mobile-only (`lg:hidden`), since the desktop sidebar is no longer toggleable.

## Changes

### `resources/js/Components/Sidebar.vue`

- Remove the `hovered` ref and `@mouseenter`/`@mouseleave` handlers.
- Remove all rail-mode conditionals and classes:
  - `lg:w-24` / `open || hovered ? 'lg:w-72' : 'lg:w-24'` → always `w-72`.
  - `!open && !hovered ? 'lg:justify-center lg:px-0' : ''` (logo block) → remove.
  - `!open && !hovered ? 'lg:justify-center' : ''` (nav items) → remove.
  - `v-if="open || hovered"` on logo text, group titles, item labels → always render.
- Keep mobile drawer mechanics: backdrop (click → `close`), `open ? 'translate-x-0' : '-translate-x-full'`, `lg:static lg:translate-x-0`.
- Add `@click="$emit('close')"` to every nav `<Link>` (enabled items). On mobile this closes the drawer after navigation; on desktop it is a no-op (sidebar stays visible regardless of `open`).

### `resources/js/Components/Header.vue`

- Hide the hamburger button at `lg+` with `lg:hidden`. `@toggle` emission stays (mobile only).

### `resources/js/Layouts/AppLayout.vue`

- No change: `sidebarOpen = ref(false)` already satisfies "mobile closed by default".

## Tests

New `tests/js/Sidebar.spec.js` (Vitest + @vue/test-utils):

1. Nav link click emits `close`.
2. Sidebar never renders the rail class `lg:w-24`; item labels always present.
3. `open=false` → drawer off-canvas (`-translate-x-full`); backdrop click emits `close`.

## Out of Scope

- No changes to nav items, permissions, or links.
- No persistence of sidebar state.
- No changes to GuestLayout or other layouts.
