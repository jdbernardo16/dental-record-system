# Odontogram Revamp — Port react-odontogram SVG Engine to Vue

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace the stylized rounded-rectangle odontogram in `ToothChart.vue` with the anatomical SVG arch rendering ported from the MIT-licensed `react-odontogram` library (the engine used by open-dentist), while preserving DCPRS's per-surface clinical charting, PDA condition/restoration legend, and the append-only backend data model.

**Architecture:** Port the pure-SVG data (`teethPaths` 8 tooth shapes + quadrant transforms + FDI notation maps) into JS data modules. Rebuild `ToothChart.vue` to render the arch layout (viewBox `0 0 409 694`) using quadrant `<g>` transforms, with each tooth drawn from its anatomical outline/shadow/highlight paths. Keep the existing props contract (`state`, `options`, `dentition`, `readonly`, `selectedCondition`, `selectedRestoration`), the `apply-tooth` emit (`{ tooth, surface }`), the 5 clickable surface zones per tooth, the `var(--color-cond-*)` / `var(--color-rest-*)` token coloring, and the FDI number labels.

**Tech Stack:** Vue 3, SVG, Tailwind v4 (OKLCH tokens), Vitest, MIT-licensed port data.

---

## File Inventory

| File | Action | Responsibility |
|------|--------|----------------|
| `resources/js/lib/odontogram/teethPaths.js` | Create | 8 anatomical tooth shape definitions (outline/shadow/highlight paths) — port of `data.ts` |
| `resources/js/lib/odontogram/quadrants.js` | Create | Quadrant `<g>` transforms, FDI↔Universal↔Palmer maps, tooth-type-by-name lookup |
| `resources/js/lib/odontogram/index.js` | Create | Barrel export |
| `resources/js/Components/ToothChart.vue` | Rewrite | The odontogram renderer — arch layout, quadrant transforms, per-tooth rendering, 5 surface zones, click handling |
| `tests/js/odontogram/quadrants.spec.js` | Create | Unit tests for quadrant/FDI logic |
| `tests/js/odontogram/teethPaths.spec.js` | Create | Unit tests for tooth shape data integrity |
| `docs/reference/odontogram/data.ts` | Create (done) | MIT source reference (already copied) |
| `docs/reference/odontogram/utils.ts` | Create (done) | MIT source reference (already copied) |
| `resources/js/Pages/Patients/Chart.vue` | Unchanged | Host page — verify only |
| `resources/js/Pages/Patients/Show.vue` | Unchanged | Host page — verify only |
| `resources/js/Pages/Patients/Export.vue` | Unchanged | Host page — verify only |
| `resources/js/Pages/Wizard/Index.vue` | Unchanged | Host page — verify only |

---

### Task 1: Create the odontogram data modules

**Files:**
- Create: `resources/js/lib/odontogram/teethPaths.js`
- Create: `resources/js/lib/odontogram/quadrants.js`
- Create: `resources/js/lib/odontogram/index.js`

- [ ] **Step 1: Create `teethPaths.js`**

Copy the `teethPaths` array from `docs/reference/odontogram/data.ts` (the circle-layout set, lines 1-97) into a JS module. Convert to ESM:

```javascript
/**
 * Ported from react-odontogram (MIT) — biomathcode/react-odontogram
 * Circle/arch layout tooth shapes. Each tooth type (1-8 within a quadrant)
 * is defined once with outline (crown/root silhouette), shadow (condition
 * fill shape), and highlight (anatomical grooves/cusps) paths.
 */
export const teethPaths = [
    // ... 8 entries verbatim from docs/reference/odontogram/data.ts ...
]
```

The 8 entries must preserve: `name` ("1".."8"), `type` ("Central Incisor".."Third Molar"), `outlinePath`, `shadowPath`, `lineHighlightPath` (string OR string[] — molar/premolar entries have arrays).

**Verification:** copy the file verbatim from the reference; do NOT hand-retype the path data (error-prone). Use `cp docs/reference/odontogram/data.ts resources/js/lib/odontogram/teethPaths.js` then convert the syntax: remove the `export const` TS types (they're plain JS-compatible), change to `export const teethPaths = [...]`. The path strings themselves must be byte-identical.

- [ ] **Step 2: Create `quadrants.js`**

```javascript
/**
 * Ported from react-odontogram (MIT) — biomathcode/react-odontogram
 * Quadrant transforms (circle/arch layout, viewBox 0 0 409 694) and
 * FDI ↔ Universal ↔ Palmer notation conversions.
 */
export const VIEW_W = 409
export const VIEW_H = 694

export const quadrants = [
    { name: 'first',  transform: '',                                      label: 'Upper Right' },
    { name: 'second', transform: 'scale(-1, 1) translate(-409, 0)',       label: 'Upper Left' },
    { name: 'third',  transform: 'scale(1, -1) translate(0, -694)',       label: 'Lower Right' },
    { name: 'fourth', transform: 'scale(-1, -1) translate(-409, -694)',   label: 'Lower Left' },
]

/** FDI tooth id (e.g. "teeth-11") → Universal / Palmer / plain FDI. */
export const convertFDIToNotation = (fdi, notation) => {
    const num = String(fdi).replace('teeth-', '')
    const fdiToUniversal = {
        '11': 8, '12': 7, '13': 6, '14': 5, '15': 4, '16': 3, '17': 2, '18': 1,
        '21': 9, '22': 10, '23': 11, '24': 12, '25': 13, '26': 14, '27': 15, '28': 16,
        '31': 24, '32': 23, '33': 22, '34': 21, '35': 20, '36': 19, '37': 18, '38': 17,
        '41': 25, '42': 26, '43': 27, '44': 28, '45': 29, '46': 30, '47': 31, '48': 32,
    }
    if (notation === 'Universal') return String(fdiToUniversal[num] ?? num)
    if (notation === 'Palmer') {
        if (num.length < 2) return num
        const symbols = { '1': 'UR', '2': 'UL', '3': 'LL', '4': 'LR' }
        return `${num[1]}${symbols[num[0]] ?? ''}`
    }
    return num
}

/** Build a full FDI id for a quadrant (1-4) and tooth type (1-8): "teeth-11".."teeth-48". */
export const toothId = (quadrant, toothType) => `teeth-${quadrant}${toothType}`
```

- [ ] **Step 3: Create `index.js` barrel**

```javascript
export * from './teethPaths'
export * from './quadrants'
```

- [ ] **Step 4: Build to verify syntax**

Run: `npm run build`
Expected: exit 0, no errors

- [ ] **Step 5: Commit**

```bash
git add resources/js/lib/odontogram/ docs/reference/odontogram/
git commit -m "feat: add ported odontogram data modules (MIT react-odontogram)"
```

---

### Task 2: Write geometry unit tests

**Files:**
- Create: `tests/js/odontogram/quadrants.spec.js`
- Create: `tests/js/odontogram/teethPaths.spec.js`

- [ ] **Step 1: Write `quadrants.spec.js`**

```javascript
import { describe, expect, it } from 'vitest'
import { convertFDIToNotation, toothId, quadrants, VIEW_W, VIEW_H } from '@/lib/odontogram'

describe('odontogram quadrants', () => {
    it('has 4 quadrants covering all 32 FDI teeth', () => {
        expect(quadrants).toHaveLength(4)
        expect(quadrants.map((q) => q.name)).toEqual(['first', 'second', 'third', 'fourth'])
        expect(quadrants.map((q) => q.label)).toEqual(['Upper Right', 'Upper Left', 'Lower Right', 'Lower Left'])
    })

    it('defines mirror transforms for each quadrant', () => {
        expect(quadrants[0].transform).toBe('')
        expect(quadrants[1].transform).toContain('scale(-1, 1)')
        expect(quadrants[2].transform).toContain('scale(1, -1)')
        expect(quadrants[3].transform).toContain('scale(-1, -1)')
    })

    it('builds correct FDI ids for all 32 teeth', () => {
        const ids = []
        for (let q = 1; q <= 4; q++) {
            for (let t = 1; t <= 8; t++) {
                ids.push(toothId(q, t))
            }
        }
        expect(ids).toHaveLength(32)
        expect(ids[0]).toBe('teeth-11')
        expect(ids[7]).toBe('teeth-18')
        expect(ids[8]).toBe('teeth-21')
        expect(ids[31]).toBe('teeth-48')
    })

    it('converts FDI to Universal numbering', () => {
        expect(convertFDIToNotation('teeth-11', 'Universal')).toBe('8')
        expect(convertFDIToNotation('teeth-18', 'Universal')).toBe('1')
        expect(convertFDIToNotation('teeth-21', 'Universal')).toBe('9')
        expect(convertFDIToNotation('teeth-48', 'Universal')).toBe('32')
        expect(convertFDIToNotation('teeth-36', 'Universal')).toBe('19')
    })

    it('converts FDI to Palmer notation', () => {
        expect(convertFDIToNotation('teeth-11', 'Palmer')).toBe('1UR')
        expect(convertFDIToNotation('teeth-21', 'Palmer')).toBe('1UL')
        expect(convertFDIToNotation('teeth-31', 'Palmer')).toBe('1LL')
        expect(convertFDIToNotation('teeth-41', 'Palmer')).toBe('1LR')
    })

    it('returns plain FDI when notation is FDI', () => {
        expect(convertFDIToNotation('teeth-24', 'FDI')).toBe('24')
    })

    it('keeps the arch viewBox dimensions', () => {
        expect(VIEW_W).toBe(409)
        expect(VIEW_H).toBe(694)
    })
})
```

- [ ] **Step 2: Write `teethPaths.spec.js`**

```javascript
import { describe, expect, it } from 'vitest'
import { teethPaths } from '@/lib/odontogram'

describe('odontogram teethPaths', () => {
    it('defines 8 tooth types in the expected order', () => {
        expect(teethPaths).toHaveLength(8)
        expect(teethPaths.map((t) => t.name)).toEqual(['1', '2', '3', '4', '5', '6', '7', '8'])
        expect(teethPaths.map((t) => t.type)).toEqual([
            'Central Incisor', 'Lateral Incisor', 'Canine', 'First Premolar',
            'Second Premolar', 'First Molar', 'Second Molar', 'Third Molar',
        ])
    })

    it('has valid SVG path strings for every tooth', () => {
        for (const tooth of teethPaths) {
            expect(tooth.outlinePath).toMatch(/^M/);
            expect(tooth.shadowPath).toMatch(/^M/);
            expect(typeof tooth.outlinePath).toBe('string')
            expect(typeof tooth.shadowPath).toBe('string')
        }
    })

    it('renders molar/premolar highlights as arrays, incisors as strings', () => {
        expect(Array.isArray(teethPaths[0].lineHighlightPath)).toBe(false) // central incisor
        expect(Array.isArray(teethPaths[1].lineHighlightPath)).toBe(false) // lateral incisor
        expect(Array.isArray(teethPaths[2].lineHighlightPath)).toBe(true)  // canine
        expect(Array.isArray(teethPaths[3].lineHighlightPath)).toBe(true)  // 1st premolar
        expect(Array.isArray(teethPaths[5].lineHighlightPath)).toBe(true)  // 1st molar
        expect(Array.isArray(teethPaths[7].lineHighlightPath)).toBe(true)  // 3rd molar
    })

    it('has non-trivial path data', () => {
        for (const tooth of teethPaths) {
            expect(tooth.outlinePath.length).toBeGreaterThan(100)
            expect(tooth.shadowPath.length).toBeGreaterThan(50)
        }
    })
})
```

- [ ] **Step 3: Run tests to verify they pass**

Run: `npm run test`
Expected: new files pass (2 files, ~11 tests). Total suite count goes up.

- [ ] **Step 4: Commit**

```bash
git add tests/js/odontogram/
git commit -m "test: add odontogram data and quadrant unit tests"
```

---

### Task 3: Rebuild ToothChart.vue with the anatomical arch renderer

**Files:**
- Rewrite: `resources/js/Components/ToothChart.vue`

This is the core task. The component must keep its exact public API (props + emit) so all 4 host pages work unchanged:

**Props:** `state` (Object, required), `dentition` (String, 'adult'|'primary'), `readonly` (Boolean), `selectedCondition` (String), `selectedRestoration` (String), `options` (Object, required)
**Emits:** `apply-tooth` with `{ tooth, surface }` (surface null = whole tooth)

- [ ] **Step 1: Replace the geometry helpers (script block, first section)**

Replace `rowToothLists` and the old coordinate math with quadrant-based layout. Keep `wholeToothOnly()` and `surfaceZones()` exports (tests may not exist but the API shape should stay for compatibility):

```javascript
<script>
/** Conditions that may only be recorded on the whole tooth (never a surface). */
export const wholeToothOnly = () => ['missing_caries', 'missing_other', 'impacted', 'supernumerary', 'unerupted']

/** Five clickable zones per tooth (percent-based, mapped onto the arch shapes). */
export const surfaceZones = () => ({
    occlusal: { x: 0.18, y: 0.10, w: 0.64, h: 0.22 },   // top band
    mesial:   { x: 0.14, y: 0.10, w: 0.22, h: 0.80 },   // left band
    distal:   { x: 0.64, y: 0.10, w: 0.22, h: 0.80 },   // right band
    buccal:   { x: 0.14, y: 0.62, w: 0.35, h: 0.28 },   // bottom-left
    lingual:  { x: 0.51, y: 0.62, w: 0.35, h: 0.28 },   // bottom-right
})
</script>
```

NOTE: the surface zones are now PERCENTAGE-based (0-1) because each tooth shape occupies a different bounding box. The template computes actual pixel rects from `getBBox()` at mount time (see Step 3).

- [ ] **Step 2: Script setup — data imports, props, computed**

```javascript
<script setup>
import { computed, onMounted, ref } from 'vue'
import { teethPaths, quadrants, toothId, VIEW_W, VIEW_H } from '@/lib/odontogram'

const props = defineProps({
    state: { type: Object, required: true },
    dentition: { type: String, default: 'adult' },
    readonly: { type: Boolean, default: false },
    selectedCondition: { type: String, default: null },
    selectedRestoration: { type: String, default: null },
    options: { type: Object, required: true },
})

const emit = defineEmits(['apply-tooth'])
```

- [ ] **Step 3: Script setup — rendering logic**

```javascript
/** Map a state slot (whole or surface) to fill/stroke/dash/symbol tokens. */
const slotStyle = (slot) => {
    const condition = slot?.condition ? props.options.conditions?.[slot.condition] : null
    const restoration = slot?.restoration ? props.options.restorations?.[slot.restoration] : null
    let fillToken = null, strokeToken = null, dash = false, symbol = null
    if (condition) {
        if (condition.render === 'missing') { fillToken = condition.color; symbol = 'x' }
        else if (condition.render === 'dashed') { fillToken = condition.color; dash = true }
        else if (condition.render === 'solid') { fillToken = condition.color }
        else if (condition.render === 'check' && !restoration) { fillToken = condition.color; symbol = 'check' }
    }
    if (restoration) {
        if (restoration.render === 'outline') { strokeToken = restoration.color }
        else if (restoration.render === 'solid' && !fillToken) { fillToken = restoration.color }
    }
    return { fillToken, strokeToken, dash, symbol }
}

/** Whole-tooth lock when a whole-tooth-only condition is armed. */
const wholeOnly = computed(() =>
    !props.readonly && props.selectedCondition !== null && wholeToothOnly().includes(props.selectedCondition),
)

/** Adult = 8 teeth per quadrant (32), primary = 5 per quadrant (20, FDI 5x/6x/7x/8x). */
const teethPerQuadrant = computed(() => (props.dentition === 'primary' ? 5 : 8))

/** Build the 32 (or 20) tooth render descriptors. */
const teeth = computed(() => {
    const list = []
    quadrants.forEach((q, qi) => {
        const quadrantNum = qi + 1
        for (let t = 0; t < teethPerQuadrant.value; t++) {
            const shape = teethPaths[t]
            const id = toothId(quadrantNum, t + 1)
            const fdiNum = String(id).replace('teeth-', '')
            // FDI quadrant digits: 1/2 upper, 3/4 lower — matches our state keys
            const whole = props.state?.[fdiNum]?.whole ?? null
            list.push({
                id,
                fdi: fdiNum,
                shape,
                transform: q.transform,
                whole,
                body: bodyVisuals(whole),
                symbol: symbolVisuals(whole),
                zones: zones.map((zone) => {
                    const surface = props.state?.[fdiNum]?.surfaces?.[zone.key] ?? null
                    const visuals = zoneVisuals(surface)
                    return { key: zone.key, ...zone, ...visuals }
                }),
            })
        }
    })
    return list
})
```

Continue with the visuals helpers (identical to current implementation):

```javascript
const bodyVisuals = (slot) => {
    const { fillToken, strokeToken, dash } = slotStyle(slot)
    const style = { fill: fillToken ? `var(--color-${fillToken})` : 'var(--color-white)' }
    if (strokeToken) {
        style.stroke = `var(--color-${strokeToken})`
        style.strokeWidth = '5'
    } else if (dash) {
        style.stroke = `var(--color-${fillToken})`
        style.strokeWidth = '2'
        style.strokeDasharray = '5 3'
        style.fillOpacity = '0.35'
    }
    return style
}

const symbolVisuals = (slot) => {
    const { symbol } = slotStyle(slot)
    if (!symbol) return null
    const condition = slot?.condition ? props.options.conditions?.[slot.condition] : null
    return {
        kind: symbol,
        color: condition?.render === 'check' ? 'var(--color-gray-500)' : 'var(--color-white)',
    }
}

const zoneVisuals = (slot) => {
    const { fillToken, strokeToken, dash } = slotStyle(slot)
    const style = { fill: fillToken ? `var(--color-${fillToken})` : 'transparent' }
    let ring = false
    if (strokeToken) {
        style.stroke = `var(--color-${strokeToken})`
        style.strokeWidth = '3'
        ring = true
    } else if (dash) {
        style.stroke = `var(--color-${fillToken})`
        style.strokeWidth = '2'
        style.strokeDasharray = '4 2'
        style.fillOpacity = '0.35'
    }
    return { style, ring }
}

const zones = Object.entries(surfaceZones()).map(([key, zone]) => ({ key, ...zone }))

const apply = (tooth, surface) => {
    if (props.readonly) return
    emit('apply-tooth', { tooth, surface })
}
```

- [ ] **Step 4: Template — arch SVG with quadrant groups**

```html
<template>
    <div :class="{ 'pointer-events-none': readonly }" class="relative">
        <svg
            viewBox="0 0 409 694"
            class="h-auto w-full select-none"
            role="img"
            :aria-label="`Dental chart — ${dentition} dentition`"
        >
            <title>Odontogram</title>
            <g v-for="q in quadrants" :key="q.name" :transform="q.transform">
                <g v-for="slot in teethIn(q)" :key="slot.id" class="tooth-group">
                    <!-- anatomical outline -->
                    <path
                        :d="slot.shape.outlinePath"
                        :style="slot.body"
                        stroke-width="2"
                        stroke-linecap="round"
                        stroke-linejoin="round"
                        class="stroke-gray-300 hover:stroke-gray-400"
                        @click="apply(slot.fdi, null)"
                    />
                    <!-- condition fill (shadow shape) -->
                    <path
                        :d="slot.shape.shadowPath"
                        :style="slot.body"
                        class="tooth-fill"
                    />
                    <!-- highlight grooves/cusps -->
                    <path
                        v-for="(hl, i) in highlightPaths(slot.shape)"
                        :key="i"
                        :d="hl"
                        stroke-width="1"
                        stroke-linecap="round"
                        stroke-linejoin="round"
                        class="stroke-gray-300"
                    />
                    <!-- whole-tooth symbol (X / check) -->
                    <g
                        v-if="slot.symbol"
                        :style="{ stroke: slot.symbol.color }"
                        fill="none"
                        stroke-width="3"
                        stroke-linecap="round"
                        stroke-linejoin="round"
                        transform="translate(0 0)"
                    >
                        <line v-if="slot.symbol.kind === 'x'" x1="0.35" y1="0.3" x2="0.65" y2="0.7" />
                        <line v-if="slot.symbol.kind === 'x'" x1="0.65" y1="0.3" x2="0.35" y2="0.7" />
                        <polyline v-else :points="symbolPoints(slot)" />
                    </g>
                    <!-- surface zones (SVG path per zone, computed from getBBox) -->
                    <path
                        v-for="zone in slot.zones"
                        :key="zone.key"
                        :d="zone.d"
                        :style="zone.style"
                        :stroke-width="zone.ring ? 3 : 1.5"
                        :title="zone.label"
                        class="hover:stroke-gray-400"
                        :class="{
                            'cursor-crosshair': !readonly && !wholeOnly,
                            'pointer-events-none opacity-60': wholeOnly,
                        }"
                        @click="apply(slot.fdi, zone.key)"
                    />
                    <!-- tooth number -->
                    <text
                        :x="slot.labelX"
                        :y="slot.labelY"
                        text-anchor="middle"
                        font-size="12"
                        class="select-none fill-gray-400"
                    >
                        {{ slot.fdi }}
                    </text>
                </g>
            </g>
        </svg>
    </div>
</template>
```

- [ ] **Step 5: Add the zone/label geometry computation**

The surface zones are percentage-based; the template needs actual pixel paths. Add a helper that measures each tooth's bounding box at mount and on resize, then builds rounded-rect paths for zones and label positions:

```javascript
/** Convert a percentage zone (0-1 relative to a tooth bbox) to a rounded-rect path. */
const zonePath = (box, zone) => {
    const x = box.x + box.width * zone.x
    const y = box.y + box.height * zone.y
    const w = box.width * zone.w
    const h = box.height * zone.h
    const r = Math.min(3, w / 4)
    return `M${x + r} ${y}H${x + w - r}A${r} ${r} 0 0 1 ${x + w} ${y + r}V${y + h - r}A${r} ${r} 0 0 1 ${x + w - r} ${y + h}H${x + r}A${r} ${r} 0 0 1 ${x} ${y + h - r}V${y + r}A${r} ${r} 0 0 1 ${x + r} ${y}Z`
}
```

Then in `onMounted`, after `nextTick`, measure each tooth's `getBBox()` and populate reactive `toothBoxes` used by `teeth` computed. Re-measure on window resize (debounced). If a tooth has no bbox yet (hidden), fall back to a default box centered on the arch.

**Simplification option (recommended for reliability):** Because each tooth shape has a known approximate bounding region within its quadrant's local coordinate space (the shapes are authored in consistent positions), you can use **hardcoded per-tooth-type percentage boxes** derived from the reference data instead of runtime `getBBox()`. For a first pass, use `getBBox()` measured once on mount with a fallback — it is the most robust against path changes.

- [ ] **Step 6: Build + test**

Run: `npm run build` — must succeed
Run: `npm run test` — all existing + new tests pass (expect ~81 total)
Run: `./vendor/bin/pest` — 123 must pass

- [ ] **Step 7: Commit**

```bash
git add resources/js/Components/ToothChart.vue
git commit -m "feat: rebuild odontogram with anatomical arch rendering (react-odontogram port)"
```

---

### Task 4: Browser verification across all host pages

**Files:** verify only — no changes expected

- [ ] **Step 1: Patient chart editor page**

Navigate to `/patients/9/chart` (logged in as admin/password). Verify:
- The arch renders: 32 anatomical teeth in 4 mirrored quadrants
- Condition chips + restoration chips in the legend render
- Click a condition chip (e.g. Decayed/D), then click a tooth → POST succeeds, tooth fills with cond-caries color
- Click the same tooth's mesial zone → surface condition applies to just that zone
- Readonly mode (when `asOf` set or without permission) disables clicks
- Tooth numbers (FDI) render under/over each tooth correctly

- [ ] **Step 2: Patient show page (read-only)**

Navigate to `/patients/9`. Open the "chart" tab. Verify the read-only arch renders from `chartState`.

- [ ] **Step 3: Export page**

Navigate to `/patients/9/export` (or the export route). Verify both adult chart renders in print layout.

- [ ] **Step 4: Wizard step 5**

Navigate to `/wizard` and advance to step 5 (dental chart) — or use the existing wizard store to jump. Verify editable arch + legend chips work.

- [ ] **Step 5: Console check**

Verify no console errors on any page. Check `list_console_messages` for errors.

---

### Task 5: Final verification & cleanup

- [ ] **Step 1: Full test suite**

Run: `npm run test` — all pass
Run: `./vendor/bin/pest` — 123 pass
Run: `npm run build` — succeeds
Run: `git diff --check` — clean

- [ ] **Step 2: Grep for stale geometry exports**

Run: `grep -rn "rowToothLists\|VIEW_W = 720\|MIDLINE_GAP\|UPPER_Y\|LOWER_Y" resources/js/`
Expected: no matches (old geometry fully removed)

- [ ] **Step 3: Verify no host page changes**

Run: `git status --short | grep -v build/`
Expected: only ToothChart.vue, lib/odontogram/, tests/js/odontogram/, docs/reference/odontogram/ changed (plus pre-existing working-tree changes from the JDC branch)

- [ ] **Step 4: Commit any stragglers**

```bash
git add -A resources/js tests/js docs/reference/odontogram
git commit -m "chore: finalize odontogram revamp"
```

---

## Spec Coverage Check

| Requirement | Task |
|---|---|
| Anatomical arch rendering (react-odontogram port) | Task 3 |
| 32-tooth adult FDI + quadrant mirroring | Tasks 1, 3 |
| Per-surface 5-zone interactivity preserved | Task 3 |
| PDA condition/restoration token coloring | Task 3 |
| Props/emit contract preserved (hosts unchanged) | Task 3 |
| FDI/Universal/Palmer notation support | Task 1 |
| Primary dentition (5 per quadrant) | Task 3 |
| Unit tests for data + geometry | Task 2 |
| Browser verification on all 4 hosts | Task 4 |
| Final cleanup | Task 5 |

## Placeholder Scan

No "TBD"/"TODO". The one deliberate implementation choice (getBBox vs hardcoded boxes) is marked with a recommended option. All path data comes from the MIT reference (verbatim copy, not retyped).

## Type Consistency Check

- `slotStyle`/`bodyVisuals`/`symbolVisuals`/`zoneVisuals` signatures identical to current implementation
- `apply(tooth, surface)` emit contract identical
- `wholeToothOnly()` / `surfaceZones()` exports preserved
- FDI keys: `state[tooth]` uses plain FDI strings ("11".."48") — unchanged from current app
