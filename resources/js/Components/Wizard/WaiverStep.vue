<script setup>
import { computed } from 'vue'
import { useForm } from '@inertiajs/vue3'
import { route } from '../../../../vendor/tightenco/ziggy'
import Button from '@/Components/Button.vue'
import InitialPad from '@/Components/InitialPad.vue'
import { useToastStore } from '@/Stores/toast'

const props = defineProps({
    patient: { type: Object, required: true },
    sections: { type: Array, default: () => [] },
    acknowledgment: { type: String, default: '' },
    authorization: { type: String, default: '' },
    patientAge: { type: Number, default: 0 },
})

const emit = defineEmits(['saved'])

const toastStore = useToastStore()

const form = useForm({
    patient_id: props.patient.id,
    initials: {},
})

const allInitialed = computed(() =>
    props.sections.every((section) => Boolean(form.initials[section.key])),
)

const initialedCount = computed(
    () => props.sections.filter((section) => Boolean(form.initials[section.key])).length,
)

const isMinor = computed(() => props.patientAge < 18)

const save = () => {
    form.post(route('consents.store'), {
        preserveScroll: true,
        onSuccess: () => {
            toastStore.show('Waiver saved — the patient signature step is next.')
            emit('saved')
        },
        onError: () => {
            toastStore.show('Saving the waiver failed — please review the pads.', 'error')
        },
    })
}
</script>

<template>
    <div class="space-y-6">
        <div>
            <h2 class="text-lg font-semibold text-gray-800">Informed consent & waiver</h2>
            <p class="mt-1 text-sm text-gray-500">
                {{ patient.first_name ?? 'Patient' }}, please read each statement and draw your initials in the box next to it.
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
                    <div class="w-44 shrink-0 sm:w-52">
                        <InitialPad v-model="form.initials[section.key]" />
                    </div>
                </div>
            </li>
        </ol>

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
                <template v-if="allInitialed">All {{ sections.length }} sections initialed.</template>
                <template v-else>
                    {{ initialedCount }} of {{ sections.length }} sections initialed — all are required to continue.
                </template>
            </p>
            <Button type="button" :disabled="!allInitialed || form.processing" @click="save">
                {{ form.processing ? 'Saving…' : 'Save & continue' }}
            </Button>
        </div>
    </div>
</template>
