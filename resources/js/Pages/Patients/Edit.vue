<script setup>
import { Head, Link, router, useForm } from '@inertiajs/vue3'
import { Trash2 } from 'lucide-vue-next'
import { route } from '../../../../vendor/tightenco/ziggy'
import AppLayout from '@/Layouts/AppLayout.vue'
import Badge from '@/Components/Badge.vue'
import Button from '@/Components/Button.vue'
import Input from '@/Components/Input.vue'
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
})

const submit = () => {
    form.patch(route('patients.update', props.patient.id), {
        preserveScroll: true,
        onSuccess: () => toastStore.show('Patient updated.'),
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
                <Input
                    v-model="form.first_name"
                    label="First name"
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
                    required
                    :error="form.errors.contact_number"
                />
                <Input
                    v-model="form.address"
                    label="Address"
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
                    required
                    :error="form.errors.emergency_contact_person"
                />
                <Input
                    v-model="form.emergency_contact_number"
                    label="Contact number"
                    required
                    :error="form.errors.emergency_contact_number"
                />
            </section>

            <div class="flex items-center justify-end gap-3 pt-2">
                <Link :href="route('patients.show', patient.id)">
                    <Button variant="outline" size="sm" :disabled="form.processing">Cancel</Button>
                </Link>
                <Button type="submit" size="sm" :disabled="form.processing">
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
                    class="inline-flex h-11 items-center justify-center rounded-lg border border-gray-300 bg-white px-5 py-3 text-sm font-medium text-gray-700 hover:bg-gray-50"
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
            <Button variant="outline" size="sm" class="border-status-cancelled/30 text-status-cancelled hover:bg-status-cancelled/10" @click="confirmDelete">
                <Trash2 class="h-4 w-4" />
                Delete patient
            </Button>
        </div>
    </div>
</template>
