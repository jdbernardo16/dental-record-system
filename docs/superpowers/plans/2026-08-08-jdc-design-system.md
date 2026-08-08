# JDC Design System Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Apply the JDC brand design system (colors, logos, neutrals, semantic tokens) across the entire DCPRS app.

**Architecture:** Replace Tailwind `@theme` tokens in `app.css` with JDC values (brand cyan, secondary blue, overridden neutrals, new semantic colors), swap generic BrandMark SVG with JDC PNG logos on all branding surfaces, update shadcn-vue primitive component styles, and clean up remaining hardcoded colors.

**Tech Stack:** Tailwind CSS v4 (CSS-first config, no `tailwind.config.js`), Vue 3, shadcn-vue, OKLCH color tokens, Vite.

---

## File Inventory

| File                                                                   | Action | Responsibility                                                                      |
| ---------------------------------------------------------------------- | ------ | ----------------------------------------------------------------------------------- |
| `resources/css/app.css`                                                | Modify | All design tokens: brand, secondary, neutrals, semantic, shadcn mappings, utilities |
| `resources/js/Components/Sidebar.vue`                                  | Modify | Swap BrandMark → jdc-square.png                                                     |
| `resources/js/Pages/Welcome.vue`                                       | Modify | Swap BrandMark → jdc-square.png                                                     |
| `resources/js/Layouts/GuestLayout.vue`                                 | Modify | Update gradient + logo                                                              |
| `resources/js/Pages/Auth/Login.vue`                                    | Modify | Swap BrandMark → jdc-square.png                                                     |
| `resources/js/Pages/Auth/Register.vue`                                 | Modify | Swap BrandMark → jdc-square.png                                                     |
| `resources/js/Pages/Auth/ForgotPassword.vue`                           | Modify | Swap BrandMark → jdc-square.png + fix green-600                                     |
| `resources/views/app.blade.php`                                        | Modify | Update favicon link                                                                 |
| `resources/js/Components/ui/button/index.js`                           | Modify | Update buttonVariants classes                                                       |
| `resources/js/Components/Badge.vue`                                    | Modify | Update variant color classes                                                        |
| `resources/js/Components/Toast.vue`                                    | Modify | Update variant color classes                                                        |
| `resources/js/Components/ResponsiveNavLink.vue`                        | Modify | Replace indigo-* with brand-*                                                       |
| `resources/js/Pages/Profile/Partials/UpdateProfileInformationForm.vue` | Modify | Replace green-600 with status-success                                               |

---

### Task 1: Backup & Replace Brand Scale in app.css

**Files:**

- Modify: `resources/css/app.css:8-17`

- [ ] **Step 1: Read current brand scale**

Read `resources/css/app.css` lines 8-17 to confirm current brand tokens.

- [ ] **Step 2: Replace brand scale with JDC Cyan**

Replace lines 8-17 with:

```css
--color-brand-50: oklch(0.985 0.01 210);
--color-brand-100: oklch(0.97 0.02 210);
--color-brand-200: oklch(0.94 0.04 210);
--color-brand-300: oklch(0.89 0.07 210);
--color-brand-400: oklch(0.78 0.1 210);
--color-brand-500: oklch(0.68 0.14 210);
--color-brand-600: oklch(0.6 0.12 210);
--color-brand-700: oklch(0.52 0.1 210);
--color-brand-800: oklch(0.42 0.12 250);
--color-brand-900: oklch(0.35 0.1 250);
```

- [ ] **Step 3: Build to verify no compilation errors**

Run: `npm run build`
Expected: exit 0, no CSS compilation errors

- [ ] **Step 4: Commit**

```bash
git add resources/css/app.css
git commit -m "feat: replace brand scale with JDC Cyan primary"
```

---

### Task 2: Add Secondary Scale & Override Neutrals in app.css

**Files:**

- Modify: `resources/css/app.css` (insert after brand scale, before status colors)

- [ ] **Step 1: Add secondary scale after brand-900**

Insert after line 17 (brand-900):

```css
--color-secondary-50: oklch(0.95 0.03 260);
--color-secondary-100: oklch(0.92 0.05 260);
--color-secondary-200: oklch(0.85 0.08 260);
--color-secondary-300: oklch(0.78 0.11 260);
--color-secondary-400: oklch(0.7 0.14 260);
--color-secondary-500: oklch(0.42 0.12 250);
--color-secondary-600: oklch(0.35 0.1 250);
--color-secondary-700: oklch(0.28 0.08 250);
--color-secondary-800: oklch(0.2 0.06 250);
--color-secondary-900: oklch(0.12 0.04 250);
```

- [ ] _*Step 2: Override gray-* with JDC neutrals_*

Insert after secondary scale (before status colors):

```css
/* JDC Neutral Palette — overrides Tailwind default gray */
--color-gray-50: oklch(0.985 0.002 250);
--color-gray-100: oklch(0.97 0.003 250);
--color-gray-200: oklch(0.93 0.005 250);
--color-gray-300: oklch(0.88 0.008 250);
--color-gray-400: oklch(0.75 0.015 250);
--color-gray-500: oklch(0.62 0.02 250);
--color-gray-600: oklch(0.5 0.025 250);
--color-gray-700: oklch(0.4 0.03 250);
--color-gray-800: oklch(0.3 0.035 250);
--color-gray-900: oklch(0.2 0.04 250);
```

- [ ] **Step 3: Build to verify**

Run: `npm run build`
Expected: exit 0

- [ ] **Step 4: Commit**

```bash
git add resources/css/app.css
git commit -m "feat: add JDC secondary blue scale and override neutrals"
```

---

### Task 3: Update Semantic Colors in app.css

**Files:**

- Modify: `resources/css/app.css:19-23` (status colors) and add new semantic tokens

- [ ] **Step 1: Replace existing status colors with JDC semantic palette**

Replace the existing status block (lines ~19-23):

```css
--color-status-pending: oklch(0.75 0.16 85);
--color-status-confirmed: oklch(0.55 0.2 260);
--color-status-completed: oklch(0.55 0.18 145);
--color-status-cancelled: oklch(0.55 0.22 25);
--color-status-no-show: oklch(0.64 0.24 25);
```

With the full JDC semantic system:

```css
/* Semantic Colors — JDC Design System */
--color-status-success: oklch(0.55 0.18 145);
--color-status-success-light: oklch(0.97 0.03 145);
--color-status-success-dark: oklch(0.45 0.15 145);

--color-status-warning: oklch(0.75 0.16 85);
--color-status-warning-light: oklch(0.99 0.02 85);
--color-status-warning-dark: oklch(0.55 0.14 85);

--color-status-error: oklch(0.55 0.22 25);
--color-status-error-light: oklch(0.98 0.02 25);
--color-status-error-dark: oklch(0.45 0.18 25);

--color-status-info: oklch(0.55 0.2 260);
--color-status-info-light: oklch(0.97 0.03 260);
--color-status-info-dark: oklch(0.45 0.18 260);

/* Legacy aliases for backward compatibility */
--color-status-pending: var(--color-status-warning);
--color-status-confirmed: var(--color-status-info);
--color-status-completed: var(--color-status-success);
--color-status-cancelled: var(--color-status-error);
--color-status-no-show: var(--color-status-error);
```

- [ ] **Step 2: Build to verify**

Run: `npm run build`
Expected: exit 0

- [ ] **Step 3: Commit**

```bash
git add resources/css/app.css
git commit -m "feat: update semantic colors to JDC palette with legacy aliases"
```

---

### Task 4: Update shadcn-vue Mappings & Utilities in app.css

**Files:**

- Modify: `resources/css/app.css:48-94` (shadcn inline theme + utilities)

- [ ] **Step 1: Update shadcn-vue inline mappings**

Replace the `@theme inline` block (lines ~48-73) with:

```css
@theme inline {
    --color-background: var(--color-gray-50);
    --color-foreground: var(--color-gray-900);
    --color-card: var(--color-white);
    --color-card-foreground: var(--color-foreground);
    --color-popover: var(--color-white);
    --color-popover-foreground: var(--color-foreground);
    --color-primary: var(--color-brand-500);
    --color-primary-foreground: var(--color-white);
    --color-secondary: var(--color-secondary-500);
    --color-secondary-foreground: var(--color-white);
    --color-muted: var(--color-gray-100);
    --color-muted-foreground: var(--color-gray-500);
    --color-accent: var(--color-brand-50);
    --color-accent-foreground: var(--color-brand-700);
    --color-destructive: var(--color-status-error);
    --color-destructive-foreground: var(--color-white);
    --color-border: var(--color-gray-200);
    --color-input: var(--color-gray-300);
    --color-ring: var(--color-brand-300);
    --radius-sm: 0.375rem;
    --radius-md: 0.5rem;
    --radius-lg: 0.625rem;
    --radius-xl: 0.75rem;
}
```

- [ ] **Step 2: Update menu-item utilities**

Replace the menu-item utilities (lines ~76-94) with:

```css
@utility menu-item {
    @apply relative flex w-full items-center gap-3 rounded-lg px-3 py-2.5 font-medium text-sm;
}

@utility menu-item-active {
    @apply bg-brand-50 text-brand-500;
}

@utility menu-item-inactive {
    @apply text-gray-700 hover:bg-gray-100 group-hover:text-gray-700;
}

@utility menu-item-icon-active {
    @apply text-brand-500;
}

@utility menu-item-icon-inactive {
    @apply text-gray-500 group-hover:text-gray-700;
}
```

- [ ] **Step 3: Build + test + verify**

Run: `npm run build`
Expected: exit 0

Run: `npm run test`
Expected: 67 passed

Run: `./vendor/bin/pest`
Expected: 123 passed

- [ ] **Step 4: Commit**

```bash
git add resources/css/app.css
git commit -m "feat: update shadcn-vue mappings and menu utilities for JDC"
```

---

### Task 5: Update Sidebar Logo

**Files:**

- Modify: `resources/js/Components/Sidebar.vue` (find BrandMark usage)

- [ ] **Step 1: Read the Sidebar.vue logo section**

Read `resources/js/Components/Sidebar.vue` around line 106 to find the BrandMark component usage.

- [ ] **Step 2: Replace BrandMark with JDC square logo**

Replace the BrandMark component with an `<img>` tag:

```vue
<img src="/images/jdc-square.png" alt="JDC Logo" class="h-10 w-10 rounded-xl" />
```

Remove the `BrandMark` import if it's no longer used anywhere in the file.

- [ ] **Step 3: Build to verify**

Run: `npm run build`
Expected: exit 0

- [ ] **Step 4: Commit**

```bash
git add resources/js/Components/Sidebar.vue
git commit -m "feat: swap sidebar logo with JDC square PNG"
```

---

### Task 6: Update Welcome Page Logo

**Files:**

- Modify: `resources/js/Pages/Welcome.vue` (find BrandMark usage)

- [ ] **Step 1: Read the Welcome.vue logo section**

Read `resources/js/Pages/Welcome.vue` around line 29 to find the BrandMark component usage.

- [ ] **Step 2: Replace BrandMark with JDC rectangle logo**

Replace the BrandMark component with:

```vue
<img
    src="/images/jdc-square.png"
    alt="Jerrmond Dental Clinic"
    class="h-12 w-auto"
/>
```

Remove the `BrandMark` import if no longer used.

- [ ] **Step 3: Build to verify**

Run: `npm run build`
Expected: exit 0

- [ ] **Step 4: Commit**

```bash
git add resources/js/Pages/Welcome.vue
git commit -m "feat: swap welcome page logo with JDC rectangle PNG"
```

---

### Task 7: Update Guest Layout Gradient & Logo

**Files:**

- Modify: `resources/js/Layouts/GuestLayout.vue`

- [ ] **Step 1: Read GuestLayout.vue**

Read `resources/js/Layouts/GuestLayout.vue` to find the gradient and BrandMark usage.

- [ ] **Step 2: Update gradient to JDC brand colors**

Replace the gradient class:

From:

```
bg-gradient-to-br from-brand-700 via-brand-800 to-brand-900
```

To:

```
bg-gradient-to-br from-brand-900 via-secondary-900 to-secondary-900
```

- [ ] **Step 3: Update logo**

Replace BrandMark with:

```vue
<img
    src="/images/jdc-square.png"
    alt="Jerrmond Dental Clinic"
    class="h-10 w-auto"
/>
```

Remove BrandMark import if no longer used.

- [ ] **Step 4: Build to verify**

Run: `npm run build`
Expected: exit 0

- [ ] **Step 5: Commit**

```bash
git add resources/js/Layouts/GuestLayout.vue
git commit -m "feat: update guest layout with JDC gradient and logo"
```

---

### Task 8: Update Auth Pages Logos

**Files:**

- Modify: `resources/js/Pages/Auth/Login.vue`
- Modify: `resources/js/Pages/Auth/Register.vue`
- Modify: `resources/js/Pages/Auth/ForgotPassword.vue`

- [ ] **Step 1: Update Login.vue logo**

Read `resources/js/Pages/Auth/Login.vue`, find BrandMark, replace with:

```vue
<img
    src="/images/jdc-square.png"
    alt="Jerrmond Dental Clinic"
    class="mx-auto h-12 w-auto"
/>
```

Remove BrandMark import if no longer used.

- [ ] **Step 2: Update Register.vue logo**

Read `resources/js/Pages/Auth/Register.vue`, find BrandMark, replace with:

```vue
<img
    src="/images/jdc-square.png"
    alt="Jerrmond Dental Clinic"
    class="mx-auto h-12 w-auto"
/>
```

Remove BrandMark import if no longer used.

- [ ] **Step 3: Update ForgotPassword.vue logo**

Read `resources/js/Pages/Auth/ForgotPassword.vue`, find BrandMark, replace with:

```vue
<img
    src="/images/jdc-square.png"
    alt="Jerrmond Dental Clinic"
    class="mx-auto h-12 w-auto"
/>
```

Remove BrandMark import if no longer used.

- [ ] **Step 4: Build to verify**

Run: `npm run build`
Expected: exit 0

- [ ] **Step 5: Commit**

```bash
git add resources/js/Pages/Auth/Login.vue resources/js/Pages/Auth/Register.vue resources/js/Pages/Auth/ForgotPassword.vue
git commit -m "feat: swap auth page logos with JDC rectangle PNG"
```

---

### Task 9: Update Favicon

**Files:**

- Modify: `resources/views/app.blade.php`

- [ ] **Step 1: Read app.blade.php favicon link**

Read `resources/views/app.blade.php` and find the `<link rel="icon">` tag.

- [ ] **Step 2: Update favicon to JDC square logo**

Replace the favicon link with:

```html
<link rel="icon" type="image/png" href="/images/jdc-square.png" />
```

- [ ] **Step 3: Commit**

```bash
git add resources/views/app.blade.php
git commit -m "feat: update favicon to JDC square logo"
```

---

### Task 10: Update Button Variants

**Files:**

- Modify: `resources/js/Components/ui/button/index.js`

- [ ] **Step 1: Read current buttonVariants**

Read `resources/js/Components/ui/button/index.js` to find the `buttonVariants` object.

- [ ] **Step 2: Update variant classes**

Update the variants to use JDC tokens:

```javascript
const buttonVariants = cva(
    "inline-flex items-center justify-center gap-2 whitespace-nowrap rounded-md text-sm font-medium transition-all disabled:pointer-events-none disabled:opacity-50 [&_svg]:pointer-events-none [&_svg:not([class*='size-'])]:size-4 shrink-0 [&_svg]:shrink-0 outline-none focus-visible:border-ring focus-visible:ring-ring/50 focus-visible:ring-[3px] aria-invalid:ring-destructive/20 dark:aria-invalid:ring-destructive/40 aria-invalid:border-destructive",
    {
        variants: {
            variant: {
                default: "bg-brand-500 text-white hover:bg-brand-600",
                destructive:
                    "bg-status-error text-white hover:bg-status-error-dark",
                outline:
                    "border border-gray-300 bg-white hover:bg-gray-50 text-gray-700",
                secondary: "bg-secondary-500 text-white hover:bg-secondary-600",
                ghost: "hover:bg-gray-100 text-gray-700",
                link: "text-brand-500 underline-offset-4 hover:underline",
            },
            size: {
                default: "h-9 px-4 py-2",
                sm: "h-8 px-3 text-xs",
                lg: "h-10 px-8",
                icon: "size-9",
            },
        },
        defaultVariants: {
            variant: "default",
            size: "default",
        },
    },
);
```

- [ ] **Step 3: Build to verify**

Run: `npm run build`
Expected: exit 0

- [ ] **Step 4: Commit**

```bash
git add resources/js/Components/ui/button/index.js
git commit -m "feat: update button variants to JDC brand colors"
```

---

### Task 11: Update Badge Component

**Files:**

- Modify: `resources/js/Components/Badge.vue`

- [ ] **Step 1: Read current Badge.vue**

Read `resources/js/Components/Badge.vue` to find the variant classes.

- [ ] **Step 2: Update variant classes**

Replace the variant definitions with:

```javascript
const variants = {
    default: {
        primary: "bg-brand-50 text-brand-600",
        success: "bg-status-success-light text-status-success",
        warning: "bg-status-warning-light text-status-warning",
        error: "bg-status-error-light text-status-error",
        info: "bg-status-info-light text-status-info",
    },
    solid: {
        primary: "bg-brand-500 text-white",
        success: "bg-status-success text-white",
        warning: "bg-status-warning text-white",
        error: "bg-status-error text-white",
        info: "bg-status-info text-white",
    },
};
```

- [ ] **Step 3: Build to verify**

Run: `npm run build`
Expected: exit 0

- [ ] **Step 4: Commit**

```bash
git add resources/js/Components/Badge.vue
git commit -m "feat: update badge variants to JDC semantic colors"
```

---

### Task 12: Update Toast Component

**Files:**

- Modify: `resources/js/Components/Toast.vue`

- [ ] **Step 1: Read current Toast.vue**

Read `resources/js/Components/Toast.vue` to find the variant classes.

- [ ] **Step 2: Update variant classes**

Replace the variant definitions with:

```javascript
const variants = {
    success: "text-status-success bg-status-success-light",
    error: "text-status-error bg-status-error-light",
    warning: "text-status-warning bg-status-warning-light",
    info: "text-status-info bg-status-info-light",
};
```

- [ ] **Step 3: Build to verify**

Run: `npm run build`
Expected: exit 0

- [ ] **Step 4: Commit**

```bash
git add resources/js/Components/Toast.vue
git commit -m "feat: update toast variants to JDC semantic colors"
```

---

### Task 13: Fix Hardcoded Colors — ResponsiveNavLink

**Files:**

- Modify: `resources/js/Components/ResponsiveNavLink.vue`

- [ ] **Step 1: Read ResponsiveNavLink.vue**

Read `resources/js/Components/ResponsiveNavLink.vue` to find the `indigo-*` classes.

- [ ] **Step 2: Replace indigo with brand tokens**

Replace all `indigo-400`, `indigo-700`, `indigo-50`, `indigo-100`, `indigo-800` with corresponding brand tokens:

- `indigo-400` → `brand-300`
- `indigo-700` → `brand-700`
- `indigo-50` → `brand-50`
- `indigo-100` → `brand-100`
- `indigo-800` → `brand-800`

- [ ] **Step 3: Build to verify**

Run: `npm run build`
Expected: exit 0

- [ ] **Step 4: Commit**

```bash
git add resources/js/Components/ResponsiveNavLink.vue
git commit -m "fix: replace hardcoded indigo colors with brand tokens"
```

---

### Task 14: Fix Hardcoded Colors — Profile & Auth Green

**Files:**

- Modify: `resources/js/Pages/Profile/Partials/UpdateProfileInformationForm.vue`
- Modify: `resources/js/Pages/Auth/ForgotPassword.vue`

- [ ] **Step 1: Fix UpdateProfileInformationForm.vue**

Read the file, find `green-600`, replace with `status-success`.

- [ ] **Step 2: Fix ForgotPassword.vue**

Read the file, find `green-600`, replace with `status-success`.

- [ ] **Step 3: Build to verify**

Run: `npm run build`
Expected: exit 0

- [ ] **Step 4: Commit**

```bash
git add resources/js/Pages/Profile/Partials/UpdateProfileInformationForm.vue resources/js/Pages/Auth/ForgotPassword.vue
git commit -m "fix: replace hardcoded green-600 with status-success token"
```

---

### Task 15: Final Verification & Cleanup

**Files:**

- All modified files

- [ ] **Step 1: Grep for remaining hardcoded colors**

Run:

```bash
grep -rn "text-green-600\|bg-green-600\|text-indigo-\|bg-indigo-\|text-blue-600\|bg-blue-600" resources/js/ --include="*.vue" --include="*.js"
```

Expected: No matches (or only in third-party code).

- [ ] **Step 2: Run full test suite**

Run: `npm run test`
Expected: 67 passed

Run: `./vendor/bin/pest`
Expected: 123 passed

- [ ] **Step 3: Build**

Run: `npm run build`
Expected: exit 0

- [ ] **Step 4: Check whitespace**

Run: `git diff --check`
Expected: clean

- [ ] **Step 5: Browser smoke test**

Navigate to these pages and verify visual consistency:

1. `/` (Welcome) — JDC rectangle logo visible, gradient background
2. `/login` — JDC rectangle logo, form renders
3. `/dashboard` (after login) — sidebar has JDC square logo, nav items use brand colors
4. `/wizard` — stepper uses brand-500, form fields render correctly
5. `/patients` — table headers, badges use new semantic colors
6. `/appointments` — status badges use new semantic colors
7. `/settings` — forms render correctly

- [ ] **Step 6: Final commit**

```bash
git add -A
git commit -m "feat: apply JDC design system — colors, logos, neutrals, semantic tokens"
```

---

## Spec Coverage Check

| Spec Section                    | Implementing Task(s) |
| ------------------------------- | -------------------- |
| Brand Scale (brand-*)           | Task 1               |
| Secondary Scale (secondary-*)   | Task 2               |
| Neutral Scale (gray-* override) | Task 2               |
| Semantic Colors                 | Task 3               |
| shadcn-vue Mappings             | Task 4               |
| Logo & Branding Surfaces        | Tasks 5-9            |
| Button Variants                 | Task 10              |
| Badge Variants                  | Task 11              |
| Toast Variants                  | Task 12              |
| Menu Item Utilities             | Task 4               |
| Hardcoded Color Cleanup         | Tasks 13-14          |
| Verification                    | Task 15              |

**All spec requirements covered. No gaps.**

## Placeholder Scan

- No "TBD", "TODO", "implement later"
- No vague "add appropriate error handling"
- No "write tests for the above" without test code
- No "similar to Task N" references
- Every step shows exact code or exact commands

## Type Consistency Check

- Token names: `brand-*`, `secondary-*`, `status-{success,warning,error,info}-{,light,dark}` — consistent across all tasks
- File paths: all use `resources/js/` and `resources/css/` and `resources/views/` — consistent
- Color class patterns: `bg-X`, `text-X`, `border-X`, `hover:bg-X` — consistent
