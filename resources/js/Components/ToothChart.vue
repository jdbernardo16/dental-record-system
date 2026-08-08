<script>
/**
 * Pure geometry helpers (exported for unit testing).
 * Surface zones are PERCENTAGE-based (0-1) — they are resolved against each
 * tooth's measured bounding box at render time.
 */
export const surfaceZones = () => ({
    occlusal: { x: 0.18, y: 0.10, w: 0.64, h: 0.22 }, // top strip
    mesial:   { x: 0.14, y: 0.10, w: 0.22, h: 0.80 }, // left strip
    distal:   { x: 0.64, y: 0.10, w: 0.22, h: 0.80 }, // right strip
    buccal:   { x: 0.14, y: 0.62, w: 0.35, h: 0.28 }, // bottom-left
    lingual:  { x: 0.51, y: 0.62, w: 0.35, h: 0.28 }, // bottom-right
})

/** Conditions that may only be recorded on the whole tooth (never a surface). */
export const wholeToothOnly = () => ['missing_caries', 'missing_other', 'impacted', 'supernumerary', 'unerupted']
</script>

<script setup>
import { computed, nextTick, onBeforeUnmount, onMounted, ref, watch } from 'vue'
import { quadrants, teethPaths, VIEW_W, VIEW_H, fdiNumber, toViewBox } from '@/lib/odontogram'

const props = defineProps({
    state: { type: Object, required: true },
    dentition: { type: String, default: 'adult' },
    readonly: { type: Boolean, default: false },
    selectedCondition: { type: String, default: null },
    selectedRestoration: { type: String, default: null },
    options: { type: Object, required: true },
})

const emit = defineEmits(['apply-tooth'])

/**
 * Approximate per-tooth-type bounding boxes (quadrant-local space), computed
 * from the authored path geometry (outline + highlight union). They render the
 * arch correctly before getBBox() measurement runs and whenever an element is
 * hidden (v-show), where getBBox() reports a zero-sized box.
 */
const FALLBACK_BOXES = [
    { x: 154.3, y: 1, width: 49.8, height: 59.7 },   // 1 central incisor
    { x: 111.7, y: 9.3, width: 43.2, height: 53.5 }, // 2 lateral incisor
    { x: 74.1, y: 32.6, width: 54.1, height: 48.6 }, // 3 canine
    { x: 48.4, y: 64.5, width: 56.6, height: 44.9 }, // 4 first premolar
    { x: 29.4, y: 100.4, width: 60.2, height: 41.2 }, // 5 second premolar
    { x: 6.6, y: 137.9, width: 72.9, height: 65.4 }, // 6 first molar
    { x: 0.5, y: 204, width: 69.2, height: 59.1 },   // 7 second molar
    { x: 0.7, y: 262.8, width: 63.3, height: 54.5 }, // 8 third molar
]

const roundedRect = (x, y, w, h, r) =>
    `M${x + r} ${y}H${x + w - r}A${r} ${r} 0 0 1 ${x + w} ${y + r}V${y + h - r}A${r} ${r} 0 0 1 ${x + w - r} ${y + h}H${x + r}A${r} ${r} 0 0 1 ${x} ${y + h - r}V${y + r}A${r} ${r} 0 0 1 ${x + r} ${y}Z`

/**
 * Resolve a slot's rendering from its condition/restoration values.
 *
 * Priority: a real condition (solid/missing/dashed) governs the fill;
 * the neutral "present" mark yields to restorations so fills show;
 * outline restorations (crown/pontic/denture) draw a ring over the fill.
 */
const slotStyle = (slot) => {
    const condition = slot?.condition ? props.options.conditions?.[slot.condition] : null
    const restoration = slot?.restoration ? props.options.restorations?.[slot.restoration] : null

    let fillToken = null
    let strokeToken = null
    let dash = false
    let symbol = null

    if (condition) {
        if (condition.render === 'missing') {
            fillToken = condition.color
            symbol = 'x'
        } else if (condition.render === 'dashed') {
            fillToken = condition.color
            dash = true
        } else if (condition.render === 'solid') {
            fillToken = condition.color
        } else if (condition.render === 'check' && !restoration) {
            fillToken = condition.color
            symbol = 'check'
        }
    }

    if (restoration) {
        if (restoration.render === 'outline') {
            strokeToken = restoration.color
        } else if (restoration.render === 'solid' && !fillToken) {
            fillToken = restoration.color
        }
    }

    return { fillToken, strokeToken, dash, symbol }
}

/** Condition/restoration fill applied to the clinical crown (shadowPath). */
const shadowVisuals = (slot) => {
    const { fillToken, dash } = slotStyle(slot)
    const style = { fill: fillToken ? `var(--color-${fillToken})` : 'var(--color-white)' }

    if (dash) {
        style.stroke = `var(--color-${fillToken})`
        style.strokeWidth = '2'
        style.strokeDasharray = '5 3'
        style.fillOpacity = '0.35'
    }

    return style
}

/** Outline-restoration ring applied to the tooth silhouette (outlinePath). */
const outlineVisuals = (slot) => {
    const { strokeToken } = slotStyle(slot)
    return strokeToken
        ? { stroke: `var(--color-${strokeToken})`, strokeWidth: '5' }
        : {}
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

/** Zones are locked when a whole-tooth-only condition is armed. */
const wholeOnly = computed(() =>
    !props.readonly && props.selectedCondition !== null && wholeToothOnly().includes(props.selectedCondition),
)

const toothFdi = (qi, i, dentition) => fdiNumber(qi, i, dentition)

const buildTooth = (qi, fdi, typeIndex) => {
    const shape = teethPaths[typeIndex]
    const box = boxes.value[fdi] ?? FALLBACK_BOXES[typeIndex]
    const whole = props.state?.[fdi]?.whole ?? null

    const zones = Object.entries(surfaceZones()).map(([key, z]) => {
        const surface = props.state?.[fdi]?.surfaces?.[key] ?? null
        const visuals = zoneVisuals(surface)
        const rect = {
            x: box.x + box.width * z.x,
            y: box.y + box.height * z.y,
            w: box.width * z.w,
            h: box.height * z.h,
        }

        return {
            key,
            d: roundedRect(rect.x, rect.y, rect.w, rect.h, Math.min(3, rect.w / 2, rect.h / 2)),
            style: visuals.style,
            ring: visuals.ring,
            label: props.options.surfaces?.[key]?.label ?? key,
        }
    })

    const sym = symbolVisuals(whole)
    let symbol = null
    if (sym) {
        if (sym.kind === 'x') {
            const inset = 0.25
            symbol = {
                ...sym,
                lines: [
                    [box.x + box.width * inset, box.y + box.height * inset, box.x + box.width * (1 - inset), box.y + box.height * (1 - inset)],
                    [box.x + box.width * (1 - inset), box.y + box.height * inset, box.x + box.width * inset, box.y + box.height * (1 - inset)],
                ],
            }
        } else {
            // check mark, same proportions as the previous rectangular rendering
            symbol = {
                ...sym,
                points: [
                    [box.x + box.width * 0.31, box.y + box.height * 0.46],
                    [box.x + box.width * 0.46, box.y + box.height * 0.59],
                    [box.x + box.width * 0.69, box.y + box.height * 0.3],
                ],
            }
        }
    }

    // Labels are rendered OUTSIDE the transformed quadrant <g> so they stay
    // upright — map the local label anchor into viewBox coordinates.
    const labelLocal = { x: box.x + box.width / 2, y: box.y + box.height + 12 }
    const label = toViewBox(qi, labelLocal.x, labelLocal.y)

    return {
        fdi,
        shape,
        strokeStyle: outlineVisuals(whole),
        fillStyle: shadowVisuals(whole),
        highlights: Array.isArray(shape.lineHighlightPath) ? shape.lineHighlightPath : [shape.lineHighlightPath],
        symbol,
        zones,
        labelX: label.x,
        labelY: label.y,
    }
}

const teethByQuadrant = computed(() => {
    const count = props.dentition === 'primary' ? 5 : 8

    return quadrants.map((q, qi) => ({
        ...q,
        teeth: Array.from({ length: count }, (_, i) => buildTooth(qi, toothFdi(qi, i, props.dentition), i)),
    }))
})

const viewBox = computed(() => `0 0 ${VIEW_W} ${VIEW_H}`)

const apply = (tooth, surface) => {
    if (props.readonly) return
    emit('apply-tooth', { tooth, surface })
}

/* Bounding-box measurement -------------------------------------------------- */

const svgRef = ref(null)
const toothEls = {}
const boxes = ref({})

const setToothRef = (el, fdi) => {
    if (el) toothEls[fdi] = el
    else delete toothEls[fdi]
}

/**
 * Measure each tooth silhouette in its quadrant-local coordinate system.
 * The quadrant <g> transform does not affect getBBox() — coordinates come back
 * in the same authored space as the path data. Zero-sized boxes (hidden SVG,
 * e.g. inside a v-show step) are skipped so the path-derived fallback holds.
 */
const measure = () => {
    const next = {}

    for (const fdi in toothEls) {
        const el = toothEls[fdi]
        if (!el || typeof el.getBBox !== 'function') continue

        try {
            const bb = el.getBBox()
            if (bb.width > 0 && bb.height > 0) {
                next[fdi] = { x: bb.x, y: bb.y, width: bb.width, height: bb.height }
            }
        } catch {
            // keep the fallback box for this tooth
        }
    }

    boxes.value = next
}

let resizeTimer = null
const onResize = () => {
    clearTimeout(resizeTimer)
    resizeTimer = setTimeout(measure, 150)
}

let resizeObserver = null

onMounted(() => {
    nextTick(measure)
    window.addEventListener('resize', onResize)

    // Fires when the chart becomes visible (v-show) or changes size, so
    // measurement lands after the initial mount even if the SVG was hidden.
    if (svgRef.value && typeof ResizeObserver !== 'undefined') {
        resizeObserver = new ResizeObserver(onResize)
        resizeObserver.observe(svgRef.value)
    }
})

onBeforeUnmount(() => {
    window.removeEventListener('resize', onResize)
    clearTimeout(resizeTimer)
    resizeObserver?.disconnect()
})

watch(() => props.dentition, () => nextTick(measure))
</script>

<template>
    <div :class="{ 'pointer-events-none': readonly }" class="relative">
        <svg
            ref="svgRef"
            :viewBox="viewBox"
            class="h-auto w-full select-none"
            role="img"
            :aria-label="`Dental chart — ${dentition} dentition`"
        >
            <g v-for="quadrant in teethByQuadrant" :key="quadrant.name" :transform="quadrant.transform">
                <g v-for="tooth in quadrant.teeth" :key="tooth.fdi">
                    <g :ref="(el) => setToothRef(el, tooth.fdi)">
                        <!-- tooth silhouette (crown + roots) -->
                        <path
                            :d="tooth.shape.outlinePath"
                            :style="tooth.strokeStyle"
                            class="stroke-gray-300 hover:stroke-gray-400"
                            :class="{ 'cursor-crosshair': !readonly }"
                            fill="var(--color-white)"
                            stroke-width="2"
                            @click="apply(tooth.fdi, null)"
                        />

                        <!-- condition fill: clinical crown -->
                        <path
                            :d="tooth.shape.shadowPath"
                            :style="tooth.fillStyle"
                            :class="{ 'cursor-crosshair': !readonly }"
                            @click="apply(tooth.fdi, null)"
                        />

                        <!-- anatomical grooves / cusps -->
                        <path
                            v-for="(hl, hi) in tooth.highlights"
                            :key="hi"
                            :d="hl"
                            fill="none"
                            stroke-width="1"
                            class="stroke-gray-300"
                        />
                    </g>

                    <!-- whole-tooth symbol (X for missing, check for present) -->
                    <g
                        v-if="tooth.symbol"
                        :style="{ stroke: tooth.symbol.color }"
                        fill="none"
                        stroke-width="3"
                        stroke-linecap="round"
                        stroke-linejoin="round"
                    >
                        <line
                            v-for="(line, li) in tooth.symbol.lines ?? []"
                            :key="li"
                            :x1="line[0]"
                            :y1="line[1]"
                            :x2="line[2]"
                            :y2="line[3]"
                        />
                        <polyline
                            v-if="tooth.symbol.points"
                            :points="tooth.symbol.points.map((p) => p.join(',')).join(' ')"
                        />
                    </g>

                    <!-- five surface zones -->
                    <path
                        v-for="zone in tooth.zones"
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
                        @click="apply(tooth.fdi, zone.key)"
                    />
                </g>
            </g>

            <!-- tooth numbers — rendered outside the mirrored quadrant groups so
                 they stay upright (viewBox-space coordinates) -->
            <g v-for="quadrant in teethByQuadrant" :key="`labels-${quadrant.name}`">
                <text
                    v-for="tooth in quadrant.teeth"
                    :key="`label-${tooth.fdi}`"
                    :x="tooth.labelX"
                    :y="tooth.labelY"
                    text-anchor="middle"
                    font-size="10"
                    class="select-none fill-gray-400"
                >
                    {{ tooth.fdi }}
                </text>
            </g>
        </svg>
    </div>
</template>
