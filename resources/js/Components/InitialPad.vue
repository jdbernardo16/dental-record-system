<script setup>
import { onBeforeUnmount, onMounted, ref } from 'vue'
import { Eraser } from 'lucide-vue-next'
import { VueSignaturePad } from 'vue-signature-pad'
import Button from '@/Components/Button.vue'

defineProps({
    modelValue: { type: String, default: null },
})

const emit = defineEmits(['update:modelValue'])

const pad = ref(null)
const container = ref(null)
const hasInk = ref(false)

// Pads mounted inside v-show wizard steps have no layout at mount, so the
// library's resizeCanvas() runs with 0×0 and the bitmap stays empty. Once the
// step becomes visible, nudge the library's window-resize listener.
let visibilityObserver = null

onMounted(() => {
    visibilityObserver = new IntersectionObserver((entries) => {
        if (entries.some((entry) => entry.isIntersecting)) {
            // Wait two frames so the v-show step has layout before nudging the
            // library's window-resize listener (same nudge SignaturePadModal uses).
            requestAnimationFrame(() => {
                requestAnimationFrame(() => {
                    window.dispatchEvent(new Event('resize'))
                })
            })
        }
    })
    if (container.value) visibilityObserver.observe(container.value)
})

onBeforeUnmount(() => {
    visibilityObserver?.disconnect()
})

// Pen color is a canvas drawing option (JS config value), not a CSS class.
// Ink tracking mirrors SignaturePadModal: the wrapper receives
// pointerup/pointercancel bubbling from the canvas, and the library's onEnd
// callback is also wired (no DOM events are emitted by vue-signature-pad).
const options = {
    penColor: '#1f2937',
    backgroundColor: 'white',
    onEnd: () => {
        hasInk.value = !pad.value?.isEmpty()
    },
}

/**
 * The backend expects a raw SVG string starting with `<svg`.
 * signature_pad (3.0.0-beta.4) returns `data:image/svg+xml;base64,…`;
 * the utf8/URI-encoded forms are handled too for forward compatibility.
 */
const extractSvg = (dataUrl) => {
    if (dataUrl.startsWith('data:image/svg+xml;base64,')) {
        return atob(dataUrl.slice('data:image/svg+xml;base64,'.length))
    }
    if (dataUrl.startsWith('data:image/svg+xml;utf8,')) {
        return decodeURIComponent(dataUrl.slice('data:image/svg+xml;utf8,'.length))
    }
    if (dataUrl.startsWith('data:image/svg+xml,')) {
        return decodeURIComponent(dataUrl.slice('data:image/svg+xml,'.length))
    }

    return null
}

const onStrokeEnd = () => {
    hasInk.value = !pad.value?.isEmpty()

    const result = pad.value?.saveSignature('image/svg+xml')
    if (!result || result.isEmpty || !result.data) return

    const svg = extractSvg(result.data)
    if (svg) emit('update:modelValue', svg)
}

const clear = () => {
    pad.value?.clearSignature()
    hasInk.value = false
    emit('update:modelValue', null)
}
</script>

<template>
    <div>
        <div
            ref="container"
            class="min-h-16 rounded-lg border border-gray-200 bg-white p-2"
            @pointerup="onStrokeEnd"
            @pointercancel="onStrokeEnd"
        >
            <VueSignaturePad
                ref="pad"
                :width="'100%'"
                :height="'60px'"
                :options="options"
                class="w-full"
            />
        </div>
        <div class="mt-1.5 flex justify-end">
            <Button
                variant="outline"
                size="sm"
                class="min-h-11 min-w-11"
                aria-label="Clear initials"
                @click="clear"
            >
                <Eraser class="h-4 w-4" />
                Clear
            </Button>
        </div>
    </div>
</template>
