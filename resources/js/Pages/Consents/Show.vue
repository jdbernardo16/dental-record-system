<script setup>
import { computed } from 'vue'
import { Head, Link } from '@inertiajs/vue3'
import { FileText, Printer } from 'lucide-vue-next'
import { route } from '../../../../vendor/tightenco/ziggy'
import AppLayout from '@/Layouts/AppLayout.vue'
import Badge from '@/Components/Badge.vue'
import { Button } from '@/Components/ui/button'
import { useToastStore } from '@/Stores/toast'

defineOptions({ layout: AppLayout })

const props = defineProps({
    consent: { type: Object, required: true },
})

const toastStore = useToastStore()

const patient = computed(() => props.consent.patient)

const statusBadgeColor = () =>
    ({
        unsigned: 'warning',
        patient_signed: 'info',
        signed: 'success',
        voided: 'error',
    })[props.consent.status] ?? 'light'

const statusLabel = () =>
    ({
        unsigned: 'Unsigned',
        patient_signed: 'Patient signed',
        signed: 'Signed',
        voided: 'Voided',
    })[props.consent.status] ?? props.consent.status

const formatDate = (value) => {
    if (!value) return '—'
    return new Date(value).toLocaleDateString(undefined, { year: 'numeric', month: 'long', day: 'numeric' })
}

const formatDateTime = (value) => {
    if (!value) return '—'
    return new Date(value).toLocaleString()
}

const printForm = () => {
    toastStore.show('Preparing the printable form…')
    window.print()
}
</script>

<template>
    <Head :title="`Consent form — ${consent.patient_name}`" />

    <div class="mx-auto max-w-3xl space-y-6">
        <div class="flex flex-wrap items-center justify-between gap-3">
            <div>
                <h1 class="text-2xl font-semibold text-gray-800">Informed consent</h1>
                <p class="mt-1 text-sm text-gray-500">Version {{ consent.version }} — {{ formatDate(consent.created_at) }}</p>
            </div>
            <div class="flex items-center gap-2">
                <Badge :color="statusBadgeColor()">{{ statusLabel() }}</Badge>
                <Link :href="route('patients.show', patient.id)">
                    <Button variant="outline" size="sm">Back to patient</Button>
                </Link>
                <!-- Plain anchor (not Inertia Link): the PDF response is not an
                     Inertia page, and Link's XHR would swallow it. Opens the
                     browser PDF viewer in a new tab. -->
                <a
                    :href="route('consents.pdf', consent.id)"
                    target="_blank"
                    rel="noopener"
                >
                    <Button variant="outline" size="sm" class="print:hidden">
                        <FileText class="h-4 w-4" />
                        Export PDF
                    </Button>
                </a>
                <Button size="sm" class="print:hidden" @click="printForm">
                    <Printer class="h-4 w-4" />
                    Print
                </Button>
            </div>
        </div>

        <div class="rounded-2xl border border-gray-200 bg-white p-6 shadow-sm print:rounded-none print:border-0 print:p-0 print:shadow-none">
            <!-- Clinic header -->
            <div class="border-b border-gray-200 pb-4 print:border-gray-300">
                <h2 class="text-lg font-semibold text-gray-800">Dental Clinic</h2>
                <p class="text-sm text-gray-500">Patient informed consent and waiver</p>
            </div>

            <!-- Patient -->
            <div class="grid grid-cols-1 gap-3 border-b border-gray-200 py-4 text-sm sm:grid-cols-3">
                <div>
                    <p class="text-xs font-medium tracking-wide text-gray-400 uppercase">Patient</p>
                    <p class="mt-0.5 font-medium text-gray-800">{{ consent.patient_name }}</p>
                </div>
                <div>
                    <p class="text-xs font-medium tracking-wide text-gray-400 uppercase">Birth date</p>
                    <p class="mt-0.5 font-medium text-gray-800">{{ patient.birth_date }}</p>
                </div>
                <div>
                    <p class="text-xs font-medium tracking-wide text-gray-400 uppercase">Age</p>
                    <p class="mt-0.5 font-medium text-gray-800">{{ patient.age }} years</p>
                </div>
            </div>

            <!-- Sections -->
            <ol class="divide-y divide-gray-100 print:divide-gray-300">
                <li v-for="section in consent.sections" :key="section.id" class="py-4">
                    <h3 class="text-sm font-semibold text-gray-800">{{ section.label }}</h3>
                    <p class="mt-1 text-base leading-relaxed text-gray-700">{{ section.text }}</p>
                </li>
            </ol>

            <!-- Acknowledgment + authorization -->
            <div class="space-y-4 border-t border-gray-200 py-4 print:border-gray-300">
                <blockquote class="rounded-lg bg-gray-50 px-4 py-3 print:border print:border-gray-300">
                    <p class="text-xs font-medium text-gray-500">Acknowledgment</p>
                    <p class="mt-1 text-sm text-gray-800">
                        “{{ consent.consent_text?.acknowledgment ?? '—' }}”
                    </p>
                </blockquote>
                <blockquote class="rounded-lg bg-gray-50 px-4 py-3 print:border print:border-gray-300">
                    <p class="text-xs font-medium text-gray-500">Authorization</p>
                    <p class="mt-1 text-sm text-gray-800">
                        “{{ consent.consent_text?.authorization ?? '—' }}”
                    </p>
                </blockquote>
            </div>

            <!-- Signatures -->
            <div class="grid grid-cols-1 gap-6 border-t border-gray-200 py-6 sm:grid-cols-2 print:border-gray-300">
                <div v-if="consent.patient_signature_path">
                    <p class="text-xs font-medium tracking-wide text-gray-400 uppercase">Patient signature</p>
                    <img
                        :src="'/storage/' + consent.patient_signature_path"
                        alt="Patient signature"
                        class="mt-2 max-h-24 rounded border border-gray-200 bg-white"
                    />
                    <p class="mt-2 text-sm font-medium text-gray-800">{{ consent.patient_name }}</p>
                    <p class="text-xs text-gray-500">{{ formatDateTime(consent.patient_signed_at) }}</p>
                </div>

                <div v-if="consent.guardian_signature_path">
                    <p class="text-xs font-medium tracking-wide text-gray-400 uppercase">Parent / guardian signature</p>
                    <img
                        :src="'/storage/' + consent.guardian_signature_path"
                        alt="Guardian signature"
                        class="mt-2 max-h-24 rounded border border-gray-200 bg-white"
                    />
                    <p class="mt-2 text-sm font-medium text-gray-800">{{ consent.guardian_name }}</p>
                    <p class="text-xs text-gray-500">{{ formatDateTime(consent.patient_signed_at) }}</p>
                </div>

                <div v-if="consent.dentist_signature_path">
                    <p class="text-xs font-medium tracking-wide text-gray-400 uppercase">Dentist signature</p>
                    <img
                        :src="'/storage/' + consent.dentist_signature_path"
                        alt="Dentist signature"
                        class="mt-2 max-h-24 rounded border border-gray-200 bg-white"
                    />
                    <p class="mt-2 text-sm font-medium text-gray-800">{{ consent.dentist?.name ?? 'Attending dentist' }}</p>
                    <p class="text-xs text-gray-500">{{ formatDateTime(consent.dentist_signed_at) }}</p>
                </div>
            </div>

            <!-- Audit footer -->
            <div class="border-t border-gray-200 pt-3 text-xs text-gray-400 print:border-gray-300">
                <p>Signed from IP {{ consent.ip_address ?? '—' }}</p>
                <p class="mt-0.5 break-words">{{ consent.user_agent ?? '—' }}</p>
            </div>
        </div>
    </div>
</template>

<style>
@media print {
    aside,
    header,
    .print\:hidden {
        display: none !important;
    }

    main {
        padding: 0 !important;
    }
}
</style>
