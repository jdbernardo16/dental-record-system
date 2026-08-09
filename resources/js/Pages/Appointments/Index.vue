<script setup>
import { computed, ref, watch } from "vue";
import { Head, Link, router, useForm } from "@inertiajs/vue3";
import {
    CalendarPlus,
    ChevronLeft,
    ChevronRight,
    ExternalLink,
    X,
} from "lucide-vue-next";
import { route } from "../../../../vendor/tightenco/ziggy";
import AppLayout from "@/Layouts/AppLayout.vue";
import BackToPatient from "@/Components/BackToPatient.vue";
import Badge from "@/Components/Badge.vue";
import { Button } from "@/Components/ui/button";
import {
    CheckboxField,
    DateField,
    SearchSelectField,
    SelectField,
    TextareaField,
    TimeRangeField,
} from "@/Components/Fields";
import { scrollToFirstError } from "@/lib/scroll";
import Modal from "@/Components/Modal.vue";
import { useToastStore } from "@/Stores/toast";

defineOptions({ layout: AppLayout });

const props = defineProps({
    appointments: { type: Array, default: () => [] },
    date: { type: String, required: true },
    patients: { type: Array, default: () => [] },
    dentists: { type: Array, default: () => [] },
    can: { type: Object, default: () => ({}) },
    statusOptions: { type: Object, default: () => ({}) },
    backToPatient: { type: Object, default: null },
});

const toastStore = useToastStore();

const badgeColorByToken = {
    "status-pending": "warning",
    "status-confirmed": "info",
    "status-completed": "success",
    "status-cancelled": "light",
    "status-no-show": "error",
};

const statusMeta = computed(() =>
    Object.fromEntries(
        Object.entries(props.statusOptions).map(([status, meta]) => [
            status,
            {
                label: meta.label,
                color: badgeColorByToken[meta.color] ?? "light",
            },
        ]),
    ),
);

const dateLabel = computed(() =>
    new Intl.DateTimeFormat("en-PH", {
        weekday: "long",
        month: "long",
        day: "numeric",
        year: "numeric",
    }).format(new Date(`${props.date}T00:00:00`)),
);

const toLocalDate = (d) => {
    const y = d.getFullYear();
    const m = String(d.getMonth() + 1).padStart(2, "0");
    const day = String(d.getDate()).padStart(2, "0");
    return `${y}-${m}-${day}`;
};

const todayLocal = () => toLocalDate(new Date());

const isToday = computed(() => props.date === todayLocal());

const goTo = (date) =>
    router.get(route("appointments.index", { date, patient: props.backToPatient?.id }));
const shiftDay = (offset) => {
    const parts = props.date.split("-").map(Number);
    const d = new Date(parts[0], parts[1] - 1, parts[2] + offset);
    goTo(toLocalDate(d));
};

const patientName = (p) =>
    p ? [p.first_name, p.last_name].filter(Boolean).join(" ") : "—";
const timeRange = (appt) =>
    appt.end_time ? `${appt.start_time} – ${appt.end_time}` : appt.start_time;

const showCreate = ref(false);
const showDetail = ref(false);
const showCancel = ref(false);
const showReschedule = ref(false);
const selected = ref(null);

const openDetail = (appt) => {
    selected.value = appt;
    showDetail.value = true;
};

const closeDetail = () => {
    showDetail.value = false;
    selected.value = null;
};

const patientOptions = computed(() =>
    props.patients.map((p) => ({
        value: p.id,
        label: `${[p.last_name, p.first_name].filter(Boolean).join(", ")} — ${p.patient_number}`,
    })),
);

// reka-ui Select cannot deselect and rejects empty-string item values, so
// the "No dentist assigned" state is represented by SelectField's noneLabel
// sentinel item: picking it emits '' — preserving the previous native
// <option value=""> reset-to-empty behavior.
const dentistOptions = computed(() =>
    props.dentists.map((d) => ({ value: String(d.id), label: d.name })),
);

const createForm = useForm({
    patient_id: "",
    dentist_id: "",
    appointment_date: props.date,
    start_time: "",
    end_time: "",
    reason: "",
    is_follow_up: false,
    patient: props.backToPatient?.id ?? "",
});

const openCreate = () => {
    createForm.reset();
    createForm.appointment_date = props.date;
    showCreate.value = true;
};

const submitCreate = () => {
    createForm.post(route("appointments.store"), {
        onError: () => scrollToFirstError(),
        preserveScroll: true,
        onSuccess: () => {
            showCreate.value = false;
            toastStore.show("Appointment created.");
        },
        onError: (errors) => {
            if (errors.appointment)
                toastStore.show(errors.appointment, "error");
        },
    });
};

const confirmForm = useForm({});
const confirmAppointment = () => {
    confirmForm.post(route("appointments.confirm", selected.value.id), {
        onError: () => scrollToFirstError(),
        onSuccess: () => {
            toastStore.show("Appointment confirmed.");
            closeDetail();
        },
        onError: (errors) => {
            if (errors.appointment)
                toastStore.show(errors.appointment, "error");
        },
    });
};

const attendanceForm = useForm({ present: false });
const markAttendance = (present) => {
    attendanceForm.present = present;
    attendanceForm.post(route("appointments.attendance", selected.value.id), {
        onSuccess: () => {
            toastStore.show(
                present ? "Attendance recorded." : "Marked as no-show.",
            );
            closeDetail();
        },
        onError: (errors) => {
            if (errors.appointment)
                toastStore.show(errors.appointment, "error");
        },
    });
};

const cancelForm = useForm({ reason: "" });
const openCancel = () => {
    cancelForm.reset();
    showCancel.value = true;
};
const submitCancel = () => {
    cancelForm.post(route("appointments.cancel", selected.value.id), {
        onSuccess: () => {
            toastStore.show("Appointment cancelled.");
            showCancel.value = false;
            closeDetail();
        },
        onError: (errors) => {
            if (errors.appointment)
                toastStore.show(errors.appointment, "error");
        },
    });
};

const rescheduleForm = useForm({
    appointment_date: "",
    start_time: "",
    end_time: "",
});
const openReschedule = () => {
    rescheduleForm.reset();
    rescheduleForm.appointment_date = selected.value.appointment_date;
    rescheduleForm.start_time = selected.value.start_time;
    rescheduleForm.end_time = selected.value.end_time;
    showReschedule.value = true;
};
const submitReschedule = () => {
    rescheduleForm.patch(route("appointments.update", selected.value.id), {
        preserveScroll: true,
        onSuccess: () => {
            toastStore.show("Appointment rescheduled.");
            showReschedule.value = false;
            closeDetail();
        },
        onError: (errors) => {
            if (errors.appointment)
                toastStore.show(errors.appointment, "error");
        },
    });
};

watch(
    () => props.date,
    () => {
        showCreate.value = false;
        showDetail.value = false;
        showCancel.value = false;
        showReschedule.value = false;
        selected.value = null;
    },
);
</script>

<template>
    <Head title="Appointments" />

    <div class="mx-auto max-w-4xl space-y-6">
        <div class="flex flex-wrap items-center justify-between gap-4">
            <div>
                <h1 class="text-2xl font-semibold text-gray-800">
                    Appointments
                </h1>
                <p class="mt-1 text-sm text-gray-500">{{ dateLabel }}</p>
            </div>
            <div class="flex items-center gap-2">
                <BackToPatient
                    v-if="backToPatient"
                    :patient-id="backToPatient.id"
                />
                <button
                    type="button"
                    class="flex h-11 w-11 items-center justify-center rounded-lg border border-gray-300 bg-white text-gray-600 transition hover:bg-gray-50"
                    :aria-label="'Previous day'"
                    @click="shiftDay(-1)"
                >
                    <ChevronLeft class="h-5 w-5" />
                </button>
                <Button
                    v-if="!isToday"
                    variant="outline"
                    size="md"
                    @click="goTo(todayLocal())"
                >
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

        <div
            v-if="appointments.length"
            class="overflow-hidden rounded-2xl border border-gray-200 bg-white shadow-sm"
        >
            <ul class="divide-y divide-gray-100">
                <li v-for="appt in appointments" :key="appt.id" class="flex items-stretch">
                    <button
                        type="button"
                        class="flex min-w-0 flex-1 flex-wrap items-center gap-x-4 gap-y-2 px-5 py-4 text-left transition hover:bg-gray-50"
                        @click="openDetail(appt)"
                    >
                        <span
                            class="w-28 shrink-0 text-sm font-medium text-gray-800"
                            >{{ timeRange(appt) }}</span
                        >
                        <span class="min-w-0 flex-1">
                            <span
                                class="block truncate text-sm font-semibold text-gray-800"
                            >
                                {{ patientName(appt.patient) }}
                            </span>
                            <span
                                class="block truncate text-xs text-gray-500"
                                >{{ appt.reason || "No reason" }}</span
                            >
                        </span>
                        <span
                            v-if="appt.dentist"
                            class="hidden text-xs text-gray-500 sm:block"
                        >
                            {{ appt.dentist.name }}
                        </span>
                        <Badge
                            size="sm"
                            :color="statusMeta[appt.status]?.color ?? 'light'"
                        >
                            {{ statusMeta[appt.status]?.label ?? appt.status }}
                        </Badge>
                    </button>
                    <Link
                        v-if="appt.patient"
                        :href="route('patients.show', appt.patient.id)"
                        class="flex shrink-0 items-center border-l border-gray-100 px-3 text-gray-400 transition hover:bg-gray-50 hover:text-brand-500"
                        :aria-label="`Open patient record for ${patientName(appt.patient)}`"
                        title="Open patient record"
                    >
                        <ExternalLink class="h-4 w-4" />
                    </Link>
                </li>
            </ul>
        </div>

        <div
            v-else
            class="flex flex-col items-center gap-2 rounded-2xl border border-gray-200 bg-white px-6 py-14 text-center shadow-sm"
        >
            <p class="text-sm font-medium text-gray-700">
                No appointments for this day
            </p>
            <p class="text-sm text-gray-500">
                Use the date navigator or create a new appointment.
            </p>
        </div>
    </div>

    <Modal :show="showCreate" max-width="xl" @close="showCreate = false">
        <form class="space-y-5 p-6" @submit.prevent="submitCreate">
            <div class="flex items-center justify-between">
                <h2 class="text-lg font-semibold text-gray-800">
                    New appointment
                </h2>
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
                <SearchSelectField
                    id="patient_search"
                    v-model="createForm.patient_id"
                    label="Patient"
                    :options="patientOptions"
                    placeholder="Search by name or patient number…"
                    :hint="patients.length >= 50 ? 'Showing the 50 most recent patients — full list on the Patients page.' : null"
                    :error="createForm.errors.patient_id"
                />
            </div>

            <div>
                <SelectField
                    id="dentist_id"
                    v-model="createForm.dentist_id"
                    label="Dentist"
                    noneLabel="No dentist assigned"
                    :options="dentistOptions"
                    :error="createForm.errors.dentist_id"
                />
            </div>

            <div class="grid grid-cols-1 gap-5 sm:grid-cols-2">
                <DateField
                    v-model="createForm.appointment_date"
                    label="Date"
                    required
                    :error="createForm.errors.appointment_date"
                />
                <TimeRangeField
                    v-model:start="createForm.start_time"
                    v-model:end="createForm.end_time"
                    label="Time"
                    required
                    :error="
                        createForm.errors.start_time ??
                        createForm.errors.end_time
                    "
                />
            </div>

            <div>
                <TextareaField
                    id="create_reason"
                    v-model="createForm.reason"
                    label="Reason"
                    :rows="2"
                    placeholder="Optional…"
                    :error="createForm.errors.reason"
                />
            </div>

            <CheckboxField
                id="create_follow_up"
                v-model="createForm.is_follow_up"
                label="Follow-up appointment"
                hint="Flags this appointment for the dashboard Follow-ups widget."
            />

            <p
                v-if="createForm.errors.appointment"
                class="rounded-lg bg-status-cancelled/10 px-4 py-3 text-sm font-medium text-status-cancelled"
            >
                {{ createForm.errors.appointment }}
            </p>

            <div class="flex items-center justify-end gap-2">
                <Button
                    variant="outline"
                    size="sm"
                    type="button"
                    :disabled="createForm.processing"
                    @click="showCreate = false"
                >
                    Cancel
                </Button>
                <Button
                    size="sm"
                    type="submit"
                    :disabled="createForm.processing"
                >
                    {{
                        createForm.processing ? "Saving…" : "Create appointment"
                    }}
                </Button>
            </div>
        </form>
    </Modal>

    <Modal :show="showDetail" max-width="2xl" @close="closeDetail">
        <div v-if="selected" class="space-y-5 p-6">
            <div class="flex items-start justify-between gap-3">
                <div>
                    <h2 class="text-lg font-semibold text-gray-800">
                        {{ patientName(selected.patient) }}
                    </h2>
                    <p class="mt-0.5 text-sm text-gray-500">
                        {{ selected.patient?.patient_number }}
                    </p>
                </div>
                <Badge
                    size="sm"
                    :color="statusMeta[selected.status]?.color ?? 'light'"
                >
                    {{ statusMeta[selected.status]?.label ?? selected.status }}
                </Badge>
            </div>

            <dl class="space-y-3 text-sm">
                <div class="flex items-start justify-between gap-4">
                    <dt class="text-gray-500">Date &amp; time</dt>
                    <dd class="text-right font-medium text-gray-800">
                        {{ selected.appointment_date }} ·
                        {{ timeRange(selected) }}
                    </dd>
                </div>
                <div class="flex items-start justify-between gap-4">
                    <dt class="text-gray-500">Dentist</dt>
                    <dd class="text-right font-medium text-gray-800">
                        {{ selected.dentist?.name ?? "—" }}
                    </dd>
                </div>
                <div class="flex items-start justify-between gap-4">
                    <dt class="text-gray-500">Reason</dt>
                    <dd class="max-w-56 text-right font-medium text-gray-800">
                        {{ selected.reason || "—" }}
                    </dd>
                </div>
            </dl>

            <div
                class="flex flex-wrap items-center justify-end gap-2 border-t border-gray-100 pt-4"
            >
                <Link
                    v-if="selected.patient"
                    :href="route('patients.show', selected.patient.id)"
                    class="mr-auto"
                >
                    <Button variant="outline" size="sm" type="button">
                        <ExternalLink class="h-4 w-4" />
                        View patient record
                    </Button>
                </Link>
                <template v-if="selected.status === 'pending'">
                    <Button
                        v-if="can.update"
                        size="sm"
                        :disabled="confirmForm.processing"
                        @click="confirmAppointment"
                    >
                        Confirm
                    </Button>
                    <Button
                        v-if="can.update"
                        variant="outline"
                        size="sm"
                        @click="openReschedule"
                    >
                        Reschedule
                    </Button>
                    <Button
                        v-if="can.cancel"
                        variant="outline"
                        size="sm"
                        class="border-status-cancelled/30 text-status-cancelled hover:bg-status-cancelled/10"
                        @click="openCancel"
                    >
                        Cancel
                    </Button>
                </template>
                <template v-else-if="selected.status === 'confirmed'">
                    <Button
                        v-if="can.attendance"
                        size="sm"
                        :disabled="attendanceForm.processing"
                        @click="markAttendance(true)"
                    >
                        Mark attended
                    </Button>
                    <Button
                        v-if="can.attendance"
                        variant="outline"
                        size="sm"
                        :disabled="attendanceForm.processing"
                        @click="markAttendance(false)"
                    >
                        Mark no-show
                    </Button>
                    <Button
                        v-if="can.update"
                        variant="outline"
                        size="sm"
                        @click="openReschedule"
                    >
                        Reschedule
                    </Button>
                    <Button
                        v-if="can.cancel"
                        variant="outline"
                        size="sm"
                        class="border-status-cancelled/30 text-status-cancelled hover:bg-status-cancelled/10"
                        @click="openCancel"
                    >
                        Cancel
                    </Button>
                </template>
                <template v-else>
                    <p class="text-xs text-gray-400">
                        This appointment is closed.
                    </p>
                </template>
            </div>
        </div>
    </Modal>

    <Modal :show="showCancel" max-width="lg" @close="showCancel = false">
        <form class="space-y-5 p-6" @submit.prevent="submitCancel">
            <h2 class="text-lg font-semibold text-gray-800">
                Cancel appointment
            </h2>
            <div>
                <TextareaField
                    id="cancel_reason"
                    v-model="cancelForm.reason"
                    label="Reason"
                    required
                    :rows="3"
                    placeholder="Why is this appointment being cancelled?"
                    :error="cancelForm.errors.reason"
                />
            </div>
            <div class="flex items-center justify-end gap-2">
                <Button
                    variant="outline"
                    size="sm"
                    type="button"
                    :disabled="cancelForm.processing"
                    @click="showCancel = false"
                >
                    Back
                </Button>
                <Button
                    size="sm"
                    type="submit"
                    :disabled="cancelForm.processing"
                >
                    {{
                        cancelForm.processing
                            ? "Cancelling…"
                            : "Cancel appointment"
                    }}
                </Button>
            </div>
        </form>
    </Modal>

    <Modal
        :show="showReschedule"
        max-width="xl"
        @close="showReschedule = false"
    >
        <form class="space-y-5 p-6" @submit.prevent="submitReschedule">
            <h2 class="text-lg font-semibold text-gray-800">
                Reschedule appointment
            </h2>
            <div class="grid grid-cols-1 gap-5">
                <DateField
                    v-model="rescheduleForm.appointment_date"
                    label="Date"
                    required
                    :error="rescheduleForm.errors.appointment_date"
                />
                <TimeRangeField
                    v-model:start="rescheduleForm.start_time"
                    v-model:end="rescheduleForm.end_time"
                    label="Time"
                    required
                    :error="
                        rescheduleForm.errors.start_time ??
                        rescheduleForm.errors.end_time
                    "
                />
            </div>
            <p
                v-if="rescheduleForm.errors.appointment"
                class="rounded-lg bg-status-cancelled/10 px-4 py-3 text-sm font-medium text-status-cancelled"
            >
                {{ rescheduleForm.errors.appointment }}
            </p>
            <div class="flex items-center justify-end gap-2">
                <Button
                    variant="outline"
                    size="sm"
                    type="button"
                    :disabled="rescheduleForm.processing"
                    @click="showReschedule = false"
                >
                    Back
                </Button>
                <Button
                    size="sm"
                    type="submit"
                    :disabled="rescheduleForm.processing"
                >
                    {{ rescheduleForm.processing ? "Saving…" : "Reschedule" }}
                </Button>
            </div>
        </form>
    </Modal>
</template>
