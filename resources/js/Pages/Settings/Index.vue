<script setup>
import { computed } from 'vue'
import { Head, useForm } from '@inertiajs/vue3'
import { route } from '../../../../vendor/tightenco/ziggy'
import AppLayout from '@/Layouts/AppLayout.vue'
import { Button } from '@/Components/ui/button'
import FormField from '@/Components/FormField.vue'
import { Input } from '@/Components/ui/input'
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from '@/Components/ui/select'
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
                    <FormField id="clinic_name" label="Clinic name" required :error="form.errors['clinic.name']">
                        <template #default="{ id }">
                            <Input
                                :id="id"
                                v-model="form.clinic.name"
                                required
                                :aria-invalid="form.errors['clinic.name'] ? 'true' : 'false'"
                            />
                        </template>
                    </FormField>
                    <FormField id="clinic_address" label="Address" :error="form.errors['clinic.address']">
                        <template #default="{ id }">
                            <Input
                                :id="id"
                                v-model="form.clinic.address"
                                :aria-invalid="form.errors['clinic.address'] ? 'true' : 'false'"
                            />
                        </template>
                    </FormField>
                </div>
            </section>

            <section class="rounded-2xl border border-gray-200 bg-white p-6 shadow-sm">
                <h2 class="mb-4 text-xs font-semibold tracking-wide text-gray-400 uppercase">Scheduling</h2>
                <div class="grid grid-cols-1 gap-5 sm:grid-cols-2">
                    <FormField
                        id="appointment_overlap"
                        label="Allow overlapping appointments"
                        :error="form.errors['appointment.overlap']"
                    >
                        <template #default="{ id }">
                            <Select v-model="overlapValue" name="appointment_overlap">
                                <SelectTrigger
                                    :id="id"
                                    class="w-full"
                                    :aria-invalid="form.errors['appointment.overlap'] ? 'true' : 'false'"
                                >
                                    <SelectValue />
                                </SelectTrigger>
                                <SelectContent>
                                    <SelectItem value="false">No</SelectItem>
                                    <SelectItem value="true">Yes</SelectItem>
                                </SelectContent>
                            </Select>
                        </template>
                    </FormField>
                </div>
            </section>

            <section class="rounded-2xl border border-gray-200 bg-white p-6 shadow-sm">
                <h2 class="mb-4 text-xs font-semibold tracking-wide text-gray-400 uppercase">Patient records</h2>
                <div class="grid grid-cols-1 gap-5 sm:grid-cols-2">
                    <FormField
                        id="patient_number_prefix"
                        label="Patient number format"
                        :error="form.errors['patient.number.prefix']"
                    >
                        <template #default="{ id }">
                            <Select v-model="form.patient.number.prefix" name="patient_number_prefix">
                                <SelectTrigger
                                    :id="id"
                                    class="w-full"
                                    :aria-invalid="form.errors['patient.number.prefix'] ? 'true' : 'false'"
                                >
                                    <SelectValue />
                                </SelectTrigger>
                                <SelectContent>
                                    <SelectItem value="year">Year-based (YYYY-NNNN)</SelectItem>
                                </SelectContent>
                            </Select>
                        </template>
                    </FormField>
                </div>
            </section>

            <section class="rounded-2xl border border-gray-200 bg-white p-6 shadow-sm">
                <h2 class="mb-4 text-xs font-semibold tracking-wide text-gray-400 uppercase">Consent</h2>
                <div class="grid grid-cols-1 gap-5 sm:grid-cols-2">
                    <FormField id="consent_version" label="Consent form version" required :error="form.errors['consent.version']">
                        <template #default="{ id }">
                            <Input
                                :id="id"
                                v-model="form.consent.version"
                                required
                                maxlength="10"
                                :aria-invalid="form.errors['consent.version'] ? 'true' : 'false'"
                            />
                        </template>
                    </FormField>
                </div>
            </section>

            <section class="rounded-2xl border border-gray-200 bg-white p-6 shadow-sm">
                <h2 class="mb-4 text-xs font-semibold tracking-wide text-gray-400 uppercase">Uploads</h2>
                <div class="grid grid-cols-1 gap-5 sm:grid-cols-2">
                    <FormField
                        id="attachment_max_size_mb"
                        label="Max file size (MB)"
                        required
                        :error="form.errors['attachment.max_size_mb']"
                    >
                        <template #default="{ id }">
                            <Input
                                :id="id"
                                v-model="form.attachment.max_size_mb"
                                type="number"
                                required
                                min="1"
                                max="512"
                                :aria-invalid="form.errors['attachment.max_size_mb'] ? 'true' : 'false'"
                            />
                        </template>
                    </FormField>
                </div>
            </section>

            <section class="rounded-2xl border border-gray-200 bg-white p-6 shadow-sm">
                <h2 class="mb-4 text-xs font-semibold tracking-wide text-gray-400 uppercase">Archiving</h2>
                <div class="grid grid-cols-1 gap-5 sm:grid-cols-2">
                    <FormField
                        id="archive_inactivity_years"
                        label="Archive after (years)"
                        required
                        :error="form.errors['archive.inactivity_years']"
                        hint="Patients with no activity for this many years are soft-deleted, then purged after the grace period."
                    >
                        <template #default="{ id }">
                            <Input
                                :id="id"
                                v-model="form.archive.inactivity_years"
                                type="number"
                                required
                                min="1"
                                max="20"
                                :aria-invalid="form.errors['archive.inactivity_years'] ? 'true' : 'false'"
                            />
                        </template>
                    </FormField>
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
