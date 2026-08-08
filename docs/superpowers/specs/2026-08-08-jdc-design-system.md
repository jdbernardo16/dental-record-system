# JDC Design System Implementation

## Overview

Apply the Jerrmond Dental Clinic (JDC) brand design system to the Dental Clinic Patient Record System (DCPRS). This replaces the generic cyan/teal brand palette with JDC's specific color system, updates the neutral palette, adds a secondary blue scale, updates semantic colors, and refreshes all branding surfaces (logos, guest layout, auth pages).

## Scope

- **Colors**: Full token replacement in `resources/css/app.css`
- **Neutrals**: Override Tailwind's `gray-*` with JDC neutral scale
- **Semantic**: Update success/warning/error/info to JDC values
- **Branding**: Swap generic BrandMark with JDC logos (square + rectangle)
- **Surfaces**: Guest layout gradient, welcome page, auth pages, sidebar header
- **Primitives**: Button, Badge, Toast, menu-item utilities

## Design Decisions

### Brand Scale (`brand-*` → JDC Cyan Primary)

The existing `brand-*` scale (generic cyan/teal, hue ~200) is replaced with JDC's primary cyan scale. All existing `brand-*` references in ~100+ component files automatically adopt the new color without file edits.

| Token | Hex | OKLCH (approx) | Usage |
|-------|-----|----------------|-------|
| `brand-50` | `#F4FBFE` | oklch(0.985 0.01 210) | Subtle backgrounds, sections |
| `brand-100` | `#EAF8FD` | oklch(0.970 0.02 210) | Selected backgrounds, highlights |
| `brand-200` | `#D0F1FA` | oklch(0.940 0.04 210) | Hover states, light borders |
| `brand-300` | `#A5E3F5` | oklch(0.890 0.07 210) | Focus rings, light accents |
| `brand-400` | `#5CCBEA` | oklch(0.780 0.10 210) | Secondary accents |
| `brand-500` | `#08AEEA` | oklch(0.680 0.14 210) | **Primary** — buttons, active states, links |
| `brand-600` | `#078FC2` | oklch(0.600 0.12 210) | Button hover, pressed states |
| `brand-700` | `#06769F` | oklch(0.520 0.10 210) | Darker hover |
| `brand-800` | `#174A9C` | oklch(0.420 0.12 250) | **JDC Blue** — headings, emphasis |
| `brand-900` | `#123B7D` | oklch(0.350 0.10 250) | Dark brand elements, charts, icons |

> Note: `brand-800` and `brand-900` shift from cyan to blue per the JDC primary scale. The `secondary-*` scale provides the full JDC Blue range.

### Secondary Scale (`secondary-*` → JDC Blue)

New scale for headings, emphasis, strong elements, active navigation backgrounds.

| Token | Hex | OKLCH (approx) | Usage |
|-------|-----|----------------|-------|
| `secondary-50` | `#EAF2FF` | oklch(0.950 0.03 260) | Light backgrounds |
| `secondary-100` | `#D6E4FF` | oklch(0.920 0.05 260) | Subtle highlights |
| `secondary-200` | `#A8C8FF` | oklch(0.850 0.08 260) | Borders |
| `secondary-300` | `#7AABFF` | oklch(0.780 0.11 260) | Accents |
| `secondary-400` | `#4D8FFF` | oklch(0.700 0.14 260) | Secondary accents |
| `secondary-500` | `#174A9C` | oklch(0.420 0.12 250) | **Headings, emphasis, strong elements** |
| `secondary-600` | `#123B7D` | oklch(0.350 0.10 250) | Darker emphasis |
| `secondary-700` | `#0E2D5E` | oklch(0.280 0.08 250) | Dark elements |
| `secondary-800` | `#091E3F` | oklch(0.200 0.06 250) | Charts, icons |
| `secondary-900` | `#050F1F` | oklch(0.120 0.04 250) | Maximum emphasis |

### Neutral Scale (Override `gray-*` with JDC Neutrals)

Tailwind's default `gray-*` is overridden in `@theme` with JDC's neutral palette. This means all existing `bg-gray-50`, `text-gray-500`, `border-gray-200`, etc. across ~100+ files automatically align.

| Tailwind | JDC Neutral | Hex | Usage |
|----------|-------------|-----|-------|
| `gray-50` | 50 | `#F8FAFC` | App background |
| `gray-100` | 100 | `#F1F5F9` | Secondary background |
| `gray-200` | 200 | `#E2E8F0` | Borders, dividers |
| `gray-300` | 300 | `#CBD5E1` | Disabled borders |
| `gray-400` | 400 | `#94A3B8` | Placeholder, muted |
| `gray-500` | 500 | `#64748B` | Secondary text |
| `gray-600` | 600 | `#475569` | Body text |
| `gray-700` | 700 | `#334155` | Strong text |
| `gray-800` | 800 | `#1E293B` | Headings |
| `gray-900` | 900 | `#0F172A` | Maximum emphasis |

### Semantic Colors (JDC Design System)

Replace existing semantic tokens with JDC's specific semantic palette.

| Token | Hex | OKLCH (approx) | Usage |
|-------|-----|----------------|-------|
| `status-success` | `#16A34A` | oklch(0.550 0.18 145) | Success, completed |
| `status-success-light` | `#F0FDF4` | oklch(0.970 0.03 145) | Success backgrounds |
| `status-success-dark` | `#15803D` | oklch(0.450 0.15 145) | Dark success |
| `status-warning` | `#F59E0B` | oklch(0.750 0.16 85) | Warnings, pending |
| `status-warning-light` | `#FFFBEB` | oklch(0.990 0.02 85) | Warning backgrounds |
| `status-warning-dark` | `#B45309` | oklch(0.550 0.14 85) | Dark warning |
| `status-error` | `#DC2626` | oklch(0.550 0.22 25) | Errors, cancelled, destructive |
| `status-error-light` | `#FEF2F2` | oklch(0.980 0.02 25) | Error backgrounds |
| `status-error-dark` | `#B91C1C` | oklch(0.450 0.18 25) | Dark error |
| `status-info` | `#2563EB` | oklch(0.550 0.20 260) | Info, confirmed |
| `status-info-light` | `#EFF6FF` | oklch(0.970 0.03 260) | Info backgrounds |
| `status-info-dark` | `#1D4ED8` | oklch(0.450 0.18 260) | Dark info |

### Tooth Condition & Restoration Palettes

These PDA-specific palettes remain unchanged — they are clinical, not brand-related.

## shadcn-vue Mapping Updates

```css
@theme inline {
  --color-background: var(--color-gray-50);       /* #F8FAFC app bg */
  --color-foreground: var(--color-gray-900);      /* #0F172A */
  --color-card: var(--color-white);
  --color-card-foreground: var(--color-foreground);
  --color-popover: var(--color-white);
  --color-popover-foreground: var(--color-foreground);
  --color-primary: var(--color-brand-500);        /* #08AEEA */
  --color-primary-foreground: var(--color-white);
  --color-secondary: var(--color-secondary-500);  /* #174A9C */
  --color-secondary-foreground: var(--color-white);
  --color-muted: var(--color-gray-100);          /* #F1F5F9 */
  --color-muted-foreground: var(--color-gray-500); /* #64748B */
  --color-accent: var(--color-brand-50);          /* #F4FBFE */
  --color-accent-foreground: var(--color-brand-700); /* #06769F */
  --color-destructive: var(--color-status-error);  /* #DC2626 */
  --color-destructive-foreground: var(--color-white);
  --color-border: var(--color-gray-200);           /* #E2E8F0 */
  --color-input: var(--color-gray-300);           /* #CBD5E1 */
  --color-ring: var(--color-brand-300);           /* #A5E3F5 */
}
```

## Logo & Branding Surfaces

| Location | Asset | Size | Notes |
|----------|-------|------|-------|
| Sidebar header | `jdc-square.png` | 40×40 | Replace generic tooth icon |
| Welcome page hero | `jdc-rectangle.png` | 200×auto | Centered above heading |
| Auth pages (login/register/forgot) | `jdc-rectangle.png` | 160×auto | Above form card |
| Guest layout background | Gradient | Full bleed | `from-brand-900 via-secondary-900 to-secondary-900` |
| Favicon | `jdc-square.png` | 32×32 | Update `<link rel="icon">` in app blade template |

## Component Primitive Updates

### Button Variants (shadcn-vue)
- **Primary**: `bg-brand-500 hover:bg-brand-600 text-white`
- **Secondary**: `bg-secondary-500 hover:bg-secondary-600 text-white`
- **Outline**: `border-gray-300 bg-white hover:bg-gray-50 text-gray-700`
- **Ghost**: `hover:bg-gray-100 text-gray-700`
- **Destructive**: `bg-status-error hover:bg-status-error-dark text-white`

### Badge Variants
- **Primary**: `bg-brand-50 text-brand-600`
- **Success**: `bg-status-success-light text-status-success`
- **Warning**: `bg-status-warning-light text-status-warning`
- **Error**: `bg-status-error-light text-status-error`
- **Info**: `bg-status-info-light text-status-info`

### Toast Variants
- **Success**: `text-status-success` (icon) + `bg-status-success-light` (background)
- **Error**: `text-status-error` + `bg-status-error-light`
- **Warning**: `text-status-warning` + `bg-status-warning-light`
- **Info**: `text-status-info` + `bg-status-info-light`

### Menu Item Utilities
- **Active**: `bg-brand-50 text-brand-500`
- **Inactive**: `text-gray-700 hover:bg-gray-100`
- **Active icon**: `text-brand-500`
- **Inactive icon**: `text-gray-500 group-hover:text-gray-700`

## Files to Modify

### Core Tokens
- `resources/css/app.css` — Full token replacement

### Logo Components
- `resources/js/Components/Sidebar.vue` — Swap BrandMark for jdc-square.png
- `resources/js/Pages/Welcome.vue` — Swap BrandMark for jdc-rectangle.png
- `resources/js/Layouts/GuestLayout.vue` — Update gradient + logo
- `resources/js/Pages/Auth/Login.vue` — Swap BrandMark for jdc-rectangle.png
- `resources/js/Pages/Auth/Register.vue` — Swap BrandMark for jdc-rectangle.png
- `resources/js/Pages/Auth/ForgotPassword.vue` — Swap BrandMark for jdc-rectangle.png
- `resources/views/app.blade.php` — Update favicon link

### Component Primitives
- `resources/js/Components/ui/button/index.js` — Update buttonVariants
- `resources/js/Components/Badge.vue` — Update variant classes
- `resources/js/Components/Toast.vue` — Update variant classes
- `resources/css/app.css` — Update menu-item utilities

### Hardcoded Color Fixes
- `resources/js/Components/ResponsiveNavLink.vue` — Replace `indigo-*` with `brand-*`
- `resources/js/Pages/Profile/Partials/UpdateProfileInformationForm.vue` — Replace `green-600` with `status-success`
- `resources/js/Pages/Auth/ForgotPassword.vue` — Replace `green-600` with `status-success`

## Migration Strategy

### Phase 1: Token Foundation
1. Backup current `app.css`
2. Replace brand scale with JDC Cyan
3. Add secondary scale
4. Override gray-* with JDC neutrals
5. Update semantic tokens
6. Update shadcn-vue inline mappings
7. Update menu-item utilities
8. Build + verify no compilation errors

### Phase 2: Logo & Branding
1. Update Sidebar.vue with jdc-square.png
2. Update Welcome.vue with jdc-rectangle.png
3. Update GuestLayout.vue gradient
4. Update all Auth pages with jdc-rectangle.png
5. Update app.blade.php favicon
6. Build + verify

### Phase 3: Component Primitives
1. Update button variants
2. Update Badge.vue
3. Update Toast.vue
4. Build + verify

### Phase 4: Hardcoded Color Cleanup
1. Fix ResponsiveNavLink.vue
2. Fix Profile/Auth green-600 references
3. Grep for any remaining hardcoded colors
4. Build + verify

### Phase 5: Verification
1. `npm run build` — must succeed
2. `npm run test` — 67 Vitest must pass
3. `./vendor/bin/pest` — 123 Pest must pass
4. `git diff --check` — clean
5. Browser smoke: sidebar, welcome, auth, dashboard, wizard, patients, appointments
6. Screenshot comparison (optional): key pages before/after

## Testing Strategy

- **Automated**: Existing Vitest + Pest suites must pass unchanged (token swaps are CSS-only)
- **Visual**: Browser smoke across 7 key pages
- **Accessibility**: Verify WCAG AA contrast ratios maintained (JDC design system claims AA compliance)

## Risks & Mitigations

| Risk | Mitigation |
|------|------------|
| `gray-*` override breaks third-party styles | Third-party libs use inline styles or their own classes; Tailwind v4 `@theme` override only affects utility classes |
| Brand color too bright for large backgrounds | `brand-50` (#F4FBFE) is very light; use for subtle backgrounds only |
| Logo PNGs don't match new color scheme | Verified: JDC logos use the same cyan (#08AEEA) and blue (#174A9C) as the design system |
| Migration touches many files | Phased approach; each phase independently verifiable |

## Open Questions

1. **Tooth condition palette**: Keep existing PDA colors or align with JDC? → **Decision**: Keep existing; clinical colors are independent of brand.
2. **Font**: Keep Figtree or switch to something more "professional"? → **Decision**: Keep Figtree; it's clean and modern, matches "Clean · Modern · Trustworthy · Professional · Caring" brand values.
3. **Dark mode**: JDC design system doesn't specify dark mode. → **Decision**: Not in scope; current app has no dark mode support.

## References

- JDC Design System PNG: `docs/reference/jdc-design-system.png`
- JDC Square Logo: `public/images/jdc-square.png`
- JDC Rectangle Logo: `public/images/jdc-rectangle.png`
- Current tokens: `resources/css/app.css`
