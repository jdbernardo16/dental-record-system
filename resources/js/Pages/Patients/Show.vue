<script setup>
import { ref } from 'vue'
import { Head, Link, router, useForm } from '@inertiajs/vue3'
import { CalendarDays, FileText, FolderOpen, Pencil, Stethoscope, Trash2, Wrench } from 'lucide-vue-next'
import { route } from '../../../../vendor/tightenco/ziggy'
import AppLayout from '@/Layouts/AppLayout.vue'
import Badge from '@/Components/Badge.vue'
import Button from '@/Components/Button.vue'
import { useToastStore } from '@/Stores/toast'

defineOptions({ layout: AppLayout })

const props = defineProps({
    patient: { type: Object, required: true },
    medicalHistory: { type: Object, default: null },
    can: { type: Object, default: () => ({}) },
})

const toastStore = useToastStore()

const fullName = () =>
    [props.patient.first_name, props.patient.middle_name, props.patient.last_name]
        .filter(Boolean)
        .join(' ')

const initials = () =>
    fullName()
        .split(' ')
        .map((part) => part[0])
        .slice(0, 2)
        .join('')
        .toUpperCase()

const sexLabel = () => ({ male: 'Male', female: 'Female' })[props.patient.sex] ?? props.patient.sex

const civilStatusLabel = () =>
    ({
        single: 'Single',
        married: 'Married',
        widowed: 'Widowed',
        separated: 'Separated',
        divorced: 'Divorced',
        annulled: 'Annulled',
        other: 'Other',
    })[props.patient.civil_status] ?? props.patient.civil_status

const questions = [
    { key: 'hypertension', label: 'Hypertension' },
    { key: 'diabetes', label: 'Diabetes' },
    { key: 'tuberculosis', label: 'Tuberculosis' },
    { key: 'heart_disease', label: 'Heart disease' },
    { key: 'pregnancy', label: 'Pregnancy' },
    { key: 'allergies', label: 'Allergies', detailsKey: 'allergies_details' },
    { key: 'medications', label: 'Medications', detailsKey: 'medications_details' },
    { key: 'smoking_history', label: 'Smoking history', detailsKey: 'smoking_details' },
    { key: 'alcohol_consumption', label: 'Alcohol consumption', detailsKey: 'alcohol_details' },
    { key: 'previous_surgeries', label: 'Previous surgeries', detailsKey: 'surgeries_details' },
]

const answers = ['no', 'yes', 'not_applicable']
const answerLabels = { no: 'No', yes: 'Yes', not_applicable: 'N/A' }

const answerBadgeColor = (value) =>
    value === 'yes' ? 'success' : value === 'not_applicable' ? 'warning' : 'light'

const editing = ref(false)

const form = useForm({
    hypertension: 'no',
    diabetes: 'no',
    tuberculosis: 'no',
    heart_disease: 'no',
    pregnancy: 'no',
    allergies: 'no',
    medications: 'no',
    smoking_history: 'no',
    alcohol_consumption: 'no',
    previous_surgeries: 'no',
    allergies_details: '',
    medications_details: '',
    smoking_details: '',
    alcohol_details: '',
    surgeries_details: '',
    remarks: '',
})

const openEditor = () => {
    const history = props.medicalHistory
    for (const q of questions) {
        form[q.key] = history?.[q.key] ?? 'no'
        if (q.detailsKey) form[q.detailsKey] = history?.[q.detailsKey] ?? ''
    }
    form.remarks = history?.remarks ?? ''
    editing.value = true
}

const saveMedicalHistory = () => {
    form.post(route('medical-histories.store', props.patient.id), {
        preserveScroll: true,
        onSuccess: () => {
            editing.value = false
            toastStore.show('Medical history saved.')
        },
    })
}

const detailedAnswers = () =>
    questions.filter(
        (q) => q.detailsKey && props.medicalHistory?.[q.key] === 'yes' && props.medicalHistory?.[q.detailsKey],
    )

const confirmDelete = () => {
    if (window.confirm(`Delete ${fullName()}? The record can be restored by an administrator.`)) {
        router.delete(route('patients.destroy', props.patient.id), {
            onSuccess: () => toastStore.show('Patient deleted.'),
        })
    }
}

const tabs = [
    { name: 'Appointments', icon: CalendarDays, phase: 'Phase 2' },
    { name: 'Chart', icon: Stethoscope, phase: 'Phase 2' },
    { name: 'Treatments', icon: Wrench, phase: 'Phase 2' },
    { name: 'Files', icon: FolderOpen, phase: 'Phase 2' },
    { name: 'Consents', icon: FileText, phase: 'Phase 3' },
]
</script>

<template>
    <Head :title="fullName()" />

    <div class="mx-auto max-w-4xl space-y-6">
        <div class="flex flex-wrap items-center justify-between gap-4">
            <div>
                <h1 class="text-2xl font-semibold text-gray-800">Patient record</h1>
                <p class="mt-1 text-sm text-gray-500">{{ patient.patient_number }}</p>
            </div>
            <div class="flex items-center gap-2">
                <Link v-if="can.update" :href="route('patients.edit', patient.id)">
                    <Button variant="outline" size="sm">
                        <Pencil class="h-4 w-4" />
                        Edit
                    </Button>
                </Link>
                <Button
                    v-if="can.delete"
                    variant="outline"
                    size="sm"
                    class="border-status-cancelled/30 text-status-cancelled hover:bg-status-cancelled/10"
                    @click="confirmDelete"
                >
                    <Trash2 class="h-4 w-4" />
                    Delete
                </Button>
            </div>
        </div>

        <div class="rounded-2xl border border-gray-200 bg-white p-6 shadow-sm">
            <div class="flex flex-wrap items-center gap-4">
                <span class="flex h-14 w-14 shrink-0 items-center justify-center rounded-full bg-brand-500 text-lg font-semibold text-white">
                    {{ initials() }}
                </span>
                <div class="min-w-0">
                    <h2 class="truncate text-lg font-semibold text-gray-800">{{ fullName() }}</h2>
                    <div class="mt-1.5 flex flex-wrap items-center gap-2">
                        <Badge size="sm" color="info">{{ patient.age }} yrs old</Badge>
                        <Badge size="sm" color="light">{{ sexLabel() }}</Badge>
                        <Badge size="sm" color="primary">{{ civilStatusLabel() }}</Badge>
                    </div>
                </div>
            </div>
        </div>

        <div class="rounded-2xl border border-gray-200 bg-white shadow-sm">
            <div class="grid grid-cols-1 gap-x-8 gap-y-6 p-6 sm:grid-cols-2">
                <div class="space-y-4">
                    <h3 class="text-xs font-semibold tracking-wide text-gray-400 uppercase">Identity</h3>
                    <dl class="space-y-3 text-sm">
                        <div class="flex items-start justify-between gap-4">
                            <dt class="text-gray-500">Full name</dt>
                            <dd class="text-right font-medium text-gray-800">{{ fullName() }}</dd>
                        </div>
                        <div class="flex items-start justify-between gap-4">
                            <dt class="text-gray-500">Birth date</dt>
                            <dd class="text-right font-medium text-gray-800">{{ patient.birth_date }}</dd>
                        </div>
                        <div class="flex items-start justify-between gap-4">
                            <dt class="text-gray-500">Nationality</dt>
                            <dd class="text-right font-medium text-gray-800">{{ patient.nationality }}</dd>
                        </div>
                        <div class="flex items-start justify-between gap-4">
                            <dt class="text-gray-500">Occupation</dt>
                            <dd class="text-right font-medium text-gray-800">{{ patient.occupation || '—' }}</dd>
                        </div>
                    </dl>
                </div>

                <div class="space-y-4">
                    <h3 class="text-xs font-semibold tracking-wide text-gray-400 uppercase">Contact</h3>
                    <dl class="space-y-3 text-sm">
                        <div class="flex items-start justify-between gap-4">
                            <dt class="text-gray-500">Contact number</dt>
                            <dd class="text-right font-medium text-gray-800">{{ patient.contact_number }}</dd>
                        </div>
                        <div class="flex items-start justify-between gap-4">
                            <dt class="text-gray-500">Email address</dt>
                            <dd class="text-right font-medium text-gray-800">{{ patient.email_address || '—' }}</dd>
                        </div>
                        <div class="flex items-start justify-between gap-4">
                            <dt class="text-gray-500">Address</dt>
                            <dd class="max-w-56 text-right font-medium text-gray-800">{{ patient.address }}</dd>
                        </div>
                    </dl>
                </div>

                <div class="space-y-4 sm:col-span-2">
                    <h3 class="text-xs font-semibold tracking-wide text-gray-400 uppercase">Emergency contact</h3>
                    <dl class="grid grid-cols-1 gap-3 text-sm sm:grid-cols-2">
                        <div class="flex items-start justify-between gap-4">
                            <dt class="text-gray-500">Contact person</dt>
                            <dd class="text-right font-medium text-gray-800">{{ patient.emergency_contact_person }}</dd>
                        </div>
                        <div class="flex items-start justify-between gap-4">
                            <dt class="text-gray-500">Contact number</dt>
                            <dd class="text-right font-medium text-gray-800">{{ patient.emergency_contact_number }}</dd>
                        </div>
                    </dl>
                </div>
            </div>
        </div>

        <div class="rounded-2xl border border-gray-200 bg-white shadow-sm">
            <div class="flex flex-wrap items-center justify-between gap-3 border-b border-gray-100 px-6 py-4">
                <div>
                    <h3 class="text-sm font-semibold text-gray-800">Medical history</h3>
                    <p class="mt-0.5 text-xs text-gray-500">
                        {{ medicalHistory ? 'Pre-treatment screening on record' : 'No screening recorded yet' }}
                    </p>
                </div>
                <Button v-if="can.medicalHistory?.edit" variant="outline" size="sm" @click="openEditor">
                    <Pencil class="h-4 w-4" />
                    {{ editing ? 'Editing…' : 'Edit' }}
                </Button>
            </div>

            <div v-if="!editing" class="grid grid-cols-1 gap-x-8 gap-y-4 p-6 sm:grid-cols-2">
                <div v-for="q in questions" :key="q.key" class="flex items-center justify-between gap-3">
                    <span class="text-sm text-gray-600">{{ q.label }}</span>
                    <Badge size="sm" :color="answerBadgeColor(medicalHistory?.[q.key])">
                        {{ answerLabels[medicalHistory?.[q.key]] ?? 'No' }}
                    </Badge>
                </div>
                <div
                    v-for="q in detailedAnswers()"
                    :key="q.detailsKey"
                    class="rounded-xl bg-gray-50 px-4 py-3 sm:col-span-2"
                >
                    <p class="text-xs font-medium text-gray-500">{{ q.label }} details</p>
                    <p class="mt-1 text-sm text-gray-800">{{ medicalHistory[q.detailsKey] }}</p>
                </div>
                <div v-if="medicalHistory?.remarks" class="rounded-xl bg-gray-50 px-4 py-3 sm:col-span-2">
                    <p class="text-xs font-medium text-gray-500">Remarks</p>
                    <p class="mt-1 text-sm text-gray-800">{{ medicalHistory.remarks }}</p>
                </div>
            </div>

            <form v-else class="space-y-6 p-6" @submit.prevent="saveMedicalHistory">
                <div v-for="q in questions" :key="q.key" class="space-y-2.5">
                    <div class="flex flex-wrap items-center justify-between gap-3">
                        <p class="text-sm font-medium text-gray-700">{{ q.label }}</p>
                        <div class="inline-flex gap-1 rounded-full bg-gray-100 p-1" role="radiogroup" :aria-label="q.label">
                            <button
                                v-for="answer in answers"
                                :key="answer"
                                type="button"
                                role="radio"
                                :aria-checked="form[q.key] === answer"
                                :class="[
                                    'min-h-11 rounded-full px-4 text-sm font-medium transition',
                                    form[q.key] === answer ? 'bg-white text-gray-900 shadow-sm' : 'text-gray-500',
                                ]"
                                @click="form[q.key] = answer"
                            >
                                {{ answerLabels[answer] }}
                            </button>
                        </div>
                    </div>
                    <textarea
                        v-if="q.detailsKey && form[q.key] === 'yes'"
                        v-model="form[q.detailsKey]"
                        :rows="2"
                        :placeholder="`Details for ${q.label.toLowerCase()}…`"
                        class="w-full rounded-lg border border-gray-300 bg-transparent px-4 py-2.5 text-sm text-gray-800 shadow-sm placeholder:text-gray-400 focus:border-brand-300 focus:outline-hidden focus:ring-2 focus:ring-brand-500/10"
                    />
                </div>

                <div>
                    <label class="mb-1.5 block text-sm font-medium text-gray-700">Remarks</label>
                    <textarea
                        v-model="form.remarks"
                        :rows="3"
                        placeholder="Additional notes…"
                        class="w-full rounded-lg border border-gray-300 bg-transparent px-4 py-2.5 text-sm text-gray-800 shadow-sm placeholder:text-gray-400 focus:border-brand-300 focus:outline-hidden focus:ring-2 focus:ring-brand-500/10"
                    />
                </div>

                <div class="flex items-center justify-end gap-2">
                    <Button variant="outline" type="button" @click="editing = false">Cancel</Button>
                    <Button type="submit" :disabled="form.processing">Save</Button>
                </div>
            </form>
        </div>

        <div class="overflow-hidden rounded-2xl border border-gray-200 bg-white shadow-sm">
            <div class="flex gap-1 border-b border-gray-100 px-4 pt-3">
                <button
                    v-for="tab in tabs"
                    :key="tab.name"
                    type="button"
                    disabled
                    :title="`${tab.name} — coming in ${tab.phase}`"
                    class="inline-flex cursor-not-allowed items-center gap-2 rounded-t-lg px-4 py-2.5 text-sm font-medium text-gray-400"
                >
                    <component :is="tab.icon" class="h-4 w-4" />
                    {{ tab.name }}
                    <Badge size="sm" color="light">{{ tab.phase }}</Badge>
                </button>
            </div>
            <div class="flex flex-col items-center gap-2 px-6 py-14 text-center">
                <p class="text-sm font-medium text-gray-700">No records yet</p>
                <p class="text-sm text-gray-500">
                    Appointments, chart, treatments, files, and consents will appear here in later phases.
                </p>
            </div>
        </div>
    </div>
</template>
