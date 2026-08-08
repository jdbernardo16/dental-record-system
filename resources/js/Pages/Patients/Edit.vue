<script setup>
import { scrollToFirstError } from '@/lib/scroll'
import { Head, Link, router, useForm } from '@inertiajs/vue3'
import { Trash2 } from 'lucide-vue-next'
import { route } from '../../../../vendor/tightenco/ziggy'
import AppLayout from '@/Layouts/AppLayout.vue'
import Badge from '@/Components/Badge.vue'
import { DateField, RadioPills, TextInput } from '@/Components/Fields'
import { Button } from '@/Components/ui/button'
import { useToastStore } from '@/Stores/toast'

defineOptions({ layout: AppLayout })

const props = defineProps({
    patient: { type: Object, required: true },
    sexOptions: { type: Array, required: true },
    civilStatusOptions: { type: Array, required: true },
    can: { type: Object, default: () => ({}) },
})

const toastStore = useToastStore()

const fullName = () =>
    [props.patient.first_name, props.patient.middle_name, props.patient.last_name]
        .filter(Boolean)
        .join(' ')

const form = useForm({
    first_name: props.patient.first_name,
    middle_name: props.patient.middle_name ?? '',
    last_name: props.patient.last_name,
    sex: props.patient.sex,
    birth_date: props.patient.birth_date,
    civil_status: props.patient.civil_status,
    nationality: props.patient.nationality,
    occupation: props.patient.occupation ?? '',
    contact_number: props.patient.contact_number,
    address: props.patient.address,
    email_address: props.patient.email_address ?? '',
    emergency_contact_person: props.patient.emergency_contact_person,
    emergency_contact_number: props.patient.emergency_contact_number,
    religion: props.patient.religion ?? '',
    nickname: props.patient.nickname ?? '',
    home_phone: props.patient.home_phone ?? '',
    office_phone: props.patient.office_phone ?? '',
    fax_number: props.patient.fax_number ?? '',
    dental_insurance: props.patient.dental_insurance ?? '',
    effective_date: props.patient.effective_date ?? '',
    guardian_name: props.patient.guardian_name ?? '',
    guardian_occupation: props.patient.guardian_occupation ?? '',
})

const submit = () => {
    form.patch(route('patients.update', props.patient.id), {
        preserveScroll: true,
        onSuccess: () => toastStore.show('Patient updated.'),
        onError: () => scrollToFirstError(),
    })
}

const confirmDelete = () => {
    if (window.confirm(`Delete ${fullName()}? The record can be restored by an administrator.`)) {
        router.delete(route('patients.destroy', props.patient.id), {
            onSuccess: () => toastStore.show('Patient deleted.'),
        })
    }
}
</script>

<template>
    <Head :title="`Edit ${fullName()}`" />

    <div class="mx-auto max-w-2xl space-y-6">
        <div>
            <h1 class="text-2xl font-semibold text-gray-800">Edit patient</h1>
            <p class="mt-1 text-sm text-gray-500">{{ fullName() }} — update personal and contact details.</p>
        </div>

        <form v-if="can.update" class="space-y-6 rounded-2xl border border-gray-200 bg-white p-6 shadow-sm" @submit.prevent="submit">
            <div class="rounded-xl bg-gray-50 px-4 py-3">
                <p class="text-sm font-medium text-gray-800">Patient number</p>
                <p class="text-xs text-gray-500">{{ patient.patient_number }} — assigned at registration and cannot be changed.</p>
            </div>

            <section class="space-y-5">
                <h2 class="text-sm font-semibold text-gray-800">Identity</h2>
                <TextInput
                    v-model="form.first_name"
                    label="First name"
                    required
                    :error="form.errors.first_name"
                    autofocus
                />
                <TextInput
                    v-model="form.middle_name"
                    label="Middle name"
                    :error="form.errors.middle_name"
                    placeholder="Optional"
                />
                <TextInput
                    v-model="form.last_name"
                    label="Last name"
                    required
                    :error="form.errors.last_name"
                />
                <RadioPills
                    v-model="form.sex"
                    label="Sex"
                    required
                    :error="form.errors.sex"
                    :options="sexOptions"
                />
                <DateField v-model="form.birth_date" label="Birth date" required :error="form.errors.birth_date" />
                <RadioPills
                    v-model="form.civil_status"
                    label="Civil status"
                    required
                    :error="form.errors.civil_status"
                    :options="civilStatusOptions"
                />
                <TextInput
                    v-model="form.nationality"
                    label="Nationality"
                    required
                    :error="form.errors.nationality"
                />
            </section>

            <hr class="border-gray-100" />

            <section class="space-y-5">
                <h2 class="text-sm font-semibold text-gray-800">Contact</h2>
                <TextInput
                    v-model="form.occupation"
                    label="Occupation"
                    :error="form.errors.occupation"
                    placeholder="Optional"
                />
                <TextInput
                    v-model="form.contact_number"
                    label="Contact number"
                    required
                    :error="form.errors.contact_number"
                />
                <TextInput
                    v-model="form.address"
                    label="Address"
                    required
                    :error="form.errors.address"
                />
                <TextInput
                    v-model="form.email_address"
                    label="Email address"
                    type="email"
                    :error="form.errors.email_address"
                    placeholder="Optional"
                />
            </section>

            <hr class="border-gray-100" />

            <section class="space-y-5">
                <h2 class="text-sm font-semibold text-gray-800">Emergency contact</h2>
                <TextInput
                    v-model="form.emergency_contact_person"
                    label="Contact person"
                    required
                    :error="form.errors.emergency_contact_person"
                />
                <TextInput
                    v-model="form.emergency_contact_number"
                    label="Contact number"
                    required
                    :error="form.errors.emergency_contact_number"
                />
            </section>

            <hr class="border-gray-100" />

            <section class="space-y-5">
                <h2 class="text-sm font-semibold text-gray-800">PDA additional details</h2>
                <p class="text-xs text-gray-500">Optional fields from the PDA patient information record.</p>
                <TextInput
                    v-model="form.religion"
                    label="Religion"
                    :error="form.errors.religion"
                    placeholder="Optional"
                />
                <TextInput
                    v-model="form.nickname"
                    label="Nickname"
                    :error="form.errors.nickname"
                    placeholder="Optional"
                />
                <TextInput
                    v-model="form.home_phone"
                    label="Home phone"
                    :error="form.errors.home_phone"
                    placeholder="02 8123 4567"
                />
                <TextInput
                    v-model="form.office_phone"
                    label="Office phone"
                    :error="form.errors.office_phone"
                    placeholder="02 8765 4321"
                />
                <TextInput
                    v-model="form.fax_number"
                    label="Fax number"
                    :error="form.errors.fax_number"
                    placeholder="Optional"
                />
                <TextInput
                    v-model="form.dental_insurance"
                    label="Dental insurance"
                    :error="form.errors.dental_insurance"
                    placeholder="e.g. PhilHealth"
                />
                <DateField v-model="form.effective_date" label="Effective date" :error="form.errors.effective_date" />
                <TextInput
                    v-model="form.guardian_name"
                    label="Guardian name"
                    :error="form.errors.guardian_name"
                    placeholder="For minors"
                />
                <TextInput
                    v-model="form.guardian_occupation"
                    label="Guardian occupation"
                    :error="form.errors.guardian_occupation"
                    placeholder="For minors"
                />
            </section>

            <div class="flex items-center justify-end gap-3 pt-2">
                <Link :href="route('patients.show', patient.id)">
                    <Button variant="outline" :disabled="form.processing">Cancel</Button>
                </Link>
                <Button type="submit" :disabled="form.processing">
                    {{ form.processing ? 'Saving…' : 'Save changes' }}
                </Button>
            </div>
        </form>

        <div v-else class="space-y-5 rounded-2xl border border-gray-200 bg-white p-6 shadow-sm">
            <dl class="divide-y divide-gray-100">
                <div class="flex items-center justify-between py-3 first:pt-0 last:pb-0">
                    <dt class="text-sm font-medium text-gray-500">Full name</dt>
                    <dd class="text-sm font-medium text-gray-800">{{ fullName() }}</dd>
                </div>
                <div class="flex items-center justify-between py-3">
                    <dt class="text-sm font-medium text-gray-500">Patient number</dt>
                    <dd class="text-sm text-gray-800">{{ patient.patient_number }}</dd>
                </div>
                <div class="flex items-center justify-between py-3">
                    <dt class="text-sm font-medium text-gray-500">Age</dt>
                    <dd>
                        <Badge size="sm" color="info">{{ patient.age }} yrs old</Badge>
                    </dd>
                </div>
            </dl>
            <div class="pt-2">
                <Link
                    :href="route('patients.show', patient.id)"
                    class="inline-flex min-h-11 items-center justify-center rounded-lg border border-gray-300 bg-white px-5 py-3 text-sm font-medium text-gray-700 hover:bg-gray-50"
                >
                    Back to record
                </Link>
            </div>
        </div>

        <div v-if="can.delete" class="flex items-center justify-between rounded-2xl border border-status-cancelled/20 bg-status-cancelled/5 p-6">
            <div>
                <p class="text-sm font-semibold text-gray-800">Danger zone</p>
                <p class="mt-0.5 text-sm text-gray-500">Soft-delete this patient record. It can be restored by an administrator.</p>
            </div>
            <Button variant="destructive" @click="confirmDelete">
                <Trash2 class="h-4 w-4" />
                Delete patient
            </Button>
        </div>
    </div>
</template>
