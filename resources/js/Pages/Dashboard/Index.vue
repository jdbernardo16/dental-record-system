<script setup>
import { computed } from 'vue'
import { Head, Link } from '@inertiajs/vue3'
import {
    ArrowRight,
    BarChart3,
    CalendarCheck2,
    CalendarDays,
    ClipboardList,
    Users,
} from 'lucide-vue-next'
import { route } from '../../../../vendor/tightenco/ziggy'
import VueApexCharts from 'vue3-apexcharts'
import AppLayout from '@/Layouts/AppLayout.vue'
import Badge from '@/Components/Badge.vue'

const apexchart = VueApexCharts

defineOptions({ layout: AppLayout })

const props = defineProps({
    todayAppointments: { type: Array, default: () => [] },
    recentPatients: { type: Array, default: () => [] },
    pendingProcedures: { type: Object, default: () => ({ count: 0, items: [] }) },
    monthlyStats: {
        type: Object,
        default: () => ({ patients: 0, appointments: 0, series: { labels: [], patients: [], appointments: [] } }),
    },
    followUps: { type: Array, default: () => [] },
    statusOptions: { type: Object, default: () => ({}) },
    can: { type: Object, default: () => ({}) },
})

const greeting = computed(() => {
    const hour = new Date().getHours()
    if (hour < 12) return 'Good morning'
    if (hour < 18) return 'Good afternoon'
    return 'Good evening'
})

const todayLabel = computed(() =>
    new Intl.DateTimeFormat('en-PH', { weekday: 'long', month: 'long', day: 'numeric', year: 'numeric' }).format(
        new Date(),
    ),
)

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

const patientName = (p) => (p ? [p.first_name, p.last_name].filter(Boolean).join(' ') : '—')

const followUpDateLabel = (date) =>
    new Intl.DateTimeFormat('en-PH', { weekday: 'short', month: 'short', day: 'numeric' }).format(
        new Date(`${date}T00:00:00`),
    )

const chartOptions = computed(() => ({
    chart: {
        type: 'bar',
        toolbar: { show: false },
        fontFamily: 'inherit',
    },
    colors: ['oklch(0.60 0.10 200)', 'oklch(0.79 0.08 200)'], // brand-500, brand-300 tokens
    plotOptions: { bar: { borderRadius: 6, columnWidth: '40%' } },
    dataLabels: { enabled: false },
    grid: { borderColor: 'oklch(0.928 0.006 264.531)', strokeDashArray: 4 }, // gray-200
    xaxis: {
        categories: props.monthlyStats.series.labels,
        axisBorder: { show: false },
        axisTicks: { show: false },
        labels: { style: { colors: 'oklch(0.551 0.027 264.364)' } }, // gray-500
    },
    yaxis: {
        labels: { style: { colors: 'oklch(0.551 0.027 264.364)' } },
    },
    legend: { position: 'top', horizontalAlign: 'right' },
    tooltip: { shared: true, intersect: false },
}))

const chartSeries = computed(() => [
    { name: 'Patients', data: props.monthlyStats.series.patients },
    { name: 'Appointments', data: props.monthlyStats.series.appointments },
])
</script>

<template>
    <Head title="Dashboard" />

    <div class="mx-auto max-w-7xl space-y-6">
        <div>
            <h1 class="text-2xl font-semibold text-gray-800">{{ greeting }}, {{ $page.props.auth.user.name }}</h1>
            <p class="mt-1 text-sm text-gray-500">{{ todayLabel }}</p>
        </div>

        <div class="grid grid-cols-1 gap-4 sm:grid-cols-2 xl:grid-cols-4">
            <!-- Today's appointments -->
            <section class="rounded-2xl border border-gray-200 bg-white p-5 shadow-sm">
                <div class="flex items-center justify-between">
                    <h2 class="text-sm font-medium text-gray-500">Today's appointments</h2>
                    <span class="flex h-10 w-10 items-center justify-center rounded-full bg-brand-50 text-brand-500">
                        <CalendarDays class="h-5 w-5" />
                    </span>
                </div>
                <p class="mt-3 text-3xl font-semibold text-gray-800">{{ todayAppointments.length }}</p>
                <ul v-if="todayAppointments.length" class="mt-4 space-y-1">
                    <li
                        v-for="appt in todayAppointments.slice(0, 4)"
                        :key="appt.id"
                        class="flex min-h-11 items-center gap-3"
                    >
                        <span class="w-14 shrink-0 text-xs font-medium text-gray-500">{{ appt.start_time }}</span>
                        <span class="min-w-0 flex-1 truncate text-sm font-medium text-gray-800">
                            {{ patientName(appt.patient) }}
                        </span>
                        <Badge size="sm" :color="statusMeta[appt.status]?.color ?? 'light'">
                            {{ statusMeta[appt.status]?.label ?? appt.status }}
                        </Badge>
                    </li>
                </ul>
                <p v-else class="mt-4 text-sm text-gray-500">No appointments today.</p>
                <Link
                    :href="route('appointments.index')"
                    class="mt-4 flex h-11 items-center justify-center gap-2 rounded-lg bg-brand-50 text-sm font-medium text-brand-500 transition hover:bg-brand-100"
                >
                    View all
                    <ArrowRight class="h-4 w-4" />
                </Link>
            </section>

            <!-- Recent patients -->
            <section class="rounded-2xl border border-gray-200 bg-white p-5 shadow-sm">
                <div class="flex items-center justify-between">
                    <h2 class="text-sm font-medium text-gray-500">Recent patients</h2>
                    <span class="flex h-10 w-10 items-center justify-center rounded-full bg-brand-50 text-brand-500">
                        <Users class="h-5 w-5" />
                    </span>
                </div>
                <p class="mt-3 text-3xl font-semibold text-gray-800">{{ recentPatients.length }}</p>
                <ul v-if="recentPatients.length" class="mt-4 space-y-1">
                    <li v-for="patient in recentPatients.slice(0, 4)" :key="patient.id" class="flex min-h-11 items-center gap-3">
                        <span class="min-w-0 flex-1 truncate text-sm font-medium text-gray-800">
                            {{ patientName(patient) }}
                        </span>
                        <span class="shrink-0 text-xs text-gray-500">{{ patient.patient_number }}</span>
                    </li>
                </ul>
                <p v-else class="mt-4 text-sm text-gray-500">No patients yet.</p>
                <Link
                    :href="route('patients.index')"
                    class="mt-4 flex h-11 items-center justify-center gap-2 rounded-lg bg-brand-50 text-sm font-medium text-brand-500 transition hover:bg-brand-100"
                >
                    View all
                    <ArrowRight class="h-4 w-4" />
                </Link>
            </section>

            <!-- Pending procedures (treatments page ships in Phase 2) -->
            <section v-if="can.viewTreatments" class="rounded-2xl border border-gray-200 bg-white p-5 shadow-sm">
                <div class="flex items-center justify-between">
                    <h2 class="text-sm font-medium text-gray-500">Pending procedures</h2>
                    <span class="flex h-10 w-10 items-center justify-center rounded-full bg-brand-50 text-brand-500">
                        <ClipboardList class="h-5 w-5" />
                    </span>
                </div>
                <p class="mt-3 text-3xl font-semibold text-gray-800">{{ pendingProcedures.count }}</p>
                <ul v-if="pendingProcedures.items.length" class="mt-4 space-y-1">
                    <li
                        v-for="procedure in pendingProcedures.items.slice(0, 4)"
                        :key="procedure.id"
                        class="flex min-h-11 items-center gap-3"
                    >
                        <span class="min-w-0 flex-1 truncate text-sm font-medium text-gray-800">
                            {{ procedure.procedure_name || procedure.id }}
                        </span>
                    </li>
                </ul>
                <p v-else class="mt-4 text-sm text-gray-500">No pending procedures.</p>
                <span
                    aria-disabled="true"
                    class="mt-4 flex h-11 cursor-not-allowed items-center justify-center gap-2 rounded-lg bg-gray-100 text-sm font-medium text-gray-400"
                >
                    View all
                    <ArrowRight class="h-4 w-4" />
                </span>
            </section>

            <!-- Follow-up appointments -->
            <section v-if="can.viewAppointments" class="rounded-2xl border border-gray-200 bg-white p-5 shadow-sm">
                <div class="flex items-center justify-between">
                    <h2 class="text-sm font-medium text-gray-500">Follow-ups</h2>
                    <span class="flex h-10 w-10 items-center justify-center rounded-full bg-brand-50 text-brand-500">
                        <CalendarCheck2 class="h-5 w-5" />
                    </span>
                </div>
                <p class="mt-3 text-3xl font-semibold text-gray-800">{{ followUps.length }}</p>
                <ul v-if="followUps.length" class="mt-4 space-y-1">
                    <li v-for="appt in followUps.slice(0, 5)" :key="appt.id" class="flex min-h-11 items-center gap-3">
                        <span class="w-24 shrink-0 text-xs font-medium text-gray-500">
                            {{ followUpDateLabel(appt.appointment_date) }}
                        </span>
                        <span class="min-w-0 flex-1 truncate text-sm font-medium text-gray-800">
                            {{ patientName(appt.patient) }}
                        </span>
                    </li>
                </ul>
                <p v-else class="mt-4 text-sm text-gray-500">No follow-ups this week.</p>
                <Link
                    :href="route('appointments.index')"
                    class="mt-4 flex h-11 items-center justify-center gap-2 rounded-lg bg-brand-50 text-sm font-medium text-brand-500 transition hover:bg-brand-100"
                >
                    View all
                    <ArrowRight class="h-4 w-4" />
                </Link>
            </section>
        </div>

        <!-- Monthly statistics -->
        <div class="grid grid-cols-1 gap-4 sm:grid-cols-2">
            <section class="rounded-2xl border border-gray-200 bg-white p-5 shadow-sm sm:col-span-2">
                <div class="flex items-center justify-between">
                    <h2 class="text-sm font-medium text-gray-500">Monthly statistics</h2>
                    <span class="flex h-10 w-10 items-center justify-center rounded-full bg-brand-50 text-brand-500">
                        <BarChart3 class="h-5 w-5" />
                    </span>
                </div>
                <div class="mt-2 flex gap-8">
                    <div>
                        <p class="text-xs text-gray-500">New patients this month</p>
                        <p class="mt-0.5 text-xl font-semibold text-gray-800">{{ monthlyStats.patients }}</p>
                    </div>
                    <div>
                        <p class="text-xs text-gray-500">New appointments this month</p>
                        <p class="mt-0.5 text-xl font-semibold text-gray-800">{{ monthlyStats.appointments }}</p>
                    </div>
                </div>
                <apexchart type="bar" height="260" :options="chartOptions" :series="chartSeries" />
            </section>
        </div>
    </div>
</template>
