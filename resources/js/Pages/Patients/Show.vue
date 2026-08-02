<script setup>
import { ref } from 'vue'
import { Head, Link, router, useForm } from '@inertiajs/vue3'
import { CalendarDays, ChevronDown, FileText, FolderOpen, Pencil, Plus, Signature, Stethoscope, Trash2, Wrench } from 'lucide-vue-next'
import { route } from '../../../../vendor/tightenco/ziggy'
import AppLayout from '@/Layouts/AppLayout.vue'
import Badge from '@/Components/Badge.vue'
import Button from '@/Components/Button.vue'
import ConsultationForm from '@/Components/Wizard/ConsultationForm.vue'
import SignaturePadModal from '@/Components/SignaturePadModal.vue'
import TreatmentForm from '@/Components/Wizard/TreatmentForm.vue'
import { useToastStore } from '@/Stores/toast'

defineOptions({ layout: AppLayout })

const props = defineProps({
    patient: { type: Object, required: true },
    medicalHistory: { type: Object, default: null },
    consultations: { type: Array, default: () => [] },
    consultationCount: { type: Number, default: 0 },
    consultationOptions: { type: Object, default: () => ({}) },
    treatments: { type: Array, default: () => [] },
    toothOptions: { type: Array, default: () => [] },
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

const pdaAnswers = ['no', 'yes']
const pdaAnswerLabels = { no: 'No', yes: 'Yes' }

const bloodTypes = ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-']

const pdaPillQuestions = [
    { key: 'good_health', label: 'Are you in good health?', group: 'general' },
    {
        key: 'under_medical_treatment',
        label: 'Are you under medical treatment now?',
        group: 'general',
        detailsKey: 'medical_treatment_details',
    },
    {
        key: 'hospitalized',
        label: 'Have you ever been hospitalized?',
        group: 'general',
        detailsKey: 'hospitalization_details',
    },
    {
        key: 'drug_use',
        label: 'Do you use alcohol, cocaine, or dangerous drugs?',
        group: 'general',
        detailsKey: 'drug_use_details',
    },
    { key: 'nursing', label: 'Are you nursing?', group: 'women' },
    { key: 'birth_control_pills', label: 'Are you taking birth control pills?', group: 'women' },
]

const pdaQuestionsIn = (group) => pdaPillQuestions.filter((q) => q.group === group)

const physicianFields = [
    { key: 'physician_name', label: 'Physician name' },
    { key: 'physician_specialty', label: 'Specialty' },
    { key: 'physician_address', label: 'Office address' },
    { key: 'physician_phone', label: 'Office number' },
]

/** PDA Page 1 Q13 medical condition labels (36 keys). */
const pdaConditionLabels = {
    high_blood_pressure: 'High blood pressure',
    low_blood_pressure: 'Low blood pressure',
    epilepsy: 'Epilepsy',
    aids_hiv: 'AIDS or HIV infection',
    sexually_transmitted_disease: 'Sexually transmitted disease',
    stomach_ulcers: 'Stomach ulcers',
    fainting_seizure: 'Fainting seizure',
    rapid_weight_loss: 'Rapid weight loss',
    radiation_therapy: 'Radiation therapy',
    joint_replacement: 'Joint replacement',
    heart_surgery: 'Heart surgery',
    heart_attack: 'Heart attack',
    thyroid_problem: 'Thyroid problem',
    heart_disease: 'Heart disease',
    heart_murmur: 'Heart murmur',
    hepatitis_liver_disease: 'Hepatitis or liver disease',
    rheumatic_fever: 'Rheumatic fever',
    hay_fever: 'Hay fever',
    respiratory_problems: 'Respiratory problems',
    hepatitis_jaundice: 'Hepatitis or jaundice',
    tuberculosis: 'Tuberculosis',
    swollen_ankles: 'Swollen ankles',
    kidney_disease: 'Kidney disease',
    diabetes: 'Diabetes',
    chest_pain: 'Chest pain',
    stroke: 'Stroke',
    cancer_tumors: 'Cancer or tumors',
    anemia: 'Anemia',
    angina: 'Angina',
    asthma: 'Asthma',
    emphysema: 'Emphysema',
    bleeding_disorders: 'Bleeding disorders',
    blood_diseases: 'Blood diseases',
    head_injuries: 'Head injuries',
    arthritis: 'Arthritis',
    others: 'Others',
}

const toggleCondition = (key) => {
    if (form.conditions_checklist.includes(key)) {
        form.conditions_checklist = form.conditions_checklist.filter((item) => item !== key)
    } else {
        form.conditions_checklist = [...form.conditions_checklist, key]
    }
}

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
    good_health: null,
    under_medical_treatment: null,
    medical_treatment_details: '',
    hospitalized: null,
    hospitalization_details: '',
    nursing: null,
    birth_control_pills: null,
    bleeding_time: '',
    blood_type: '',
    blood_pressure: '',
    conditions_checklist: [],
    physician_name: '',
    physician_specialty: '',
    physician_address: '',
    physician_phone: '',
    dental_history_previous_dentist: '',
    dental_history_last_visit: '',
    referral_source: '',
    drug_use: null,
    drug_use_details: '',
})

const openEditor = () => {
    const history = props.medicalHistory
    for (const q of questions) {
        form[q.key] = history?.[q.key] ?? 'no'
        if (q.detailsKey) form[q.detailsKey] = history?.[q.detailsKey] ?? ''
    }
    for (const q of pdaPillQuestions) {
        form[q.key] = history?.[q.key] ?? null
        if (q.detailsKey) form[q.detailsKey] = history?.[q.detailsKey] ?? ''
    }
    form.remarks = history?.remarks ?? ''
    form.bleeding_time = history?.bleeding_time ?? ''
    form.blood_type = history?.blood_type ?? ''
    form.blood_pressure = history?.blood_pressure ?? ''
    form.conditions_checklist = history?.conditions_checklist ?? []
    form.physician_name = history?.physician_name ?? ''
    form.physician_specialty = history?.physician_specialty ?? ''
    form.physician_address = history?.physician_address ?? ''
    form.physician_phone = history?.physician_phone ?? ''
    form.dental_history_previous_dentist = history?.dental_history_previous_dentist ?? ''
    form.dental_history_last_visit = history?.dental_history_last_visit ?? ''
    form.referral_source = history?.referral_source ?? ''
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

const pdaDisplayRows = () => {
    const rows = []
    const history = props.medicalHistory ?? {}
    const add = (label, value) => {
        if (value !== null && value !== undefined && value !== '') rows.push({ label, value })
    }
    add('Good health', pdaAnswerLabels[history.good_health])
    add('Under medical treatment', pdaAnswerLabels[history.under_medical_treatment])
    add('Medical treatment details', history.medical_treatment_details)
    add('Hospitalized', pdaAnswerLabels[history.hospitalized])
    add('Hospitalization details', history.hospitalization_details)
    add('Bleeding time', history.bleeding_time)
    add('Blood type', history.blood_type)
    add('Blood pressure', history.blood_pressure)
    add('Drug use', pdaAnswerLabels[history.drug_use])
    add('Drug use details', history.drug_use_details)
    add('Nursing', pdaAnswerLabels[history.nursing])
    add('Birth control pills', pdaAnswerLabels[history.birth_control_pills])
    add('Physician name', history.physician_name)
    add('Physician specialty', history.physician_specialty)
    add('Physician address', history.physician_address)
    add('Physician phone', history.physician_phone)
    add('Previous dentist', history.dental_history_previous_dentist)
    add('Last dental visit', history.dental_history_last_visit)
    add('Referral source', history.referral_source)

    return rows
}

const conditionLabels = () =>
    (props.medicalHistory?.conditions_checklist ?? []).map((key) => pdaConditionLabels[key] ?? key)

const confirmDelete = () => {
    if (window.confirm(`Delete ${fullName()}? The record can be restored by an administrator.`)) {
        router.delete(route('patients.destroy', props.patient.id), {
            onSuccess: () => toastStore.show('Patient deleted.'),
        })
    }
}

const adding = ref(false)
const expandedId = ref(null)

const toggleExpanded = (id) => {
    expandedId.value = expandedId.value === id ? null : id
}

const optionLabel = (map, value) => map[value] ?? value

const pdaRows = (consultation) => [
    { label: 'Periodontal screening', value: optionLabel(props.consultationOptions.periodontal, consultation.periodontal_screening) },
    { label: 'Occlusion class', value: optionLabel(props.consultationOptions.occlusion, consultation.occlusion_class) },
    { label: 'Overjet', value: consultation.overjet },
    { label: 'Overbite', value: consultation.overbite },
    { label: 'Midline deviation', value: consultation.midline_deviation },
    { label: 'Crossbite', value: consultation.crossbite },
    {
        label: 'Appliances',
        value: (consultation.appliances ?? [])
            .map((key) => optionLabel(props.consultationOptions.appliances, key))
            .join(', '),
    },
    {
        label: 'TMD findings',
        value: (consultation.tmd_findings ?? [])
            .map((key) => optionLabel(props.consultationOptions.tmd, key))
            .join(', '),
    },
].filter((row) => row.value)

const tabs = [
    { name: 'Appointments', icon: CalendarDays, phase: 'Phase 2' },
    { name: 'Chart', icon: Stethoscope, phase: 'Phase 2', href: (id) => route('patients.chart', id) },
    { name: 'Treatments', icon: Wrench, wired: true },
    { name: 'Files', icon: FolderOpen, phase: 'Phase 3' },
    { name: 'Consents', icon: FileText, phase: 'Phase 3' },
]

const activeTab = ref(null)
const addingTreatment = ref(false)
const expandedTreatmentId = ref(null)

const toggleExpandedTreatment = (id) => {
    expandedTreatmentId.value = expandedTreatmentId.value === id ? null : id
}

const signModalOpen = ref(false)
const signingTreatment = ref(null)

const signForm = useForm({
    signature_svg: '',
})

const openSign = (treatment) => {
    signingTreatment.value = treatment
    signModalOpen.value = true
}

const confirmSign = (svg) => {
    signForm.signature_svg = svg
    signForm.post(route('treatments.sign', signingTreatment.value.id), {
        preserveScroll: true,
        onSuccess: () => {
            signModalOpen.value = false
            signForm.reset()
            signingTreatment.value = null
            toastStore.show('Treatment signed.')
        },
        onError: () => {
            toastStore.show('Signing failed — please try again.', 'error')
        },
    })
}

const closeSign = () => {
    signModalOpen.value = false
    signingTreatment.value = null
}

const formatSignedAt = (value) => {
    if (!value) return ''
    return new Date(value).toLocaleString()
}
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

        <div v-if="can.medicalHistory?.view" class="rounded-2xl border border-gray-200 bg-white shadow-sm">
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
                <div
                    v-if="pdaDisplayRows().length || conditionLabels().length"
                    class="rounded-xl bg-gray-50 px-4 py-3 sm:col-span-2"
                >
                    <p class="text-xs font-semibold tracking-wide text-gray-400 uppercase">PDA screening</p>
                    <dl class="mt-2 grid grid-cols-1 gap-x-8 gap-y-3 text-sm sm:grid-cols-2">
                        <div
                            v-for="row in pdaDisplayRows()"
                            :key="row.label"
                            class="flex items-start justify-between gap-4"
                        >
                            <dt class="text-gray-500">{{ row.label }}</dt>
                            <dd class="text-right font-medium text-gray-800">{{ row.value }}</dd>
                        </div>
                    </dl>
                    <div v-if="conditionLabels().length" class="mt-3 flex flex-wrap items-center gap-1.5">
                        <span class="text-xs font-medium text-gray-500">Conditions</span>
                        <Badge v-for="label in conditionLabels()" :key="label" size="sm" color="primary">
                            {{ label }}
                        </Badge>
                    </div>
                </div>
            </div>

            <form v-else class="space-y-6 p-6" @submit.prevent="saveMedicalHistory">
                <p
                    v-if="form.hasErrors"
                    role="alert"
                    class="rounded-lg bg-status-cancelled/10 px-4 py-3 text-sm font-medium text-status-cancelled"
                >
                    Please review the highlighted fields.
                </p>
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
                    <p v-if="form.errors[q.key]" class="text-xs text-status-cancelled">{{ form.errors[q.key] }}</p>
                    <textarea
                        v-if="q.detailsKey && form[q.key] === 'yes'"
                        v-model="form[q.detailsKey]"
                        :rows="2"
                        :placeholder="`Details for ${q.label.toLowerCase()}…`"
                        class="w-full rounded-lg border border-gray-300 bg-transparent px-4 py-2.5 text-sm text-gray-800 shadow-sm placeholder:text-gray-400 focus:border-brand-300 focus:outline-hidden focus:ring-2 focus:ring-brand-500/10"
                    />
                    <p v-if="q.detailsKey && form.errors[q.detailsKey]" class="text-xs text-status-cancelled">
                        {{ form.errors[q.detailsKey] }}
                    </p>
                </div>

                <div class="space-y-2 rounded-xl border border-gray-100 p-2">
                    <details class="group rounded-lg">
                        <summary
                            class="flex min-h-11 cursor-pointer items-center justify-between gap-3 rounded-lg px-4 py-3 text-sm font-semibold text-gray-800 transition select-none hover:bg-gray-50"
                        >
                            <span>General health</span>
                            <ChevronDown class="h-4 w-4 text-gray-400 transition group-open:rotate-180" />
                        </summary>
                        <div class="space-y-4 border-t border-gray-100 p-3">
                            <template v-for="q in pdaQuestionsIn('general')" :key="q.key">
                                <div class="space-y-2.5">
                                    <div class="flex flex-wrap items-center justify-between gap-3">
                                        <p class="text-sm font-medium text-gray-700">{{ q.label }}</p>
                                        <div
                                            class="inline-flex gap-1 rounded-full bg-gray-100 p-1"
                                            role="radiogroup"
                                            :aria-label="q.label"
                                        >
                                            <button
                                                v-for="answer in pdaAnswers"
                                                :key="answer"
                                                type="button"
                                                role="radio"
                                                :aria-checked="form[q.key] === answer"
                                                :class="[
                                                    'min-h-11 rounded-full px-4 text-sm font-medium transition',
                                                    form[q.key] === answer
                                                        ? 'bg-white text-gray-900 shadow-sm'
                                                        : 'text-gray-500',
                                                ]"
                                                @click="form[q.key] = answer"
                                            >
                                                {{ pdaAnswerLabels[answer] }}
                                            </button>
                                        </div>
                                    </div>
                                    <p v-if="form.errors[q.key]" class="text-xs text-status-cancelled">
                                        {{ form.errors[q.key] }}
                                    </p>
                                    <textarea
                                        v-if="q.detailsKey && form[q.key] === 'yes'"
                                        v-model="form[q.detailsKey]"
                                        :rows="2"
                                        :placeholder="`Details for ${q.label.toLowerCase()}…`"
                                        class="w-full rounded-lg border border-gray-300 bg-transparent px-4 py-2.5 text-sm text-gray-800 shadow-sm placeholder:text-gray-400 focus:border-brand-300 focus:outline-hidden focus:ring-2 focus:ring-brand-500/10"
                                    />
                                    <p v-if="q.detailsKey && form.errors[q.detailsKey]" class="text-xs text-status-cancelled">
                                        {{ form.errors[q.detailsKey] }}
                                    </p>
                                </div>
                            </template>

                            <div>
                                <label class="mb-1.5 block text-sm font-medium text-gray-700">Bleeding time</label>
                                <input
                                    v-model="form.bleeding_time"
                                    type="text"
                                    placeholder="e.g. normal"
                                    class="h-11 w-full rounded-lg border border-gray-300 bg-transparent px-4 py-2.5 text-sm text-gray-800 shadow-sm placeholder:text-gray-400 focus:border-brand-300 focus:outline-hidden focus:ring-2 focus:ring-brand-500/10"
                                    :class="{ 'border-status-cancelled': form.errors.bleeding_time }"
                                />
                                <p v-if="form.errors.bleeding_time" class="mt-1.5 text-xs text-status-cancelled">
                                    {{ form.errors.bleeding_time }}
                                </p>
                            </div>

                            <div>
                                <label for="blood_type" class="mb-1.5 block text-sm font-medium text-gray-700">
                                    Blood type
                                </label>
                                <select
                                    id="blood_type"
                                    v-model="form.blood_type"
                                    class="h-11 w-full rounded-lg border border-gray-300 bg-transparent px-4 py-2.5 text-sm text-gray-800 shadow-sm focus:border-brand-300 focus:outline-hidden focus:ring-2 focus:ring-brand-500/10"
                                    :class="{ 'border-status-cancelled': form.errors.blood_type }"
                                >
                                    <option value="" disabled>Select blood type</option>
                                    <option v-for="type in bloodTypes" :key="type" :value="type">{{ type }}</option>
                                </select>
                                <p v-if="form.errors.blood_type" class="mt-1.5 text-xs text-status-cancelled">
                                    {{ form.errors.blood_type }}
                                </p>
                            </div>

                            <div>
                                <label class="mb-1.5 block text-sm font-medium text-gray-700">Blood pressure</label>
                                <input
                                    v-model="form.blood_pressure"
                                    type="text"
                                    placeholder="e.g. 120/80"
                                    class="h-11 w-full rounded-lg border border-gray-300 bg-transparent px-4 py-2.5 text-sm text-gray-800 shadow-sm placeholder:text-gray-400 focus:border-brand-300 focus:outline-hidden focus:ring-2 focus:ring-brand-500/10"
                                    :class="{ 'border-status-cancelled': form.errors.blood_pressure }"
                                />
                                <p v-if="form.errors.blood_pressure" class="mt-1.5 text-xs text-status-cancelled">
                                    {{ form.errors.blood_pressure }}
                                </p>
                            </div>
                        </div>
                    </details>

                    <details class="group rounded-lg">
                        <summary
                            class="flex min-h-11 cursor-pointer items-center justify-between gap-3 rounded-lg px-4 py-3 text-sm font-semibold text-gray-800 transition select-none hover:bg-gray-50"
                        >
                            <span>Physician</span>
                            <ChevronDown class="h-4 w-4 text-gray-400 transition group-open:rotate-180" />
                        </summary>
                        <div class="space-y-4 border-t border-gray-100 p-3">
                            <div v-for="field in physicianFields" :key="field.key">
                                <label class="mb-1.5 block text-sm font-medium text-gray-700">{{ field.label }}</label>
                                <input
                                    v-model="form[field.key]"
                                    type="text"
                                    class="h-11 w-full rounded-lg border border-gray-300 bg-transparent px-4 py-2.5 text-sm text-gray-800 shadow-sm placeholder:text-gray-400 focus:border-brand-300 focus:outline-hidden focus:ring-2 focus:ring-brand-500/10"
                                    :class="{ 'border-status-cancelled': form.errors[field.key] }"
                                />
                                <p v-if="form.errors[field.key]" class="mt-1.5 text-xs text-status-cancelled">
                                    {{ form.errors[field.key] }}
                                </p>
                            </div>
                        </div>
                    </details>

                    <details class="group rounded-lg">
                        <summary
                            class="flex min-h-11 cursor-pointer items-center justify-between gap-3 rounded-lg px-4 py-3 text-sm font-semibold text-gray-800 transition select-none hover:bg-gray-50"
                        >
                            <span>Dental history</span>
                            <ChevronDown class="h-4 w-4 text-gray-400 transition group-open:rotate-180" />
                        </summary>
                        <div class="space-y-4 border-t border-gray-100 p-3">
                            <div>
                                <label class="mb-1.5 block text-sm font-medium text-gray-700">Previous dentist</label>
                                <input
                                    v-model="form.dental_history_previous_dentist"
                                    type="text"
                                    class="h-11 w-full rounded-lg border border-gray-300 bg-transparent px-4 py-2.5 text-sm text-gray-800 shadow-sm placeholder:text-gray-400 focus:border-brand-300 focus:outline-hidden focus:ring-2 focus:ring-brand-500/10"
                                    :class="{ 'border-status-cancelled': form.errors.dental_history_previous_dentist }"
                                />
                                <p v-if="form.errors.dental_history_previous_dentist" class="mt-1.5 text-xs text-status-cancelled">
                                    {{ form.errors.dental_history_previous_dentist }}
                                </p>
                            </div>
                            <div>
                                <label class="mb-1.5 block text-sm font-medium text-gray-700">Last dental visit</label>
                                <input
                                    v-model="form.dental_history_last_visit"
                                    type="date"
                                    class="h-11 w-full rounded-lg border border-gray-300 bg-transparent px-4 py-2.5 text-sm text-gray-800 shadow-sm placeholder:text-gray-400 focus:border-brand-300 focus:outline-hidden focus:ring-2 focus:ring-brand-500/10"
                                    :class="{ 'border-status-cancelled': form.errors.dental_history_last_visit }"
                                />
                                <p v-if="form.errors.dental_history_last_visit" class="mt-1.5 text-xs text-status-cancelled">
                                    {{ form.errors.dental_history_last_visit }}
                                </p>
                            </div>
                            <div>
                                <label class="mb-1.5 block text-sm font-medium text-gray-700">Referral source</label>
                                <input
                                    v-model="form.referral_source"
                                    type="text"
                                    placeholder="Who may we thank for referring you?"
                                    class="h-11 w-full rounded-lg border border-gray-300 bg-transparent px-4 py-2.5 text-sm text-gray-800 shadow-sm placeholder:text-gray-400 focus:border-brand-300 focus:outline-hidden focus:ring-2 focus:ring-brand-500/10"
                                    :class="{ 'border-status-cancelled': form.errors.referral_source }"
                                />
                                <p v-if="form.errors.referral_source" class="mt-1.5 text-xs text-status-cancelled">
                                    {{ form.errors.referral_source }}
                                </p>
                            </div>
                        </div>
                    </details>

                    <details class="group rounded-lg">
                        <summary
                            class="flex min-h-11 cursor-pointer items-center justify-between gap-3 rounded-lg px-4 py-3 text-sm font-semibold text-gray-800 transition select-none hover:bg-gray-50"
                        >
                            <span>For women only</span>
                            <ChevronDown class="h-4 w-4 text-gray-400 transition group-open:rotate-180" />
                        </summary>
                        <div class="space-y-4 border-t border-gray-100 p-3">
                            <template v-for="q in pdaQuestionsIn('women')" :key="q.key">
                                <div class="space-y-2.5">
                                    <div class="flex flex-wrap items-center justify-between gap-3">
                                        <p class="text-sm font-medium text-gray-700">{{ q.label }}</p>
                                        <div
                                            class="inline-flex gap-1 rounded-full bg-gray-100 p-1"
                                            role="radiogroup"
                                            :aria-label="q.label"
                                        >
                                            <button
                                                v-for="answer in pdaAnswers"
                                                :key="answer"
                                                type="button"
                                                role="radio"
                                                :aria-checked="form[q.key] === answer"
                                                :class="[
                                                    'min-h-11 rounded-full px-4 text-sm font-medium transition',
                                                    form[q.key] === answer
                                                        ? 'bg-white text-gray-900 shadow-sm'
                                                        : 'text-gray-500',
                                                ]"
                                                @click="form[q.key] = answer"
                                            >
                                                {{ pdaAnswerLabels[answer] }}
                                            </button>
                                        </div>
                                    </div>
                                    <p v-if="form.errors[q.key]" class="text-xs text-status-cancelled">
                                        {{ form.errors[q.key] }}
                                    </p>
                                </div>
                            </template>
                        </div>
                    </details>

                    <details class="group rounded-lg">
                        <summary
                            class="flex min-h-11 cursor-pointer items-center justify-between gap-3 rounded-lg px-4 py-3 text-sm font-semibold text-gray-800 transition select-none hover:bg-gray-50"
                        >
                            <span>Medical conditions checklist</span>
                            <ChevronDown class="h-4 w-4 text-gray-400 transition group-open:rotate-180" />
                        </summary>
                        <div class="space-y-3 border-t border-gray-100 p-3">
                            <div class="flex flex-wrap gap-2">
                                <button
                                    v-for="(label, key) in pdaConditionLabels"
                                    :key="key"
                                    type="button"
                                    :aria-pressed="form.conditions_checklist.includes(key)"
                                    :class="[
                                        'min-h-11 min-w-11 rounded-lg border px-4 py-2 text-sm font-medium transition',
                                        form.conditions_checklist.includes(key)
                                            ? 'border-brand-500 bg-brand-50 text-brand-700'
                                            : 'border-gray-200 bg-white text-gray-600 hover:border-gray-300',
                                    ]"
                                    @click="toggleCondition(key)"
                                >
                                    {{ label }}
                                </button>
                            </div>
                            <p v-if="form.errors.conditions_checklist" class="text-xs text-status-cancelled">
                                {{ form.errors.conditions_checklist }}
                            </p>
                        </div>
                    </details>
                </div>

                <div>
                    <label class="mb-1.5 block text-sm font-medium text-gray-700">Remarks</label>
                    <textarea
                        v-model="form.remarks"
                        :rows="3"
                        placeholder="Additional notes…"
                        class="w-full rounded-lg border border-gray-300 bg-transparent px-4 py-2.5 text-sm text-gray-800 shadow-sm placeholder:text-gray-400 focus:border-brand-300 focus:outline-hidden focus:ring-2 focus:ring-brand-500/10"
                    />
                    <p v-if="form.errors.remarks" class="mt-1.5 text-xs text-status-cancelled">{{ form.errors.remarks }}</p>
                </div>

                <div class="flex items-center justify-end gap-2">
                    <Button variant="outline" type="button" @click="editing = false">Cancel</Button>
                    <Button type="submit" :disabled="form.processing">Save</Button>
                </div>
            </form>
        </div>

        <div v-if="can.consultations?.view" class="rounded-2xl border border-gray-200 bg-white shadow-sm">
            <div class="flex flex-wrap items-center justify-between gap-3 border-b border-gray-100 px-6 py-4">
                <div>
                    <h3 class="text-sm font-semibold text-gray-800">Consultations</h3>
                    <p class="mt-0.5 text-xs text-gray-500">
                        {{ consultationCount ? `${consultationCount} on record` : 'No consultations recorded yet' }}
                    </p>
                </div>
                <Button v-if="can.consultations?.create" variant="outline" size="sm" @click="adding = !adding">
                    <Plus class="h-4 w-4" />
                    {{ adding ? 'Cancel' : 'Add consultation' }}
                </Button>
            </div>

            <ConsultationForm
                v-if="adding"
                :patient-id="patient.id"
                :options="consultationOptions"
                class="border-b border-gray-100 p-6"
                @saved="adding = false"
            />

            <div v-if="!consultations.length && !adding" class="px-6 py-10 text-center">
                <p class="text-sm text-gray-500">No consultations yet — add the first one.</p>
            </div>

            <ul v-else class="divide-y divide-gray-100">
                <li v-for="consultation in consultations" :key="consultation.id">
                    <button
                        type="button"
                        class="flex w-full items-center justify-between gap-3 px-6 py-4 text-left"
                        @click="toggleExpanded(consultation.id)"
                    >
                        <div class="flex min-w-0 items-center gap-3">
                            <Badge size="sm" color="light">{{ consultation.consultation_date }}</Badge>
                            <span class="truncate text-sm font-medium text-gray-800">
                                {{ consultation.chief_complaint }}
                            </span>
                        </div>
                        <div class="flex shrink-0 items-center gap-2">
                            <Badge v-if="consultation.diagnosis" size="sm" color="primary">
                                {{ consultation.diagnosis }}
                            </Badge>
                            <span class="hidden text-xs text-gray-500 sm:inline">
                                {{ consultation.dentist?.name ?? '—' }}
                            </span>
                            <ChevronDown
                                class="h-4 w-4 text-gray-400 transition"
                                :class="{ 'rotate-180': expandedId === consultation.id }"
                            />
                        </div>
                    </button>

                    <div
                        v-if="expandedId === consultation.id"
                        class="grid grid-cols-1 gap-x-8 gap-y-4 border-t border-gray-100 bg-gray-50/50 px-6 py-5 sm:grid-cols-2"
                    >
                        <div v-if="consultation.examination_findings">
                            <p class="text-xs font-medium text-gray-500">Examination findings</p>
                            <p class="mt-1 text-sm text-gray-800">{{ consultation.examination_findings }}</p>
                        </div>
                        <div v-if="consultation.treatment_plan">
                            <p class="text-xs font-medium text-gray-500">Treatment plan</p>
                            <p class="mt-1 text-sm text-gray-800">{{ consultation.treatment_plan }}</p>
                        </div>
                        <div v-if="consultation.recommendations">
                            <p class="text-xs font-medium text-gray-500">Recommendations</p>
                            <p class="mt-1 text-sm text-gray-800">{{ consultation.recommendations }}</p>
                        </div>
                        <div v-if="consultation.notes">
                            <p class="text-xs font-medium text-gray-500">Notes</p>
                            <p class="mt-1 text-sm text-gray-800">{{ consultation.notes }}</p>
                        </div>
                        <div v-if="consultation.dentist">
                            <p class="text-xs font-medium text-gray-500">Dentist</p>
                            <p class="mt-1 text-sm text-gray-800">{{ consultation.dentist.name }}</p>
                        </div>
                        <div v-if="pdaRows(consultation).length" class="sm:col-span-2">
                            <p class="text-xs font-semibold tracking-wide text-gray-400 uppercase">
                                Intraoral examination
                            </p>
                            <dl class="mt-2 grid grid-cols-1 gap-x-8 gap-y-3 text-sm sm:grid-cols-2">
                                <div
                                    v-for="row in pdaRows(consultation)"
                                    :key="row.label"
                                    class="flex items-start justify-between gap-4"
                                >
                                    <dt class="text-gray-500">{{ row.label }}</dt>
                                    <dd class="text-right font-medium text-gray-800">{{ row.value }}</dd>
                                </div>
                            </dl>
                        </div>
                    </div>
                </li>
            </ul>
        </div>

        <div class="overflow-hidden rounded-2xl border border-gray-200 bg-white shadow-sm">
            <div class="flex gap-1 border-b border-gray-100 px-4 pt-3">
                <template v-for="tab in tabs" :key="tab.name">
                    <Link
                        v-if="tab.href"
                        :href="tab.href(patient.id)"
                        class="inline-flex items-center gap-2 rounded-t-lg px-4 py-2.5 text-sm font-medium text-gray-700 transition hover:text-brand-600"
                    >
                        <component :is="tab.icon" class="h-4 w-4" />
                        {{ tab.name }}
                        <Badge size="sm" color="light">{{ tab.phase }}</Badge>
                    </Link>
                    <button
                        v-else-if="tab.wired"
                        type="button"
                        :aria-pressed="activeTab === tab.name.toLowerCase()"
                        class="inline-flex items-center gap-2 rounded-t-lg px-4 py-2.5 text-sm font-medium transition"
                        :class="
                            activeTab === tab.name.toLowerCase()
                                ? 'bg-gray-50 text-brand-600'
                                : 'text-gray-700 hover:text-brand-600'
                        "
                        @click="
                            activeTab = activeTab === tab.name.toLowerCase() ? null : tab.name.toLowerCase()
                        "
                    >
                        <component :is="tab.icon" class="h-4 w-4" />
                        {{ tab.name }}
                    </button>
                    <button
                        v-else
                        type="button"
                        disabled
                        :title="`${tab.name} — coming in ${tab.phase}`"
                        class="inline-flex cursor-not-allowed items-center gap-2 rounded-t-lg px-4 py-2.5 text-sm font-medium text-gray-400"
                    >
                        <component :is="tab.icon" class="h-4 w-4" />
                        {{ tab.name }}
                        <Badge size="sm" color="light">{{ tab.phase }}</Badge>
                    </button>
                </template>
            </div>

            <div v-if="activeTab === 'treatments'">
                <div class="flex flex-wrap items-center justify-between gap-3 border-b border-gray-100 px-6 py-4">
                    <div>
                        <h3 class="text-sm font-semibold text-gray-800">Treatment records</h3>
                        <p class="mt-0.5 text-xs text-gray-500">
                            {{ treatments.length ? `${treatments.length} on record` : 'No treatments recorded yet' }}
                        </p>
                    </div>
                    <Button v-if="can.treatments?.create" variant="outline" size="sm" @click="addingTreatment = !addingTreatment">
                        <Plus class="h-4 w-4" />
                        {{ addingTreatment ? 'Cancel' : 'Add treatment' }}
                    </Button>
                </div>

                <TreatmentForm
                    v-if="addingTreatment"
                    :patient-id="patient.id"
                    :consultations="consultations"
                    :tooth-options="toothOptions"
                    class="border-b border-gray-100 p-6"
                    @saved="addingTreatment = false"
                />

                <div v-if="!treatments.length && !addingTreatment" class="px-6 py-10 text-center">
                    <p class="text-sm text-gray-500">No treatments yet — add the first one.</p>
                </div>

                <ul v-else class="divide-y divide-gray-100">
                    <li v-for="treatment in treatments" :key="treatment.id">
                        <button
                            type="button"
                            class="flex w-full items-center justify-between gap-3 px-6 py-4 text-left"
                            @click="toggleExpandedTreatment(treatment.id)"
                        >
                            <div class="flex min-w-0 items-center gap-3">
                                <Badge size="sm" color="light">{{ treatment.treatment_date }}</Badge>
                                <span class="truncate text-sm font-medium text-gray-800">
                                    {{ treatment.procedure_name }}
                                </span>
                            </div>
                            <div class="flex shrink-0 items-center gap-2">
                                <Badge v-if="treatment.tooth_number" size="sm" color="primary">
                                    Tooth {{ treatment.tooth_number }}
                                </Badge>
                                <Badge size="sm" :color="treatment.signed_at ? 'success' : 'warning'">
                                    {{ treatment.signed_at ? 'Signed' : 'Pending' }}
                                </Badge>
                                <span class="hidden text-xs text-gray-500 sm:inline">
                                    {{ treatment.dentist?.name ?? '—' }}
                                </span>
                                <ChevronDown
                                    class="h-4 w-4 text-gray-400 transition"
                                    :class="{ 'rotate-180': expandedTreatmentId === treatment.id }"
                                />
                            </div>
                        </button>

                        <div
                            v-if="expandedTreatmentId === treatment.id"
                            class="space-y-4 border-t border-gray-100 bg-gray-50/50 px-6 py-5"
                        >
                            <div v-if="treatment.description">
                                <p class="text-xs font-medium text-gray-500">Description</p>
                                <p class="mt-1 text-sm text-gray-800">{{ treatment.description }}</p>
                            </div>
                            <div v-if="treatment.notes">
                                <p class="text-xs font-medium text-gray-500">Notes</p>
                                <p class="mt-1 text-sm text-gray-800">{{ treatment.notes }}</p>
                            </div>
                            <div v-if="treatment.consultation">
                                <p class="text-xs font-medium text-gray-500">Linked consultation</p>
                                <p class="mt-1 text-sm text-gray-800">
                                    {{ treatment.consultation.chief_complaint }}
                                </p>
                            </div>
                            <div v-if="treatment.signed_at">
                                <p class="text-xs font-medium text-gray-500">Dentist signature</p>
                                <img
                                    v-if="treatment.signature_path"
                                    :src="'/storage/' + treatment.signature_path"
                                    :alt="`Signature for ${treatment.procedure_name}`"
                                    class="mt-2 max-h-40 rounded-lg border border-gray-200 bg-white"
                                />
                                <p class="mt-2 text-xs text-gray-500">
                                    Signed {{ formatSignedAt(treatment.signed_at) }} by
                                    {{ treatment.dentist?.name ?? 'the attending dentist' }}
                                </p>
                            </div>
                            <div v-else-if="can.treatments?.sign" class="flex justify-end">
                                <Button size="sm" @click="openSign(treatment)">
                                    <Signature class="h-4 w-4" />
                                    Sign treatment
                                </Button>
                            </div>
                        </div>
                    </li>
                </ul>
            </div>

            <div v-else class="flex flex-col items-center gap-2 px-6 py-14 text-center">
                <p class="text-sm font-medium text-gray-700">No records yet</p>
                <p class="text-sm text-gray-500">
                    Appointments, files, and consents will appear here in later phases.
                </p>
            </div>
        </div>

        <SignaturePadModal
            :show="signModalOpen"
            title="Sign treatment"
            confirm-label="Accept signature"
            @close="closeSign"
            @confirm="confirmSign"
        />
    </div>
</template>
