<script setup>
import { computed } from 'vue'
import { useForm } from '@inertiajs/vue3'
import { route } from '../../../../vendor/tightenco/ziggy'
import Button from '@/Components/Button.vue'
import Input from '@/Components/Input.vue'
import { useToastStore } from '@/Stores/toast'
import { errorList, scrollToFirstError } from '@/lib/scroll'

const props = defineProps({
    patientId: { type: Number, required: true },
    options: { type: Object, required: true },
})

const emit = defineEmits(['saved'])

const toastStore = useToastStore()

const today = () => {
    const d = new Date()
    const pad = (n) => String(n).padStart(2, '0')

    return `${d.getFullYear()}-${pad(d.getMonth() + 1)}-${pad(d.getDate())}`
}

const form = useForm({
    consultation_date: today(),
    chief_complaint: '',
    examination_findings: '',
    diagnosis: '',
    treatment_plan: '',
    recommendations: '',
    notes: '',
    periodontal_screening: '',
    occlusion_class: '',
    overjet: '',
    overbite: '',
    midline_deviation: '',
    crossbite: '',
    appliances: [],
    tmd_findings: [],
})

const formErrorList = computed(() => errorList(form.errors))

const submit = () => {
    form.post(route('consultations.store', props.patientId), {
        preserveScroll: true,
        onSuccess: () => {
            form.reset()
            toastStore.show('Consultation saved.')
            emit('saved')
        },
        onError: () => scrollToFirstError(),
    })
}

const selectClasses = (field) => [
    'h-11 w-full rounded-lg border bg-transparent px-4 py-2.5 text-sm text-gray-800 shadow-sm focus:border-brand-300 focus:outline-hidden focus:ring-2 focus:ring-brand-500/10',
    form.errors[field] ? 'border-status-cancelled' : 'border-gray-300',
]

const textareaClasses = (field) => [
    'w-full rounded-lg border bg-transparent px-4 py-2.5 text-sm text-gray-800 shadow-sm placeholder:text-gray-400 focus:border-brand-300 focus:outline-hidden focus:ring-2 focus:ring-brand-500/10',
    form.errors[field] ? 'border-status-cancelled' : 'border-gray-300',
]
</script>

<template>
    <form class="space-y-6" @submit.prevent="submit">
        <ul
            v-if="form.hasErrors"
            role="alert"
            class="space-y-1 rounded-lg bg-status-cancelled/10 px-4 py-3 text-sm font-medium text-status-cancelled"
        >
            <li v-for="message in formErrorList" :key="message">{{ message }}</li>
        </ul>

        <div class="grid grid-cols-1 gap-5 sm:grid-cols-2">
            <Input
                v-model="form.consultation_date"
                type="date"
                label="Consultation date"
                required
                :error="form.errors.consultation_date"
            />

            <div class="sm:col-span-2">
                <label for="chief_complaint" class="mb-1.5 block text-sm font-medium text-gray-700">
                    Chief complaint
                    <span class="text-status-cancelled">*</span>
                </label>
                <textarea
                    id="chief_complaint"
                    v-model="form.chief_complaint"
                    :rows="2"
                    placeholder="Reason for the visit…"
                    :class="textareaClasses('chief_complaint')"
                />
                <p v-if="form.errors.chief_complaint" class="mt-1.5 text-xs text-status-cancelled">
                    {{ form.errors.chief_complaint }}
                </p>
            </div>

            <div>
                <label for="examination_findings" class="mb-1.5 block text-sm font-medium text-gray-700">
                    Examination findings
                </label>
                <textarea
                    id="examination_findings"
                    v-model="form.examination_findings"
                    :rows="3"
                    placeholder="Intraoral and extraoral findings…"
                    :class="textareaClasses('examination_findings')"
                />
                <p v-if="form.errors.examination_findings" class="mt-1.5 text-xs text-status-cancelled">
                    {{ form.errors.examination_findings }}
                </p>
            </div>

            <div>
                <label for="diagnosis" class="mb-1.5 block text-sm font-medium text-gray-700">Diagnosis</label>
                <textarea
                    id="diagnosis"
                    v-model="form.diagnosis"
                    :rows="3"
                    placeholder="Clinical diagnosis…"
                    :class="textareaClasses('diagnosis')"
                />
                <p v-if="form.errors.diagnosis" class="mt-1.5 text-xs text-status-cancelled">
                    {{ form.errors.diagnosis }}
                </p>
            </div>

            <div>
                <label for="treatment_plan" class="mb-1.5 block text-sm font-medium text-gray-700">Treatment plan</label>
                <textarea
                    id="treatment_plan"
                    v-model="form.treatment_plan"
                    :rows="3"
                    placeholder="Planned procedures…"
                    :class="textareaClasses('treatment_plan')"
                />
                <p v-if="form.errors.treatment_plan" class="mt-1.5 text-xs text-status-cancelled">
                    {{ form.errors.treatment_plan }}
                </p>
            </div>

            <div>
                <label for="recommendations" class="mb-1.5 block text-sm font-medium text-gray-700">Recommendations</label>
                <textarea
                    id="recommendations"
                    v-model="form.recommendations"
                    :rows="3"
                    placeholder="Follow-up advice…"
                    :class="textareaClasses('recommendations')"
                />
                <p v-if="form.errors.recommendations" class="mt-1.5 text-xs text-status-cancelled">
                    {{ form.errors.recommendations }}
                </p>
            </div>
        </div>

        <div class="rounded-xl bg-gray-50 p-5">
            <h4 class="text-xs font-semibold tracking-wide text-gray-400 uppercase">Intraoral examination</h4>

            <div class="mt-4 grid grid-cols-1 gap-5 sm:grid-cols-2">
                <div>
                    <label for="periodontal_screening" class="mb-1.5 block text-sm font-medium text-gray-700">
                        Periodontal screening
                    </label>
                    <select
                        id="periodontal_screening"
                        v-model="form.periodontal_screening"
                        :class="selectClasses('periodontal_screening')"
                    >
                        <option value="">Not assessed</option>
                        <option v-for="(label, key) in options.periodontal" :key="key" :value="key">{{ label }}</option>
                    </select>
                    <p v-if="form.errors.periodontal_screening" class="mt-1.5 text-xs text-status-cancelled">
                        {{ form.errors.periodontal_screening }}
                    </p>
                </div>

                <div>
                    <label for="occlusion_class" class="mb-1.5 block text-sm font-medium text-gray-700">Occlusion class</label>
                    <select id="occlusion_class" v-model="form.occlusion_class" :class="selectClasses('occlusion_class')">
                        <option value="">Not assessed</option>
                        <option v-for="(label, key) in options.occlusion" :key="key" :value="key">{{ label }}</option>
                    </select>
                    <p v-if="form.errors.occlusion_class" class="mt-1.5 text-xs text-status-cancelled">
                        {{ form.errors.occlusion_class }}
                    </p>
                </div>

                <Input v-model="form.overjet" label="Overjet" placeholder="e.g. 2mm" :error="form.errors.overjet" />
                <Input v-model="form.overbite" label="Overbite" placeholder="e.g. 1mm" :error="form.errors.overbite" />
                <Input v-model="form.midline_deviation" label="Midline deviation" placeholder="e.g. none" :error="form.errors.midline_deviation" />
                <Input v-model="form.crossbite" label="Crossbite" placeholder="e.g. none" :error="form.errors.crossbite" />

                <div>
                    <p class="mb-1.5 text-sm font-medium text-gray-700">Appliances</p>
                    <div class="flex flex-wrap gap-x-6 gap-y-2">
                        <label
                            v-for="(label, key) in options.appliances"
                            :key="key"
                            class="inline-flex cursor-pointer items-center gap-2 text-sm text-gray-700"
                        >
                            <input
                                v-model="form.appliances"
                                type="checkbox"
                                :value="key"
                                class="h-4 w-4 rounded border-gray-300 text-brand-500 focus:ring-brand-500/10"
                            />
                            {{ label }}
                        </label>
                    </div>
                    <p v-if="form.errors.appliances" class="mt-1.5 text-xs text-status-cancelled">
                        {{ form.errors.appliances }}
                    </p>
                </div>

                <div>
                    <p class="mb-1.5 text-sm font-medium text-gray-700">TMD findings</p>
                    <div class="flex flex-wrap gap-x-6 gap-y-2">
                        <label
                            v-for="(label, key) in options.tmd"
                            :key="key"
                            class="inline-flex cursor-pointer items-center gap-2 text-sm text-gray-700"
                        >
                            <input
                                v-model="form.tmd_findings"
                                type="checkbox"
                                :value="key"
                                class="h-4 w-4 rounded border-gray-300 text-brand-500 focus:ring-brand-500/10"
                            />
                            {{ label }}
                        </label>
                    </div>
                    <p v-if="form.errors.tmd_findings" class="mt-1.5 text-xs text-status-cancelled">
                        {{ form.errors.tmd_findings }}
                    </p>
                </div>
            </div>
        </div>

        <div>
            <label for="notes" class="mb-1.5 block text-sm font-medium text-gray-700">Notes</label>
            <textarea
                id="notes"
                v-model="form.notes"
                :rows="2"
                placeholder="Additional notes…"
                :class="textareaClasses('notes')"
            />
            <p v-if="form.errors.notes" class="mt-1.5 text-xs text-status-cancelled">
                {{ form.errors.notes }}
            </p>
        </div>

        <div class="flex items-center justify-end gap-2">
            <Button type="submit" :disabled="form.processing">{{ form.processing ? 'Saving…' : 'Save consultation' }}</Button>
        </div>
    </form>
</template>
