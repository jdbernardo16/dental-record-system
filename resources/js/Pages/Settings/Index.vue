<script setup>
import { Head, useForm } from '@inertiajs/vue3'
import { route } from '../../../../vendor/tightenco/ziggy'
import AppLayout from '@/Layouts/AppLayout.vue'
import Button from '@/Components/Button.vue'
import Input from '@/Components/Input.vue'
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

const selectClasses = (field) => [
    'h-11 w-full rounded-lg border bg-transparent px-4 py-2.5 text-sm text-gray-800 shadow-sm focus:border-brand-300 focus:outline-hidden focus:ring-2 focus:ring-brand-500/10',
    form.errors[field] ? 'border-status-cancelled' : 'border-gray-300',
]

const submit = () => {
    form.patch(route('settings.update'), {
        preserveScroll: true,
        onSuccess: () => toastStore.show('Settings saved.'),
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
                    <Input
                        v-model="form.clinic.name"
                        label="Clinic name"
                        required
                        :error="form.errors['clinic.name']"
                    />
                    <Input
                        v-model="form.clinic.address"
                        label="Address"
                        :error="form.errors['clinic.address']"
                    />
                </div>
            </section>

            <section class="rounded-2xl border border-gray-200 bg-white p-6 shadow-sm">
                <h2 class="mb-4 text-xs font-semibold tracking-wide text-gray-400 uppercase">Scheduling</h2>
                <div class="grid grid-cols-1 gap-5 sm:grid-cols-2">
                    <div>
                        <label for="appointment_overlap" class="mb-1.5 block text-sm font-medium text-gray-700">
                            Allow overlapping appointments
                        </label>
                        <select
                            id="appointment_overlap"
                            v-model="form.appointment.overlap"
                            :class="selectClasses('appointment.overlap')"
                        >
                            <option :value="false">No</option>
                            <option :value="true">Yes</option>
                        </select>
                        <p v-if="form.errors['appointment.overlap']" class="mt-1.5 text-xs text-status-cancelled">
                            {{ form.errors['appointment.overlap'] }}
                        </p>
                    </div>
                </div>
            </section>

            <section class="rounded-2xl border border-gray-200 bg-white p-6 shadow-sm">
                <h2 class="mb-4 text-xs font-semibold tracking-wide text-gray-400 uppercase">Patient records</h2>
                <div class="grid grid-cols-1 gap-5 sm:grid-cols-2">
                    <div>
                        <label for="patient_number_prefix" class="mb-1.5 block text-sm font-medium text-gray-700">
                            Patient number format
                        </label>
                        <select
                            id="patient_number_prefix"
                            v-model="form.patient.number.prefix"
                            :class="selectClasses('patient.number.prefix')"
                        >
                            <option value="year">Year-based (YYYY-NNNN)</option>
                        </select>
                        <p v-if="form.errors['patient.number.prefix']" class="mt-1.5 text-xs text-status-cancelled">
                            {{ form.errors['patient.number.prefix'] }}
                        </p>
                    </div>
                </div>
            </section>

            <section class="rounded-2xl border border-gray-200 bg-white p-6 shadow-sm">
                <h2 class="mb-4 text-xs font-semibold tracking-wide text-gray-400 uppercase">Consent</h2>
                <div class="grid grid-cols-1 gap-5 sm:grid-cols-2">
                    <Input
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
                    <Input
                        v-model="form.attachment.max_size_mb"
                        label="Max file size (MB)"
                        type="number"
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
                    <div>
                        <Input
                            v-model="form.archive.inactivity_years"
                            label="Archive after (years)"
                            type="number"
                            required
                            min="1"
                            max="20"
                            :error="form.errors['archive.inactivity_years']"
                        />
                        <p class="mt-1.5 text-xs text-gray-500">
                            Patients with no activity for this many years are soft-deleted, then purged after the
                            grace period.
                        </p>
                    </div>
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
