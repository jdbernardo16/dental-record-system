<script setup>
import { computed } from 'vue'
import { useForm } from '@inertiajs/vue3'
import { route } from '../../../../vendor/tightenco/ziggy'
import { Button } from '@/Components/ui/button'
import { CheckboxGroup, DateField, SelectField, TextInput, TextareaField } from '@/Components/Fields'
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

// options.periodontal / options.occlusion are objects keyed by value with
// label strings — flatten to SelectField's [{ value, label }] shape.
const periodontalOptions = computed(() =>
    Object.entries(props.options.periodontal ?? {}).map(([value, label]) => ({ value, label })),
)

const occlusionOptions = computed(() =>
    Object.entries(props.options.occlusion ?? {}).map(([value, label]) => ({ value, label })),
)

// options.appliances / options.tmd are objects keyed by value with label
// strings — flatten to CheckboxGroup's [{ value, label }] shape.
const appliancesOptions = computed(() =>
    Object.entries(props.options.appliances ?? {}).map(([value, label]) => ({ value, label })),
)

const tmdOptions = computed(() =>
    Object.entries(props.options.tmd ?? {}).map(([value, label]) => ({ value, label })),
)

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
            <DateField
                v-model="form.consultation_date"
                label="Consultation date"
                required
                :error="form.errors.consultation_date"
            />

            <div class="sm:col-span-2">
                <TextareaField
                    id="chief_complaint"
                    v-model="form.chief_complaint"
                    label="Chief complaint"
                    required
                    :rows="2"
                    placeholder="Reason for the visit…"
                    :error="form.errors.chief_complaint"
                />
            </div>

            <div>
                <TextareaField
                    id="examination_findings"
                    v-model="form.examination_findings"
                    label="Examination findings"
                    :rows="3"
                    placeholder="Intraoral and extraoral findings…"
                    :error="form.errors.examination_findings"
                />
            </div>

            <div>
                <TextareaField
                    id="diagnosis"
                    v-model="form.diagnosis"
                    label="Diagnosis"
                    :rows="3"
                    placeholder="Clinical diagnosis…"
                    :error="form.errors.diagnosis"
                />
            </div>

            <div>
                <TextareaField
                    id="treatment_plan"
                    v-model="form.treatment_plan"
                    label="Treatment plan"
                    :rows="3"
                    placeholder="Planned procedures…"
                    :error="form.errors.treatment_plan"
                />
            </div>

            <div>
                <TextareaField
                    id="recommendations"
                    v-model="form.recommendations"
                    label="Recommendations"
                    :rows="3"
                    placeholder="Follow-up advice…"
                    :error="form.errors.recommendations"
                />
            </div>
        </div>

        <div class="rounded-xl bg-gray-50 p-5">
            <h4 class="text-xs font-semibold tracking-wide text-gray-400 uppercase">Intraoral examination</h4>

            <div class="mt-4 grid grid-cols-1 gap-5 sm:grid-cols-2">
                <div>
                    <SelectField
                        id="periodontal_screening"
                        v-model="form.periodontal_screening"
                        label="Periodontal screening"
                        noneLabel="Not assessed"
                        :options="periodontalOptions"
                        :error="form.errors.periodontal_screening"
                    />
                </div>

                <div>
                    <SelectField
                        id="occlusion_class"
                        v-model="form.occlusion_class"
                        label="Occlusion class"
                        noneLabel="Not assessed"
                        :options="occlusionOptions"
                        :error="form.errors.occlusion_class"
                    />
                </div>

                <TextInput v-model="form.overjet" label="Overjet" placeholder="e.g. 2mm" :error="form.errors.overjet" />
                <TextInput v-model="form.overbite" label="Overbite" placeholder="e.g. 1mm" :error="form.errors.overbite" />
                <TextInput v-model="form.midline_deviation" label="Midline deviation" placeholder="e.g. none" :error="form.errors.midline_deviation" />
                <TextInput v-model="form.crossbite" label="Crossbite" placeholder="e.g. none" :error="form.errors.crossbite" />

                <div>
                    <CheckboxGroup
                        v-model="form.appliances"
                        label="Appliances"
                        :options="appliancesOptions"
                        :error="form.errors.appliances"
                    />
                </div>

                <div>
                    <CheckboxGroup
                        v-model="form.tmd_findings"
                        label="TMD findings"
                        :options="tmdOptions"
                        :error="form.errors.tmd_findings"
                    />
                </div>
            </div>
        </div>

        <div>
            <TextareaField
                id="notes"
                v-model="form.notes"
                label="Notes"
                :rows="2"
                placeholder="Additional notes…"
                :error="form.errors.notes"
            />
        </div>

        <div class="flex items-center justify-end gap-2">
            <Button size="md" type="submit" :disabled="form.processing">
                {{ form.processing ? 'Saving…' : 'Save consultation' }}
            </Button>
        </div>
    </form>
</template>
