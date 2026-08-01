<script setup>
import { computed, ref, watch } from 'vue'
import { Head, router, useForm } from '@inertiajs/vue3'
import { CalendarPlus, Check, ChevronLeft, ChevronRight, X } from 'lucide-vue-next'
import { route } from '../../../../vendor/tightenco/ziggy'
import AppLayout from '@/Layouts/AppLayout.vue'
import Badge from '@/Components/Badge.vue'
import Button from '@/Components/Button.vue'
import Input from '@/Components/Input.vue'
import Modal from '@/Components/Modal.vue'
import { useToastStore } from '@/Stores/toast'

defineOptions({ layout: AppLayout })

const props = defineProps({
    appointments: { type: Array, default: () => [] },
    date: { type: String, required: true },
    patients: { type: Array, default: () => [] },
    dentists: { type: Array, default: () => [] },
    can: { type: Object, default: () => ({}) },
    statusOptions: { type: Object, default: () => ({}) },
})

const toastStore = useToastStore()

const badgeColorByToken = {
    'status-pending': 'warning',
    'status-confirmed': 'info',
    'status-completed': 'success',
    'status-cancelled': 'light',
    'status-no-show': 'error',
}

const statusMeta = computed(() =>
    Object.fromEntries(
        Object.entries(props.statusOptions).map(([status, meta]) => [
            status,
            { label: meta.label, color: badgeColorByToken[meta.color] ?? 'light' },
        ]),
    ),
)

const dateLabel = computed(() =>
    new Intl.DateTimeFormat('en-PH', { weekday: 'long', month: 'long', day: 'numeric', year: 'numeric' }).format(
        new Date(`${props.date}T00:00:00`),
    ),
)

const toLocalDate = (d) => {
    const y = d.getFullYear()
    const m = String(d.getMonth() + 1).padStart(2, '0')
    const day = String(d.getDate()).padStart(2, '0')
    return `${y}-${m}-${day}`
}

const todayLocal = () => toLocalDate(new Date())

const isToday = computed(() => props.date === todayLocal())

const goTo = (date) => router.get(route('appointments.index', { date }))
const shiftDay = (offset) => {
    const parts = props.date.split('-').map(Number)
    const d = new Date(parts[0], parts[1] - 1, parts[2] + offset)
    goTo(toLocalDate(d))
}

const patientName = (p) => (p ? [p.first_name, p.last_name].filter(Boolean).join(' ') : '—')
const timeRange = (appt) => (appt.end_time ? `${appt.start_time} – ${appt.end_time}` : appt.start_time)

const showCreate = ref(false)
const showDetail = ref(false)
const showCancel = ref(false)
const showReschedule = ref(false)
const selected = ref(null)

const openDetail = (appt) => {
    selected.value = appt
    showDetail.value = true
}

const closeDetail = () => {
    showDetail.value = false
    selected.value = null
}

const patientSearch = ref('')
const filteredPatients = computed(() => {
    const term = patientSearch.value.trim().toLowerCase()
    if (!term) return props.patients
    return props.patients.filter(
        (p) =>
            `${p.first_name} ${p.last_name}`.toLowerCase().includes(term) ||
            p.patient_number.toLowerCase().includes(term),
    )
})

const createForm = useForm({
    patient_id: '',
    dentist_id: '',
    appointment_date: props.date,
    start_time: '',
    end_time: '',
    reason: '',
})

const openCreate = () => {
    createForm.reset()
    createForm.appointment_date = props.date
    patientSearch.value = ''
    showCreate.value = true
}

const submitCreate = () => {
    createForm.post(route('appointments.store'), {
        preserveScroll: true,
        onSuccess: () => {
            showCreate.value = false
            toastStore.show('Appointment created.')
        },
        onError: (errors) => {
            if (errors.appointment) toastStore.show(errors.appointment, 'error')
        },
    })
}

const confirmForm = useForm({})
const confirmAppointment = () => {
    confirmForm.post(route('appointments.confirm', selected.value.id), {
        onSuccess: () => {
            toastStore.show('Appointment confirmed.')
            closeDetail()
        },
        onError: (errors) => {
            if (errors.appointment) toastStore.show(errors.appointment, 'error')
        },
    })
}

const attendanceForm = useForm({ present: false })
const markAttendance = (present) => {
    attendanceForm.present = present
    attendanceForm.post(route('appointments.attendance', selected.value.id), {
        onSuccess: () => {
            toastStore.show(present ? 'Attendance recorded.' : 'Marked as no-show.')
            closeDetail()
        },
        onError: (errors) => {
            if (errors.appointment) toastStore.show(errors.appointment, 'error')
        },
    })
}

const cancelForm = useForm({ reason: '' })
const openCancel = () => {
    cancelForm.reset()
    showCancel.value = true
}
const submitCancel = () => {
    cancelForm.post(route('appointments.cancel', selected.value.id), {
        onSuccess: () => {
            toastStore.show('Appointment cancelled.')
            showCancel.value = false
            closeDetail()
        },
        onError: (errors) => {
            if (errors.appointment) toastStore.show(errors.appointment, 'error')
        },
    })
}

const rescheduleForm = useForm({ appointment_date: '', start_time: '', end_time: '' })
const openReschedule = () => {
    rescheduleForm.reset()
    rescheduleForm.appointment_date = selected.value.appointment_date
    rescheduleForm.start_time = selected.value.start_time
    rescheduleForm.end_time = selected.value.end_time
    showReschedule.value = true
}
const submitReschedule = () => {
    rescheduleForm.patch(route('appointments.update', selected.value.id), {
        preserveScroll: true,
        onSuccess: () => {
            toastStore.show('Appointment rescheduled.')
            showReschedule.value = false
            closeDetail()
        },
        onError: (errors) => {
            if (errors.appointment) toastStore.show(errors.appointment, 'error')
        },
    })
}

watch(
    () => props.date,
    () => {
        showCreate.value = false
        showDetail.value = false
        showCancel.value = false
        showReschedule.value = false
        selected.value = null
    },
)
</script>

<template>
    <Head title="Appointments" />

    <div class="mx-auto max-w-4xl space-y-6">
        <div class="flex flex-wrap items-center justify-between gap-4">
            <div>
                <h1 class="text-2xl font-semibold text-gray-800">Appointments</h1>
                <p class="mt-1 text-sm text-gray-500">{{ dateLabel }}</p>
            </div>
            <div class="flex items-center gap-2">
                <button
                    type="button"
                    class="flex h-11 w-11 items-center justify-center rounded-lg border border-gray-300 bg-white text-gray-600 transition hover:bg-gray-50"
                    :aria-label="'Previous day'"
                    @click="shiftDay(-1)"
                >
                    <ChevronLeft class="h-5 w-5" />
                </button>
                <Button v-if="!isToday" variant="outline" @click="goTo(todayLocal())">
                    Today
                </Button>
                <button
                    type="button"
                    class="flex h-11 w-11 items-center justify-center rounded-lg border border-gray-300 bg-white text-gray-600 transition hover:bg-gray-50"
                    :aria-label="'Next day'"
                    @click="shiftDay(1)"
                >
                    <ChevronRight class="h-5 w-5" />
                </button>
                <Button v-if="can.create" size="sm" @click="openCreate">
                    <CalendarPlus class="h-4 w-4" />
                    New appointment
                </Button>
            </div>
        </div>

        <div v-if="appointments.length" class="overflow-hidden rounded-2xl border border-gray-200 bg-white shadow-sm">
            <ul class="divide-y divide-gray-100">
                <li v-for="appt in appointments" :key="appt.id">
                    <button
                        type="button"
                        class="flex w-full flex-wrap items-center gap-x-4 gap-y-2 px-5 py-4 text-left transition hover:bg-gray-50"
                        @click="openDetail(appt)"
                    >
                        <span class="w-28 shrink-0 text-sm font-medium text-gray-800">{{ timeRange(appt) }}</span>
                        <span class="min-w-0 flex-1">
                            <span class="block truncate text-sm font-semibold text-gray-800">
                                {{ patientName(appt.patient) }}
                            </span>
                            <span class="block truncate text-xs text-gray-500">{{ appt.reason || 'No reason' }}</span>
                        </span>
                        <span v-if="appt.dentist" class="hidden text-xs text-gray-500 sm:block">
                            {{ appt.dentist.name }}
                        </span>
                        <Badge size="sm" :color="statusMeta[appt.status]?.color ?? 'light'">
                            {{ statusMeta[appt.status]?.label ?? appt.status }}
                        </Badge>
                    </button>
                </li>
            </ul>
        </div>

        <div v-else class="flex flex-col items-center gap-2 rounded-2xl border border-gray-200 bg-white px-6 py-14 text-center shadow-sm">
            <p class="text-sm font-medium text-gray-700">No appointments for this day</p>
            <p class="text-sm text-gray-500">Use the date navigator or create a new appointment.</p>
        </div>
    </div>

    <Modal :show="showCreate" max-width="lg" @close="showCreate = false">
        <form class="space-y-5 p-6" @submit.prevent="submitCreate">
            <div class="flex items-center justify-between">
                <h2 class="text-lg font-semibold text-gray-800">New appointment</h2>
                <button
                    type="button"
                    class="flex h-11 w-11 items-center justify-center rounded-lg text-gray-500 transition hover:bg-gray-100"
                    :aria-label="'Close'"
                    @click="showCreate = false"
                >
                    <X class="h-5 w-5" />
                </button>
            </div>

            <div>
                <label for="patient_search" class="mb-1.5 block text-sm font-medium text-gray-700">
                    Patient
                    <span class="text-status-cancelled">*</span>
                </label>
                <Input
                    id="patient_search"
                    v-model="patientSearch"
                    type="search"
                    placeholder="Search by name or patient number…"
                />
                <div class="mt-2 max-h-56 overflow-y-auto rounded-lg border border-gray-300">
                    <button
                        v-for="p in filteredPatients"
                        :key="p.id"
                        type="button"
                        class="flex w-full items-center justify-between gap-3 px-4 py-3 text-left text-sm transition hover:bg-gray-50"
                        :class="createForm.patient_id === p.id ? 'bg-brand-50' : ''"
                        @click="createForm.patient_id = p.id"
                    >
                        <span class="min-w-0">
                            <span class="block truncate font-medium text-gray-800">
                                {{ [p.last_name, p.first_name].filter(Boolean).join(', ') }}
                            </span>
                            <span class="block text-xs text-gray-500">{{ p.patient_number }}</span>
                        </span>
                        <Check v-if="createForm.patient_id === p.id" class="h-4 w-4 shrink-0 text-brand-500" />
                    </button>
                    <p v-if="!filteredPatients.length" class="px-4 py-3 text-sm text-gray-500">No patients found.</p>
                </div>
                <p v-if="patients.length >= 50" class="mt-1.5 text-xs text-gray-400">
                    Showing the 50 most recent patients — full list on the Patients page.
                </p>
                <p v-if="createForm.errors.patient_id" class="mt-1.5 text-xs text-status-cancelled">
                    {{ createForm.errors.patient_id }}
                </p>
            </div>

            <div>
                <label for="dentist_id" class="mb-1.5 block text-sm font-medium text-gray-700">
                    Dentist
                </label>
                <select
                    id="dentist_id"
                    v-model="createForm.dentist_id"
                    :aria-invalid="createForm.errors.dentist_id ? 'true' : 'false'"
                    class="h-11 w-full rounded-lg border bg-transparent px-4 py-2.5 text-sm text-gray-800 shadow-sm focus:border-brand-300 focus:outline-hidden focus:ring-2 focus:ring-brand-500/10"
                    :class="createForm.errors.dentist_id ? 'border-status-cancelled' : 'border-gray-300'"
                >
                    <option value="">No dentist assigned</option>
                    <option v-for="d in dentists" :key="d.id" :value="d.id">{{ d.name }}</option>
                </select>
                <p v-if="createForm.errors.dentist_id" class="mt-1.5 text-xs text-status-cancelled">
                    {{ createForm.errors.dentist_id }}
                </p>
            </div>

            <div class="grid grid-cols-1 gap-5 sm:grid-cols-3">
                <Input v-model="createForm.appointment_date" type="date" label="Date" required :error="createForm.errors.appointment_date" />
                <Input v-model="createForm.start_time" type="time" label="Start" required :error="createForm.errors.start_time" />
                <Input v-model="createForm.end_time" type="time" label="End" :error="createForm.errors.end_time" />
            </div>

            <div>
                <label for="create_reason" class="mb-1.5 block text-sm font-medium text-gray-700">Reason</label>
                <textarea
                    id="create_reason"
                    v-model="createForm.reason"
                    :rows="2"
                    placeholder="Optional…"
                    class="w-full rounded-lg border border-gray-300 bg-transparent px-4 py-2.5 text-sm text-gray-800 shadow-sm placeholder:text-gray-400 focus:border-brand-300 focus:outline-hidden focus:ring-2 focus:ring-brand-500/10"
                />
                <p v-if="createForm.errors.reason" class="mt-1.5 text-xs text-status-cancelled">
                    {{ createForm.errors.reason }}
                </p>
            </div>

            <p v-if="createForm.errors.appointment" class="rounded-lg bg-status-cancelled/10 px-4 py-3 text-sm font-medium text-status-cancelled">
                {{ createForm.errors.appointment }}
            </p>

            <div class="flex items-center justify-end gap-2">
                <Button variant="outline" size="sm" type="button" :disabled="createForm.processing" @click="showCreate = false">
                    Cancel
                </Button>
                <Button size="sm" type="submit" :disabled="createForm.processing">
                    {{ createForm.processing ? 'Saving…' : 'Create appointment' }}
                </Button>
            </div>
        </form>
    </Modal>

    <Modal :show="showDetail" max-width="sm" @close="closeDetail">
        <div v-if="selected" class="space-y-5 p-6">
            <div class="flex items-start justify-between gap-3">
                <div>
                    <h2 class="text-lg font-semibold text-gray-800">{{ patientName(selected.patient) }}</h2>
                    <p class="mt-0.5 text-sm text-gray-500">{{ selected.patient?.patient_number }}</p>
                </div>
                <Badge size="sm" :color="statusMeta[selected.status]?.color ?? 'light'">
                    {{ statusMeta[selected.status]?.label ?? selected.status }}
                </Badge>
            </div>

            <dl class="space-y-3 text-sm">
                <div class="flex items-start justify-between gap-4">
                    <dt class="text-gray-500">Date &amp; time</dt>
                    <dd class="text-right font-medium text-gray-800">{{ selected.appointment_date }} · {{ timeRange(selected) }}</dd>
                </div>
                <div class="flex items-start justify-between gap-4">
                    <dt class="text-gray-500">Dentist</dt>
                    <dd class="text-right font-medium text-gray-800">{{ selected.dentist?.name ?? '—' }}</dd>
                </div>
                <div class="flex items-start justify-between gap-4">
                    <dt class="text-gray-500">Reason</dt>
                    <dd class="max-w-56 text-right font-medium text-gray-800">{{ selected.reason || '—' }}</dd>
                </div>
            </dl>

            <div class="flex flex-wrap items-center justify-end gap-2 border-t border-gray-100 pt-4">
                <template v-if="selected.status === 'pending'">
                    <Button
                        v-if="can.update"
                        size="sm"
                        :disabled="confirmForm.processing"
                        @click="confirmAppointment"
                    >
                        Confirm
                    </Button>
                    <Button v-if="can.update" variant="outline" size="sm" @click="openReschedule">
                        Reschedule
                    </Button>
                    <Button v-if="can.cancel" variant="outline" size="sm" class="border-status-cancelled/30 text-status-cancelled hover:bg-status-cancelled/10" @click="openCancel">
                        Cancel
                    </Button>
                </template>
                <template v-else-if="selected.status === 'confirmed'">
                    <Button v-if="can.attendance" size="sm" :disabled="attendanceForm.processing" @click="markAttendance(true)">
                        Mark attended
                    </Button>
                    <Button v-if="can.attendance" variant="outline" size="sm" :disabled="attendanceForm.processing" @click="markAttendance(false)">
                        Mark no-show
                    </Button>
                    <Button v-if="can.update" variant="outline" size="sm" @click="openReschedule">
                        Reschedule
                    </Button>
                    <Button v-if="can.cancel" variant="outline" size="sm" class="border-status-cancelled/30 text-status-cancelled hover:bg-status-cancelled/10" @click="openCancel">
                        Cancel
                    </Button>
                </template>
                <template v-else>
                    <p class="text-xs text-gray-400">This appointment is closed.</p>
                </template>
            </div>
        </div>
    </Modal>

    <Modal :show="showCancel" max-width="sm" @close="showCancel = false">
        <form class="space-y-5 p-6" @submit.prevent="submitCancel">
            <h2 class="text-lg font-semibold text-gray-800">Cancel appointment</h2>
            <div>
                <label for="cancel_reason" class="mb-1.5 block text-sm font-medium text-gray-700">
                    Reason
                    <span class="text-status-cancelled">*</span>
                </label>
                <textarea
                    id="cancel_reason"
                    v-model="cancelForm.reason"
                    :rows="3"
                    placeholder="Why is this appointment being cancelled?"
                    class="w-full rounded-lg border border-gray-300 bg-transparent px-4 py-2.5 text-sm text-gray-800 shadow-sm placeholder:text-gray-400 focus:border-brand-300 focus:outline-hidden focus:ring-2 focus:ring-brand-500/10"
                    :class="cancelForm.errors.reason ? 'border-status-cancelled' : ''"
                />
                <p v-if="cancelForm.errors.reason" class="mt-1.5 text-xs text-status-cancelled">
                    {{ cancelForm.errors.reason }}
                </p>
            </div>
            <div class="flex items-center justify-end gap-2">
                <Button variant="outline" size="sm" type="button" :disabled="cancelForm.processing" @click="showCancel = false">
                    Back
                </Button>
                <Button size="sm" type="submit" :disabled="cancelForm.processing">
                    {{ cancelForm.processing ? 'Cancelling…' : 'Cancel appointment' }}
                </Button>
            </div>
        </form>
    </Modal>

    <Modal :show="showReschedule" max-width="sm" @close="showReschedule = false">
        <form class="space-y-5 p-6" @submit.prevent="submitReschedule">
            <h2 class="text-lg font-semibold text-gray-800">Reschedule appointment</h2>
            <div class="grid grid-cols-1 gap-5">
                <Input v-model="rescheduleForm.appointment_date" type="date" label="Date" required :error="rescheduleForm.errors.appointment_date" />
                <div class="grid grid-cols-2 gap-4">
                    <Input v-model="rescheduleForm.start_time" type="time" label="Start" required :error="rescheduleForm.errors.start_time" />
                    <Input v-model="rescheduleForm.end_time" type="time" label="End" :error="rescheduleForm.errors.end_time" />
                </div>
            </div>
            <p v-if="rescheduleForm.errors.appointment" class="rounded-lg bg-status-cancelled/10 px-4 py-3 text-sm font-medium text-status-cancelled">
                {{ rescheduleForm.errors.appointment }}
            </p>
            <div class="flex items-center justify-end gap-2">
                <Button variant="outline" size="sm" type="button" :disabled="rescheduleForm.processing" @click="showReschedule = false">
                    Back
                </Button>
                <Button size="sm" type="submit" :disabled="rescheduleForm.processing">
                    {{ rescheduleForm.processing ? 'Saving…' : 'Reschedule' }}
                </Button>
            </div>
        </form>
    </Modal>
</template>
