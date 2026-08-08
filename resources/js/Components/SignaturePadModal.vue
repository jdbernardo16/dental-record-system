<script setup>
import { nextTick, ref, watch } from 'vue'
import { X } from 'lucide-vue-next'
import { VueSignaturePad } from 'vue-signature-pad'
import { Button } from '@/Components/ui/button'
import Modal from '@/Components/Modal.vue'
import { normalizeSvg } from '@/lib/signatureSvg'

const props = defineProps({
    show: { type: Boolean, default: false },
    title: { type: String, default: 'Sign document' },
    confirmLabel: { type: String, default: 'Accept signature' },
})

const emit = defineEmits(['close', 'confirm'])

const pad = ref(null)
const hasInk = ref(false)

watch(
    () => props.show,
    async (open) => {
        if (!open) return

        hasInk.value = false

        // The pad mounts inside the dialog after the show-flush, so its own
        // resizeCanvas() can run before the dialog content has layout (bitmap
        // ends up 0×0). Resize the canvas directly once layout exists.
        await nextTick()
        requestAnimationFrame(() => {
            requestAnimationFrame(() => {
                pad.value?.resizeCanvas()
            })
        })
    },
)

// Pen color is a canvas drawing option (JS config value), not a CSS class.
const options = {
    penColor: '#1f2937',
    backgroundColor: 'white',
    // vue-signature-pad v3 forwards options to signature_pad; ink is also
    // tracked via the library's onEnd callback (no DOM events are emitted).
    onEnd: () => {
        hasInk.value = !pad.value?.isEmpty()
    },
}

// The wrapper receives pointerup/pointercancel bubbling from the canvas, so
// ink state is updated deterministically after every stroke.
const onStrokeEnd = () => {
    hasInk.value = !pad.value?.isEmpty()
}

const clear = () => {
    pad.value?.clearSignature()
    hasInk.value = false
}

/**
 * The backend expects a raw SVG string starting with `<svg`.
 * signature_pad (3.0.0-beta.4) returns `data:image/svg+xml;base64,…`;
 * the utf8/URI-encoded form is handled too for forward compatibility.
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

const accept = () => {
    const result = pad.value?.saveSignature('image/svg+xml')
    if (!result || result.isEmpty || !result.data) return

    const svg = normalizeSvg(extractSvg(result.data))
    if (svg) emit('confirm', svg)
}
</script>

<template>
    <Modal :show="show" max-width="md" @close="emit('close')">
        <div class="p-6">
            <div class="flex items-start justify-between gap-4">
                <div>
                    <h3 class="text-sm font-semibold text-gray-800">{{ title }}</h3>
                    <p class="mt-1 text-xs text-gray-500">Draw your signature on the pad below.</p>
                </div>
                <button
                    type="button"
                    class="inline-flex min-h-11 min-w-11 items-center justify-center rounded-lg text-gray-400 transition hover:bg-gray-100 hover:text-gray-600"
                    aria-label="Close signature pad"
                    @click="emit('close')"
                >
                    <X class="h-5 w-5" />
                </button>
            </div>

            <div
                class="mt-4 rounded-xl border border-gray-200 bg-white p-3"
                @pointerup="onStrokeEnd"
                @pointercancel="onStrokeEnd"
            >
                <VueSignaturePad
                    ref="pad"
                    :width="'100%'"
                    :height="'150px'"
                    :options="options"
                    class="mx-auto w-full"
                />
            </div>

            <div class="mt-5 flex items-center justify-end gap-2">
                <Button variant="outline" class="min-h-11" @click="clear">Clear</Button>
                <Button class="min-h-11" :disabled="!hasInk" @click="accept">{{ confirmLabel }}</Button>
            </div>
        </div>
    </Modal>
</template>
