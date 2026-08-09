<script setup>
import { computed, onBeforeUnmount, onMounted, ref } from 'vue'
import { useForm } from '@inertiajs/vue3'
import { route } from '../../../../vendor/tightenco/ziggy'
import { CheckCircle2 } from 'lucide-vue-next'
import { Button } from '@/Components/ui/button'
import { VueSignaturePad } from 'vue-signature-pad'
import { useToastStore } from '@/Stores/toast'
import { normalizeSvg } from '@/lib/signatureSvg'
import { encodeSvgPayload } from '@/lib/svgWire'
import { scrollToFirstError } from '@/lib/scroll'

const props = defineProps({
    patient: { type: Object, required: true },
    sections: { type: Array, default: () => [] },
    acknowledgment: { type: String, default: '' },
    authorization: { type: String, default: '' },
    patientAge: { type: Number, default: 0 },
    existingInitialSvg: { type: String, default: '' },
})

const emit = defineEmits(['saved'])

const toastStore = useToastStore()

// A single signature captured once, applied to every consent section (best
// practice: the PDA paper form asks for a signature per line, but digitally one
// mark covers all statements — each section still stores its own copy for the
// legal record). When an unsigned draft already exists, re-display the
// signature the patient drew.
const signatureSvg = ref(props.existingInitialSvg ?? '')
const accepted = ref(Boolean(props.existingInitialSvg))

const form = useForm({
    patient_id: props.patient.id,
    initials: {},
})

const isMinor = computed(() => props.patientAge < 18)

// The pad mounts inside a hidden v-show wizard step with no layout (0×0
// bitmap), and signature_pad's window-resize listener is not reliable here.
// When this step becomes visible, resize the canvas directly once layout exists.
const stepRoot = ref(null)

let visibilityObserver = null

const resizePads = () => {
    requestAnimationFrame(() => {
        requestAnimationFrame(() => {
            // resizeCanvas() sets the bitmap size from the canvas CSS size and
            // clears it — safe here because it runs before the user draws.
            pad.value?.resizeCanvas()
        })
    })
}

const attachObserver = () => {
    visibilityObserver?.disconnect()
    visibilityObserver = new IntersectionObserver((entries) => {
        if (entries.some((entry) => entry.isIntersecting)) resizePads()
    })
    if (stepRoot.value) visibilityObserver.observe(stepRoot.value)
}

onMounted(() => {
    attachObserver()
})

onBeforeUnmount(() => {
    visibilityObserver?.disconnect()
})

const pad = ref(null)
const hasInk = ref(false)

const options = {
    penColor: '#1f2937',
    backgroundColor: 'white',
    onEnd: () => {
        hasInk.value = !pad.value?.isEmpty()
    },
}

const svgDataUrl = (svg) => (svg ? `data:image/svg+xml;utf8,${encodeURIComponent(svg)}` : null)

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

// Stroke tracking only — the signature is NOT captured on stroke; the user
// explicitly saves it (or clears) with the buttons below.
const onStrokeEnd = () => {
    hasInk.value = !pad.value?.isEmpty()
}

const capture = () => {
    const result = pad.value?.saveSignature('image/svg+xml')
    if (!result || result.isEmpty || !result.data) return

    const svg = normalizeSvg(extractSvg(result.data))
    if (svg) {
        signatureSvg.value = svg
        accepted.value = true
    }
}

const clear = () => {
    pad.value?.clearSignature()
    hasInk.value = false
    accepted.value = false
    signatureSvg.value = ''
}

const save = () => {
    if (!accepted.value) return

    form.initials = Object.fromEntries(props.sections.map((section) => [section.key, signatureSvg.value]))

    // Base64-encode SVG payloads on the wire: the CDN WAF rejects any POST
    // body containing the literal `<svg` tag. The server decodes first, and
    // the transform reads the raw form data on every submit (no double-encode).
    form.transform((data) => ({
        ...data,
        initials: Object.fromEntries(
            Object.entries(data.initials).map(([key, svg]) => [key, encodeSvgPayload(svg)]),
        ),
    }))

    form.post(route('consents.store'), {
        preserveScroll: true,
        onSuccess: () => {
            toastStore.show('Waiver saved — the patient signature step is next.')
            emit('saved')
        },
        onError: () => {
            toastStore.show('Saving the waiver failed — please review the signature.', 'error')
            scrollToFirstError()
        },
    })
}
</script>

<template>
    <div ref="stepRoot" class="space-y-6">
        <div>
            <h2 class="text-lg font-semibold text-gray-800">Informed consent & waiver</h2>
            <p class="mt-1 text-sm text-gray-500">
                {{ patient.first_name ?? 'Patient' }}, read each statement below, then sign once — your signature
                covers all {{ sections.length }} statements.
            </p>
            <p v-if="isMinor" class="mt-2 rounded-lg bg-status-confirmed/10 px-4 py-3 text-sm text-status-confirmed">
                This patient is a minor — a parent or guardian signature will be required on the next step.
            </p>
        </div>

        <ol class="space-y-4">
            <li
                v-for="(section, index) in sections"
                :key="section.key"
                class="rounded-2xl border border-gray-200 bg-white p-5 shadow-sm"
            >
                <div class="flex items-start justify-between gap-4">
                    <div class="min-w-0">
                        <h3 class="text-sm font-semibold text-gray-800">
                            <span class="mr-2 text-gray-400">{{ index + 1 }}.</span>
                            {{ section.label }}
                        </h3>
                        <p class="mt-1.5 text-base leading-relaxed text-gray-700">{{ section.text }}</p>
                    </div>
                    <CheckCircle2
                        v-if="accepted"
                        class="h-5 w-5 shrink-0 text-status-completed"
                        aria-label="Covered by the signature"
                    />
                </div>
            </li>
        </ol>

        <div class="rounded-2xl border border-gray-200 bg-white p-5 shadow-sm">
            <h3 class="text-sm font-semibold text-gray-800">Patient signature</h3>
            <p class="mt-0.5 text-xs text-gray-500">Draw the patient's signature on the pad below.</p>
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
                <img
                    v-if="accepted && signatureSvg"
                    :src="svgDataUrl(signatureSvg)"
                    alt="Captured patient signature"
                    class="mx-auto mt-3 h-24 border border-gray-200 bg-white object-contain"
                />
            </div>
            <div class="mt-3 flex items-center justify-end gap-2">
                <Button variant="outline" size="sm" class="min-h-11" @click="clear">Clear</Button>
                <Button size="sm" class="min-h-11" :disabled="!hasInk" @click="capture">
                    {{ accepted ? 'Signature captured — redraw to change' : 'Save signature' }}
                </Button>
            </div>
        </div>

        <blockquote class="rounded-xl border-l-4 border-brand-500 bg-brand-50 px-5 py-4 text-base text-gray-800">
            <p class="font-medium text-brand-700">Acknowledgment</p>
            <p class="mt-1">“{{ acknowledgment }}”</p>
        </blockquote>

        <blockquote class="rounded-xl border-l-4 border-brand-500 bg-brand-50 px-5 py-4 text-base text-gray-800">
            <p class="font-medium text-brand-700">Authorization</p>
            <p class="mt-1">“{{ authorization }}”</p>
        </blockquote>

        <div class="flex flex-wrap items-center justify-between gap-3 border-t border-gray-100 pt-4">
            <p class="text-sm text-gray-500">
                <template v-if="accepted">Signature captured — applies to all {{ sections.length }} statements.</template>
                <template v-else>Draw the patient's signature above to continue.</template>
            </p>
            <Button type="button" :disabled="!accepted || form.processing" @click="save">
                {{ form.processing ? 'Saving…' : 'Save & continue' }}
            </Button>
        </div>
    </div>
</template>
