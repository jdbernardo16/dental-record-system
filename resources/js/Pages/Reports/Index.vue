<script setup>
import { computed, ref } from 'vue'
import { Head, router } from '@inertiajs/vue3'
import { CalendarCheck2, Download, Printer, TrendingUp, Users, Stethoscope } from 'lucide-vue-next'
import { route } from '../../../../vendor/tightenco/ziggy'
import VueApexCharts from 'vue3-apexcharts'
import AppLayout from '@/Layouts/AppLayout.vue'

const apexchart = VueApexCharts

defineOptions({ layout: AppLayout })

const props = defineProps({
    range: { type: Object, default: () => ({ from: '', to: '' }) },
    patientGrowth: { type: Array, default: () => [] },
    appointmentSummary: { type: Array, default: () => [] },
    procedureSummary: { type: Array, default: () => [] },
    conditionSummary: { type: Array, default: () => [] },
    dentistWorkload: { type: Array, default: () => [] },
    totals: { type: Object, default: () => ({ patients: 0, appointments: 0 }) },
    conditionLabels: { type: Object, default: () => ({}) },
})

const from = ref(props.range.from ?? '')
const to = ref(props.range.to ?? '')

const applyRange = () => {
    router.get(route('reports.index', { from: from.value || undefined, to: to.value || undefined }), {}, {
        preserveState: false,
        replace: false,
    })
}

const print = () => window.print()

const exportUrl = (report) => route('reports.export', { report, from: from.value, to: to.value })

// --- Metric cards -----------------------------------------------------------

const totalProcedures = computed(() => props.procedureSummary.reduce((sum, row) => sum + row.count, 0))

const avgAttendance = computed(() => {
    const months = props.appointmentSummary.filter((row) => row.completed + row.no_show > 0)
    if (!months.length) return 0
    const mean = months.reduce((sum, row) => sum + row.attendance_rate, 0) / months.length
    return Math.round(mean * 10) / 10
})

// --- Chart data -------------------------------------------------------------

const growthCategories = computed(() => props.patientGrowth.map((row) => row.month))
const growthSeries = computed(() => [{ name: 'Patients', data: props.patientGrowth.map((row) => row.count) }])
const growthHasData = computed(() => props.patientGrowth.length > 0)

const statusLabels = {
    pending: 'Pending',
    confirmed: 'Confirmed',
    completed: 'Completed',
    cancelled: 'Cancelled',
    no_show: 'No-show',
}

const statusTokenColors = {
    'status-pending': 'oklch(0.71 0.16 85)',
    'status-confirmed': 'oklch(0.55 0.25 263)',
    'status-completed': 'oklch(0.65 0.24 152)',
    'status-cancelled': 'oklch(0.45 0.01 280)',
    'status-no-show': 'oklch(0.64 0.24 25)',
}

const summaryMonths = computed(() => props.appointmentSummary.map((row) => row.month))
const summarySeries = computed(() =>
    ['pending', 'confirmed', 'completed', 'cancelled', 'no_show'].map((status) => ({
        name: statusLabels[status],
        data: props.appointmentSummary.map((row) => row[status]),
    })),
)
const summaryHasData = computed(() => props.appointmentSummary.length > 0)

const procedureRows = computed(() => props.procedureSummary.slice(0, 8))
const procedureCategories = computed(() => procedureRows.value.map((row) => row.procedure_name))
const procedureSeries = computed(() => [{ name: 'Procedures', data: procedureRows.value.map((row) => row.count) }])
const procedureHasData = computed(() => procedureRows.value.length > 0)

const conditionTokenColors = {
    'cond-caries': 'oklch(0.64 0.24 25)',
    'cond-missing-caries': 'oklch(0.42 0.01 280)',
    'cond-missing-other': 'oklch(0.58 0.02 280)',
    'cond-impacted': 'oklch(0.71 0.16 85)',
    'cond-supernumerary': 'oklch(0.55 0.16 190)',
    'cond-root-fragment': 'oklch(0.60 0.14 45)',
    'cond-unerupted': 'oklch(0.82 0.02 280)',
    'cond-present': 'oklch(0.93 0.04 200)',
}

const conditionRows = computed(() => props.conditionSummary)
const conditionCategories = computed(() =>
    conditionRows.value.map((row) => props.conditionLabels[row.condition]?.label ?? row.condition),
)
const conditionColors = computed(() =>
    conditionRows.value.map(
        (row) => conditionTokenColors[props.conditionLabels[row.condition]?.color] ?? 'oklch(0.60 0.10 200)',
    ),
)
const conditionSeries = computed(() => [{ name: 'Teeth', data: conditionRows.value.map((row) => row.count) }])
const conditionHasData = computed(() => conditionRows.value.length > 0)

const workloadRows = computed(() => props.dentistWorkload)
const workloadCategories = computed(() => workloadRows.value.map((row) => row.dentist_name))
const workloadSeries = computed(() => [{ name: 'Treatments', data: workloadRows.value.map((row) => row.count) }])
const workloadHasData = computed(() => workloadRows.value.length > 0)

// --- Chart options (OKLCH token values as concrete strings, per Dashboard) ---

const baseChartOptions = (categories, { stacked = false, horizontal = false, colors = [] } = {}) => ({
    chart: {
        type: 'bar',
        stacked,
        toolbar: { show: false },
        fontFamily: 'inherit',
    },
    colors: colors.length ? colors : ['oklch(0.60 0.10 200)'], // brand-500
    plotOptions: { bar: { borderRadius: 6, columnWidth: '40%', horizontal } },
    dataLabels: { enabled: false },
    grid: { borderColor: 'oklch(0.928 0.006 264.531)', strokeDashArray: 4 }, // gray-200
    xaxis: {
        categories,
        axisBorder: { show: false },
        axisTicks: { show: false },
        labels: { style: { colors: 'oklch(0.551 0.027 264.364)' } }, // gray-500
    },
    yaxis: {
        labels: { style: { colors: 'oklch(0.551 0.027 264.364)' } },
    },
    legend: { position: 'top', horizontalAlign: 'right' },
    tooltip: { shared: true, intersect: false },
})

const growthOptions = computed(() => baseChartOptions(growthCategories.value))
const summaryOptions = computed(() =>
    baseChartOptions(summaryMonths.value, {
        stacked: true,
        colors: ['pending', 'confirmed', 'completed', 'cancelled', 'no_show'].map(
            (status) => statusTokenColors[`status-${status}`],
        ),
    }),
)
const procedureOptions = computed(() =>
    baseChartOptions(procedureCategories.value, {
        horizontal: true,
        colors: ['oklch(0.70 0.09 200)'], // brand-400
    }),
)
const conditionOptions = computed(() =>
    baseChartOptions(conditionCategories.value, {
        horizontal: true,
        colors: conditionColors.value,
    }),
)
const workloadOptions = computed(() =>
    baseChartOptions(workloadCategories.value, {
        horizontal: true,
        colors: ['oklch(0.53 0.09 200)'], // brand-600
    }),
)
</script>

<template>
    <Head title="Reports" />

    <div class="mx-auto max-w-7xl space-y-6">
        <div class="flex flex-wrap items-end justify-between gap-4">
            <div>
                <h1 class="text-2xl font-semibold text-gray-800">Reports</h1>
                <p class="mt-1 text-sm text-gray-500">Practice overview for the selected period.</p>
            </div>

            <div class="flex flex-wrap items-end gap-3 print:hidden">
                <label class="flex flex-col gap-1 text-xs font-medium text-gray-500">
                    From
                    <input
                        v-model="from"
                        type="date"
                        class="h-11 rounded-lg border border-gray-200 bg-white px-3 text-sm text-gray-800 focus:border-brand-500 focus:ring-brand-500"
                    />
                </label>
                <label class="flex flex-col gap-1 text-xs font-medium text-gray-500">
                    To
                    <input
                        v-model="to"
                        type="date"
                        class="h-11 rounded-lg border border-gray-200 bg-white px-3 text-sm text-gray-800 focus:border-brand-500 focus:ring-brand-500"
                    />
                </label>
                <button
                    type="button"
                    class="flex h-11 items-center gap-2 rounded-lg bg-brand-500 px-5 text-sm font-medium text-white transition hover:bg-brand-600"
                    @click="applyRange"
                >
                    Apply
                </button>
                <button
                    type="button"
                    class="flex h-11 items-center gap-2 rounded-lg border border-gray-200 bg-white px-5 text-sm font-medium text-gray-700 transition hover:bg-gray-50"
                    @click="print"
                >
                    <Printer class="h-4 w-4" />
                    Print
                </button>
            </div>
        </div>

        <!-- Metric cards -->
        <div class="grid grid-cols-1 gap-4 sm:grid-cols-2 xl:grid-cols-4">
            <section class="rounded-2xl border border-gray-200 bg-white p-5 shadow-sm">
                <div class="flex items-center justify-between">
                    <h2 class="text-sm font-medium text-gray-500">New patients</h2>
                    <span class="flex h-10 w-10 items-center justify-center rounded-full bg-brand-50 text-brand-500">
                        <Users class="h-5 w-5" />
                    </span>
                </div>
                <p class="mt-3 text-3xl font-semibold text-gray-800">{{ totals.patients }}</p>
            </section>

            <section class="rounded-2xl border border-gray-200 bg-white p-5 shadow-sm">
                <div class="flex items-center justify-between">
                    <h2 class="text-sm font-medium text-gray-500">Appointments</h2>
                    <span class="flex h-10 w-10 items-center justify-center rounded-full bg-brand-50 text-brand-500">
                        <CalendarCheck2 class="h-5 w-5" />
                    </span>
                </div>
                <p class="mt-3 text-3xl font-semibold text-gray-800">{{ totals.appointments }}</p>
            </section>

            <section class="rounded-2xl border border-gray-200 bg-white p-5 shadow-sm">
                <div class="flex items-center justify-between">
                    <h2 class="text-sm font-medium text-gray-500">Procedures</h2>
                    <span class="flex h-10 w-10 items-center justify-center rounded-full bg-brand-50 text-brand-500">
                        <Stethoscope class="h-5 w-5" />
                    </span>
                </div>
                <p class="mt-3 text-3xl font-semibold text-gray-800">{{ totalProcedures }}</p>
            </section>

            <section class="rounded-2xl border border-gray-200 bg-white p-5 shadow-sm">
                <div class="flex items-center justify-between">
                    <h2 class="text-sm font-medium text-gray-500">Avg. attendance</h2>
                    <span class="flex h-10 w-10 items-center justify-center rounded-full bg-brand-50 text-brand-500">
                        <TrendingUp class="h-5 w-5" />
                    </span>
                </div>
                <p class="mt-3 text-3xl font-semibold text-gray-800">{{ avgAttendance }}%</p>
            </section>
        </div>

        <!-- Patient growth -->
        <section class="rounded-2xl border border-gray-200 bg-white p-5 shadow-sm">
            <div class="flex items-center justify-between">
                <h2 class="text-sm font-medium text-gray-500">Patient growth</h2>
                <a
                    :href="exportUrl('patientGrowth')"
                    class="flex h-11 items-center gap-1.5 rounded-lg px-3 text-xs font-medium text-brand-500 transition hover:bg-brand-50"
                >
                    <Download class="h-4 w-4" />
                    CSV
                </a>
            </div>
            <apexchart v-if="growthHasData" type="bar" height="260" :options="growthOptions" :series="growthSeries" />
            <p v-else class="flex h-64 items-center justify-center text-sm text-gray-500">No data for this period</p>
        </section>

        <!-- Appointment summary -->
        <section class="rounded-2xl border border-gray-200 bg-white p-5 shadow-sm">
            <div class="flex items-center justify-between">
                <h2 class="text-sm font-medium text-gray-500">Appointment summary</h2>
                <a
                    :href="exportUrl('appointmentSummary')"
                    class="flex h-11 items-center gap-1.5 rounded-lg px-3 text-xs font-medium text-brand-500 transition hover:bg-brand-50"
                >
                    <Download class="h-4 w-4" />
                    CSV
                </a>
            </div>
            <apexchart v-if="summaryHasData" type="bar" height="260" :options="summaryOptions" :series="summarySeries" />
            <p v-else class="flex h-64 items-center justify-center text-sm text-gray-500">No data for this period</p>
        </section>

        <!-- Procedure summary -->
        <section class="rounded-2xl border border-gray-200 bg-white p-5 shadow-sm">
            <div class="flex items-center justify-between">
                <h2 class="text-sm font-medium text-gray-500">Procedure summary</h2>
                <a
                    :href="exportUrl('procedureSummary')"
                    class="flex h-11 items-center gap-1.5 rounded-lg px-3 text-xs font-medium text-brand-500 transition hover:bg-brand-50"
                >
                    <Download class="h-4 w-4" />
                    CSV
                </a>
            </div>
            <apexchart v-if="procedureHasData" type="bar" height="260" :options="procedureOptions" :series="procedureSeries" />
            <p v-else class="flex h-64 items-center justify-center text-sm text-gray-500">No data for this period</p>
        </section>

        <!-- Condition summary -->
        <section class="rounded-2xl border border-gray-200 bg-white p-5 shadow-sm">
            <div class="flex items-center justify-between">
                <h2 class="text-sm font-medium text-gray-500">Condition summary</h2>
                <a
                    :href="exportUrl('conditionSummary')"
                    class="flex h-11 items-center gap-1.5 rounded-lg px-3 text-xs font-medium text-brand-500 transition hover:bg-brand-50"
                >
                    <Download class="h-4 w-4" />
                    CSV
                </a>
            </div>
            <apexchart v-if="conditionHasData" type="bar" height="260" :options="conditionOptions" :series="conditionSeries" />
            <p v-else class="flex h-64 items-center justify-center text-sm text-gray-500">No data for this period</p>
        </section>

        <!-- Dentist workload -->
        <section class="rounded-2xl border border-gray-200 bg-white p-5 shadow-sm">
            <div class="flex items-center justify-between">
                <h2 class="text-sm font-medium text-gray-500">Dentist workload</h2>
                <a
                    :href="exportUrl('dentistWorkload')"
                    class="flex h-11 items-center gap-1.5 rounded-lg px-3 text-xs font-medium text-brand-500 transition hover:bg-brand-50"
                >
                    <Download class="h-4 w-4" />
                    CSV
                </a>
            </div>
            <apexchart v-if="workloadHasData" type="bar" height="260" :options="workloadOptions" :series="workloadSeries" />
            <p v-else class="flex h-64 items-center justify-center text-sm text-gray-500">No data for this period</p>
        </section>
    </div>
</template>
