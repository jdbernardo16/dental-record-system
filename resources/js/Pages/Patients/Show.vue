<script setup>
import { Head, Link, router } from '@inertiajs/vue3'
import { CalendarDays, FileText, FolderOpen, Pencil, Stethoscope, Trash2, Wrench } from 'lucide-vue-next'
import { route } from '../../../../vendor/tightenco/ziggy'
import AppLayout from '@/Layouts/AppLayout.vue'
import Badge from '@/Components/Badge.vue'
import Button from '@/Components/Button.vue'
import { useToastStore } from '@/Stores/toast'

defineOptions({ layout: AppLayout })

const props = defineProps({
    patient: { type: Object, required: true },
    can: { type: Object, default: () => ({}) },
})

const toastStore = useToastStore()

const fullName = () =>
    [props.patient.first_name, props.patient.middle_name, props.patient.last_name]
        .filter(Boolean)
        .join(' ')

const initials = () =>
    fullName()
        .split(' ')
        .map((part) => part[0])
        .slice(0, 2)
        .join('')
        .toUpperCase()

const sexLabel = () => ({ male: 'Male', female: 'Female' })[props.patient.sex] ?? props.patient.sex

const civilStatusLabel = () =>
    ({
        single: 'Single',
        married: 'Married',
        widowed: 'Widowed',
        separated: 'Separated',
        divorced: 'Divorced',
        annulled: 'Annulled',
        other: 'Other',
    })[props.patient.civil_status] ?? props.patient.civil_status

const confirmDelete = () => {
    if (window.confirm(`Delete ${fullName()}? The record can be restored by an administrator.`)) {
        router.delete(route('patients.destroy', props.patient.id), {
            onSuccess: () => toastStore.show('Patient deleted.'),
        })
    }
}

const tabs = [
    { name: 'Appointments', icon: CalendarDays, phase: 'Phase 2' },
    { name: 'Chart', icon: Stethoscope, phase: 'Phase 2' },
    { name: 'Treatments', icon: Wrench, phase: 'Phase 2' },
    { name: 'Files', icon: FolderOpen, phase: 'Phase 2' },
    { name: 'Consents', icon: FileText, phase: 'Phase 3' },
]
</script>

<template>
    <Head :title="fullName()" />

    <div class="mx-auto max-w-4xl space-y-6">
        <div class="flex flex-wrap items-center justify-between gap-4">
            <div>
                <h1 class="text-2xl font-semibold text-gray-800">Patient record</h1>
                <p class="mt-1 text-sm text-gray-500">{{ patient.patient_number }}</p>
            </div>
            <div class="flex items-center gap-2">
                <Link v-if="can.update" :href="route('patients.edit', patient.id)">
                    <Button variant="outline" size="sm">
                        <Pencil class="h-4 w-4" />
                        Edit
                    </Button>
                </Link>
                <Button
                    v-if="can.delete"
                    variant="outline"
                    size="sm"
                    class="border-status-cancelled/30 text-status-cancelled hover:bg-status-cancelled/10"
                    @click="confirmDelete"
                >
                    <Trash2 class="h-4 w-4" />
                    Delete
                </Button>
            </div>
        </div>

        <div class="rounded-2xl border border-gray-200 bg-white p-6 shadow-sm">
            <div class="flex flex-wrap items-center gap-4">
                <span class="flex h-14 w-14 shrink-0 items-center justify-center rounded-full bg-brand-500 text-lg font-semibold text-white">
                    {{ initials() }}
                </span>
                <div class="min-w-0">
                    <h2 class="truncate text-lg font-semibold text-gray-800">{{ fullName() }}</h2>
                    <div class="mt-1.5 flex flex-wrap items-center gap-2">
                        <Badge size="sm" color="info">{{ patient.age }} yrs old</Badge>
                        <Badge size="sm" color="light">{{ sexLabel() }}</Badge>
                        <Badge size="sm" color="primary">{{ civilStatusLabel() }}</Badge>
                    </div>
                </div>
            </div>
        </div>

        <div class="rounded-2xl border border-gray-200 bg-white shadow-sm">
            <div class="grid grid-cols-1 gap-x-8 gap-y-6 p-6 sm:grid-cols-2">
                <div class="space-y-4">
                    <h3 class="text-xs font-semibold tracking-wide text-gray-400 uppercase">Identity</h3>
                    <dl class="space-y-3 text-sm">
                        <div class="flex items-start justify-between gap-4">
                            <dt class="text-gray-500">Full name</dt>
                            <dd class="text-right font-medium text-gray-800">{{ fullName() }}</dd>
                        </div>
                        <div class="flex items-start justify-between gap-4">
                            <dt class="text-gray-500">Birth date</dt>
                            <dd class="text-right font-medium text-gray-800">{{ patient.birth_date }}</dd>
                        </div>
                        <div class="flex items-start justify-between gap-4">
                            <dt class="text-gray-500">Nationality</dt>
                            <dd class="text-right font-medium text-gray-800">{{ patient.nationality }}</dd>
                        </div>
                        <div class="flex items-start justify-between gap-4">
                            <dt class="text-gray-500">Occupation</dt>
                            <dd class="text-right font-medium text-gray-800">{{ patient.occupation || '—' }}</dd>
                        </div>
                    </dl>
                </div>

                <div class="space-y-4">
                    <h3 class="text-xs font-semibold tracking-wide text-gray-400 uppercase">Contact</h3>
                    <dl class="space-y-3 text-sm">
                        <div class="flex items-start justify-between gap-4">
                            <dt class="text-gray-500">Contact number</dt>
                            <dd class="text-right font-medium text-gray-800">{{ patient.contact_number }}</dd>
                        </div>
                        <div class="flex items-start justify-between gap-4">
                            <dt class="text-gray-500">Email address</dt>
                            <dd class="text-right font-medium text-gray-800">{{ patient.email_address || '—' }}</dd>
                        </div>
                        <div class="flex items-start justify-between gap-4">
                            <dt class="text-gray-500">Address</dt>
                            <dd class="max-w-56 text-right font-medium text-gray-800">{{ patient.address }}</dd>
                        </div>
                    </dl>
                </div>

                <div class="space-y-4 sm:col-span-2">
                    <h3 class="text-xs font-semibold tracking-wide text-gray-400 uppercase">Emergency contact</h3>
                    <dl class="grid grid-cols-1 gap-3 text-sm sm:grid-cols-2">
                        <div class="flex items-start justify-between gap-4">
                            <dt class="text-gray-500">Contact person</dt>
                            <dd class="text-right font-medium text-gray-800">{{ patient.emergency_contact_person }}</dd>
                        </div>
                        <div class="flex items-start justify-between gap-4">
                            <dt class="text-gray-500">Contact number</dt>
                            <dd class="text-right font-medium text-gray-800">{{ patient.emergency_contact_number }}</dd>
                        </div>
                    </dl>
                </div>
            </div>
        </div>

        <div class="overflow-hidden rounded-2xl border border-gray-200 bg-white shadow-sm">
            <div class="flex gap-1 border-b border-gray-100 px-4 pt-3">
                <button
                    v-for="tab in tabs"
                    :key="tab.name"
                    type="button"
                    disabled
                    :title="`${tab.name} — coming in ${tab.phase}`"
                    class="inline-flex cursor-not-allowed items-center gap-2 rounded-t-lg px-4 py-2.5 text-sm font-medium text-gray-400"
                >
                    <component :is="tab.icon" class="h-4 w-4" />
                    {{ tab.name }}
                    <Badge size="sm" color="light">{{ tab.phase }}</Badge>
                </button>
            </div>
            <div class="flex flex-col items-center gap-2 px-6 py-14 text-center">
                <p class="text-sm font-medium text-gray-700">No records yet</p>
                <p class="text-sm text-gray-500">
                    Appointments, chart, treatments, files, and consents will appear here in later phases.
                </p>
            </div>
        </div>
    </div>
</template>
