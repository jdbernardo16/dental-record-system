<script setup>
import { computed, onMounted, ref } from 'vue'
import { Head, Link, router, useForm } from '@inertiajs/vue3'
import { ArrowLeft, Check, Pencil, Signature } from 'lucide-vue-next'
import { route } from '../../../../vendor/tightenco/ziggy'
import AppLayout from '@/Layouts/AppLayout.vue'
import Badge from '@/Components/Badge.vue'
import Button from '@/Components/Button.vue'
import ConsultationForm from '@/Components/Wizard/ConsultationForm.vue'
import MedicalHistoryForm from '@/Components/Wizard/MedicalHistoryForm.vue'
import SignaturePadModal from '@/Components/SignaturePadModal.vue'
import SignatureStep from '@/Components/Wizard/SignatureStep.vue'
import ToothChart, { wholeToothOnly } from '@/Components/ToothChart.vue'
import TreatmentForm from '@/Components/Wizard/TreatmentForm.vue'
import WaiverStep from '@/Components/Wizard/WaiverStep.vue'
import { useToastStore } from '@/Stores/toast'
import { useWizardStore } from '@/Stores/wizard'
import { errorList, scrollToFirstError, scrollToTop } from '@/lib/scroll'

defineOptions({ layout: AppLayout })

const props = defineProps({
    patient: { type: Object, default: null },
    steps: { type: Array, required: true },
    resumeStep: { type: Number, default: 0 },
    medicalHistory: { type: Object, default: null },
    consentSections: { type: Array, default: () => [] },
    consentAcknowledgment: { type: String, default: '' },
    consentAuthorization: { type: String, default: '' },
    consentFormId: { type: Number, default: null },
    existingInitialSvg: { type: String, default: '' },
    patientAge: { type: Number, default: 0 },
    sexOptions: { type: Array, default: () => [] },
    civilStatusOptions: { type: Array, default: () => [] },
    consultationOptions: { type: Object, default: () => ({}) },
    toothOptions: { type: Array, default: () => [] },
    statusOptions: { type: Object, default: () => ({}) },
    chartState: { type: Object, default: () => ({}) },
    chartHistory: { type: Array, default: () => [] },
    chartOptions: { type: Object, default: () => ({}) },
    treatments: { type: Array, default: () => [] },
    consultations: { type: Array, default: () => [] },
    can: { type: Object, default: () => ({}) },
})

const wizardStore = useWizardStore()
const toastStore = useToastStore()

const patientId = computed(() => props.patient?.id ?? wizardStore.patientId)

onMounted(() => {
    wizardStore.start(props.patient?.id ?? null, props.resumeStep ?? 0)
})

const stepLabel = (index) => props.steps[index]?.label ?? ''
const stepKey = (index) => props.steps[index]?.key ?? ''
const isCompleted = (index) => wizardStore.completed[stepKey(index)] ?? index < wizardStore.step
const isCurrent = (index) => wizardStore.step === index

const progressPercent = computed(() => {
    const done = props.steps.reduce((count, _, index) => count + (isCompleted(index) ? 1 : 0), 0)
    return Math.round((done / Math.max(props.steps.length, 1)) * 100)
})

const navigateTo = (index) => {
    if (!isCompleted(index) && !isCurrent(index)) return
    wizardStore.go(index)
    scrollToTop()
}

const backStep = () => {
    const current = wizardStore.step
    wizardStore.go(current === 4 ? 1 : Math.max(0, current - 1))
    scrollToTop()
}

/* ---------------------------------------------------------------- Step 0 */

const patientForm = useForm({
    first_name: '',
    middle_name: '',
    last_name: '',
    sex: '',
    birth_date: '',
    civil_status: '',
    nationality: 'Filipino',
    occupation: '',
    contact_number: '',
    address: '',
    email_address: '',
    emergency_contact_person: '',
    emergency_contact_number: '',
    religion: '',
    nickname: '',
    home_phone: '',
    office_phone: '',
    fax_number: '',
    dental_insurance: '',
    effective_date: '',
    guardian_name: '',
    guardian_occupation: '',
    wizard: 1,
})

const patientErrorList = computed(() => errorList(patientForm.errors))

const submitPatient = () => {
    patientForm.post(route('patients.store'), {
        preserveScroll: true,
        onSuccess: (page) => {
            wizardStore.patientId = page.props.patient.id
            wizardStore.markComplete('patient')
            wizardStore.go(1)
            scrollToTop()
        },
        onError: () => scrollToFirstError(),
    })
}

const onMedicalHistorySaved = () => {
    wizardStore.markComplete('medical_history')
    wizardStore.go(2)
    scrollToTop()
}

const onWaiverSaved = () => {
    wizardStore.markComplete('waiver')
    wizardStore.go(3)
    scrollToTop()
}

const onSignatureSaved = () => {
    wizardStore.markComplete('signature')
    wizardStore.go(4)
    scrollToTop()
}

const onConsultationSaved = () => {
    wizardStore.markComplete('consultation')
    wizardStore.go(5)
    scrollToTop()
}

const onChartDone = () => {
    wizardStore.markComplete('dental_chart')
    wizardStore.go(6)
    scrollToTop()
}

const onTreatmentSaved = () => {
    wizardStore.markComplete('treatment')
    scrollToTop()
}

const patientFullName = () =>
    [props.patient?.first_name, props.patient?.middle_name, props.patient?.last_name]
        .filter(Boolean)
        .join(' ')

/* ---------------------------------------------------------------- Step 5 */

const selectedCondition = ref(null)
const selectedRestoration = ref(null)
const applying = ref(false)

const pickTool = (kind, key) => {
    if (kind === 'condition') {
        selectedCondition.value = selectedCondition.value === key ? null : key
        selectedRestoration.value = null
    } else {
        selectedRestoration.value = selectedRestoration.value === key ? null : key
        selectedCondition.value = null
    }
}

const chartEditable = computed(() => props.can.dentalChart?.update ?? false)

const applyTooth = ({ tooth, surface }) => {
    if (applying.value || !chartEditable.value) return

    // restorations are recorded on a present tooth (condition is required by the backend)
    const tool = selectedRestoration.value
        ? { condition: 'present', restoration_type: selectedRestoration.value }
        : { condition: selectedCondition.value }
    if (!tool.condition) return

    applying.value = true
    router.post(
        route('dental-chart.store'),
        {
            patient_id: patientId.value,
            tooth_number: tooth,
            dentition: 'adult',
            surface,
            recorded_at: new Date().toISOString().slice(0, 10),
            ...tool,
        },
        {
            // keep the wizard on the chart step — a remount would resume the patient at a later step
            preserveState: true,
            preserveScroll: true,
            onSuccess: () => toastStore.show(`Tooth ${tooth} updated.`),
            onFinish: () => (applying.value = false),
        },
    )
}

const chartHint = computed(() => {
    let text = 'Tap a condition or restoration, then tap a tooth (or its surface) to record it. Changes are saved instantly.'
    if (selectedCondition.value && wholeToothOnly().includes(selectedCondition.value)) {
        text += ' This condition applies to the whole tooth only.'
    }
    return text
})

const chipClass = (selected) => [
    'min-h-11 inline-flex items-center gap-2 rounded-full border px-4 text-sm font-medium transition',
    selected
        ? 'border-brand-500 bg-brand-50 text-brand-700 ring-2 ring-brand-500'
        : 'border-gray-200 bg-white text-gray-600 hover:bg-gray-50',
]

/* ---------------------------------------------------------------- Step 6 */

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
        // keep the wizard on the treatment step — a completed intake resumes at step 0
        preserveState: true,
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

const finishWizard = () => {
    wizardStore.reset()
    router.visit(route('patients.show', props.patient.id))
}
</script>

<template>
    <Head :title="patient ? `Intake — ${patientFullName()}` : 'Patient intake'" />

    <div class="mx-auto max-w-5xl space-y-6">
        <div>
            <h1 class="text-2xl font-semibold text-gray-800">Patient intake</h1>
            <p class="mt-1 text-sm text-gray-500">
                {{ patient ? `Resuming intake for ${patientFullName()}` : 'Register a new patient and complete the intake checklist.' }}
            </p>
        </div>

        <!-- Stepper -->
        <div class="border-b border-gray-200 pb-4">
            <nav class="overflow-x-auto no-scrollbar px-1 py-1" aria-label="Intake steps">
                <ol class="flex min-w-max items-center gap-1 sm:gap-2">
                    <li
                        v-for="(step, index) in steps"
                        :key="step.key"
                        class="flex shrink-0 items-center"
                    >
                        <span
                            v-if="index > 0"
                            aria-hidden="true"
                            class="mx-1 h-0.5 w-5 rounded-full sm:w-10"
                            :class="isCompleted(index - 1) ? 'bg-brand-500' : 'bg-gray-200'"
                        ></span>
                        <button
                            type="button"
                            :disabled="!isCompleted(index) && !isCurrent(index)"
                            :aria-current="isCurrent(index) ? 'step' : undefined"
                            class="group flex items-center gap-2 rounded-full px-1 py-0.5 transition hover:bg-gray-50 disabled:cursor-default disabled:hover:bg-transparent"
                            @click="navigateTo(index)"
                        >
                            <span
                                :class="[
                                    'flex h-8 w-8 shrink-0 items-center justify-center rounded-full text-xs font-semibold transition sm:h-9 sm:w-9 sm:text-sm',
                                    isCompleted(index) || isCurrent(index)
                                        ? 'bg-brand-500 text-white'
                                        : 'bg-gray-100 text-gray-500',
                                ]"
                            >
                                <Check v-if="isCompleted(index) && !isCurrent(index)" class="h-4 w-4" />
                                <span v-else>{{ index + 1 }}</span>
                            </span>
                            <span
                                :class="[
                                    'whitespace-nowrap text-xs font-medium transition sm:text-sm',
                                    isCurrent(index)
                                        ? 'font-semibold text-brand-700'
                                        : isCompleted(index)
                                          ? 'text-gray-600'
                                          : 'text-gray-400',
                                ]"
                            >
                                {{ step.label }}
                            </span>
                        </button>
                    </li>
                </ol>
            </nav>

            <div class="mt-3 flex items-center gap-3">
                <div class="h-1 flex-1 overflow-hidden rounded-full bg-gray-100">
                    <div
                        class="h-full rounded-full bg-brand-500 transition-all duration-300"
                        :style="{ width: `${progressPercent}%` }"
                    ></div>
                </div>
                <p class="shrink-0 text-xs text-gray-500">
                    Step {{ wizardStore.step + 1 }} of {{ steps.length }}
                </p>
            </div>
        </div>

        <!-- Step content -->
        <div class="rounded-2xl border border-gray-200 bg-white p-4 shadow-sm sm:p-6">
            <!-- 0 · Patient -->
            <div v-show="wizardStore.step === 0">
                <div v-if="patient" class="space-y-5">
                    <div class="flex flex-wrap items-center justify-between gap-3">
                        <div class="min-w-0">
                            <h2 class="text-lg font-semibold text-gray-800">{{ patientFullName() }}</h2>
                            <p class="mt-0.5 text-sm text-gray-500">{{ patient.patient_number }}</p>
                        </div>
                        <Link :href="route('patients.edit', patient.id)">
                            <Button variant="outline" size="sm">
                                <Pencil class="h-4 w-4" />
                                Edit
                            </Button>
                        </Link>
                    </div>
                    <div class="flex justify-end">
                        <Button type="button" @click="wizardStore.go(1)">Continue</Button>
                    </div>
                </div>

                <form v-else class="space-y-6" @submit.prevent="submitPatient">
                    <ul
                        v-if="patientForm.hasErrors"
                        role="alert"
                        class="space-y-1 rounded-lg bg-status-cancelled/10 px-4 py-3 text-sm font-medium text-status-cancelled"
                    >
                        <li v-for="message in patientErrorList" :key="message">{{ message }}</li>
                    </ul>

                    <section class="space-y-5">
                        <h2 class="text-sm font-semibold text-gray-800">Identity</h2>
                        <div>
                            <label for="first_name" class="mb-1.5 block text-sm font-medium text-gray-700">
                                First name
                                <span class="text-status-cancelled">*</span>
                            </label>
                            <input
                                id="first_name"
                                v-model="patientForm.first_name"
                                type="text"
                                placeholder="Liza"
                                required
                                autofocus
                                class="h-11 w-full rounded-lg border bg-transparent px-4 py-2.5 text-sm text-gray-800 shadow-sm placeholder:text-gray-400 focus:border-brand-300 focus:outline-hidden focus:ring-2 focus:ring-brand-500/10"
                                :class="{ 'border-status-cancelled': patientForm.errors.first_name }"
                            />
                            <p v-if="patientForm.errors.first_name" class="mt-1.5 text-xs text-status-cancelled">
                                {{ patientForm.errors.first_name }}
                            </p>
                        </div>
                        <div>
                            <label for="middle_name" class="mb-1.5 block text-sm font-medium text-gray-700">Middle name</label>
                            <input
                                id="middle_name"
                                v-model="patientForm.middle_name"
                                type="text"
                                placeholder="Optional"
                                class="h-11 w-full rounded-lg border bg-transparent px-4 py-2.5 text-sm text-gray-800 shadow-sm placeholder:text-gray-400 focus:border-brand-300 focus:outline-hidden focus:ring-2 focus:ring-brand-500/10"
                                :class="{ 'border-status-cancelled': patientForm.errors.middle_name }"
                            />
                            <p v-if="patientForm.errors.middle_name" class="mt-1.5 text-xs text-status-cancelled">
                                {{ patientForm.errors.middle_name }}
                            </p>
                        </div>
                        <div>
                            <label for="last_name" class="mb-1.5 block text-sm font-medium text-gray-700">
                                Last name
                                <span class="text-status-cancelled">*</span>
                            </label>
                            <input
                                id="last_name"
                                v-model="patientForm.last_name"
                                type="text"
                                placeholder="Reyes"
                                required
                                class="h-11 w-full rounded-lg border bg-transparent px-4 py-2.5 text-sm text-gray-800 shadow-sm placeholder:text-gray-400 focus:border-brand-300 focus:outline-hidden focus:ring-2 focus:ring-brand-500/10"
                                :class="{ 'border-status-cancelled': patientForm.errors.last_name }"
                            />
                            <p v-if="patientForm.errors.last_name" class="mt-1.5 text-xs text-status-cancelled">
                                {{ patientForm.errors.last_name }}
                            </p>
                        </div>
                        <div>
                            <p class="mb-1.5 text-sm font-medium text-gray-700">
                                Sex
                                <span class="text-status-cancelled">*</span>
                            </p>
                            <div class="inline-flex flex-wrap gap-1 rounded-full bg-gray-100 p-1" role="radiogroup" aria-label="Sex">
                        <button
                            v-for="option in sexOptions"
                            :key="option.value"
                            type="button"
                            role="radio"
                            :aria-checked="patientForm.sex === option.value ? 'true' : 'false'"
                            :class="[
                                'min-h-11 rounded-full px-4 text-sm font-medium transition',
                                patientForm.sex === option.value ? 'bg-white text-gray-900 shadow-sm' : 'text-gray-500',
                            ]"
                            @click="patientForm.sex = option.value"
                        >
                            { option.label }
                        </button>
                    </div>
                            <p v-if="patientForm.errors.sex" class="mt-1.5 text-xs text-status-cancelled">
                                { patientForm.errors.sex }
                            </p>
                        </div>
                        <div>
                            <label for="birth_date" class="mb-1.5 block text-sm font-medium text-gray-700">
                                Birth date
                                <span class="text-status-cancelled">*</span>
                            </label>
                            <input
                                id="birth_date"
                                v-model="patientForm.birth_date"
                                type="date"
                                required
                                class="h-11 w-full rounded-lg border bg-transparent px-4 py-2.5 text-sm text-gray-800 shadow-sm focus:border-brand-300 focus:outline-hidden focus:ring-2 focus:ring-brand-500/10"
                                :class="{ 'border-status-cancelled': patientForm.errors.birth_date }"
                            />
                            <p v-if="patientForm.errors.birth_date" class="mt-1.5 text-xs text-status-cancelled">
                                {{ patientForm.errors.birth_date }}
                            </p>
                        </div>
                        <div>
                            <p class="mb-1.5 text-sm font-medium text-gray-700">
                                Civil status
                                <span class="text-status-cancelled">*</span>
                            </p>
                            <div class="inline-flex flex-wrap gap-1 rounded-full bg-gray-100 p-1" role="radiogroup" aria-label="Civil status">
                        <button
                            v-for="option in civilStatusOptions"
                            :key="option.value"
                            type="button"
                            role="radio"
                            :aria-checked="patientForm.civil_status === option.value ? 'true' : 'false'"
                            :class="[
                                'min-h-11 rounded-full px-4 text-sm font-medium transition',
                                patientForm.civil_status === option.value ? 'bg-white text-gray-900 shadow-sm' : 'text-gray-500',
                            ]"
                            @click="patientForm.civil_status = option.value"
                        >
                            { option.label }
                        </button>
                    </div>
                            <p v-if="patientForm.errors.civil_status" class="mt-1.5 text-xs text-status-cancelled">
                                { patientForm.errors.civil_status }
                            </p>
                        </div>
                        <div>
                            <label for="nationality" class="mb-1.5 block text-sm font-medium text-gray-700">
                                Nationality
                                <span class="text-status-cancelled">*</span>
                            </label>
                            <input
                                id="nationality"
                                v-model="patientForm.nationality"
                                type="text"
                                required
                                class="h-11 w-full rounded-lg border bg-transparent px-4 py-2.5 text-sm text-gray-800 shadow-sm placeholder:text-gray-400 focus:border-brand-300 focus:outline-hidden focus:ring-2 focus:ring-brand-500/10"
                                :class="{ 'border-status-cancelled': patientForm.errors.nationality }"
                            />
                            <p v-if="patientForm.errors.nationality" class="mt-1.5 text-xs text-status-cancelled">
                                {{ patientForm.errors.nationality }}
                            </p>
                        </div>
                    </section>

                    <hr class="border-gray-100" />

                    <section class="space-y-5">
                        <h2 class="text-sm font-semibold text-gray-800">Contact</h2>
                        <div>
                            <label for="occupation" class="mb-1.5 block text-sm font-medium text-gray-700">Occupation</label>
                            <input
                                id="occupation"
                                v-model="patientForm.occupation"
                                type="text"
                                placeholder="Optional"
                                class="h-11 w-full rounded-lg border bg-transparent px-4 py-2.5 text-sm text-gray-800 shadow-sm placeholder:text-gray-400 focus:border-brand-300 focus:outline-hidden focus:ring-2 focus:ring-brand-500/10"
                                :class="{ 'border-status-cancelled': patientForm.errors.occupation }"
                            />
                            <p v-if="patientForm.errors.occupation" class="mt-1.5 text-xs text-status-cancelled">
                                {{ patientForm.errors.occupation }}
                            </p>
                        </div>
                        <div>
                            <label for="contact_number" class="mb-1.5 block text-sm font-medium text-gray-700">
                                Contact number
                                <span class="text-status-cancelled">*</span>
                            </label>
                            <input
                                id="contact_number"
                                v-model="patientForm.contact_number"
                                type="text"
                                placeholder="0917 123 4567"
                                required
                                class="h-11 w-full rounded-lg border bg-transparent px-4 py-2.5 text-sm text-gray-800 shadow-sm placeholder:text-gray-400 focus:border-brand-300 focus:outline-hidden focus:ring-2 focus:ring-brand-500/10"
                                :class="{ 'border-status-cancelled': patientForm.errors.contact_number }"
                            />
                            <p v-if="patientForm.errors.contact_number" class="mt-1.5 text-xs text-status-cancelled">
                                {{ patientForm.errors.contact_number }}
                            </p>
                        </div>
                        <div>
                            <label for="address" class="mb-1.5 block text-sm font-medium text-gray-700">
                                Address
                                <span class="text-status-cancelled">*</span>
                            </label>
                            <input
                                id="address"
                                v-model="patientForm.address"
                                type="text"
                                placeholder="House number, street, barangay, city"
                                required
                                class="h-11 w-full rounded-lg border bg-transparent px-4 py-2.5 text-sm text-gray-800 shadow-sm placeholder:text-gray-400 focus:border-brand-300 focus:outline-hidden focus:ring-2 focus:ring-brand-500/10"
                                :class="{ 'border-status-cancelled': patientForm.errors.address }"
                            />
                            <p v-if="patientForm.errors.address" class="mt-1.5 text-xs text-status-cancelled">
                                {{ patientForm.errors.address }}
                            </p>
                        </div>
                        <div>
                            <label for="email_address" class="mb-1.5 block text-sm font-medium text-gray-700">Email address</label>
                            <input
                                id="email_address"
                                v-model="patientForm.email_address"
                                type="email"
                                placeholder="Optional"
                                class="h-11 w-full rounded-lg border bg-transparent px-4 py-2.5 text-sm text-gray-800 shadow-sm placeholder:text-gray-400 focus:border-brand-300 focus:outline-hidden focus:ring-2 focus:ring-brand-500/10"
                                :class="{ 'border-status-cancelled': patientForm.errors.email_address }"
                            />
                            <p v-if="patientForm.errors.email_address" class="mt-1.5 text-xs text-status-cancelled">
                                {{ patientForm.errors.email_address }}
                            </p>
                        </div>
                    </section>

                    <hr class="border-gray-100" />

                    <section class="space-y-5">
                        <h2 class="text-sm font-semibold text-gray-800">Emergency contact</h2>
                        <div>
                            <label for="emergency_contact_person" class="mb-1.5 block text-sm font-medium text-gray-700">
                                Contact person
                                <span class="text-status-cancelled">*</span>
                            </label>
                            <input
                                id="emergency_contact_person"
                                v-model="patientForm.emergency_contact_person"
                                type="text"
                                placeholder="John Reyes"
                                required
                                class="h-11 w-full rounded-lg border bg-transparent px-4 py-2.5 text-sm text-gray-800 shadow-sm placeholder:text-gray-400 focus:border-brand-300 focus:outline-hidden focus:ring-2 focus:ring-brand-500/10"
                                :class="{ 'border-status-cancelled': patientForm.errors.emergency_contact_person }"
                            />
                            <p v-if="patientForm.errors.emergency_contact_person" class="mt-1.5 text-xs text-status-cancelled">
                                {{ patientForm.errors.emergency_contact_person }}
                            </p>
                        </div>
                        <div>
                            <label for="emergency_contact_number" class="mb-1.5 block text-sm font-medium text-gray-700">
                                Contact number
                                <span class="text-status-cancelled">*</span>
                            </label>
                            <input
                                id="emergency_contact_number"
                                v-model="patientForm.emergency_contact_number"
                                type="text"
                                placeholder="0917 987 6543"
                                required
                                class="h-11 w-full rounded-lg border bg-transparent px-4 py-2.5 text-sm text-gray-800 shadow-sm placeholder:text-gray-400 focus:border-brand-300 focus:outline-hidden focus:ring-2 focus:ring-brand-500/10"
                                :class="{ 'border-status-cancelled': patientForm.errors.emergency_contact_number }"
                            />
                            <p v-if="patientForm.errors.emergency_contact_number" class="mt-1.5 text-xs text-status-cancelled">
                                {{ patientForm.errors.emergency_contact_number }}
                            </p>
                        </div>
                    </section>

                    <hr class="border-gray-100" />

                    <section class="space-y-5">
                        <h2 class="text-sm font-semibold text-gray-800">PDA additional details</h2>
                        <p class="text-xs text-gray-500">Optional fields from the PDA patient information record.</p>
                        <div>
                            <label for="religion" class="mb-1.5 block text-sm font-medium text-gray-700">Religion</label>
                            <input
                                id="religion"
                                v-model="patientForm.religion"
                                type="text"
                                placeholder="Optional"
                                class="h-11 w-full rounded-lg border bg-transparent px-4 py-2.5 text-sm text-gray-800 shadow-sm placeholder:text-gray-400 focus:border-brand-300 focus:outline-hidden focus:ring-2 focus:ring-brand-500/10"
                                :class="{ 'border-status-cancelled': patientForm.errors.religion }"
                            />
                            <p v-if="patientForm.errors.religion" class="mt-1.5 text-xs text-status-cancelled">
                                {{ patientForm.errors.religion }}
                            </p>
                        </div>
                        <div>
                            <label for="nickname" class="mb-1.5 block text-sm font-medium text-gray-700">Nickname</label>
                            <input
                                id="nickname"
                                v-model="patientForm.nickname"
                                type="text"
                                placeholder="Optional"
                                class="h-11 w-full rounded-lg border bg-transparent px-4 py-2.5 text-sm text-gray-800 shadow-sm placeholder:text-gray-400 focus:border-brand-300 focus:outline-hidden focus:ring-2 focus:ring-brand-500/10"
                                :class="{ 'border-status-cancelled': patientForm.errors.nickname }"
                            />
                            <p v-if="patientForm.errors.nickname" class="mt-1.5 text-xs text-status-cancelled">
                                {{ patientForm.errors.nickname }}
                            </p>
                        </div>
                        <div>
                            <label for="home_phone" class="mb-1.5 block text-sm font-medium text-gray-700">Home phone</label>
                            <input
                                id="home_phone"
                                v-model="patientForm.home_phone"
                                type="text"
                                placeholder="02 8123 4567"
                                class="h-11 w-full rounded-lg border bg-transparent px-4 py-2.5 text-sm text-gray-800 shadow-sm placeholder:text-gray-400 focus:border-brand-300 focus:outline-hidden focus:ring-2 focus:ring-brand-500/10"
                                :class="{ 'border-status-cancelled': patientForm.errors.home_phone }"
                            />
                            <p v-if="patientForm.errors.home_phone" class="mt-1.5 text-xs text-status-cancelled">
                                {{ patientForm.errors.home_phone }}
                            </p>
                        </div>
                        <div>
                            <label for="office_phone" class="mb-1.5 block text-sm font-medium text-gray-700">Office phone</label>
                            <input
                                id="office_phone"
                                v-model="patientForm.office_phone"
                                type="text"
                                placeholder="02 8765 4321"
                                class="h-11 w-full rounded-lg border bg-transparent px-4 py-2.5 text-sm text-gray-800 shadow-sm placeholder:text-gray-400 focus:border-brand-300 focus:outline-hidden focus:ring-2 focus:ring-brand-500/10"
                                :class="{ 'border-status-cancelled': patientForm.errors.office_phone }"
                            />
                            <p v-if="patientForm.errors.office_phone" class="mt-1.5 text-xs text-status-cancelled">
                                {{ patientForm.errors.office_phone }}
                            </p>
                        </div>
                        <div>
                            <label for="fax_number" class="mb-1.5 block text-sm font-medium text-gray-700">Fax number</label>
                            <input
                                id="fax_number"
                                v-model="patientForm.fax_number"
                                type="text"
                                placeholder="Optional"
                                class="h-11 w-full rounded-lg border bg-transparent px-4 py-2.5 text-sm text-gray-800 shadow-sm placeholder:text-gray-400 focus:border-brand-300 focus:outline-hidden focus:ring-2 focus:ring-brand-500/10"
                                :class="{ 'border-status-cancelled': patientForm.errors.fax_number }"
                            />
                            <p v-if="patientForm.errors.fax_number" class="mt-1.5 text-xs text-status-cancelled">
                                {{ patientForm.errors.fax_number }}
                            </p>
                        </div>
                        <div>
                            <label for="dental_insurance" class="mb-1.5 block text-sm font-medium text-gray-700">Dental insurance</label>
                            <input
                                id="dental_insurance"
                                v-model="patientForm.dental_insurance"
                                type="text"
                                placeholder="e.g. PhilHealth"
                                class="h-11 w-full rounded-lg border bg-transparent px-4 py-2.5 text-sm text-gray-800 shadow-sm placeholder:text-gray-400 focus:border-brand-300 focus:outline-hidden focus:ring-2 focus:ring-brand-500/10"
                                :class="{ 'border-status-cancelled': patientForm.errors.dental_insurance }"
                            />
                            <p v-if="patientForm.errors.dental_insurance" class="mt-1.5 text-xs text-status-cancelled">
                                {{ patientForm.errors.dental_insurance }}
                            </p>
                        </div>
                        <div>
                            <label for="effective_date" class="mb-1.5 block text-sm font-medium text-gray-700">Effective date</label>
                            <input
                                id="effective_date"
                                v-model="patientForm.effective_date"
                                type="date"
                                class="h-11 w-full rounded-lg border bg-transparent px-4 py-2.5 text-sm text-gray-800 shadow-sm focus:border-brand-300 focus:outline-hidden focus:ring-2 focus:ring-brand-500/10"
                                :class="{ 'border-status-cancelled': patientForm.errors.effective_date }"
                            />
                            <p v-if="patientForm.errors.effective_date" class="mt-1.5 text-xs text-status-cancelled">
                                {{ patientForm.errors.effective_date }}
                            </p>
                        </div>
                        <div>
                            <label for="guardian_name" class="mb-1.5 block text-sm font-medium text-gray-700">Guardian name</label>
                            <input
                                id="guardian_name"
                                v-model="patientForm.guardian_name"
                                type="text"
                                placeholder="For minors"
                                class="h-11 w-full rounded-lg border bg-transparent px-4 py-2.5 text-sm text-gray-800 shadow-sm placeholder:text-gray-400 focus:border-brand-300 focus:outline-hidden focus:ring-2 focus:ring-brand-500/10"
                                :class="{ 'border-status-cancelled': patientForm.errors.guardian_name }"
                            />
                            <p v-if="patientForm.errors.guardian_name" class="mt-1.5 text-xs text-status-cancelled">
                                {{ patientForm.errors.guardian_name }}
                            </p>
                        </div>
                        <div>
                            <label for="guardian_occupation" class="mb-1.5 block text-sm font-medium text-gray-700">Guardian occupation</label>
                            <input
                                id="guardian_occupation"
                                v-model="patientForm.guardian_occupation"
                                type="text"
                                placeholder="For minors"
                                class="h-11 w-full rounded-lg border bg-transparent px-4 py-2.5 text-sm text-gray-800 shadow-sm placeholder:text-gray-400 focus:border-brand-300 focus:outline-hidden focus:ring-2 focus:ring-brand-500/10"
                                :class="{ 'border-status-cancelled': patientForm.errors.guardian_occupation }"
                            />
                            <p v-if="patientForm.errors.guardian_occupation" class="mt-1.5 text-xs text-status-cancelled">
                                {{ patientForm.errors.guardian_occupation }}
                            </p>
                        </div>
                    </section>

                    <div class="flex items-center justify-between gap-3 pt-2">
                        <p class="text-xs text-gray-500">
                            Required fields are marked with <span class="text-status-cancelled">*</span>
                        </p>
                        <Button type="submit" :disabled="patientForm.processing">
                            {{ patientForm.processing ? 'Saving…' : 'Register & continue' }}
                        </Button>
                    </div>
                </form>
            </div>

            <!-- 1 · Medical history -->
            <div v-show="wizardStore.step === 1">
                <MedicalHistoryForm
                    v-if="patientId"
                    :patient-id="patientId"
                    :medical-history="medicalHistory"
                    submit-label="Save & continue"
                    :cancelable="false"
                    @saved="onMedicalHistorySaved"
                />
                <p v-else class="py-10 text-center text-sm text-gray-500">
                    Register the patient first to continue.
                </p>
            </div>

            <!-- 2 · Waiver -->
            <div v-show="wizardStore.step === 2">
                <WaiverStep
                    v-if="patient"
                    :patient="patient"
                    :sections="consentSections"
                    :acknowledgment="consentAcknowledgment"
                    :authorization="consentAuthorization"
                    :patient-age="patientAge"
                    :existing-initial-svg="existingInitialSvg"
                    @saved="onWaiverSaved"
                />
                <p v-else class="py-10 text-center text-sm text-gray-500">
                    Register the patient first to continue.
                </p>
            </div>

            <!-- 3 · Signature -->
            <div v-show="wizardStore.step === 3">
                <SignatureStep
                    v-if="patient"
                    :patient="patient"
                    :consent-form-id="consentFormId"
                    :patient-age="patientAge"
                    @saved="onSignatureSaved"
                />
                <p v-else class="py-10 text-center text-sm text-gray-500">
                    Register the patient first to continue.
                </p>
            </div>

            <!-- 4 · Consultation -->
            <div v-show="wizardStore.step === 4">
                <ConsultationForm
                    v-if="patientId"
                    :patient-id="patientId"
                    :options="consultationOptions"
                    @saved="onConsultationSaved"
                />
                <p v-else class="py-10 text-center text-sm text-gray-500">
                    Register the patient first to continue.
                </p>
            </div>

            <!-- 5 · Dental chart -->
            <div v-show="wizardStore.step === 5" class="space-y-6">
                <ToothChart
                    :state="chartState"
                    dentition="adult"
                    :readonly="!chartEditable"
                    :selected-condition="selectedCondition"
                    :selected-restoration="selectedRestoration"
                    :options="chartOptions"
                    @apply-tooth="applyTooth"
                />

                <p class="text-center text-sm text-gray-500">
                    {{ chartHistory.length ? `${chartHistory.length} chart entr${chartHistory.length === 1 ? 'y' : 'ies'} on record` : 'No chart entries yet — tap a condition then a tooth to begin.' }}
                </p>

                <div v-if="chartEditable" class="rounded-xl bg-gray-50 px-4 py-3 text-sm text-gray-600">
                    {{ chartHint }}
                </div>

                <div v-if="chartEditable" class="rounded-2xl border border-gray-200 bg-white p-6 shadow-sm">
                    <h3 class="text-xs font-semibold tracking-wide text-gray-400 uppercase">Conditions</h3>
                    <div class="mt-3 flex flex-wrap gap-2">
                        <button
                            v-for="(meta, key) in chartOptions.conditions"
                            :key="key"
                            type="button"
                            :title="meta.code"
                            :class="chipClass(selectedCondition === key)"
                            @click="pickTool('condition', key)"
                        >
                            <span
                                class="h-4 w-4 shrink-0 rounded-full"
                                :style="{ background: `var(--color-${meta.color})` }"
                            />
                            {{ meta.label }}
                        </button>
                    </div>

                    <h3 class="mt-6 text-xs font-semibold tracking-wide text-gray-400 uppercase">Restorations</h3>
                    <div class="mt-3 flex flex-wrap gap-2">
                        <button
                            v-for="(meta, key) in chartOptions.restorations"
                            :key="key"
                            type="button"
                            :title="meta.code"
                            :class="chipClass(selectedRestoration === key)"
                            @click="pickTool('restoration', key)"
                        >
                            <span
                                class="h-4 w-4 shrink-0 rounded-full"
                                :style="{ background: `var(--color-${meta.color})` }"
                            />
                            {{ meta.label }}
                        </button>
                    </div>
                </div>

                <div class="flex justify-end">
                    <Button type="button" @click="onChartDone">Continue to treatment</Button>
                </div>
            </div>

            <!-- 6 · Treatment -->
            <div v-show="wizardStore.step === 6" class="space-y-6">
                <TreatmentForm
                    v-if="patientId"
                    :patient-id="patientId"
                    :consultations="consultations"
                    :tooth-options="toothOptions"
                    @saved="onTreatmentSaved"
                />

                <div v-if="treatments.length" class="rounded-2xl border border-gray-200 bg-gray-50/50 p-6">
                    <div class="flex flex-wrap items-center justify-between gap-3">
                        <div>
                            <h3 class="text-sm font-semibold text-gray-800">Treatment records</h3>
                            <p class="mt-0.5 text-xs text-gray-500">
                                {{ treatments.length }} on record{{ treatments.some((t) => !t.signed_at) ? ' — sign pending records to complete the intake' : '' }}
                            </p>
                        </div>
                        <Badge size="sm" color="success">Created</Badge>
                    </div>

                    <ul class="mt-4 divide-y divide-gray-100">
                        <li
                            v-for="treatment in treatments"
                            :key="treatment.id"
                            class="flex flex-wrap items-center justify-between gap-3 py-3"
                        >
                            <div class="flex min-w-0 flex-wrap items-center gap-2">
                                <Badge size="sm" color="light">{{ treatment.treatment_date }}</Badge>
                                <span class="truncate text-sm font-medium text-gray-800">
                                    {{ treatment.procedure_name }}
                                </span>
                                <Badge v-if="treatment.tooth_number" size="sm" color="primary">
                                    Tooth {{ treatment.tooth_number }}
                                </Badge>
                                <Badge size="sm" :color="treatment.signed_at ? 'success' : 'warning'">
                                    {{ treatment.signed_at ? 'Signed' : 'Pending' }}
                                </Badge>
                            </div>
                            <div class="flex shrink-0 items-center gap-2">
                                <span class="text-xs text-gray-500">{{ treatment.dentist?.name ?? '—' }}</span>
                                <Button
                                    v-if="!treatment.signed_at && can.treatments?.sign"
                                    variant="outline"
                                    size="sm"
                                    @click="openSign(treatment)"
                                >
                                    <Signature class="h-4 w-4" />
                                    Sign now
                                </Button>
                            </div>
                        </li>
                    </ul>
                </div>

                <div class="flex justify-end">
                    <Button type="button" @click="finishWizard">Finish</Button>
                </div>
            </div>
        </div>

        <!-- Footer navigation -->
        <div class="flex items-center justify-between gap-3">
            <Button variant="outline" :disabled="wizardStore.step === 0" @click="backStep">
                <ArrowLeft class="h-4 w-4" />
                Back
            </Button>
            <p class="text-sm text-gray-500">Step {{ wizardStore.step + 1 }} of 7</p>
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
