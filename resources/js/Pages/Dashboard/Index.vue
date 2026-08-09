<script setup>
import { computed } from "vue";
import { Head, Link } from "@inertiajs/vue3";
import {
    ArrowRight,
    BarChart3,
    CalendarCheck2,
    CalendarDays,
    Users,
} from "lucide-vue-next";
import { route } from "../../../../vendor/tightenco/ziggy";
import VueApexCharts from "vue3-apexcharts";
import AppLayout from "@/Layouts/AppLayout.vue";
import { Button } from "@/Components/ui/button";
import {
    Card,
    CardAction,
    CardContent,
    CardFooter,
    CardHeader,
    CardTitle,
} from "@/Components/ui/card";
import { jdcColors } from "@/lib/colors";

const apexchart = VueApexCharts;

defineOptions({ layout: AppLayout });

const props = defineProps({
    todayAppointments: { type: Array, default: () => [] },
    recentPatients: { type: Array, default: () => [] },
    monthlyStats: {
        type: Object,
        default: () => ({
            patients: 0,
            appointments: 0,
            series: { labels: [], patients: [], appointments: [] },
        }),
    },
    followUps: { type: Array, default: () => [] },
    can: { type: Object, default: () => ({}) },
});

const greeting = computed(() => {
    const hour = new Date().getHours();
    if (hour < 12) return "Good morning";
    if (hour < 18) return "Good afternoon";
    return "Good evening";
});

const todayLabel = computed(() =>
    new Intl.DateTimeFormat("en-PH", {
        weekday: "long",
        month: "long",
        day: "numeric",
        year: "numeric",
    }).format(new Date()),
);

const chartOptions = computed(() => ({
    chart: {
        type: "bar",
        toolbar: { show: false },
        fontFamily: "inherit",
    },
    colors: [jdcColors.brand[500], jdcColors.brand[300]], // JDC brand tokens
    plotOptions: { bar: { borderRadius: 6, columnWidth: "40%" } },
    dataLabels: { enabled: false },
    grid: { borderColor: jdcColors.gray[200], strokeDashArray: 4 }, // JDC gray-200
    xaxis: {
        categories: props.monthlyStats.series.labels,
        axisBorder: { show: false },
        axisTicks: { show: false },
        labels: { style: { colors: jdcColors.gray[500] } }, // JDC gray-500
    },
    yaxis: {
        labels: { style: { colors: jdcColors.gray[500] } },
    },
    legend: { position: "top", horizontalAlign: "right" },
    tooltip: { shared: true, intersect: false },
}));

const chartSeries = computed(() => [
    { name: "Patients", data: props.monthlyStats.series.patients },
    { name: "Appointments", data: props.monthlyStats.series.appointments },
]);
</script>

<template>
    <Head title="Dashboard" />

    <div class="mx-auto max-w-7xl space-y-6">
        <div>
            <h1 class="text-2xl font-semibold text-gray-800">
                {{ greeting }}, {{ $page.props.auth.user.name }}
            </h1>
            <p class="mt-1 text-sm text-gray-500">{{ todayLabel }}</p>
        </div>

        <div class="grid grid-cols-1 gap-4 sm:grid-cols-2 xl:grid-cols-3">
            <!-- Today's appointments -->
            <Card>
                <CardHeader>
                    <CardTitle class="text-sm font-medium text-gray-500"
                        >Today's appointments</CardTitle
                    >
                    <CardAction>
                        <span
                            class="flex h-10 w-10 items-center justify-center rounded-full bg-brand-50 text-brand-500"
                        >
                            <CalendarDays class="h-5 w-5" />
                        </span>
                    </CardAction>
                </CardHeader>
                <CardContent>
                    <p class="text-3xl font-semibold text-gray-800">
                        {{ todayAppointments.length }}
                    </p>
                </CardContent>
                <CardFooter class="mt-auto border-t border-gray-200">
                    <Button
                        as-child
                        class="w-full bg-brand-50 text-brand-500 hover:bg-brand-100"
                    >
                        <Link :href="route('appointments.index')">
                            View all
                            <ArrowRight class="size-4" />
                        </Link>
                    </Button>
                </CardFooter>
            </Card>

            <!-- Recent patients -->
            <Card>
                <CardHeader>
                    <CardTitle class="text-sm font-medium text-gray-500"
                        >Recent patients</CardTitle
                    >
                    <CardAction>
                        <span
                            class="flex h-10 w-10 items-center justify-center rounded-full bg-brand-50 text-brand-500"
                        >
                            <Users class="h-5 w-5" />
                        </span>
                    </CardAction>
                </CardHeader>
                <CardContent>
                    <p class="text-3xl font-semibold text-gray-800">
                        {{ recentPatients.length }}
                    </p>
                </CardContent>
                <CardFooter class="mt-auto border-t border-gray-200">
                    <Button
                        as-child
                        class="w-full bg-brand-50 text-brand-500 hover:bg-brand-100"
                    >
                        <Link :href="route('patients.index')">
                            View all
                            <ArrowRight class="size-4" />
                        </Link>
                    </Button>
                </CardFooter>
            </Card>

            <!-- Follow-up appointments -->
            <Card v-if="can.viewAppointments">
                <CardHeader>
                    <CardTitle class="text-sm font-medium text-gray-500"
                        >Follow-ups</CardTitle
                    >
                    <CardAction>
                        <span
                            class="flex h-10 w-10 items-center justify-center rounded-full bg-brand-50 text-brand-500"
                        >
                            <CalendarCheck2 class="h-5 w-5" />
                        </span>
                    </CardAction>
                </CardHeader>
                <CardContent>
                    <p class="text-3xl font-semibold text-gray-800">
                        {{ followUps.length }}
                    </p>
                </CardContent>
                <CardFooter class="mt-auto border-t border-gray-200">
                    <Button
                        as-child
                        class="w-full bg-brand-50 text-brand-500 hover:bg-brand-100"
                    >
                        <Link :href="route('appointments.index')">
                            View all
                            <ArrowRight class="size-4" />
                        </Link>
                    </Button>
                </CardFooter>
            </Card>
        </div>

        <!-- Monthly statistics -->
        <div class="grid grid-cols-1 gap-4 sm:grid-cols-2">
            <Card class="sm:col-span-2">
                <CardHeader>
                    <CardTitle class="text-sm font-medium text-gray-500"
                        >Monthly statistics</CardTitle
                    >
                    <CardAction>
                        <span
                            class="flex h-10 w-10 items-center justify-center rounded-full bg-brand-50 text-brand-500"
                        >
                            <BarChart3 class="h-5 w-5" />
                        </span>
                    </CardAction>
                </CardHeader>
                <CardContent>
                    <div class="flex gap-8">
                        <div>
                            <p class="text-xs text-gray-500">
                                New patients this month
                            </p>
                            <p
                                class="mt-0.5 text-xl font-semibold text-gray-800"
                            >
                                {{ monthlyStats.patients }}
                            </p>
                        </div>
                        <div>
                            <p class="text-xs text-gray-500">
                                New appointments this month
                            </p>
                            <p
                                class="mt-0.5 text-xl font-semibold text-gray-800"
                            >
                                {{ monthlyStats.appointments }}
                            </p>
                        </div>
                    </div>
                    <apexchart
                        type="bar"
                        height="260"
                        :options="chartOptions"
                        :series="chartSeries"
                    />
                </CardContent>
            </Card>
        </div>
    </div>
</template>
