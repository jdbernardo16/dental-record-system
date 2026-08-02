<script setup>
import { watch } from 'vue'
import { useForm } from '@inertiajs/vue3'
import { ChevronDown } from 'lucide-vue-next'
import { route } from '../../../../vendor/tightenco/ziggy'
import Button from '@/Components/Button.vue'
import { useToastStore } from '@/Stores/toast'

const props = defineProps({
    patientId: { type: Number, required: true },
    medicalHistory: { type: Object, default: null },
    submitLabel: { type: String, default: 'Save' },
    cancelable: { type: Boolean, default: true },
})

const emit = defineEmits(['saved', 'cancel'])

const toastStore = useToastStore()

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

const hydrate = (history) => {
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
}

watch(() => props.medicalHistory, hydrate, { immediate: true })

const submit = () => {
    form.post(route('medical-histories.store', props.patientId), {
        preserveScroll: true,
        onSuccess: () => {
            toastStore.show('Medical history saved.')
            emit('saved')
        },
    })
}

const inputClasses = (field) => [
    'h-11 w-full rounded-lg border bg-transparent px-4 py-2.5 text-sm text-gray-800 shadow-sm placeholder:text-gray-400 focus:border-brand-300 focus:outline-hidden focus:ring-2 focus:ring-brand-500/10',
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
                :class="textareaClasses(q.detailsKey)"
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
                                :class="textareaClasses(q.detailsKey)"
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
                            :class="inputClasses('bleeding_time')"
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
                            :class="inputClasses('blood_type')"
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
                            :class="inputClasses('blood_pressure')"
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
                        <input v-model="form[field.key]" type="text" :class="inputClasses(field.key)" />
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
                            :class="inputClasses('dental_history_previous_dentist')"
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
                            :class="inputClasses('dental_history_last_visit')"
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
                            :class="inputClasses('referral_source')"
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
                :class="textareaClasses('remarks')"
            />
            <p v-if="form.errors.remarks" class="mt-1.5 text-xs text-status-cancelled">{{ form.errors.remarks }}</p>
        </div>

        <div class="flex items-center justify-end gap-2">
            <Button v-if="cancelable" variant="outline" type="button" @click="$emit('cancel')">Cancel</Button>
            <Button type="submit" :disabled="form.processing">{{ form.processing ? 'Saving…' : submitLabel }}</Button>
        </div>
    </form>
</template>
