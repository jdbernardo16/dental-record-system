<script setup>
import { useForm } from '@inertiajs/vue3'
import { route } from '../../../../vendor/tightenco/ziggy'
import { Button } from '@/Components/ui/button'
import { DateField, SelectField, TextInput, TextareaField } from '@/Components/Fields'
import { useToastStore } from '@/Stores/toast'
import { computed } from 'vue'
import { errorList, scrollToFirstError } from '@/lib/scroll'

const props = defineProps({
    patientId: { type: Number, required: true },
    consultations: { type: Array, default: () => [] },
    toothOptions: { type: Array, default: () => [] },
})

const emit = defineEmits(['saved'])

const toastStore = useToastStore()

const procedures = [
    'Scaling and polishing',
    'Composite restoration',
    'Amalgam filling',
    'Extraction',
    'Root canal treatment',
    'Crown placement',
    'Denture fitting',
    'Sealant application',
]

const today = () => {
    const d = new Date()
    const pad = (n) => String(n).padStart(2, '0')

    return `${d.getFullYear()}-${pad(d.getMonth() + 1)}-${pad(d.getDate())}`
}

const form = useForm({
    treatment_date: today(),
    tooth_number: '',
    procedure_name: '',
    description: '',
    notes: '',
    consultation_id: '',
})

const formErrorList = computed(() => errorList(form.errors))

// toothOptions arrives as a plain array of tooth labels — flatten to
// SelectField's [{ value, label }] shape.
const toothSelectOptions = computed(() =>
    props.toothOptions.map((tooth) => ({ value: tooth, label: tooth })),
)

// consultations arrive as objects — label them like the old <select> did.
const consultationSelectOptions = computed(() =>
    props.consultations.map((consultation) => ({
        value: String(consultation.id),
        label: `#${consultation.id} — ${consultation.chief_complaint}`,
    })),
)

const submit = () => {
    form.post(route('treatments.store', props.patientId), {
        // keep the wizard on the treatment step — a remount would resume a completed intake at step 0
        preserveState: true,
        preserveScroll: true,
        onSuccess: () => {
            form.reset()
            toastStore.show('Treatment saved.')
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
                v-model="form.treatment_date"
                label="Treatment date"
                required
                :error="form.errors.treatment_date"
            />

            <div>
                <SelectField
                    id="tooth_number"
                    v-model="form.tooth_number"
                    label="Tooth"
                    noneLabel="Non-tooth procedure"
                    :options="toothSelectOptions"
                    :error="form.errors.tooth_number"
                />
            </div>

            <div class="sm:col-span-2">
                <TextInput
                    id="procedure_name"
                    v-model="form.procedure_name"
                    label="Procedure"
                    required
                    list="treatment-procedures"
                    placeholder="e.g. Composite restoration"
                    :error="form.errors.procedure_name"
                />
                <datalist id="treatment-procedures">
                    <option v-for="procedure in procedures" :key="procedure" :value="procedure" />
                </datalist>
            </div>

            <div>
                <SelectField
                    id="consultation_id"
                    v-model="form.consultation_id"
                    label="Linked consultation"
                    noneLabel="None"
                    :options="consultationSelectOptions"
                    :error="form.errors.consultation_id"
                />
            </div>

            <div>
                <TextareaField
                    id="description"
                    v-model="form.description"
                    label="Description"
                    :rows="3"
                    placeholder="Procedure details…"
                    :error="form.errors.description"
                />
            </div>

            <div>
                <TextareaField
                    id="notes"
                    v-model="form.notes"
                    label="Notes"
                    :rows="3"
                    placeholder="Additional notes…"
                    :error="form.errors.notes"
                />
            </div>
        </div>

        <div class="flex items-center justify-end gap-2">
            <Button size="md" type="submit" :disabled="form.processing">
                {{ form.processing ? 'Saving…' : 'Save treatment' }}
            </Button>
        </div>
    </form>
</template>
