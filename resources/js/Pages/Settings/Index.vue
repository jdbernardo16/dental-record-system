<script setup>
import { scrollToFirstError } from '@/lib/scroll'
import { computed } from 'vue'
import { Head, useForm } from '@inertiajs/vue3'
import { route } from '../../../../vendor/tightenco/ziggy'
import AppLayout from '@/Layouts/AppLayout.vue'
import { Button } from '@/Components/ui/button'
import { SelectField, TextInput } from '@/Components/Fields'
import { useToastStore } from '@/Stores/toast'

defineOptions({ layout: AppLayout })

const props = defineProps({
    settings: { type: Object, default: () => ({}) },
    can: { type: Object, default: () => ({ update: false }) },
})

const toastStore = useToastStore()

const form = useForm({
    clinic: {
        name: props.settings['clinic.name'] ?? '',
        address: props.settings['clinic.address'] ?? '',
    },
    consent: {
        version: props.settings['consent.version'] ?? '',
    },
    patient: {
        number: {
            prefix: props.settings['patient.number.prefix'] ?? 'year',
        },
    },
    appointment: {
        overlap: props.settings['appointment.overlap'] === 'true',
    },
    attachment: {
        max_size_mb: props.settings['attachment.max_size_mb'] ?? '',
    },
    archive: {
        inactivity_years: props.settings['archive.inactivity_years'] ?? '',
    },
})

// The backend validates appointment.overlap as a real boolean, so keep the form
// value boolean while the select works with string option values.
const overlapValue = computed({
    get: () => String(form.appointment.overlap),
    set: (value) => {
        form.appointment.overlap = value === 'true'
    },
})

const submit = () => {
    form.patch(route('settings.update'), {
        preserveScroll: true,
        onSuccess: () => toastStore.show('Settings saved.'),
        onError: () => scrollToFirstError(),
    })
}
</script>

<template>
    <Head title="Settings" />

    <div class="mx-auto max-w-3xl space-y-6">
        <div>
            <h1 class="text-2xl font-semibold text-gray-800">Settings</h1>
            <p class="mt-1 text-sm text-gray-500">Clinic-wide configuration.</p>
        </div>

        <form class="space-y-6" @submit.prevent="submit">
            <section class="rounded-2xl border border-gray-200 bg-white p-6 shadow-sm">
                <h2 class="mb-4 text-xs font-semibold tracking-wide text-gray-400 uppercase">General</h2>
                <div class="grid grid-cols-1 gap-5 sm:grid-cols-2">
                    <TextInput
                        id="clinic_name"
                        v-model="form.clinic.name"
                        label="Clinic name"
                        required
                        :error="form.errors['clinic.name']"
                    />
                    <TextInput
                        id="clinic_address"
                        v-model="form.clinic.address"
                        label="Address"
                        :error="form.errors['clinic.address']"
                    />
                </div>
            </section>

            <section class="rounded-2xl border border-gray-200 bg-white p-6 shadow-sm">
                <h2 class="mb-4 text-xs font-semibold tracking-wide text-gray-400 uppercase">Scheduling</h2>
                <div class="grid grid-cols-1 gap-5 sm:grid-cols-2">
                    <SelectField
                        id="appointment_overlap"
                        v-model="overlapValue"
                        label="Allow overlapping appointments"
                        :options="[
                            { value: 'false', label: 'No' },
                            { value: 'true', label: 'Yes' },
                        ]"
                        :error="form.errors['appointment.overlap']"
                    />
                </div>
            </section>

            <section class="rounded-2xl border border-gray-200 bg-white p-6 shadow-sm">
                <h2 class="mb-4 text-xs font-semibold tracking-wide text-gray-400 uppercase">Patient records</h2>
                <div class="grid grid-cols-1 gap-5 sm:grid-cols-2">
                    <SelectField
                        id="patient_number_prefix"
                        v-model="form.patient.number.prefix"
                        label="Patient number format"
                        :options="[{ value: 'year', label: 'Year-based (YYYY-NNNN)' }]"
                        :error="form.errors['patient.number.prefix']"
                    />
                </div>
            </section>

            <section class="rounded-2xl border border-gray-200 bg-white p-6 shadow-sm">
                <h2 class="mb-4 text-xs font-semibold tracking-wide text-gray-400 uppercase">Consent</h2>
                <div class="grid grid-cols-1 gap-5 sm:grid-cols-2">
                    <TextInput
                        id="consent_version"
                        v-model="form.consent.version"
                        label="Consent form version"
                        required
                        maxlength="10"
                        :error="form.errors['consent.version']"
                    />
                </div>
            </section>

            <section class="rounded-2xl border border-gray-200 bg-white p-6 shadow-sm">
                <h2 class="mb-4 text-xs font-semibold tracking-wide text-gray-400 uppercase">Uploads</h2>
                <div class="grid grid-cols-1 gap-5 sm:grid-cols-2">
                    <TextInput
                        id="attachment_max_size_mb"
                        v-model="form.attachment.max_size_mb"
                        type="number"
                        label="Max file size (MB)"
                        required
                        min="1"
                        max="512"
                        :error="form.errors['attachment.max_size_mb']"
                    />
                </div>
            </section>

            <section class="rounded-2xl border border-gray-200 bg-white p-6 shadow-sm">
                <h2 class="mb-4 text-xs font-semibold tracking-wide text-gray-400 uppercase">Archiving</h2>
                <div class="grid grid-cols-1 gap-5 sm:grid-cols-2">
                    <TextInput
                        id="archive_inactivity_years"
                        v-model="form.archive.inactivity_years"
                        type="number"
                        label="Archive after (years)"
                        required
                        min="1"
                        max="20"
                        hint="Patients with no activity for this many years are soft-deleted, then purged after the grace period."
                        :error="form.errors['archive.inactivity_years']"
                    />
                </div>
            </section>

            <div class="flex justify-end">
                <Button v-if="can.update" type="submit" :disabled="form.processing">
                    {{ form.processing ? 'Saving…' : 'Save settings' }}
                </Button>
            </div>
        </form>
    </div>
</template>
