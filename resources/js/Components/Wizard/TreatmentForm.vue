<script setup>
import { useForm } from '@inertiajs/vue3'
import { route } from '../../../../vendor/tightenco/ziggy'
import Button from '@/Components/Button.vue'
import Input from '@/Components/Input.vue'
import { useToastStore } from '@/Stores/toast'

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
        <p
            v-if="form.hasErrors"
            role="alert"
            class="rounded-lg bg-status-cancelled/10 px-4 py-3 text-sm font-medium text-status-cancelled"
        >
            Please review the highlighted fields.
        </p>

        <div class="grid grid-cols-1 gap-5 sm:grid-cols-2">
            <Input
                v-model="form.treatment_date"
                type="date"
                label="Treatment date"
                required
                :error="form.errors.treatment_date"
            />

            <div>
                <label for="tooth_number" class="mb-1.5 block text-sm font-medium text-gray-700">Tooth</label>
                <select
                    id="tooth_number"
                    v-model="form.tooth_number"
                    :class="selectClasses('tooth_number')"
                >
                    <option value="">Non-tooth procedure</option>
                    <option v-for="tooth in toothOptions" :key="tooth" :value="tooth">{{ tooth }}</option>
                </select>
                <p v-if="form.errors.tooth_number" class="mt-1.5 text-xs text-status-cancelled">
                    {{ form.errors.tooth_number }}
                </p>
            </div>

            <div class="sm:col-span-2">
                <label for="procedure_name" class="mb-1.5 block text-sm font-medium text-gray-700">
                    Procedure
                    <span class="text-status-cancelled">*</span>
                </label>
                <input
                    id="procedure_name"
                    v-model="form.procedure_name"
                    type="text"
                    list="treatment-procedures"
                    placeholder="e.g. Composite restoration"
                    :class="selectClasses('procedure_name')"
                />
                <datalist id="treatment-procedures">
                    <option v-for="procedure in procedures" :key="procedure" :value="procedure" />
                </datalist>
                <p v-if="form.errors.procedure_name" class="mt-1.5 text-xs text-status-cancelled">
                    {{ form.errors.procedure_name }}
                </p>
            </div>

            <div>
                <label for="consultation_id" class="mb-1.5 block text-sm font-medium text-gray-700">
                    Linked consultation
                </label>
                <select
                    id="consultation_id"
                    v-model="form.consultation_id"
                    :class="selectClasses('consultation_id')"
                >
                    <option value="">None</option>
                    <option
                        v-for="consultation in consultations"
                        :key="consultation.id"
                        :value="consultation.id"
                    >
                        #{{ consultation.id }} — {{ consultation.chief_complaint }}
                    </option>
                </select>
                <p v-if="form.errors.consultation_id" class="mt-1.5 text-xs text-status-cancelled">
                    {{ form.errors.consultation_id }}
                </p>
            </div>

            <div>
                <label for="description" class="mb-1.5 block text-sm font-medium text-gray-700">Description</label>
                <textarea
                    id="description"
                    v-model="form.description"
                    :rows="3"
                    placeholder="Procedure details…"
                    :class="textareaClasses('description')"
                />
                <p v-if="form.errors.description" class="mt-1.5 text-xs text-status-cancelled">
                    {{ form.errors.description }}
                </p>
            </div>

            <div>
                <label for="notes" class="mb-1.5 block text-sm font-medium text-gray-700">Notes</label>
                <textarea
                    id="notes"
                    v-model="form.notes"
                    :rows="3"
                    placeholder="Additional notes…"
                    :class="textareaClasses('notes')"
                />
                <p v-if="form.errors.notes" class="mt-1.5 text-xs text-status-cancelled">
                    {{ form.errors.notes }}
                </p>
            </div>
        </div>

        <div class="flex items-center justify-end gap-2">
            <Button type="submit" :disabled="form.processing">{{ form.processing ? 'Saving…' : 'Save treatment' }}</Button>
        </div>
    </form>
</template>
