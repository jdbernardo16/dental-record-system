<script setup>
import { computed } from 'vue'
import { Head, router } from '@inertiajs/vue3'
import { ArrowLeft, Printer } from 'lucide-vue-next'
import { route } from '../../../../vendor/tightenco/ziggy'
import ToothChart from '@/Components/ToothChart.vue'
import { useToastStore } from '@/Stores/toast'

// Standalone A4 document layout (no app shell) so printing is clean.
defineOptions({ layout: null })

const props = defineProps({
    patient: { type: Object, required: true },
    canViewClinical: { type: Object, default: () => ({}) },
    medicalHistory: { type: Object, default: null },
    consultations: { type: Array, default: () => [] },
    chartState: { type: Object, default: null },
    chartHistory: { type: Array, default: () => [] },
    treatments: { type: Array, default: () => [] },
    consentForms: { type: Array, default: () => [] },
    attachments: { type: Array, default: () => [] },
    options: { type: Object, default: () => ({}) },
    clinic: { type: Object, default: () => ({}) },
    exportedAt: { type: String, default: '' },
})

const toastStore = useToastStore()

const fullName = computed(() =>
    [props.patient.first_name, props.patient.middle_name, props.patient.last_name].filter(Boolean).join(' '),
)

const sexLabel = computed(() => ({ male: 'Male', female: 'Female' })[props.patient.sex] ?? props.patient.sex)

const storageUrl = (path) => (path ? `/storage/${path}` : null)

const formatDate = (value) => {
    if (!value) return '—'
    const date = new Date(value)
    if (Number.isNaN(date.getTime())) return String(value)
    return date.toLocaleDateString('en-PH', { year: 'numeric', month: 'short', day: 'numeric' })
}

const formatDateTime = (value) => {
    if (!value) return '—'
    const date = new Date(value)
    if (Number.isNaN(date.getTime())) return String(value)
    return date.toLocaleString('en-PH', { year: 'numeric', month: 'short', day: 'numeric', hour: 'numeric', minute: '2-digit' })
}

const conditionLabel = (key) => props.options.conditions?.[key]?.label ?? key
const restorationLabel = (key) => props.options.restorations?.[key]?.label ?? key
const surfaceLabel = (key) => props.options.surfaces?.[key]?.label ?? key

const chartEntryRows = computed(() =>
    props.chartHistory.map((entry) => ({
        date: entry.recorded_at,
        tooth: entry.tooth_number,
        dentition: entry.dentition,
        condition: conditionLabel(entry.condition),
        restoration: entry.restoration_type ? restorationLabel(entry.restoration_type) : null,
        surface: entry.surface ? surfaceLabel(entry.surface) : 'Whole tooth',
        notes: entry.notes,
        by: entry.recorded_by?.name ?? '—',
    })),
)

const primaryHasEntries = computed(
    () => Object.keys(props.chartState?.primary ?? {}).length > 0,
)

const historyQuestions = [
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

const pdaDisplayRows = () => {
    const rows = []
    const h = props.medicalHistory ?? {}
    const add = (label, value) => {
        if (value !== null && value !== undefined && value !== '') rows.push({ label, value })
    }
    add('Good health', h.good_health === 'yes' ? 'Yes' : h.good_health === 'no' ? 'No' : h.good_health)
    add('Under medical treatment', h.under_medical_treatment === 'yes' ? 'Yes' : h.under_medical_treatment === 'no' ? 'No' : h.under_medical_treatment)
    add('Medical treatment details', h.medical_treatment_details)
    add('Hospitalized', h.hospitalized === 'yes' ? 'Yes' : h.hospitalized === 'no' ? 'No' : h.hospitalized)
    add('Hospitalization details', h.hospitalization_details)
    add('Bleeding time', h.bleeding_time)
    add('Blood type', h.blood_type)
    add('Blood pressure', h.blood_pressure)
    add('Drug use', h.drug_use === 'yes' ? 'Yes' : h.drug_use === 'no' ? 'No' : h.drug_use)
    add('Drug use details', h.drug_use_details)
    add('Nursing', h.nursing === 'yes' ? 'Yes' : h.nursing === 'no' ? 'No' : h.nursing)
    add('Birth control pills', h.birth_control_pills === 'yes' ? 'Yes' : h.birth_control_pills === 'no' ? 'No' : h.birth_control_pills)
    add('Physician name', h.physician_name)
    add('Physician specialty', h.physician_specialty)
    add('Physician address', h.physician_address)
    add('Physician phone', h.physician_phone)
    add('Previous dentist', h.dental_history_previous_dentist)
    add('Last dental visit', h.dental_history_last_visit)
    add('Referral source', h.referral_source)
    return rows
}

const conditionsList = computed(() =>
    (props.medicalHistory?.conditions_checklist ?? []).map((key) => pdaConditionLabels[key] ?? key),
)

const formatBytes = (bytes) => {
    if (bytes >= 1048576) return `${(bytes / 1048576).toFixed(1)} MB`
    if (bytes >= 1024) return `${(bytes / 1024).toFixed(1)} KB`
    return `${bytes} B`
}

const printExport = () => {
    toastStore.show('Preparing the printable record…')
    window.print()
}
</script>

<template>
    <Head :title="`Export — ${fullName}`" />

    <div class="min-h-screen bg-gray-100 print:bg-white">
        <!-- On-screen toolbar (hidden when printing) -->
        <div class="sticky top-0 z-20 border-b border-gray-200 bg-white/95 backdrop-blur print:hidden">
            <div class="mx-auto flex max-w-4xl items-center justify-between gap-3 px-4 py-3">
                <button
                    type="button"
                    class="inline-flex h-11 items-center gap-2 rounded-lg px-3 text-sm font-medium text-gray-600 transition hover:bg-gray-100"
                    @click="router.visit(route('patients.show', patient.id))"
                >
                    <ArrowLeft class="h-4 w-4" />
                    Back to patient
                </button>
                <div class="flex items-center gap-2">
                    <span class="text-sm text-gray-500">Exported {{ exportedAt }}</span>
                    <button
                        type="button"
                        class="inline-flex h-11 items-center gap-2 rounded-lg bg-brand-500 px-4 text-sm font-medium text-white shadow-sm transition hover:bg-brand-600"
                        @click="printExport"
                    >
                        <Printer class="h-4 w-4" />
                        Print / PDF
                    </button>
                </div>
            </div>
        </div>

        <!-- A4 document -->
        <div class="mx-auto max-w-4xl bg-white px-8 py-10 shadow-sm print:max-w-none print:px-0 print:py-0 print:shadow-none">
            <!-- Clinic letterhead -->
            <header class="flex items-start justify-between gap-4 border-b-2 border-gray-800 pb-4">
                <div>
                    <h1 class="text-xl font-semibold text-gray-900">{{ clinic.name || 'Dental Clinic' }}</h1>
                    <p v-if="clinic.address" class="mt-0.5 text-sm text-gray-600">{{ clinic.address }}</p>
                </div>
                <div class="text-right">
                    <p class="text-sm font-medium text-gray-800">Patient Record Export</p>
                    <p class="mt-0.5 text-xs text-gray-500">{{ exportedAt }}</p>
                </div>
            </header>

            <!-- Patient identification -->
            <section class="mt-6">
                <h2 class="text-xs font-semibold uppercase tracking-wide text-gray-400">Patient Information</h2>
                <div class="mt-2 rounded-lg border border-gray-200 p-4">
                    <div class="flex flex-wrap items-baseline gap-x-6 gap-y-1">
                        <p class="text-lg font-semibold text-gray-900">{{ fullName }}</p>
                        <p class="text-sm font-medium text-gray-500">{{ patient.patient_number }}</p>
                        <p class="text-sm text-gray-600">{{ patient.age }} yrs old · {{ sexLabel }} · {{ patient.civil_status }}</p>
                    </div>
                    <dl class="mt-3 grid grid-cols-1 gap-x-8 gap-y-1.5 text-sm sm:grid-cols-2">
                        <div class="flex justify-between gap-4"><dt class="text-gray-500">Birth date</dt><dd class="font-medium text-gray-800">{{ patient.birth_date }}</dd></div>
                        <div class="flex justify-between gap-4"><dt class="text-gray-500">Nationality</dt><dd class="font-medium text-gray-800">{{ patient.nationality }}</dd></div>
                        <div class="flex justify-between gap-4"><dt class="text-gray-500">Occupation</dt><dd class="font-medium text-gray-800">{{ patient.occupation || '—' }}</dd></div>
                        <div class="flex justify-between gap-4"><dt class="text-gray-500">Religion</dt><dd class="font-medium text-gray-800">{{ patient.religion || '—' }}</dd></div>
                        <div class="flex justify-between gap-4"><dt class="text-gray-500">Nickname</dt><dd class="font-medium text-gray-800">{{ patient.nickname || '—' }}</dd></div>
                        <div class="flex justify-between gap-4"><dt class="text-gray-500">Contact number</dt><dd class="font-medium text-gray-800">{{ patient.contact_number }}</dd></div>
                        <div class="flex justify-between gap-4"><dt class="text-gray-500">Home phone</dt><dd class="font-medium text-gray-800">{{ patient.home_phone || '—' }}</dd></div>
                        <div class="flex justify-between gap-4"><dt class="text-gray-500">Office phone</dt><dd class="font-medium text-gray-800">{{ patient.office_phone || '—' }}</dd></div>
                        <div class="flex justify-between gap-4"><dt class="text-gray-500">Email</dt><dd class="font-medium text-gray-800">{{ patient.email_address || '—' }}</dd></div>
                        <div class="flex justify-between gap-4"><dt class="text-gray-500">Address</dt><dd class="text-right font-medium text-gray-800">{{ patient.address }}</dd></div>
                        <div class="flex justify-between gap-4"><dt class="text-gray-500">Dental insurance</dt><dd class="font-medium text-gray-800">{{ patient.dental_insurance || '—' }}</dd></div>
                        <div class="flex justify-between gap-4"><dt class="text-gray-500">Effective date</dt><dd class="font-medium text-gray-800">{{ patient.effective_date || '—' }}</dd></div>
                        <div class="flex justify-between gap-4"><dt class="text-gray-500">Emergency contact</dt><dd class="text-right font-medium text-gray-800">{{ patient.emergency_contact_person }} · {{ patient.emergency_contact_number }}</dd></div>
                        <div v-if="patient.guardian_name" class="flex justify-between gap-4"><dt class="text-gray-500">Guardian</dt><dd class="text-right font-medium text-gray-800">{{ patient.guardian_name }}<span v-if="patient.guardian_occupation"> · {{ patient.guardian_occupation }}</span></dd></div>
                    </dl>
                </div>
            </section>

            <!-- Medical history -->
            <section v-if="canViewClinical['medical-history'] && medicalHistory" class="mt-6">
                <h2 class="text-xs font-semibold uppercase tracking-wide text-gray-400">Medical History</h2>
                <div class="mt-2 rounded-lg border border-gray-200 p-4">
                    <dl class="grid grid-cols-1 gap-x-8 gap-y-1.5 text-sm sm:grid-cols-2">
                        <div v-for="q in historyQuestions" :key="q.key" class="flex justify-between gap-4">
                            <dt class="text-gray-500">{{ q.label }}</dt>
                            <dd class="font-medium text-gray-800">{{ medicalHistory[q.key] ?? 'No' }}</dd>
                        </div>
                        <div v-for="q in historyQuestions.filter((item) => item.detailsKey && medicalHistory[item.key] === 'yes' && medicalHistory[item.detailsKey])" :key="q.detailsKey" class="sm:col-span-2">
                            <p class="text-xs font-medium text-gray-500">{{ q.label }} details</p>
                            <p class="text-sm text-gray-800">{{ medicalHistory[q.detailsKey] }}</p>
                        </div>
                        <div v-for="row in pdaDisplayRows()" :key="row.label" class="flex justify-between gap-4">
                            <dt class="text-gray-500">{{ row.label }}</dt>
                            <dd class="text-right font-medium text-gray-800">{{ row.value }}</dd>
                        </div>
                        <div v-if="conditionsList.length" class="sm:col-span-2">
                            <p class="text-xs font-medium text-gray-500">Medical conditions</p>
                            <p class="text-sm text-gray-800">{{ conditionsList.join(', ') }}</p>
                        </div>
                        <div v-if="medicalHistory.remarks" class="sm:col-span-2">
                            <p class="text-xs font-medium text-gray-500">Remarks</p>
                            <p class="text-sm text-gray-800">{{ medicalHistory.remarks }}</p>
                        </div>
                    </dl>
                </div>
            </section>

            <!-- Dental chart -->
            <section v-if="canViewClinical.chart && chartState" class="mt-6">
                <h2 class="text-xs font-semibold uppercase tracking-wide text-gray-400">Dental Chart</h2>
                <div class="mt-2 rounded-lg border border-gray-200 p-4">
                    <div class="print:scale-90 print:origin-top-left">
                        <ToothChart :state="chartState.adult" dentition="adult" readonly :options="options" />
                    </div>
                    <div v-if="primaryHasEntries" class="mt-4 print:scale-90 print:origin-top-left">
                        <p class="mb-2 text-sm font-medium text-gray-600">Primary dentition</p>
                        <ToothChart :state="chartState.primary" dentition="primary" readonly :options="options" />
                    </div>

                    <table v-if="chartEntryRows.length" class="mt-4 w-full text-left text-sm">
                        <thead>
                            <tr class="border-b border-gray-300 text-xs uppercase tracking-wide text-gray-500">
                                <th class="py-1.5 pr-3 font-semibold">Date</th>
                                <th class="py-1.5 pr-3 font-semibold">Tooth</th>
                                <th class="py-1.5 pr-3 font-semibold">Finding</th>
                                <th class="py-1.5 pr-3 font-semibold">Surface</th>
                                <th class="py-1.5 pr-3 font-semibold">Recorded by</th>
                                <th class="py-1.5 font-semibold">Notes</th>
                            </tr>
                        </thead>
                        <tbody class="divide-y divide-gray-200">
                            <tr v-for="(row, index) in chartEntryRows" :key="index">
                                <td class="py-1.5 pr-3">{{ formatDate(row.date) }}</td>
                                <td class="py-1.5 pr-3">{{ row.tooth }} <span class="text-gray-400">({{ row.dentition }})</span></td>
                                <td class="py-1.5 pr-3">
                                    {{ row.condition }}<span v-if="row.restoration"> · {{ row.restoration }}</span>
                                </td>
                                <td class="py-1.5 pr-3">{{ row.surface }}</td>
                                <td class="py-1.5 pr-3">{{ row.by }}</td>
                                <td class="py-1.5 text-gray-600">{{ row.notes || '—' }}</td>
                            </tr>
                        </tbody>
                    </table>
                    <p v-else class="mt-3 text-sm text-gray-500">No chart entries recorded.</p>
                </div>
            </section>

            <!-- Consultations -->
            <section v-if="canViewClinical.consultations && consultations.length" class="mt-6">
                <h2 class="text-xs font-semibold uppercase tracking-wide text-gray-400">Consultations</h2>
                <div class="mt-2 space-y-3">
                    <div v-for="consultation in consultations" :key="consultation.id" class="rounded-lg border border-gray-200 p-4">
                        <div class="flex flex-wrap items-baseline justify-between gap-2">
                            <p class="text-sm font-semibold text-gray-800">{{ formatDate(consultation.consultation_date) }}</p>
                            <p class="text-xs text-gray-500">{{ consultation.dentist?.name ?? '—' }}</p>
                        </div>
                        <dl class="mt-2 space-y-1 text-sm">
                            <div><dt class="inline font-medium text-gray-500">Chief complaint: </dt><dd class="inline text-gray-800">{{ consultation.chief_complaint }}</dd></div>
                            <div v-if="consultation.examination_findings"><dt class="inline font-medium text-gray-500">Findings: </dt><dd class="inline text-gray-800">{{ consultation.examination_findings }}</dd></div>
                            <div v-if="consultation.diagnosis"><dt class="inline font-medium text-gray-500">Diagnosis: </dt><dd class="inline text-gray-800">{{ consultation.diagnosis }}</dd></div>
                            <div v-if="consultation.treatment_plan"><dt class="inline font-medium text-gray-500">Plan: </dt><dd class="inline text-gray-800">{{ consultation.treatment_plan }}</dd></div>
                            <div v-if="consultation.recommendations"><dt class="inline font-medium text-gray-500">Recommendations: </dt><dd class="inline text-gray-800">{{ consultation.recommendations }}</dd></div>
                            <div v-if="consultation.periodontal_screening || consultation.occlusion_class || consultation.appliances?.length || consultation.tmd_findings?.length" class="pt-1 text-xs text-gray-600">
                                Exam: <template v-if="consultation.periodontal_screening">{{ consultation.periodontal_screening }}; </template>
                                <template v-if="consultation.occlusion_class">{{ consultation.occlusion_class }}; </template>
                                <template v-if="consultation.appliances?.length">Appliances: {{ consultation.appliances.join(', ')}}
                                <template v-if="consultation.tmd_findings?.length">; TMD: {{ consultation.tmd_findings.join(', ') }}</template></template>
                            </div>
                        </dl>
                    </div>
                </div>
            </section>

            <!-- Treatments -->
            <section v-if="canViewClinical.treatments && treatments.length" class="mt-6">
                <h2 class="text-xs font-semibold uppercase tracking-wide text-gray-400">Treatments</h2>
                <div class="mt-2 rounded-lg border border-gray-200 p-4">
                    <table class="w-full text-left text-sm">
                        <thead>
                            <tr class="border-b border-gray-300 text-xs uppercase tracking-wide text-gray-500">
                                <th class="py-1.5 pr-3 font-semibold">Date</th>
                                <th class="py-1.5 pr-3 font-semibold">Tooth</th>
                                <th class="py-1.5 pr-3 font-semibold">Procedure</th>
                                <th class="py-1.5 pr-3 font-semibold">Dentist</th>
                                <th class="py-1.5 pr-3 font-semibold">Status</th>
                                <th class="py-1.5 font-semibold">Signature</th>
                            </tr>
                        </thead>
                        <tbody class="divide-y divide-gray-200 align-top">
                            <tr v-for="treatment in treatments" :key="treatment.id">
                                <td class="py-2 pr-3">{{ formatDate(treatment.treatment_date) }}</td>
                                <td class="py-2 pr-3">{{ treatment.tooth_number ?? '—' }}</td>
                                <td class="py-2 pr-3">
                                    {{ treatment.procedure_name }}
                                    <p v-if="treatment.description" class="text-xs text-gray-500">{{ treatment.description }}</p>
                                </td>
                                <td class="py-2 pr-3">{{ treatment.dentist?.name ?? '—' }}</td>
                                <td class="py-2 pr-3">{{ treatment.signed_at ? 'Signed' : 'Pending' }}</td>
                                <td class="py-2">
                                    <img
                                        v-if="treatment.signature_path"
                                        :src="storageUrl(treatment.signature_path)"
                                        alt="Treatment signature"
                                        class="h-16 border border-gray-200 bg-white"
                                    />
                                    <span v-else class="text-xs text-gray-400">Not signed</span>
                                </td>
                            </tr>
                        </tbody>
                    </table>
                </div>
            </section>

            <!-- Consents -->
            <section v-if="canViewClinical.consents && consentForms.length" class="mt-6">
                <h2 class="text-xs font-semibold uppercase tracking-wide text-gray-400">Consent Forms</h2>
                <div class="mt-2 space-y-3">
                    <div v-for="form in consentForms" :key="form.id" class="rounded-lg border border-gray-200 p-4">
                        <div class="flex flex-wrap items-baseline justify-between gap-2">
                            <p class="text-sm font-semibold text-gray-800">
                                Informed consent — v{{ form.version }}
                                <span class="ml-2 rounded-full bg-gray-100 px-2 py-0.5 text-xs font-medium text-gray-600">{{ form.status }}</span>
                            </p>
                            <p class="text-xs text-gray-500">{{ formatDate(form.created_at) }}</p>
                        </div>

                        <div class="mt-3 grid grid-cols-1 gap-x-8 gap-y-1.5 text-sm sm:grid-cols-2">
                            <div v-for="section in form.sections" :key="section.id" class="flex items-center gap-2">
                                <span class="min-w-0 flex-1 text-gray-600">{{ section.label }}</span>
                                <img
                                    v-if="section.initial_svg_path"
                                    :src="storageUrl(section.initial_svg_path)"
                                    alt="Initial"
                                    class="h-10 w-24 border border-gray-200 bg-white object-contain"
                                />
                                <span v-else class="text-xs text-gray-400">Not initialed</span>
                            </div>
                        </div>

                        <div class="mt-4 grid grid-cols-1 gap-4 border-t border-gray-200 pt-3 text-sm sm:grid-cols-3">
                            <div>
                                <p class="text-xs font-medium text-gray-500">Patient</p>
                                <img v-if="form.patient_signature_path" :src="storageUrl(form.patient_signature_path)" alt="Patient signature" class="mt-1 h-14 w-full border border-gray-200 bg-white object-contain" />
                                <p class="mt-1 font-medium text-gray-800">{{ form.patient_name }}</p>
                                <p v-if="form.patient_signed_at" class="text-xs text-gray-500">{{ formatDateTime(form.patient_signed_at) }}</p>
                            </div>
                            <div v-if="form.guardian_name">
                                <p class="text-xs font-medium text-gray-500">Guardian</p>
                                <img v-if="form.guardian_signature_path" :src="storageUrl(form.guardian_signature_path)" alt="Guardian signature" class="mt-1 h-14 w-full border border-gray-200 bg-white object-contain" />
                                <p class="mt-1 font-medium text-gray-800">{{ form.guardian_name }}</p>
                            </div>
                            <div>
                                <p class="text-xs font-medium text-gray-500">Dentist</p>
                                <img v-if="form.dentist_signature_path" :src="storageUrl(form.dentist_signature_path)" alt="Dentist signature" class="mt-1 h-14 w-full border border-gray-200 bg-white object-contain" />
                                <p class="mt-1 font-medium text-gray-800">{{ form.dentist?.name ?? '—' }}</p>
                                <p v-if="form.dentist_signed_at" class="text-xs text-gray-500">{{ formatDateTime(form.dentist_signed_at) }}</p>
                            </div>
                        </div>

                        <p v-if="form.ip_address" class="mt-2 text-[11px] text-gray-400">
                            Signed from {{ form.ip_address }} · {{ form.user_agent }}
                        </p>
                    </div>
                </div>
            </section>

            <!-- Attachments -->
            <section v-if="canViewClinical.attachments && attachments.length" class="mt-6">
                <h2 class="text-xs font-semibold uppercase tracking-wide text-gray-400">Attachments</h2>
                <div class="mt-2 rounded-lg border border-gray-200 p-4">
                    <table class="w-full text-left text-sm">
                        <thead>
                            <tr class="border-b border-gray-300 text-xs uppercase tracking-wide text-gray-500">
                                <th class="py-1.5 pr-3 font-semibold">Name</th>
                                <th class="py-1.5 pr-3 font-semibold">Category</th>
                                <th class="py-1.5 pr-3 font-semibold">Size</th>
                                <th class="py-1.5 pr-3 font-semibold">Uploaded</th>
                                <th class="py-1.5 font-semibold">By</th>
                            </tr>
                        </thead>
                        <tbody class="divide-y divide-gray-200">
                            <tr v-for="attachment in attachments" :key="attachment.id">
                                <td class="py-1.5 pr-3">{{ attachment.original_name }}</td>
                                <td class="py-1.5 pr-3 capitalize">{{ attachment.category }}<span v-if="attachment.xray_type"> · {{ attachment.xray_type }}</span></td>
                                <td class="py-1.5 pr-3">{{ formatBytes(attachment.file_size) }}</td>
                                <td class="py-1.5 pr-3">{{ formatDate(attachment.created_at) }}</td>
                                <td class="py-1.5">{{ attachment.uploaded_by?.name ?? '—' }}</td>
                            </tr>
                        </tbody>
                    </table>
                </div>
            </section>

            <footer class="mt-8 border-t border-gray-300 pt-3 text-center text-xs text-gray-400">
                {{ clinic.name || 'Dental Clinic' }} — Patient Record Export · Generated {{ exportedAt }}
            </footer>
        </div>
    </div>
</template>

<style>
@media print {
    @page {
        margin: 1.4cm;
    }
    body {
        background: white !important;
    }
    section {
        break-inside: auto;
    }
    table {
        break-inside: auto;
    }
}
</style>
