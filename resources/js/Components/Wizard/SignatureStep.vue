<script setup>
import { computed, onBeforeUnmount, onMounted, ref } from 'vue'
import { useForm } from '@inertiajs/vue3'
import { Signature } from 'lucide-vue-next'
import { route } from '../../../../vendor/tightenco/ziggy'
import Button from '@/Components/Button.vue'
import { VueSignaturePad } from 'vue-signature-pad'
import { useToastStore } from '@/Stores/toast'

const props = defineProps({
    patient: { type: Object, required: true },
    consentFormId: { type: Number, default: null },
    patientAge: { type: Number, default: 0 },
})

const emit = defineEmits(['saved'])

const toastStore = useToastStore()

const stepRoot = ref(null)

// The pads mount inside v-show wizard steps with no layout (0×0 bitmap).
// Once this step becomes visible, nudge the library's resize listener.
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
    if (stepRoot.value) visibilityObserver.observe(stepRoot.value)
})

onBeforeUnmount(() => {
    visibilityObserver?.disconnect()
})

const isMinor = computed(() => props.patientAge < 18)

const form = useForm({
    signature_svg: '',
    guardian_name: props.patient.guardian_name ?? '',
    guardian_svg: '',
})

/* ------------------------------------------------------------ Patient pad */

const patientPad = ref(null)
const patientHasInk = ref(false)

const patientOptions = {
    penColor: '#1f2937',
    backgroundColor: 'white',
    onEnd: () => {
        patientHasInk.value = !patientPad.value?.isEmpty()
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

const onPatientStrokeEnd = () => {
    patientHasInk.value = !patientPad.value?.isEmpty()
}

const acceptPatient = () => {
    const result = patientPad.value?.saveSignature('image/svg+xml')
    if (!result || result.isEmpty || !result.data) return

    const svg = extractSvg(result.data)
    if (svg) form.signature_svg = svg
}

const clearPatient = () => {
    patientPad.value?.clearSignature()
    patientHasInk.value = false
    form.signature_svg = ''
}

/* -------------------------------------------------------- Guardian pad */

const guardianPad = ref(null)
const guardianHasInk = ref(false)

const guardianOptions = {
    penColor: '#1f2937',
    backgroundColor: 'white',
    onEnd: () => {
        guardianHasInk.value = !guardianPad.value?.isEmpty()
    },
}

const onGuardianStrokeEnd = () => {
    guardianHasInk.value = !guardianPad.value?.isEmpty()
}

const acceptGuardian = () => {
    const result = guardianPad.value?.saveSignature('image/svg+xml')
    if (!result || result.isEmpty || !result.data) return

    const svg = extractSvg(result.data)
    if (svg) form.guardian_svg = svg
}

const clearGuardian = () => {
    guardianPad.value?.clearSignature()
    guardianHasInk.value = false
    form.guardian_svg = ''
}

/* ---------------------------------------------------------------- Sign */

const canSign = computed(() => {
    if (!form.signature_svg) return false
    if (!isMinor.value) return true
    return Boolean(form.guardian_name.trim()) && Boolean(form.guardian_svg)
})

const sign = () => {
    form.post(route('consents.patient-sign', props.consentFormId), {
        preserveScroll: true,
        onSuccess: () => {
            toastStore.show('Consent signed by the patient.')
            emit('saved')
        },
        onError: () => {
            toastStore.show('Signing failed — please try again.', 'error')
        },
    })
}
</script>

<template>
    <div v-if="!consentFormId" ref="stepRoot" class="flex flex-col items-center gap-3 py-10 text-center">
        <span class="flex h-14 w-14 items-center justify-center rounded-full bg-gray-100 text-gray-400">
            <Signature class="h-6 w-6" />
        </span>
        <p class="text-sm font-medium text-gray-700">Complete the waiver first</p>
        <p class="max-w-sm text-sm text-gray-500">
            The 10 consent statements must be read and initialed before the patient signature can be captured.
        </p>
    </div>

    <div v-else ref="stepRoot" class="space-y-6">
        <div>
            <h2 class="text-lg font-semibold text-gray-800">Patient signature</h2>
            <p class="mt-1 text-sm text-gray-500">
                {{ patient.first_name ?? 'The patient' }}, sign below to confirm that you have read and understood the waiver.
            </p>
        </div>

        <div class="rounded-2xl border border-gray-200 bg-white p-5 shadow-sm">
            <h3 class="text-sm font-semibold text-gray-800">Patient signature</h3>
            <p class="mt-0.5 text-xs text-gray-500">Draw your signature on the pad below.</p>
            <div
                class="mt-4 rounded-xl border border-gray-200 bg-white p-3"
                @pointerup="onPatientStrokeEnd"
                @pointercancel="onPatientStrokeEnd"
            >
                <VueSignaturePad
                    ref="patientPad"
                    :width="'100%'"
                    :height="'150px'"
                    :options="patientOptions"
                    class="mx-auto w-full"
                />
            </div>
            <div class="mt-3 flex items-center justify-end gap-2">
                <Button variant="outline" size="sm" class="min-h-11" @click="clearPatient">Clear</Button>
                <Button size="sm" class="min-h-11" :disabled="!patientHasInk" @click="acceptPatient">
                    {{ form.signature_svg ? 'Signature captured' : 'Accept signature' }}
                </Button>
            </div>
        </div>

        <div v-if="isMinor" class="rounded-2xl border border-gray-200 bg-white p-5 shadow-sm">
            <h3 class="text-sm font-semibold text-gray-800">Parent / guardian signature</h3>
            <p class="mt-1 text-sm text-gray-500">Required because this patient is under 18.</p>
            <div class="mt-4 space-y-4">
                <div>
                    <label for="guardian_name" class="mb-1.5 block text-sm font-medium text-gray-700">
                        Guardian name
                        <span class="text-status-cancelled">*</span>
                    </label>
                    <input
                        id="guardian_name"
                        v-model="form.guardian_name"
                        type="text"
                        placeholder="Full name of the parent or guardian"
                        required
                        class="h-11 w-full rounded-lg border bg-transparent px-4 py-2.5 text-sm text-gray-800 shadow-sm placeholder:text-gray-400 focus:border-brand-300 focus:outline-hidden focus:ring-2 focus:ring-brand-500/10"
                        :class="{ 'border-status-cancelled': form.errors.guardian_name }"
                    />
                    <p v-if="form.errors.guardian_name" class="mt-1.5 text-xs text-status-cancelled">
                        {{ form.errors.guardian_name }}
                    </p>
                </div>
                <div>
                    <p class="mb-1.5 text-sm font-medium text-gray-700">Guardian signature</p>
                    <div
                        class="rounded-xl border border-gray-200 bg-white p-3"
                        @pointerup="onGuardianStrokeEnd"
                        @pointercancel="onGuardianStrokeEnd"
                    >
                        <VueSignaturePad
                            ref="guardianPad"
                            :width="'100%'"
                            :height="'150px'"
                            :options="guardianOptions"
                            class="mx-auto w-full"
                        />
                    </div>
                    <div class="mt-3 flex items-center justify-end gap-2">
                        <Button variant="outline" size="sm" class="min-h-11" @click="clearGuardian">Clear</Button>
                        <Button size="sm" class="min-h-11" :disabled="!guardianHasInk" @click="acceptGuardian">
                            {{ form.guardian_svg ? 'Signature captured' : 'Accept signature' }}
                        </Button>
                    </div>
                </div>
            </div>
        </div>

        <div class="flex flex-wrap items-center justify-between gap-3 border-t border-gray-100 pt-4">
            <p class="text-sm text-gray-500">
                <template v-if="isMinor">The patient and the guardian must both sign.</template>
                <template v-else>The signed form is stored with the patient record.</template>
            </p>
            <Button type="button" :disabled="!canSign || form.processing" @click="sign">
                {{ form.processing ? 'Signing…' : 'Sign & continue' }}
            </Button>
        </div>
    </div>
</template>
