<script>
/**
 * Pure geometry helpers (exported for unit testing).
 * PDA twin-arch layout, mirroring the paper chart:
 * the patient's right side is rendered on the viewer's left.
 */
export const rowToothLists = (dentition) => {
    if (dentition === 'primary') {
        return {
            upper: [[55, 54, 53, 52, 51], [61, 62, 63, 64, 65]],
            lower: [[85, 84, 83, 82, 81], [71, 72, 73, 74, 75]],
        }
    }

    return {
        upper: [[18, 17, 16, 15, 14, 13, 12, 11], [21, 22, 23, 24, 25, 26, 27, 28]],
        lower: [[48, 47, 46, 45, 44, 43, 42, 41], [31, 32, 33, 34, 35, 36, 37, 38]],
    }
}

/** Five clickable zones per tooth, in a 48-wide × 56-tall tooth space. */
export const surfaceZones = () => ({
    occlusal: { x: 4, y: 4, w: 40, h: 14 },   // top strip
    mesial:   { x: 4, y: 4, w: 10, h: 48 },   // left strip
    distal:   { x: 34, y: 4, w: 10, h: 48 },  // right strip
    buccal:   { x: 4, y: 32, w: 20, h: 20 },  // bottom-left
    lingual:  { x: 24, y: 32, w: 20, h: 20 }, // bottom-right
})

/** Conditions that may only be recorded on the whole tooth (never a surface). */
export const wholeToothOnly = () => ['missing_caries', 'missing_other', 'impacted', 'supernumerary', 'unerupted']
</script>

<script setup>
import { computed } from 'vue'

const VIEW_W = 720
const MIDLINE_GAP = 16
const UPPER_Y = 44
const LOWER_Y = 196

const props = defineProps({
    state: { type: Object, required: true },
    dentition: { type: String, default: 'adult' },
    readonly: { type: Boolean, default: false },
    selectedCondition: { type: String, default: null },
    selectedRestoration: { type: String, default: null },
    options: { type: Object, required: true },
})

const emit = defineEmits(['apply-tooth'])

const upperRoots = 'M12 50 L17 58 L22 50 Z M26 50 L31 58 L36 50 Z'
const lowerRoots = 'M12 10 L17 2 L22 10 Z M26 10 L31 2 L36 10 Z'

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

const rootVisuals = (slot) => {
    const { fillToken } = slotStyle(slot)
    return { fill: fillToken ? `var(--color-${fillToken})` : 'var(--color-white)' }
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

const zones = Object.entries(surfaceZones()).map(([key, zone]) => ({ key, ...zone }))

const rows = computed(() => {
    const lists = rowToothLists(props.dentition)

    const layout = (groups) => {
        const n1 = groups[0].length
        const slotW = (VIEW_W - MIDLINE_GAP) / (n1 + groups[1].length)

        const place = (group, groupIndex) =>
            group.map((tooth, i) => {
                const slotX = (groupIndex === 0 ? i : n1 + i) * slotW + (groupIndex === 0 ? 0 : MIDLINE_GAP)
                const tx = Math.round((slotX + (slotW - 48) / 2) * 10) / 10
                const whole = props.state?.[tooth]?.whole ?? null

                return {
                    tooth,
                    tx,
                    body: bodyVisuals(whole),
                    root: rootVisuals(whole),
                    symbol: symbolVisuals(whole),
                    zones: zones.map((zone) => {
                        const surface = props.state?.[tooth]?.surfaces?.[zone.key] ?? null
                        const visuals = zoneVisuals(surface)
                        return {
                            key: zone.key,
                            d: roundedRect(zone.x, zone.y, zone.w, zone.h, 3),
                            style: visuals.style,
                            ring: visuals.ring,
                            label: props.options.surfaces?.[zone.key]?.label ?? zone.key,
                        }
                    }),
                }
            })

        return [...place(groups[0], 0), ...place(groups[1], 1)]
    }

    return [
        { y: UPPER_Y, upper: true, teeth: layout(lists.upper) },
        { y: LOWER_Y, upper: false, teeth: layout(lists.lower) },
    ]
})

const apply = (tooth, surface) => {
    if (props.readonly) return
    emit('apply-tooth', { tooth, surface })
}
</script>

<template>
    <div :class="{ 'pointer-events-none': readonly }" class="relative">
        <svg
            viewBox="0 0 720 340"
            class="h-auto w-full select-none"
            role="img"
            :aria-label="`Dental chart — ${dentition} dentition`"
        >
            <g v-for="row in rows" :key="row.upper ? 'upper' : 'lower'">
                <g v-for="slot in row.teeth" :key="slot.tooth" :transform="`translate(${slot.tx} ${row.y})`">
                    <!-- root nubs (below the body for uppers, above for lowers) -->
                    <path
                        :d="row.upper ? upperRoots : lowerRoots"
                        :style="slot.root"
                        class="stroke-gray-300"
                        stroke-width="1"
                    />

                    <!-- tooth body: whole-tooth slot -->
                    <rect
                        x="4"
                        y="4"
                        width="40"
                        height="48"
                        rx="6"
                        :style="slot.body"
                        class="stroke-gray-300 hover:stroke-gray-400"
                        :class="{ 'cursor-crosshair': !readonly }"
                        stroke-width="1.5"
                        @click="apply(slot.tooth, null)"
                    />

                    <!-- whole-tooth symbol (X for missing, check for present) -->
                    <g
                        v-if="slot.symbol"
                        :style="{ stroke: slot.symbol.color }"
                        fill="none"
                        stroke-width="3"
                        stroke-linecap="round"
                        stroke-linejoin="round"
                    >
                        <line v-if="slot.symbol.kind === 'x'" x1="15" y1="15" x2="33" y2="33" />
                        <line v-if="slot.symbol.kind === 'x'" x1="33" y1="15" x2="15" y2="33" />
                        <polyline v-else points="15 26, 22 33, 33 17" />
                    </g>

                    <!-- five surface zones -->
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
                        @click="apply(slot.tooth, zone.key)"
                    />

                    <!-- tooth number -->
                    <text
                        x="24"
                        y="66"
                        text-anchor="middle"
                        font-size="10"
                        class="select-none fill-gray-400"
                    >
                        {{ slot.tooth }}
                    </text>
                </g>
            </g>
        </svg>
    </div>
</template>
