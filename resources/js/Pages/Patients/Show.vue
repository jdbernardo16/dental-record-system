<script setup>
import { computed, onMounted, onUnmounted, ref } from 'vue'
import { Head, Link, router, useForm } from '@inertiajs/vue3'
import { CalendarDays, ChevronDown, ChevronLeft, ChevronRight, FileText, FlaskConical, Folder, FolderOpen, Image as ImageIcon, Paperclip, Pencil, Plus, Scan, Signature, Stethoscope, Trash2, Upload, Wrench } from 'lucide-vue-next'
import { route } from '../../../../vendor/tightenco/ziggy'
import AppLayout from '@/Layouts/AppLayout.vue'
import AttachmentPreviewModal from '@/Components/AttachmentPreviewModal.vue'
import Badge from '@/Components/Badge.vue'
import { Button } from '@/Components/ui/button'
import { SelectField, TextareaField } from '@/Components/Fields'
import ConsultationForm from '@/Components/Wizard/ConsultationForm.vue'
import MedicalHistoryForm from '@/Components/Wizard/MedicalHistoryForm.vue'
import SignaturePadModal from '@/Components/SignaturePadModal.vue'
import ToothChart from '@/Components/ToothChart.vue'
import TreatmentForm from '@/Components/Wizard/TreatmentForm.vue'
import { useToastStore } from '@/Stores/toast'
import { scrollToFirstError } from '@/lib/scroll'

defineOptions({ layout: AppLayout })

const props = defineProps({
    patient: { type: Object, required: true },
    medicalHistory: { type: Object, default: null },
    consultations: { type: Object, default: () => ({ data: [], current_page: 1, last_page: 1, prev_page_url: null, next_page_url: null, total: 0 }) },
    consultationCount: { type: Number, default: 0 },
    consultationOptions: { type: Object, default: () => ({}) },
    treatments: { type: Object, default: () => ({ data: [], current_page: 1, last_page: 1, prev_page_url: null, next_page_url: null, total: 0 }) },
    toothOptions: { type: Array, default: () => [] },
    consentForms: { type: Object, default: () => ({ data: [], current_page: 1, last_page: 1, prev_page_url: null, next_page_url: null, total: 0 }) },
    attachments: { type: Object, default: () => ({ data: [], current_page: 1, last_page: 1, prev_page_url: null, next_page_url: null, total: 0 }) },
    attachmentOptions: { type: Object, default: () => ({}) },
    appointments: { type: Object, default: () => ({ data: [], current_page: 1, last_page: 1, prev_page_url: null, next_page_url: null, total: 0 }) },
    chartState: { type: Object, default: () => ({}) },
    chartOptions: { type: Object, default: () => ({}) },
    chartEntryCount: { type: Number, default: 0 },
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

const answerLabels = { no: 'No', yes: 'Yes', not_applicable: 'N/A' }

const answerBadgeColor = (value) =>
    value === 'yes' ? 'success' : value === 'not_applicable' ? 'warning' : 'light'

const pdaAnswerLabels = { no: 'No', yes: 'Yes' }

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

const detailedAnswers = () =>
    questions.filter(
        (q) => q.detailsKey && props.medicalHistory?.[q.key] === 'yes' && props.medicalHistory?.[q.detailsKey],
    )

const editing = ref(false)

const conditionLabels = () =>
    (props.medicalHistory?.conditions_checklist ?? []).map((key) => pdaConditionLabels[key] ?? key)

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

const confirmDelete = () => {
    if (window.confirm(`Delete ${fullName()}? The record can be restored by an administrator.`)) {
        router.delete(route('patients.destroy', props.patient.id), {
            onSuccess: () => toastStore.show('Patient deleted.'),
            onError: () => scrollToFirstError(),
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
    { name: 'Appointments', icon: CalendarDays, wired: true },
    { name: 'Chart', icon: Stethoscope, wired: true },
    { name: 'Treatments', icon: Wrench, wired: true },
    { name: 'Files', icon: FolderOpen, wired: true },
    { name: 'Consents', icon: FileText, wired: true },
]

const activeTab = ref(null)
const addingTreatment = ref(false)
const expandedTreatmentId = ref(null)

const VALID_TABS = ['appointments', 'chart', 'treatments', 'files', 'consents']

const tabFromUrl = (url) => {
    const tab = new URL(url, window.location.origin).searchParams.get('tab')
    return VALID_TABS.includes(tab) ? tab : null
}

onMounted(() => {
    activeTab.value = tabFromUrl(window.location.href)
})

const syncTabFromUrl = (event) => {
    activeTab.value = tabFromUrl(event.detail.page.url)
}

const removeNavigateListener = router.on('navigate', syncTabFromUrl)

onUnmounted(removeNavigateListener)

const LIST_TABS = {
    appointments: 'appointments',
    treatments: 'treatments',
    files: 'attachments', // prop name
    consents: 'consentForms',
}

const openTab = (tab) => {
    if (tab === activeTab.value) {
        activeTab.value = null // toggle-close
        const url = new URL(window.location.href)
        url.searchParams.delete('tab')
        history.replaceState(history.state, '', url.pathname + url.search)
        return
    }
    activeTab.value = tab
    if (tab === 'chart' || !LIST_TABS[tab]) return // chart is canvas-only, no server fetch
    router.get(route('patients.show', { patient: props.patient.id, tab }), {}, {
        only: [LIST_TABS[tab]],
        preserveState: true,
        preserveScroll: true,
    })
}

const PAGE_PARAMS = {
    consultations: 'consultations_page',
    appointments: 'appointments_page',
    treatments: 'treatments_page',
    attachments: 'files_page',
    consentForms: 'consents_page',
}

const goToListPage = (propName, page) => {
    const url = new URL(window.location.href)
    url.searchParams.set(PAGE_PARAMS[propName], String(page))
    router.get(url.pathname + url.search, {}, { only: [propName], preserveState: true, preserveScroll: true })
}

/* ---------------------------------------------------------------- Appointments tab */

const appointmentStatusLabels = {
    pending: 'Pending',
    confirmed: 'Confirmed',
    completed: 'Completed',
    cancelled: 'Cancelled',
    no_show: 'No-show',
}

const appointmentBadgeColors = {
    pending: 'warning',
    confirmed: 'info',
    completed: 'success',
    cancelled: 'light',
    no_show: 'error',
}

const appointmentStatusLabel = (status) => appointmentStatusLabels[status] ?? status

const appointmentBadgeColor = (status) => appointmentBadgeColors[status] ?? 'light'

const appointmentTimeRange = (appointment) =>
    appointment.end_time ? `${appointment.start_time} – ${appointment.end_time}` : appointment.start_time

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
            scrollToFirstError()
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

/* ---------------------------------------------------------------- Consents tab */

const consentSignModalOpen = ref(false)
const signingConsent = ref(null)

const consentSignForm = useForm({
    signature_svg: '',
})

const consentStatusBadgeColor = (status) =>
    ({
        unsigned: 'warning',
        patient_signed: 'info',
        signed: 'success',
        voided: 'error',
    })[status] ?? 'light'

const openConsentSign = (consentForm) => {
    signingConsent.value = consentForm
    consentSignModalOpen.value = true
}

const confirmConsentSign = (svg) => {
    consentSignForm.signature_svg = svg
    consentSignForm.post(route('consents.dentist-sign', signingConsent.value.id), {
        onError: () => scrollToFirstError(),
        preserveScroll: true,
        onSuccess: () => {
            consentSignModalOpen.value = false
            consentSignForm.reset()
            signingConsent.value = null
            toastStore.show('Consent countersigned by the dentist.')
        },
        onError: () => {
            toastStore.show('Signing failed — please try again.', 'error')
        },
    })
}

const closeConsentSign = () => {
    consentSignModalOpen.value = false
    signingConsent.value = null
}

const formatConsentDate = (value) => {
    if (!value) return '—'
    return new Date(value).toLocaleDateString()
}

/* ---------------------------------------------------------------- Files tab */

const categoryIcons = {
    image: ImageIcon,
    pdf: FileText,
    xray: Scan,
    prescription: FileText,
    laboratory: FlaskConical,
    document: Folder,
    other: Paperclip,
}

const categoryLabels = Object.fromEntries(
    Object.entries(props.attachmentOptions?.categories ?? {}).map(([value, meta]) => [value, meta.label]),
)

const xrayLabels = Object.fromEntries(
    (props.attachmentOptions?.xrayTypes ?? []).map((type) => [
        type,
        type.replace(/_/g, ' ').replace(/\b\w/g, (char) => char.toUpperCase()),
    ]),
)

const categoryOptions = computed(() =>
    Object.entries(props.attachmentOptions?.categories ?? {}).map(([value, meta]) => ({
        value,
        label: meta.label,
    })),
)

const xrayOptions = computed(() =>
    (props.attachmentOptions?.xrayTypes ?? []).map((type) => ({ value: type, label: xrayLabels[type] })),
)

const activeCategory = ref('all')

const filteredAttachments = computed(() =>
    activeCategory.value === 'all'
        ? props.attachments.data
        : props.attachments.data.filter((attachment) => attachment.category === activeCategory.value),
)

const isImageTile = (attachment) => ['image', 'xray'].includes(attachment.category)

const tileCaption = (attachment) =>
    attachment.category === 'xray'
        ? (xrayLabels[attachment.xray_type] ?? 'X-ray')
        : (categoryLabels[attachment.category] ?? attachment.category)

const showUploadForm = ref(false)
const uploadProgress = ref(0)
const fileInput = ref(null)

const uploadForm = useForm({
    file: null,
    category: 'image',
    xray_type: '',
    notes: '',
})

const onFileChange = (event) => {
    uploadForm.file = event.target.files[0] ?? null
}

const submitUpload = () => {
    uploadForm.post(route('attachments.store', props.patient.id), {
        onError: () => scrollToFirstError(),
        preserveScroll: true,
        onProgress: (event) => {
            uploadProgress.value = event.percentage ?? 0
        },
        onSuccess: () => {
            toastStore.show('Attachment uploaded.')
            uploadForm.reset()
            uploadProgress.value = 0
            if (fileInput.value) fileInput.value.value = ''
            showUploadForm.value = false
        },
        onError: () => {
            toastStore.show('Upload failed — please review the form.', 'error')
        },
    })
}

const previewAttachment = ref(null)

const openPreview = (attachment) => {
    previewAttachment.value = attachment
}

const confirmDeleteAttachment = (attachment) => {
    if (window.confirm(`Delete ${attachment.original_name}? This can be restored by an administrator.`)) {
        router.delete(route('attachments.destroy', attachment.id), {
            preserveScroll: true,
            onSuccess: () => {
                previewAttachment.value = null
                toastStore.show('Attachment deleted.')
            },
        })
    }
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
                <Link :href="route('patients.export', patient.id)">
                    <Button variant="outline" size="sm">
                        <FileText class="h-4 w-4" />
                        Export
                    </Button>
                </Link>
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
                <Button v-if="can.medicalHistory?.edit" variant="outline" size="sm" @click="editing = true">
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

            <MedicalHistoryForm
                v-else
                :patient-id="patient.id"
                :medical-history="medicalHistory"
                class="space-y-6 p-6"
                @saved="editing = false"
                @cancel="editing = false"
            />
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

            <div v-if="!consultations.data.length && !adding" class="px-6 py-10 text-center">
                <p class="text-sm text-gray-500">No consultations yet — add the first one.</p>
            </div>

            <ul v-else class="divide-y divide-gray-100">
                <li v-for="consultation in consultations.data" :key="consultation.id">
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

            <div
                v-if="consultations.last_page > 1"
                class="flex items-center justify-between border-t border-gray-100 px-6 py-4"
            >
                <span class="text-sm text-gray-500">
                    Page {{ consultations.current_page }} of {{ consultations.last_page }}
                </span>
                <div class="flex items-center gap-2">
                    <Button
                        variant="outline"
                        size="sm"
                        :disabled="!consultations.prev_page_url"
                        aria-label="Previous page"
                        @click="goToListPage('consultations', consultations.current_page - 1)"
                    >
                        <ChevronLeft class="h-4 w-4" />
                    </Button>
                    <Button
                        variant="outline"
                        size="sm"
                        :disabled="!consultations.next_page_url"
                        aria-label="Next page"
                        @click="goToListPage('consultations', consultations.current_page + 1)"
                    >
                        <ChevronRight class="h-4 w-4" />
                    </Button>
                </div>
            </div>
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
                        @click="openTab(tab.name.toLowerCase())"
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

            <div v-if="activeTab === 'appointments'">
                <div class="flex flex-wrap items-center justify-between gap-3 border-b border-gray-100 px-6 py-4">
                    <div>
                        <h3 class="text-sm font-semibold text-gray-800">Appointments</h3>
                        <p class="mt-0.5 text-xs text-gray-500">
                            {{ appointments.total ? `${appointments.total} on record` : 'No appointments on record' }}
                        </p>
                    </div>
                    <Link v-if="can.appointments?.view" :href="route('appointments.index')">
                        <Button variant="outline" size="sm">View calendar</Button>
                    </Link>
                </div>

                <div v-if="!appointments.data.length" class="px-6 py-10 text-center">
                    <p class="text-sm text-gray-500">No appointments yet — schedule one from the calendar.</p>
                </div>

                <ul v-else class="divide-y divide-gray-100">
                    <li v-for="appointment in appointments.data" :key="appointment.id">
                        <div class="flex flex-wrap items-center justify-between gap-3 px-6 py-4">
                            <div class="flex min-w-0 flex-wrap items-center gap-2">
                                <Badge size="sm" color="light">{{ appointment.appointment_date }}</Badge>
                                <span class="text-sm font-medium text-gray-800">
                                    {{ appointmentTimeRange(appointment) }}
                                </span>
                                <span class="min-w-0 truncate text-sm text-gray-600">
                                    {{ appointment.reason || 'No reason given' }}
                                </span>
                            </div>
                            <div class="flex shrink-0 items-center gap-2">
                                <span class="text-xs text-gray-500">
                                    {{ appointment.dentist?.name ?? '—' }}
                                </span>
                                <Badge size="sm" :color="appointmentBadgeColor(appointment.status)">
                                    {{ appointmentStatusLabel(appointment.status) }}
                                </Badge>
                            </div>
                        </div>
                    </li>
                </ul>

                <div
                    v-if="appointments.last_page > 1"
                    class="flex items-center justify-between border-t border-gray-100 px-6 py-4"
                >
                    <span class="text-sm text-gray-500">
                        Page {{ appointments.current_page }} of {{ appointments.last_page }}
                    </span>
                    <div class="flex items-center gap-2">
                        <Button
                            variant="outline"
                            size="sm"
                            :disabled="!appointments.prev_page_url"
                            aria-label="Previous page"
                            @click="goToListPage('appointments', appointments.current_page - 1)"
                        >
                            <ChevronLeft class="h-4 w-4" />
                        </Button>
                        <Button
                            variant="outline"
                            size="sm"
                            :disabled="!appointments.next_page_url"
                            aria-label="Next page"
                            @click="goToListPage('appointments', appointments.current_page + 1)"
                        >
                            <ChevronRight class="h-4 w-4" />
                        </Button>
                    </div>
                </div>
            </div>

            <div v-else-if="activeTab === 'chart'">
                <div class="flex flex-wrap items-center justify-between gap-3 border-b border-gray-100 px-6 py-4">
                    <div>
                        <h3 class="text-sm font-semibold text-gray-800">Dental chart</h3>
                        <p class="mt-0.5 text-xs text-gray-500">
                            {{ chartEntryCount ? `${chartEntryCount} ${chartEntryCount === 1 ? 'entry' : 'entries'} on record` : 'No chart entries recorded yet' }}
                        </p>
                    </div>
                    <Link v-if="can.chart?.view" :href="route('patients.chart', patient.id)">
                        <Button variant="outline" size="sm">
                            {{ can.chart?.update ? 'Open chart editor' : 'Open chart' }}
                        </Button>
                    </Link>
                </div>

                <div v-if="chartEntryCount" class="bg-gray-50/50 p-4 sm:p-6">
                    <ToothChart
                        :state="chartState"
                        dentition="adult"
                        readonly
                        :options="chartOptions"
                    />
                </div>
                <div v-else class="px-6 py-10 text-center">
                    <p class="text-sm text-gray-500">No chart entries yet — open the chart editor to record the first finding.</p>
                </div>
            </div>

            <div v-else-if="activeTab === 'treatments'">
                <div class="flex flex-wrap items-center justify-between gap-3 border-b border-gray-100 px-6 py-4">
                    <div>
                        <h3 class="text-sm font-semibold text-gray-800">Treatment records</h3>
                        <p class="mt-0.5 text-xs text-gray-500">
                            {{ treatments.total ? `${treatments.total} on record` : 'No treatments recorded yet' }}
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
                    :consultations="consultations.data"
                    :tooth-options="toothOptions"
                    class="border-b border-gray-100 p-6"
                    @saved="addingTreatment = false"
                />

                <div v-if="!treatments.data.length && !addingTreatment" class="px-6 py-10 text-center">
                    <p class="text-sm text-gray-500">No treatments yet — add the first one.</p>
                </div>

                <ul v-else class="divide-y divide-gray-100">
                    <li v-for="treatment in treatments.data" :key="treatment.id">
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

                <div
                    v-if="treatments.last_page > 1"
                    class="flex items-center justify-between border-t border-gray-100 px-6 py-4"
                >
                    <span class="text-sm text-gray-500">
                        Page {{ treatments.current_page }} of {{ treatments.last_page }}
                    </span>
                    <div class="flex items-center gap-2">
                        <Button
                            variant="outline"
                            size="sm"
                            :disabled="!treatments.prev_page_url"
                            aria-label="Previous page"
                            @click="goToListPage('treatments', treatments.current_page - 1)"
                        >
                            <ChevronLeft class="h-4 w-4" />
                        </Button>
                        <Button
                            variant="outline"
                            size="sm"
                            :disabled="!treatments.next_page_url"
                            aria-label="Next page"
                            @click="goToListPage('treatments', treatments.current_page + 1)"
                        >
                            <ChevronRight class="h-4 w-4" />
                        </Button>
                    </div>
                </div>
            </div>

            <div v-else-if="activeTab === 'consents'">
                <div class="flex flex-wrap items-center justify-between gap-3 border-b border-gray-100 px-6 py-4">
                    <div>
                        <h3 class="text-sm font-semibold text-gray-800">Consent forms</h3>
                        <p class="mt-0.5 text-xs text-gray-500">
                            {{ consentForms.total ? `${consentForms.total} on record` : 'No consent forms on record' }}
                        </p>
                    </div>
                    <Link
                        v-if="can.consents?.create"
                        :href="route('wizard.index', patient.id)"
                        class="inline-flex"
                    >
                        <Button variant="outline" size="sm">
                            <FileText class="h-4 w-4" />
                            New waiver
                        </Button>
                    </Link>
                </div>

                <div v-if="!consentForms.data.length" class="px-6 py-10 text-center">
                    <p class="text-sm text-gray-500">
                        No consents yet — start the waiver from here, or through the intake wizard.
                    </p>
                </div>

                <ul v-else class="divide-y divide-gray-100">
                    <li v-for="consentForm in consentForms.data" :key="consentForm.id">
                        <div class="flex flex-wrap items-center justify-between gap-3 px-6 py-4">
                            <div class="flex min-w-0 flex-wrap items-center gap-2">
                                <Badge size="sm" color="light">{{ formatConsentDate(consentForm.created_at) }}</Badge>
                                <Badge size="sm" color="primary">v{{ consentForm.version }}</Badge>
                                <Badge size="sm" :color="consentStatusBadgeColor(consentForm.status)">{{ consentForm.status }}</Badge>
                            </div>
                            <div class="flex shrink-0 items-center gap-2">
                                <Link :href="route('consents.show', consentForm.id)">
                                    <Button variant="outline" size="sm">View</Button>
                                </Link>
                                <Button
                                    v-if="consentForm.status === 'patient_signed' && can.consents?.['sign-dentist']"
                                    size="sm"
                                    @click="openConsentSign(consentForm)"
                                >
                                    <Signature class="h-4 w-4" />
                                    Dentist sign
                                </Button>
                            </div>
                        </div>
                    </li>
                </ul>

                <div
                    v-if="consentForms.last_page > 1"
                    class="flex items-center justify-between border-t border-gray-100 px-6 py-4"
                >
                    <span class="text-sm text-gray-500">
                        Page {{ consentForms.current_page }} of {{ consentForms.last_page }}
                    </span>
                    <div class="flex items-center gap-2">
                        <Button
                            variant="outline"
                            size="sm"
                            :disabled="!consentForms.prev_page_url"
                            aria-label="Previous page"
                            @click="goToListPage('consentForms', consentForms.current_page - 1)"
                        >
                            <ChevronLeft class="h-4 w-4" />
                        </Button>
                        <Button
                            variant="outline"
                            size="sm"
                            :disabled="!consentForms.next_page_url"
                            aria-label="Next page"
                            @click="goToListPage('consentForms', consentForms.current_page + 1)"
                        >
                            <ChevronRight class="h-4 w-4" />
                        </Button>
                    </div>
                </div>
            </div>

            <div v-else-if="activeTab === 'files'">
                <div class="flex flex-wrap items-center justify-between gap-3 border-b border-gray-100 px-6 py-4">
                    <div>
                        <h3 class="text-sm font-semibold text-gray-800">Files &amp; attachments</h3>
                        <p class="mt-0.5 text-xs text-gray-500">
                            {{ attachments.total ? `${attachments.total} on record` : 'No attachments on record yet' }}
                        </p>
                    </div>
                    <Button
                        v-if="can.attachments?.upload"
                        variant="outline"
                        size="sm"
                        @click="showUploadForm = !showUploadForm"
                    >
                        <Upload class="h-4 w-4" />
                        {{ showUploadForm ? 'Cancel' : 'Upload file' }}
                    </Button>
                </div>

                <form
                    v-if="showUploadForm"
                    class="space-y-5 border-b border-gray-100 bg-gray-50/50 p-6"
                    @submit.prevent="submitUpload"
                >
                    <div class="grid grid-cols-1 gap-5 sm:grid-cols-2">
                        <div class="sm:col-span-2">
                            <label for="attachment_file" class="mb-1.5 block text-sm font-medium text-gray-700">
                                File
                                <span class="text-status-cancelled">*</span>
                            </label>
                            <input
                                id="attachment_file"
                                ref="fileInput"
                                type="file"
                                accept=".jpg,.jpeg,.png,.gif,.webp,.pdf"
                                class="block w-full text-sm text-gray-500 file:mr-3 file:rounded-lg file:border-0 file:bg-brand-50 file:px-4 file:py-2.5 file:text-sm file:font-medium file:text-brand-700 hover:file:bg-brand-100"
                                @change="onFileChange"
                            />
                            <p v-if="uploadForm.errors.file" class="mt-1.5 text-xs text-status-cancelled">
                                {{ uploadForm.errors.file }}
                            </p>
                        </div>

                        <div>
                            <SelectField
                                v-model="uploadForm.category"
                                label="Category"
                                :error="uploadForm.errors.category"
                                :options="categoryOptions"
                            />
                        </div>

                        <div v-if="uploadForm.category === 'xray'">
                            <SelectField
                                v-model="uploadForm.xray_type"
                                label="X-ray type"
                                placeholder="Select type…"
                                :error="uploadForm.errors.xray_type"
                                :options="xrayOptions"
                            />
                        </div>

                        <div class="sm:col-span-2">
                            <TextareaField
                                v-model="uploadForm.notes"
                                label="Notes"
                                :rows="2"
                                placeholder="Optional notes about this file…"
                                :error="uploadForm.errors.notes"
                            />
                        </div>
                    </div>

                    <div class="flex flex-wrap items-center gap-4">
                        <Button type="submit" :disabled="uploadForm.processing">
                            {{ uploadForm.processing ? 'Uploading…' : 'Upload' }}
                        </Button>
                        <div class="flex min-w-48 flex-1 items-center gap-3">
                            <div v-if="uploadProgress > 0" class="h-1.5 flex-1 rounded-full bg-gray-100">
                                <div
                                    class="h-full rounded-full bg-brand-500 transition-all"
                                    :style="{ width: uploadProgress + '%' }"
                                />
                            </div>
                            <span v-if="uploadProgress > 0" class="w-10 text-right text-xs font-medium text-gray-500">
                                {{ Math.round(uploadProgress) }}%
                            </span>
                        </div>
                    </div>
                </form>

                <div class="flex flex-wrap items-center gap-2 border-b border-gray-100 px-6 py-4">
                    <button
                        type="button"
                        class="rounded-full px-4 py-2 text-sm font-medium transition"
                        :class="activeCategory === 'all' ? 'bg-brand-500 text-white' : 'bg-gray-100 text-gray-600 hover:bg-gray-200'"
                        @click="activeCategory = 'all'"
                    >
                        All
                    </button>
                    <button
                        v-for="(meta, value) in attachmentOptions?.categories ?? {}"
                        :key="value"
                        type="button"
                        class="rounded-full px-4 py-2 text-sm font-medium transition"
                        :class="activeCategory === value ? 'bg-brand-500 text-white' : 'bg-gray-100 text-gray-600 hover:bg-gray-200'"
                        @click="activeCategory = value"
                    >
                        {{ meta.label }}
                    </button>
                </div>

                <div v-if="!filteredAttachments.length" class="px-6 py-10 text-center">
                    <p class="text-sm text-gray-500">No files here yet — upload the first attachment.</p>
                </div>

                <ul v-else class="grid grid-cols-2 gap-4 p-6 sm:grid-cols-3 md:grid-cols-4">
                    <li v-for="attachment in filteredAttachments" :key="attachment.id">
                        <button
                            type="button"
                            class="w-full rounded-xl border border-gray-200 bg-white p-3 text-left transition hover:border-brand-300 hover:shadow-sm"
                            @click="openPreview(attachment)"
                        >
                            <div class="flex h-24 w-24 items-center justify-center overflow-hidden rounded-lg bg-gray-50">
                                <img
                                    v-if="isImageTile(attachment)"
                                    :src="attachment.storage_url"
                                    :alt="attachment.original_name"
                                    class="h-24 w-24 rounded-lg object-cover"
                                />
                                <component
                                    :is="categoryIcons[attachment.category] ?? Paperclip"
                                    v-else
                                    class="h-10 w-10 text-gray-400"
                                />
                            </div>
                            <p class="mt-2 truncate text-sm font-medium text-gray-800">{{ attachment.original_name }}</p>
                            <p class="text-xs text-gray-500">{{ tileCaption(attachment) }}</p>
                        </button>
                    </li>
                </ul>

                <div
                    v-if="attachments.last_page > 1"
                    class="flex items-center justify-between border-t border-gray-100 px-6 py-4"
                >
                    <span class="text-sm text-gray-500">
                        Page {{ attachments.current_page }} of {{ attachments.last_page }}
                    </span>
                    <div class="flex items-center gap-2">
                        <Button
                            variant="outline"
                            size="sm"
                            :disabled="!attachments.prev_page_url"
                            aria-label="Previous page"
                            @click="goToListPage('attachments', attachments.current_page - 1)"
                        >
                            <ChevronLeft class="h-4 w-4" />
                        </Button>
                        <Button
                            variant="outline"
                            size="sm"
                            :disabled="!attachments.next_page_url"
                            aria-label="Next page"
                            @click="goToListPage('attachments', attachments.current_page + 1)"
                        >
                            <ChevronRight class="h-4 w-4" />
                        </Button>
                    </div>
                </div>
            </div>

            <div v-else class="flex flex-col items-center gap-2 px-6 py-14 text-center">
                <p class="text-sm font-medium text-gray-700">No records yet</p>
                <p class="text-sm text-gray-500">
                    Records from each section will appear here. Select a tab to get started.
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

        <SignaturePadModal
            :show="consentSignModalOpen"
            title="Countersign consent form"
            confirm-label="Accept signature"
            @close="closeConsentSign"
            @confirm="confirmConsentSign"
        />

        <AttachmentPreviewModal
            :show="previewAttachment !== null"
            :attachment="previewAttachment"
            :category-labels="categoryLabels"
            :xray-labels="xrayLabels"
            :can-delete="can.attachments?.delete"
            @close="previewAttachment = null"
            @delete="confirmDeleteAttachment"
        />
    </div>
</template>
