<script setup>
import { computed, ref } from 'vue'
import { useForm } from '@inertiajs/vue3'
import { route } from '../../../../vendor/tightenco/ziggy'
import { CheckCircle2 } from 'lucide-vue-next'
import Button from '@/Components/Button.vue'
import InitialPad from '@/Components/InitialPad.vue'
import { useToastStore } from '@/Stores/toast'

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

// A single initial drawn once, applied to every consent section (best practice:
// the PDA paper form asks for an initial per line, but digitally one mark covers
// all statements — each section still stores its own copy for the legal record).
// When an unsigned draft already exists, re-display the initial the patient drew.
const initialSvg = ref(props.existingInitialSvg ?? '')

const form = useForm({
    patient_id: props.patient.id,
    initials: {},
})

const hasInitial = computed(() => Boolean(initialSvg.value))

const isMinor = computed(() => props.patientAge < 18)

const save = () => {
    if (!hasInitial.value) return

    form.initials = Object.fromEntries(props.sections.map((section) => [section.key, initialSvg.value]))

    form.post(route('consents.store'), {
        preserveScroll: true,
        onSuccess: () => {
            toastStore.show('Waiver saved — the patient signature step is next.')
            emit('saved')
        },
        onError: () => {
            toastStore.show('Saving the waiver failed — please review the initial.', 'error')
        },
    })
}
</script>

<template>
    <div class="space-y-6">
        <div>
            <h2 class="text-lg font-semibold text-gray-800">Informed consent & waiver</h2>
            <p class="mt-1 text-sm text-gray-500">
                {{ patient.first_name ?? 'Patient' }}, please read each statement below, then draw your initial
                <strong>once</strong> — it is applied to all {{ sections.length }} statements.
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
                        v-if="hasInitial"
                        class="h-5 w-5 shrink-0 text-status-completed"
                        aria-label="Covered by the initial"
                    />
                </div>
            </li>
        </ol>

        <div
            class="rounded-2xl border border-dashed border-brand-300 bg-brand-50 p-5 shadow-sm"
            :class="hasInitial ? 'border-solid border-brand-500' : ''"
        >
            <h3 class="text-sm font-semibold text-brand-800">Patient initial</h3>
            <p class="mt-0.5 text-sm text-brand-700">
                Draw the patient's initial here. It applies to all {{ sections.length }} statements above.
            </p>
            <div class="mt-3">
                <InitialPad v-model="initialSvg" />
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
                <template v-if="hasInitial">Initial drawn — applies to all {{ sections.length }} statements.</template>
                <template v-else>Draw the patient's initial above to continue.</template>
            </p>
            <Button type="button" :disabled="!hasInitial || form.processing" @click="save">
                {{ form.processing ? 'Saving…' : 'Save & continue' }}
            </Button>
        </div>
    </div>
</template>
