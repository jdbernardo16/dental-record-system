<script setup>
import { scrollToFirstError } from '@/lib/scroll'
import { Head, Link, useForm } from '@inertiajs/vue3'
import { route } from '../../../../vendor/tightenco/ziggy'
import AppLayout from '@/Layouts/AppLayout.vue'
import { DateField, RadioPills, TextInput } from '@/Components/Fields'
import { Button } from '@/Components/ui/button'
import { useToastStore } from '@/Stores/toast'

defineOptions({ layout: AppLayout })

const props = defineProps({
    sexOptions: { type: Array, required: true },
    civilStatusOptions: { type: Array, required: true },
})

const toastStore = useToastStore()

const form = useForm({
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
})

const submit = () => {
    form.post(route('patients.store'), {
        preserveScroll: true,
        onSuccess: () => toastStore.show('Patient registered.'),
        onError: () => scrollToFirstError(),
    })
}
</script>

<template>
    <Head title="Register patient" />

    <div class="mx-auto max-w-2xl space-y-6">
        <div>
            <h1 class="text-2xl font-semibold text-gray-800">Register patient</h1>
            <p class="mt-1 text-sm text-gray-500">Enter the patient's personal and contact details.</p>
        </div>

        <form class="space-y-6 rounded-2xl border border-gray-200 bg-white p-6 shadow-sm" @submit.prevent="submit">
            <section class="space-y-5">
                <h2 class="text-sm font-semibold text-gray-800">Identity</h2>
                <TextInput
                    v-model="form.first_name"
                    label="First name"
                    required
                    :error="form.errors.first_name"
                    placeholder="Liza"
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
                    placeholder="Reyes"
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
                    placeholder="0917 123 4567"
                />
                <TextInput
                    v-model="form.address"
                    label="Address"
                    required
                    :error="form.errors.address"
                    placeholder="House number, street, barangay, city"
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
                    placeholder="John Reyes"
                />
                <TextInput
                    v-model="form.emergency_contact_number"
                    label="Contact number"
                    required
                    :error="form.errors.emergency_contact_number"
                    placeholder="0917 987 6543"
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
                <Link :href="route('patients.index')">
                    <Button variant="outline" :disabled="form.processing">Cancel</Button>
                </Link>
                <Button type="submit" :disabled="form.processing">
                    {{ form.processing ? 'Saving…' : 'Register patient' }}
                </Button>
            </div>
        </form>
    </div>
</template>
