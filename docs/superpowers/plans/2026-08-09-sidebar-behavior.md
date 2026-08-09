# Sidebar Behavior Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Make the sidebar always expanded on desktop (no hover-collapse rail), and make the mobile drawer close automatically when a nav item is tapped.

**Architecture:** Pure client-side layout behavior. `Sidebar.vue` loses its `hovered` rail state entirely (always `w-72`, labels always rendered, `lg:static` keeps it pinned on desktop) while retaining the mobile off-canvas drawer mechanics (`open` prop → `translate-x`). Each nav `<Link>` gains `@click="$emit('close')"` so AppLayout closes the drawer after navigation on mobile (a no-op on desktop). `Header.vue` hides the hamburger at `lg+` since the desktop sidebar is no longer toggleable. `AppLayout.vue` is untouched (`sidebarOpen = ref(false)` already = closed-by-default on mobile).

**Tech Stack:** Vue 3 (script setup), Tailwind CSS v4, Inertia.js v3 (`Link`), Ziggy (`route`), Vitest + @vue/test-utils (happy-dom).

---

## File Structure

| File | Action | Responsibility |
|---|---|---|
| `tests/js/Sidebar.spec.js` | Create | Unit tests for Sidebar behavior (close-on-nav, no rail class, off-canvas when closed, backdrop close) |
| `resources/js/Components/Sidebar.vue` | Modify | Always-expanded desktop sidebar; close-on-nav-link click |
| `resources/js/Components/Header.vue` | Modify | Hamburger toggle becomes mobile-only (`lg:hidden`) |
| `resources/js/Layouts/AppLayout.vue` | No change | Verify `sidebarOpen = ref(false)` remains |

**Mocking notes for the spec file:** `Sidebar.vue` calls `route(...)` (from `../../../vendor/tightenco/ziggy` — resolves to `<project>/vendor/tightenco/ziggy`) and `usePage()` at setup, so both must be mocked. From the test file's location (`tests/js/`), ziggy resolves via `../../vendor/tightenco/ziggy`. `usePage` is mocked by partially mocking `@inertiajs/vue3`. Inertia's `Link` is stubbed in `mount()` so clicks don't trigger real router navigation.

---

### Task 1: Write the failing Sidebar tests

**Files:**
- Create: `tests/js/Sidebar.spec.js`

- [ ] **Step 1: Create the test file**

```js
import { describe, expect, it, vi } from 'vitest'
import { mount } from '@vue/test-utils'
import { defineComponent } from 'vue'

vi.mock('@inertiajs/vue3', async (importOriginal) => {
    const actual = await importOriginal()
    return {
        ...actual,
        usePage: () => ({
            props: {
                auth: { can: { manageUsers: true, managePatients: true, manageAppointments: true } },
                can: { reports: true, settings: true },
            },
        }),
    }
})

vi.mock('../../vendor/tightenco/ziggy', () => ({
    route: (name) => {
        if (!name) return { current: () => '' } // isActive() calls route().current() with no args
        return `/${String(name).replace(/\.\*/g, '').replace(/\./g, '/')}`
    },
}))

import Sidebar from '../../resources/js/Components/Sidebar.vue'

const LinkStub = defineComponent({
    name: 'Link',
    props: { href: { type: String, required: true } },
    template: '<a :href="href"><slot /></a>',
})

const mountSidebar = (props = {}) =>
    mount(Sidebar, {
        props: { open: false, ...props },
        global: { stubs: { Link: LinkStub } },
    })

describe('Sidebar', () => {
    it('emits close when a nav link is clicked', async () => {
        const wrapper = mountSidebar({ open: true })
        const links = wrapper.findAll('a')
        expect(links.length).toBeGreaterThan(0)
        await links[0].trigger('click')
        expect(wrapper.emitted('close')).toHaveLength(1)
    })

    it('is always full width on desktop and never renders the rail class', () => {
        const wrapper = mountSidebar({ open: false })
        const aside = wrapper.get('aside')
        expect(aside.classes()).toContain('w-72')
        expect(aside.classes()).toContain('lg:static')
        expect(aside.classes()).toContain('lg:translate-x-0')
        expect(aside.classes()).not.toContain('lg:w-24')
        expect(wrapper.text()).toContain('Dashboard')
    })

    it('renders off-canvas when closed and closes via backdrop click', async () => {
        const wrapper = mountSidebar({ open: false })
        const aside = wrapper.get('aside')
        expect(aside.classes()).toContain('-translate-x-full')
        expect(aside.classes()).not.toContain('translate-x-0')

        const openWrapper = mountSidebar({ open: true })
        await openWrapper.get('.fixed.inset-0').trigger('click')
        expect(openWrapper.emitted('close')).toHaveLength(1)
    })
})
```

- [ ] **Step 2: Run the tests and verify they FAIL**

Run: `npx vitest run tests/js/Sidebar.spec.js`
Expected: FAILURES —
- "emits close when a nav link is clicked": `wrapper.emitted('close')` is `undefined` (no `@click` handler yet).
- "never renders the rail class": `aside.classes()` contains `lg:w-24` when `open=false` (current code has `open || hovered ? 'lg:w-72' : 'lg:w-24'`).

- [ ] **Step 3: Commit the failing test**

```bash
git add tests/js/Sidebar.spec.js
git commit -m "test: add sidebar behavior tests (red)"
```

---

### Task 2: Rewrite `Sidebar.vue` — always expanded, close on nav

**Files:**
- Modify: `resources/js/Components/Sidebar.vue`

- [ ] **Step 1: Replace the script section**

Replace the entire `<script setup>` block (lines 1–79) with:

```vue
<script setup>
import { computed } from 'vue'
import { Link, usePage } from '@inertiajs/vue3'
import { route } from '../../../vendor/tightenco/ziggy'
import {
    BarChart3,
    CalendarDays,
    ClipboardPlus,
    LayoutDashboard,
    Settings,
    ShieldCheck,
    Users,
} from 'lucide-vue-next'
import Badge from '../Components/Badge.vue'

defineProps({
    open: { type: Boolean, default: false },
})

defineEmits(['close'])

const page = usePage()

const canManageUsers = computed(() => page.props.auth?.can?.manageUsers ?? false)
const canManagePatients = computed(() => page.props.auth?.can?.managePatients ?? false)
const canManageAppointments = computed(() => page.props.auth?.can?.manageAppointments ?? false)
const canViewReports = computed(() => page.props.auth?.can?.reports ?? page.props.can?.reports ?? false)
const canViewSettings = computed(() => page.props.auth?.can?.settings ?? page.props.can?.settings ?? false)

const navGroups = computed(() => [
    {
        title: 'Menu',
        items: [
            { name: 'Dashboard', icon: LayoutDashboard, href: route('dashboard'), routeName: 'dashboard' },
            {
                name: 'New intake',
                icon: ClipboardPlus,
                href: route('wizard.index'),
                routeName: 'wizard.*',
            },
            ...(canManagePatients.value
                ? [{
                    name: 'Patients',
                    icon: Users,
                    href: route('patients.index'),
                    routes: ['patients.*'],
                }]
                : [{ name: 'Patients', icon: Users, badge: 'Phase 2' }]),
            ...(canManageAppointments.value
                ? [{
                    name: 'Appointments',
                    icon: CalendarDays,
                    href: route('appointments.index'),
                    routes: ['appointments.*'],
                }]
                : [{ name: 'Appointments', icon: CalendarDays, badge: 'No access' }]),
            ...(canManageUsers.value
                ? [{ name: 'Users', icon: ShieldCheck, href: route('users.index'), routeName: 'users.*' }]
                : [{ name: 'Users', icon: ShieldCheck, badge: 'Admin' }]),
            ...(canViewReports.value
                ? [{ name: 'Reports', icon: BarChart3, href: route('reports.index'), routeName: 'reports.*' }]
                : []),
            ...(canViewSettings.value
                ? [{ name: 'Settings', icon: Settings, href: route('settings.index'), routeName: 'settings.*' }]
                : []),
        ],
    },
])

const isActive = (item) => {
    const current = route().current()
    if (typeof current !== 'string') return false
    return (item.routes ?? [item.routeName])
        .filter(Boolean)
        .some((name) => route().current(name))
}
</script>
```

Changes vs. current: `import { computed, ref } from 'vue'` → `import { computed } from 'vue'` (the `hovered` ref is gone).

- [ ] **Step 2: Replace the template**

Replace the entire `<template>` block (lines 81–179) with:

```vue
<template>
    <div>
        <div
            v-if="open"
            class="fixed inset-0 z-40 bg-gray-900/50 lg:hidden"
            @click="$emit('close')"
        ></div>

        <aside
            :class="[
                'fixed top-0 left-0 z-50 flex h-full w-72 flex-col border-r border-gray-200 bg-white transition-transform duration-300 ease-in-out',
                open ? 'translate-x-0' : '-translate-x-full',
                'lg:static lg:translate-x-0',
            ]"
        >
            <div class="flex h-16 shrink-0 items-center gap-3 border-b border-gray-100 px-5">
                <img src="/images/jdc-square.png" alt="Jerrmond Dental Clinic" class="h-10 w-10 rounded-xl" />
                <span class="whitespace-nowrap text-base font-semibold text-gray-900">
                    Dental Clinic
                </span>
            </div>

            <nav class="no-scrollbar flex-1 overflow-y-auto px-4 py-6">
                <div v-for="group in navGroups" :key="group.title" class="mb-6 last:mb-0">
                    <h2 class="mb-3 text-xs font-medium uppercase leading-5 tracking-wide text-gray-400">
                        {{ group.title }}
                    </h2>
                    <ul class="flex flex-col gap-1.5">
                        <li v-for="item in group.items" :key="item.name">
                            <Link
                                v-if="item.href"
                                :href="item.href"
                                :class="[
                                    'menu-item group',
                                    isActive(item) ? 'menu-item-active' : 'menu-item-inactive',
                                ]"
                                @click="$emit('close')"
                            >
                                <span
                                    :class="
                                        isActive(item)
                                            ? 'menu-item-icon-active'
                                            : 'menu-item-icon-inactive'
                                    "
                                >
                                    <component :is="item.icon" class="h-5 w-5" />
                                </span>
                                <span class="flex-1 text-left whitespace-nowrap">
                                    {{ item.name }}
                                </span>
                            </Link>
                            <button
                                v-else
                                type="button"
                                disabled
                                :title="`${item.name} — coming in ${item.badge}`"
                                class="menu-item menu-item-inactive w-full cursor-not-allowed opacity-50 disabled:hover:bg-transparent"
                            >
                                <span class="menu-item-icon-inactive">
                                    <component :is="item.icon" class="h-5 w-5" />
                                </span>
                                <span class="flex flex-1 items-center justify-between gap-2">
                                    <span class="whitespace-nowrap">{{ item.name }}</span>
                                    <Badge
                                        :color="item.badge === 'Admin' ? 'info' : 'light'"
                                        size="sm"
                                    >
                                        {{ item.badge }}
                                    </Badge>
                                </span>
                            </button>
                        </li>
                    </ul>
                </div>
            </nav>
        </aside>
    </div>
</template>
```

Changes vs. current: removed `@mouseenter`/`@mouseleave`, the `hovered` class conditionals, all `lg:w-24`/`lg:justify-center`/`lg:px-0` rail classes, all `v-if="open || hovered"` on labels; added `@click="$emit('close')"` to the nav `<Link>`.

- [ ] **Step 3: Run the Sidebar tests and verify they PASS**

Run: `npx vitest run tests/js/Sidebar.spec.js`
Expected: 3 passing.

- [ ] **Step 4: Run the full JS suite to catch regressions**

Run: `npx vitest run`
Expected: 91 passing (88 existing + 3 new), 0 failures.

- [ ] **Step 5: Commit**

```bash
git add resources/js/Components/Sidebar.vue tests/js/Sidebar.spec.js
git commit -m "feat: make sidebar always expanded on desktop and close on mobile navigation"
```

---

### Task 3: Hide the hamburger on desktop

**Files:**
- Modify: `resources/js/Components/Header.vue:46-53`

- [ ] **Step 1: Add `lg:hidden` to the hamburger button**

In `resources/js/Components/Header.vue`, change the toggle button's class list (line 48) from:

```html
class="flex h-11 w-11 items-center justify-center rounded-lg text-gray-500 hover:bg-gray-100"
```

to:

```html
class="flex h-11 w-11 items-center justify-center rounded-lg text-gray-500 hover:bg-gray-100 lg:hidden"
```

The `@click="$emit('toggle')"` handler and `aria-label="Toggle sidebar"` stay unchanged — the toggle still works on mobile.

- [ ] **Step 2: Verify the full JS suite still passes**

Run: `npx vitest run`
Expected: 91 passing.

- [ ] **Step 3: Commit**

```bash
git add resources/js/Components/Header.vue
git commit -m "feat: hide sidebar toggle on desktop since the sidebar is always open"
```

---

### Task 4: Full verification

- [ ] **Step 1: Run backend tests**

Run: `./vendor/bin/pest`
Expected: 123 passing.

- [ ] **Step 2: Rebuild frontend assets**

Run: `npm run build`
Expected: build completes; `public/build/`, `public/sw.js`, `public/manifest.webmanifest` change (asset hashes).

- [ ] **Step 3: Commit the rebuilt assets**

```bash
git add public/build public/sw.js public/manifest.webmanifest
git commit -m "chore: rebuild frontend assets"
```

- [ ] **Step 4: Browser verification (desktop)**

With `php artisan serve` running, open `http://localhost:8000/dashboard` in a browser at ≥1024px viewport:
- Sidebar is expanded (w-72) with labels visible — NOT a 96px icon rail.
- Hovering nav items does NOT expand/collapse anything.
- No hamburger button in the header.

- [ ] **Step 5: Browser verification (mobile)**

Resize to ≤1023px viewport (e.g. 375×667) and reload:
- Sidebar drawer is closed; hamburger button is visible in the header.
- Tap hamburger → drawer slides in with backdrop.
- Tap a nav item (e.g. "Patients") → page navigates AND drawer closes (backdrop gone).

- [ ] **Step 6: Check the working tree is clean and no whitespace errors**

Run: `git status --short && git diff --check`
Expected: no output (clean tree).
