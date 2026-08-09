<script setup>
import { computed, onMounted, ref } from 'vue'
import { Head, Link, router, useForm } from '@inertiajs/vue3'
import { ArrowLeft, Check, Pencil } from 'lucide-vue-next'
import { route } from '../../../../vendor/tightenco/ziggy'
import AppLayout from '@/Layouts/AppLayout.vue'
import BackToPatient from '@/Components/BackToPatient.vue'
import { Button } from '@/Components/ui/button'
import { DateField, RadioPills, TextInput } from '@/Components/Fields'
import MedicalHistoryForm from '@/Components/Wizard/MedicalHistoryForm.vue'
import SignatureStep from '@/Components/Wizard/SignatureStep.vue'
import ToothChart, { wholeToothOnly } from '@/Components/ToothChart.vue'
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
    statusOptions: { type: Object, default: () => ({}) },
    chartState: { type: Object, default: () => ({}) },
    chartHistory: { type: Array, default: () => [] },
    chartOptions: { type: Object, default: () => ({}) },
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
    wizardStore.go(Math.max(0, current - 1))
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

const finishWizard = () => {
    wizardStore.reset()
    router.visit(route('patients.show', props.patient.id))
}
</script>

<template>
    <Head :title="patient ? `Intake — ${patientFullName()}` : 'Patient intake'" />

    <div class="mx-auto max-w-5xl space-y-6">
        <div class="flex flex-wrap items-center justify-between gap-4">
            <div>
                <h1 class="text-2xl font-semibold text-gray-800">Patient intake</h1>
                <p class="mt-1 text-sm text-gray-500">
                    {{ patient ? `Resuming intake for ${patientFullName()}` : 'Register a new patient and complete the intake checklist.' }}
                </p>
            </div>
            <BackToPatient v-if="patient" :patient-id="patient.id" />
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
                        <Button size="md" type="button" @click="wizardStore.go(1)">Continue</Button>
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
                        <TextInput
                            id="first_name"
                            v-model="patientForm.first_name"
                            label="First name"
                            required
                            placeholder="Liza"
                            autofocus
                            :error="patientForm.errors.first_name"
                        />
                        <TextInput
                            id="middle_name"
                            v-model="patientForm.middle_name"
                            label="Middle name"
                            placeholder="Optional"
                            :error="patientForm.errors.middle_name"
                        />
                        <TextInput
                            id="last_name"
                            v-model="patientForm.last_name"
                            label="Last name"
                            required
                            placeholder="Reyes"
                            :error="patientForm.errors.last_name"
                        />
                        <RadioPills
                            v-model="patientForm.sex"
                            label="Sex"
                            required
                            :options="sexOptions"
                            :error="patientForm.errors.sex"
                        />
                        <DateField
                            id="birth_date"
                            v-model="patientForm.birth_date"
                            label="Birth date"
                            required
                            :error="patientForm.errors.birth_date"
                        />
                        <RadioPills
                            v-model="patientForm.civil_status"
                            label="Civil status"
                            required
                            :options="civilStatusOptions"
                            :error="patientForm.errors.civil_status"
                        />
                        <TextInput
                            id="nationality"
                            v-model="patientForm.nationality"
                            label="Nationality"
                            required
                            :error="patientForm.errors.nationality"
                        />
                    </section>

                    <hr class="border-gray-100" />

                    <section class="space-y-5">
                        <h2 class="text-sm font-semibold text-gray-800">Contact</h2>
                        <TextInput
                            id="occupation"
                            v-model="patientForm.occupation"
                            label="Occupation"
                            placeholder="Optional"
                            :error="patientForm.errors.occupation"
                        />
                        <TextInput
                            id="contact_number"
                            v-model="patientForm.contact_number"
                            label="Contact number"
                            required
                            placeholder="0917 123 4567"
                            :error="patientForm.errors.contact_number"
                        />
                        <TextInput
                            id="address"
                            v-model="patientForm.address"
                            label="Address"
                            required
                            placeholder="House number, street, barangay, city"
                            :error="patientForm.errors.address"
                        />
                        <TextInput
                            id="email_address"
                            v-model="patientForm.email_address"
                            type="email"
                            label="Email address"
                            placeholder="Optional"
                            :error="patientForm.errors.email_address"
                        />
                    </section>

                    <hr class="border-gray-100" />

                    <section class="space-y-5">
                        <h2 class="text-sm font-semibold text-gray-800">Emergency contact</h2>
                        <TextInput
                            id="emergency_contact_person"
                            v-model="patientForm.emergency_contact_person"
                            label="Contact person"
                            placeholder="John Reyes"
                            :error="patientForm.errors.emergency_contact_person"
                        />
                        <TextInput
                            id="emergency_contact_number"
                            v-model="patientForm.emergency_contact_number"
                            label="Contact number"
                            placeholder="0917 987 6543"
                            :error="patientForm.errors.emergency_contact_number"
                        />
                    </section>

                    <hr class="border-gray-100" />

                    <section class="space-y-5">
                        <h2 class="text-sm font-semibold text-gray-800">PDA additional details</h2>
                        <p class="text-xs text-gray-500">Optional fields from the PDA patient information record.</p>
                        <TextInput
                            id="religion"
                            v-model="patientForm.religion"
                            label="Religion"
                            placeholder="Optional"
                            :error="patientForm.errors.religion"
                        />
                        <TextInput
                            id="nickname"
                            v-model="patientForm.nickname"
                            label="Nickname"
                            placeholder="Optional"
                            :error="patientForm.errors.nickname"
                        />
                        <TextInput
                            id="home_phone"
                            v-model="patientForm.home_phone"
                            label="Home phone"
                            placeholder="02 8123 4567"
                            :error="patientForm.errors.home_phone"
                        />
                        <TextInput
                            id="office_phone"
                            v-model="patientForm.office_phone"
                            label="Office phone"
                            placeholder="02 8765 4321"
                            :error="patientForm.errors.office_phone"
                        />
                        <TextInput
                            id="fax_number"
                            v-model="patientForm.fax_number"
                            label="Fax number"
                            placeholder="Optional"
                            :error="patientForm.errors.fax_number"
                        />
                        <TextInput
                            id="dental_insurance"
                            v-model="patientForm.dental_insurance"
                            label="Dental insurance"
                            placeholder="e.g. PhilHealth"
                            :error="patientForm.errors.dental_insurance"
                        />
                        <DateField
                            id="effective_date"
                            v-model="patientForm.effective_date"
                            label="Effective date"
                            :error="patientForm.errors.effective_date"
                        />
                        <TextInput
                            id="guardian_name"
                            v-model="patientForm.guardian_name"
                            label="Guardian name"
                            placeholder="For minors"
                            :error="patientForm.errors.guardian_name"
                        />
                        <TextInput
                            id="guardian_occupation"
                            v-model="patientForm.guardian_occupation"
                            label="Guardian occupation"
                            placeholder="For minors"
                            :error="patientForm.errors.guardian_occupation"
                        />
                    </section>

                    <div class="flex items-center justify-between gap-3 pt-2">
                        <p class="text-xs text-gray-500">
                            Required fields are marked with <span class="text-status-cancelled">*</span>
                        </p>
                        <Button size="md" type="submit" :disabled="patientForm.processing">
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

            <!-- 4 · Dental chart -->
            <div v-show="wizardStore.step === 4" class="space-y-6">
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
                    <Button size="md" type="button" @click="finishWizard">Finish</Button>
                </div>
            </div>
        </div>

        <!-- Footer navigation -->
        <div class="flex items-center justify-between gap-3">
            <Button variant="outline" size="md" :disabled="wizardStore.step === 0" @click="backStep">
                <ArrowLeft class="h-4 w-4" />
                Back
            </Button>
            <p class="text-sm text-gray-500">Step {{ wizardStore.step + 1 }} of {{ steps.length }}</p>
        </div>
    </div>
</template>
