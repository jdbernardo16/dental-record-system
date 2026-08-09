# Sidebar Behavior — Design Spec

**Date:** 2026-08-09 (rev. 3 — hamburger is the single toggle)
**Status:** Approved by user (verbal; Option A chosen)
**Branch:** feat/odontogram-revamp

## Problem

The app sidebar has behaviors the user wants changed:

1. **Desktop "auto open/close"**: at `lg+` the sidebar auto-collapses to a 96px icon-only rail (`lg:w-24`) and expands on hover. The user wants the auto behavior **removed**; the sidebar must be **open (expanded) by default** — but still **manually collapsible to the rail** via a button (Option A).
2. **Mobile drawer stays open after navigation**: the off-canvas drawer must **auto-close when a nav item is tapped**.
3. **No visible close control**: after the first change, there was no way to close the sidebar (hamburger hidden at `lg+`). The user asked "where is the button to close it?" → restore the header hamburger as the **single** open/close toggle (no X button).
4. **Active menu item stale after SPA navigation**: the highlight only updates on full page reload. Root cause: `isActive()` reads only non-reactive sources (ziggy reads `window.location`), so the Sidebar never re-renders on Inertia navigation (its props/`navGroups` don't change).

## Requirements

- Desktop (`lg+`): sidebar **expanded (`w-72`, labels visible) by default**. Header hamburger **collapses it to an icons-only rail (`lg:w-24`, labels hidden)**; clicking again expands. No hover behavior.
- Mobile (<lg): drawer **closed by default**; the **header hamburger toggles it** open and closed; also closes via backdrop click or **nav-link tap** (navigates + closes).
- **Active-state fix**: the highlighted nav item must update immediately on SPA navigation (reactive dependency on the Inertia `page.url`).
- Header hamburger is the single toggle: mobile drawer open/close and desktop rail expand/collapse. Header must stay above the backdrop/drawer so the hamburger remains clickable while the drawer is open.
- Default state: desktop expanded, mobile closed — initialize `sidebarOpen` from viewport width.

## Changes

### `resources/js/Components/Sidebar.vue`

- Remove the `hovered` ref and `@mouseenter`/`@mouseleave` handlers (no auto behavior).
- Rail is now **manual**: `open ? 'lg:w-72' : 'lg:w-24'`; mobile drawer keeps `open ? 'translate-x-0' : '-translate-x-full'`; always `lg:static lg:translate-x-0`.
- Labels (logo text, group titles, item labels) render when `open` (`v-if="open"`) — expanded sidebar/drawer shows them; desktop rail hides them; mobile closed drawer is off-canvas.
- **No X button** — the logo row shows only the logo + name (no close control).
- Nav links emit `close` **only on mobile** (`window.innerWidth < 1024`) so desktop navigation never collapses the rail; mobile navigation closes the drawer.
- **Active-state fix**: `isActive(item)` reads `page.url` (reactive — changes on every Inertia navigation) so the render re-runs and the highlight updates without a refresh.

### `resources/js/Components/Header.vue`

- **Restore** the hamburger button at all viewports (remove `lg:hidden`) — it toggles the drawer (mobile) / rail (desktop). Keep the `ml-auto` on the dropdown wrapper.
- Raise the header to `z-50` (was `z-30`) so it sits above the mobile backdrop (`z-40`) and the drawer (`z-50`, earlier in DOM) — the hamburger stays clickable while the drawer is open.

### `resources/js/Layouts/AppLayout.vue`

- `sidebarOpen = ref(window.innerWidth >= 1024)` — desktop starts expanded, mobile starts closed. (`lg` breakpoint = 1024px.)

## Tests

`tests/js/Sidebar.spec.js` (Vitest + @vue/test-utils; mocks: reactive `usePage` with `url: mockPageUrl` ref + ziggy `route()` deriving `current()` from `mockPageUrl`):

1. Nav link click emits `close`.
2. `open=true` → `w-72`, `translate-x-0`, `lg:w-72`, labels visible (`Dashboard`); `open=false` → `-translate-x-full`, `lg:translate-x-0`, `lg:w-24` (rail), labels hidden.
3. Backdrop click emits `close`.
4. **Navigation reactivity**: with `open=true`, Dashboard is active (`menu-item-active`); change `mockPageUrl.value = '/appointments'` + `nextTick()` → Appointments becomes active, Dashboard no longer active.

## Out of Scope

- No changes to nav items, permissions, or links.
- No persistence of sidebar state.
- No changes to GuestLayout or other layouts.
- No resize-listener behavior (state persists across breakpoint changes).
