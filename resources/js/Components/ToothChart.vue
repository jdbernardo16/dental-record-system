<script>
/**
 * Conditions that may only be recorded on the whole tooth (never a surface).
 */
export const wholeToothOnly = () => ['missing_caries', 'missing_other', 'impacted', 'supernumerary', 'unerupted']
</script>

<script setup>
import { computed } from 'vue'
import { teethPaths } from '@/lib/odontogram'

const props = defineProps({
    state: { type: Object, required: true },
    dentition: { type: String, default: 'adult' },
    readonly: { type: Boolean, default: false },
    selectedCondition: { type: String, default: null },
    selectedRestoration: { type: String, default: null },
    options: { type: Object, required: true },
})

const emit = defineEmits(['apply-tooth'])

/* Linear layout --------------------------------------------------------------
 * Two straight rows in a single SVG (viewBox 0 0 820 160), patient's right on
 * the viewer's left (PDA paper-chart convention):
 *   upper row — adult 18..11 | 21..28 (primary 55..51 | 61..65), roots DOWN
 *   lower row — adult 48..41 | 31..38 (primary 85..81 | 71..75), roots UP
 * Each tooth is normalized to its own origin (translate(-box.x -box.y)) and
 * scaled into its slot; the lower row additionally flips vertically
 * (scale(S, -S)) so the roots point up. FDI labels and the whole-tooth symbol
 * are drawn in viewBox space (outside the flipped groups) so they stay upright.
 */

const VIEW_W = 820
const VIEW_H = 160
const UPPER_Y = 16 // top edge of the upper-row slot boxes
const LOWER_Y = 90 // top edge of the lower-row slot boxes
const LABEL_GAP = 12 // gap between a tooth's slot box and its FDI label

/** Scale factor from authored space to slot space (widest molar ≈ 47px). */
const SCALE = 0.65

/**
 * Approximate per-tooth-type bounding boxes (authored space), verified
 * accurate against the path geometry. Used to normalize each shape to its own
 * origin so it renders centered in its slot.
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

const viewBox = `0 0 ${VIEW_W} ${VIEW_H}`

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

/**
 * Whole-tooth lock when a whole-tooth-only condition is armed. With no surface
 * zones every click is already whole-tooth; kept for host-facing parity.
 */
const wholeOnly = computed(() =>
    !props.readonly && props.selectedCondition !== null && wholeToothOnly().includes(props.selectedCondition),
)

/**
 * Build one tooth's render descriptor.
 *
 * `slotX` is the left edge of the tooth's slot (its centered position is
 * computed inside); `slotW` is the full slot width. The lower row composes the
 * flip into the tooth transform: translate(x, y + h) scale(S, -S) translate(-box.x -box.y)
 * maps the authored bottom (roots) to the top of the slot box, keeping the
 * tooth inside the same [slotY, slotY + h] box as the upper row.
 */
const buildTooth = (fdi, typeIndex, row, slotX, slotW) => {
    const shape = teethPaths[typeIndex]
    const box = FALLBACK_BOXES[typeIndex]
    const whole = props.state?.[fdi]?.whole ?? null

    const w = SCALE * box.width
    const h = SCALE * box.height
    const x = slotX + (slotW - w) / 2
    const y = row === 'upper' ? UPPER_Y : LOWER_Y

    const transform = row === 'upper'
        ? `translate(${x} ${y}) scale(${SCALE} ${SCALE}) translate(${-box.x} ${-box.y})`
        : `translate(${x} ${y + h}) scale(${SCALE} ${-SCALE}) translate(${-box.x} ${-box.y})`

    const sym = symbolVisuals(whole)
    let symbol = null
    if (sym) {
        if (sym.kind === 'x') {
            const inset = 0.25
            symbol = {
                ...sym,
                lines: [
                    [x + w * inset, y + h * inset, x + w * (1 - inset), y + h * (1 - inset)],
                    [x + w * (1 - inset), y + h * inset, x + w * inset, y + h * (1 - inset)],
                ],
            }
        } else {
            // check mark, same proportions as the previous rectangular rendering
            symbol = {
                ...sym,
                points: [
                    [x + w * 0.31, y + h * 0.46],
                    [x + w * 0.46, y + h * 0.59],
                    [x + w * 0.69, y + h * 0.3],
                ],
            }
        }
    }

    return {
        fdi,
        shape,
        transform,
        strokeStyle: outlineVisuals(whole),
        fillStyle: shadowVisuals(whole),
        highlights: Array.isArray(shape.lineHighlightPath) ? shape.lineHighlightPath : [shape.lineHighlightPath],
        symbol,
        labelX: x + w / 2,
        labelY: y + h + LABEL_GAP,
    }
}

/**
 * All teeth, left→right across the upper row then the lower row. Each row is
 * two halves; the left half mirrors the tooth-type order (molar → incisor) so
 * the central incisors meet at the midline.
 */
const teeth = computed(() => {
    const count = props.dentition === 'primary' ? 5 : 8
    const digits = props.dentition === 'primary'
        ? { upper: ['5', '6'], lower: ['8', '7'] }
        : { upper: ['1', '2'], lower: ['4', '3'] }
    const slotW = VIEW_W / (count * 2)
    const list = []

    for (const [row, rowDigits] of [['upper', digits.upper], ['lower', digits.lower]]) {
        rowDigits.forEach((digit, h) => {
            const reversed = h === 0
            for (let p = 0; p < count; p++) {
                const typeIndex = reversed ? count - 1 - p : p
                const fdi = digit + (reversed ? count - p : p + 1)
                list.push(buildTooth(fdi, typeIndex, row, (h * count + p) * slotW, slotW))
            }
        })
    }

    return list
})

const apply = (tooth) => {
    if (props.readonly) return
    emit('apply-tooth', { tooth, surface: null })
}
</script>

<template>
    <div :class="{ 'pointer-events-none': readonly }" class="relative">
        <svg
            :viewBox="viewBox"
            class="h-auto w-full select-none"
            role="img"
            :aria-label="`Dental chart — ${dentition} dentition`"
        >
            <g v-for="tooth in teeth" :key="tooth.fdi">
                <g :transform="tooth.transform">
                    <!-- tooth silhouette (crown + roots) -->
                    <path
                        :d="tooth.shape.outlinePath"
                        :style="tooth.strokeStyle"
                        class="stroke-gray-300 hover:stroke-gray-400"
                        :class="{ 'cursor-crosshair': !readonly }"
                        fill="var(--color-white)"
                        stroke-width="2"
                        @click="apply(tooth.fdi)"
                    />

                    <!-- condition fill: clinical crown -->
                    <path
                        :d="tooth.shape.shadowPath"
                        :style="tooth.fillStyle"
                        :class="{ 'cursor-crosshair': !readonly }"
                        @click="apply(tooth.fdi)"
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

                <!-- whole-tooth symbol (X for missing, check for present) —
                     viewBox space so it stays upright on the flipped lower row -->
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

                <!-- FDI label — always upright, below the tooth -->
                <text
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
