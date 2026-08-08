<script setup>
import { computed, watch } from 'vue'
import { useForm } from '@inertiajs/vue3'
import { ChevronDown } from 'lucide-vue-next'
import { route } from '../../../../vendor/tightenco/ziggy'
import { Button } from '@/Components/ui/button'
import { CheckboxGroup, DateField, RadioPills, SelectField, TextInput, TextareaField } from '@/Components/Fields'
import { useToastStore } from '@/Stores/toast'
import { errorList, scrollToFirstError } from '@/lib/scroll'

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
const answerOptions = answers.map((value) => ({ value, label: answerLabels[value] }))

const pdaAnswers = ['no', 'yes']
const pdaAnswerLabels = { no: 'No', yes: 'Yes' }
const pdaAnswerOptions = pdaAnswers.map((value) => ({ value, label: pdaAnswerLabels[value] }))

const bloodTypes = ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-']
const bloodTypeOptions = bloodTypes.map((type) => ({ value: type, label: type }))

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

const conditionChecklistOptions = Object.entries(pdaConditionLabels).map(([value, label]) => ({
    value,
    label,
}))

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

const formErrorList = computed(() => errorList(form.errors))

const submit = () => {
    form.post(route('medical-histories.store', props.patientId), {
        preserveScroll: true,
        onSuccess: () => {
            toastStore.show('Medical history saved.')
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

        <div v-for="q in questions" :key="q.key" class="space-y-2.5">
            <RadioPills
                v-model="form[q.key]"
                :label="q.label"
                :options="answerOptions"
                :error="form.errors[q.key]"
            />
            <TextareaField
                v-if="q.detailsKey && form[q.key] === 'yes'"
                v-model="form[q.detailsKey]"
                :rows="2"
                :placeholder="`Details for ${q.label.toLowerCase()}…`"
                :error="form.errors[q.detailsKey]"
            />
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
                            <RadioPills
                                v-model="form[q.key]"
                                :label="q.label"
                                :options="pdaAnswerOptions"
                                :error="form.errors[q.key]"
                            />
                            <TextareaField
                                v-if="q.detailsKey && form[q.key] === 'yes'"
                                v-model="form[q.detailsKey]"
                                :rows="2"
                                :placeholder="`Details for ${q.label.toLowerCase()}…`"
                                :error="form.errors[q.detailsKey]"
                            />
                        </div>
                    </template>

                    <div>
                        <TextInput
                            v-model="form.bleeding_time"
                            label="Bleeding time"
                            placeholder="e.g. normal"
                            :error="form.errors.bleeding_time"
                        />
                    </div>

                    <div>
                        <SelectField
                            id="blood_type"
                            v-model="form.blood_type"
                            label="Blood type"
                            placeholder="Select blood type"
                            :options="bloodTypeOptions"
                            :error="form.errors.blood_type"
                        />
                    </div>

                    <div>
                        <TextInput
                            v-model="form.blood_pressure"
                            label="Blood pressure"
                            placeholder="e.g. 120/80"
                            :error="form.errors.blood_pressure"
                        />
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
                        <TextInput
                            v-model="form[field.key]"
                            :label="field.label"
                            :error="form.errors[field.key]"
                        />
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
                        <TextInput
                            v-model="form.dental_history_previous_dentist"
                            label="Previous dentist"
                            :error="form.errors.dental_history_previous_dentist"
                        />
                    </div>
                    <div>
                        <DateField
                            v-model="form.dental_history_last_visit"
                            label="Last dental visit"
                            :error="form.errors.dental_history_last_visit"
                        />
                    </div>
                    <div>
                        <TextInput
                            v-model="form.referral_source"
                            label="Referral source"
                            placeholder="Who may we thank for referring you?"
                            :error="form.errors.referral_source"
                        />
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
                            <RadioPills
                                v-model="form[q.key]"
                                :label="q.label"
                                :options="pdaAnswerOptions"
                                :error="form.errors[q.key]"
                            />
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
                    <CheckboxGroup
                        v-model="form.conditions_checklist"
                        :options="conditionChecklistOptions"
                        :error="form.errors.conditions_checklist"
                    />
                </div>
            </details>
        </div>

        <div>
            <TextareaField
                v-model="form.remarks"
                label="Remarks"
                :rows="3"
                placeholder="Additional notes…"
                :error="form.errors.remarks"
            />
        </div>

        <div class="flex items-center justify-end gap-2">
            <Button v-if="cancelable" variant="outline" size="md" type="button" @click="$emit('cancel')">
                Cancel
            </Button>
            <Button size="md" type="submit" :disabled="form.processing">
                {{ form.processing ? 'Saving…' : submitLabel }}
            </Button>
        </div>
    </form>
</template>
