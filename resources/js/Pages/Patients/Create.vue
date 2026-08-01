<script setup>
import { Head, Link, useForm } from '@inertiajs/vue3'
import { route } from '../../../../vendor/tightenco/ziggy'
import AppLayout from '@/Layouts/AppLayout.vue'
import Button from '@/Components/Button.vue'
import Input from '@/Components/Input.vue'
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
})

const submit = () => {
    form.post(route('patients.store'), {
        preserveScroll: true,
        onSuccess: () => toastStore.show('Patient registered.'),
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
                <Input
                    v-model="form.first_name"
                    label="First name"
                    placeholder="Liza"
                    required
                    autofocus
                    :error="form.errors.first_name"
                />
                <Input
                    v-model="form.middle_name"
                    label="Middle name"
                    placeholder="Optional"
                    :error="form.errors.middle_name"
                />
                <Input
                    v-model="form.last_name"
                    label="Last name"
                    placeholder="Reyes"
                    required
                    :error="form.errors.last_name"
                />
                <div>
                    <label for="sex" class="mb-1.5 block text-sm font-medium text-gray-700">
                        Sex
                        <span class="text-status-cancelled">*</span>
                    </label>
                    <select
                        id="sex"
                        v-model="form.sex"
                        required
                        :aria-invalid="form.errors.sex ? 'true' : 'false'"
                        class="h-11 w-full rounded-lg border border-gray-300 bg-transparent px-4 py-2.5 text-sm text-gray-800 shadow-sm focus:border-brand-300 focus:outline-hidden focus:ring-2 focus:ring-brand-500/10"
                        :class="{ 'border-status-cancelled': form.errors.sex }"
                    >
                        <option value="" disabled>Select sex</option>
                        <option v-for="option in sexOptions" :key="option.value" :value="option.value">
                            {{ option.label }}
                        </option>
                    </select>
                    <p v-if="form.errors.sex" class="mt-1.5 text-xs text-status-cancelled">{{ form.errors.sex }}</p>
                </div>
                <Input
                    v-model="form.birth_date"
                    type="date"
                    label="Birth date"
                    required
                    :error="form.errors.birth_date"
                />
                <div>
                    <label for="civil_status" class="mb-1.5 block text-sm font-medium text-gray-700">
                        Civil status
                        <span class="text-status-cancelled">*</span>
                    </label>
                    <select
                        id="civil_status"
                        v-model="form.civil_status"
                        required
                        :aria-invalid="form.errors.civil_status ? 'true' : 'false'"
                        class="h-11 w-full rounded-lg border border-gray-300 bg-transparent px-4 py-2.5 text-sm text-gray-800 shadow-sm focus:border-brand-300 focus:outline-hidden focus:ring-2 focus:ring-brand-500/10"
                        :class="{ 'border-status-cancelled': form.errors.civil_status }"
                    >
                        <option value="" disabled>Select civil status</option>
                        <option v-for="option in civilStatusOptions" :key="option.value" :value="option.value">
                            {{ option.label }}
                        </option>
                    </select>
                    <p v-if="form.errors.civil_status" class="mt-1.5 text-xs text-status-cancelled">{{ form.errors.civil_status }}</p>
                </div>
                <Input
                    v-model="form.nationality"
                    label="Nationality"
                    required
                    :error="form.errors.nationality"
                />
            </section>

            <hr class="border-gray-100" />

            <section class="space-y-5">
                <h2 class="text-sm font-semibold text-gray-800">Contact</h2>
                <Input
                    v-model="form.occupation"
                    label="Occupation"
                    placeholder="Optional"
                    :error="form.errors.occupation"
                />
                <Input
                    v-model="form.contact_number"
                    label="Contact number"
                    placeholder="0917 123 4567"
                    required
                    :error="form.errors.contact_number"
                />
                <Input
                    v-model="form.address"
                    label="Address"
                    placeholder="House number, street, barangay, city"
                    required
                    :error="form.errors.address"
                />
                <Input
                    v-model="form.email_address"
                    type="email"
                    label="Email address"
                    placeholder="Optional"
                    :error="form.errors.email_address"
                />
            </section>

            <hr class="border-gray-100" />

            <section class="space-y-5">
                <h2 class="text-sm font-semibold text-gray-800">Emergency contact</h2>
                <Input
                    v-model="form.emergency_contact_person"
                    label="Contact person"
                    placeholder="John Reyes"
                    required
                    :error="form.errors.emergency_contact_person"
                />
                <Input
                    v-model="form.emergency_contact_number"
                    label="Contact number"
                    placeholder="0917 987 6543"
                    required
                    :error="form.errors.emergency_contact_number"
                />
            </section>

            <div class="flex items-center justify-end gap-3 pt-2">
                <Link :href="route('patients.index')">
                    <Button variant="outline" size="sm" :disabled="form.processing">Cancel</Button>
                </Link>
                <Button type="submit" size="sm" :disabled="form.processing">
                    {{ form.processing ? 'Saving…' : 'Register patient' }}
                </Button>
            </div>
        </form>
    </div>
</template>
