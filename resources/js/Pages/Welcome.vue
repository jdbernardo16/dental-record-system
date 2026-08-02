<script setup>
import { computed } from 'vue';
import { Head, Link, usePage } from '@inertiajs/vue3';
import { Users, ScanLine, CalendarDays } from 'lucide-vue-next';
import BrandMark from '@/Components/BrandMark.vue';
import Button from '@/Components/Button.vue';

defineProps({
    canLogin: {
        type: Boolean,
    },
    canRegister: {
        type: Boolean,
    },
});

const page = usePage();

const clinic = computed(() => page.props.clinic ?? { name: 'Dental Clinic', address: '' });
</script>

<template>
    <Head title="Welcome" />

    <div class="min-h-screen bg-gray-50">
        <div class="mx-auto max-w-6xl px-4 sm:px-6">
            <header class="flex items-center justify-between py-5">
                <div class="flex items-center gap-2.5">
                    <BrandMark class="h-9 w-9 text-brand-500" />
                    <span class="text-lg font-semibold text-gray-900">{{ clinic.name }}</span>
                </div>

                <nav class="flex items-center gap-3">
                    <template v-if="$page.props.auth.user">
                        <Link
                            :href="route('dashboard')"
                            class="rounded-lg px-3 py-2 text-sm font-medium text-gray-600 hover:text-gray-900"
                        >
                            Dashboard
                        </Link>
                    </template>

                    <template v-else>
                        <Link :href="route('login')">
                            <Button size="sm">Sign in</Button>
                        </Link>

                        <Link v-if="canRegister" :href="route('register')">
                            <Button size="sm" variant="outline">Register</Button>
                        </Link>
                    </template>
                </nav>
            </header>

            <section class="relative py-16 text-center sm:py-24">
                <BrandMark
                    class="pointer-events-none absolute left-1/2 top-1/2 h-64 w-64 -translate-x-1/2 -translate-y-1/2 text-brand-500/5"
                />

                <div class="relative">
                    <span
                        class="inline-flex items-center gap-2 rounded-full bg-brand-50 px-4 py-1.5 text-sm font-medium text-brand-700 ring-1 ring-inset ring-brand-200"
                    >
                        Dental Clinic Patient Record System
                    </span>

                    <h1 class="mt-6 text-3xl font-semibold tracking-tight text-gray-900 sm:text-5xl">
                        Your clinic's records, all in one place.
                    </h1>

                    <p class="mx-auto mt-4 max-w-2xl text-base text-gray-600 sm:text-lg">
                        Patients, medical histories, dental charts, treatments, consents, and
                        appointments — digitized for your tablets.
                    </p>

                    <div class="mt-8 flex flex-wrap items-center justify-center gap-3">
                        <template v-if="$page.props.auth.user">
                            <Link :href="route('dashboard')">
                                <Button size="md">Go to dashboard</Button>
                            </Link>

                            <Link :href="route('wizard.index')">
                                <Button size="md" variant="outline">New patient intake</Button>
                            </Link>
                        </template>

                        <template v-else>
                            <Link :href="route('login')">
                                <Button size="md">Sign in</Button>
                            </Link>

                            <Link v-if="canRegister" :href="route('register')">
                                <Button size="md" variant="outline">Create an account</Button>
                            </Link>
                        </template>
                    </div>
                </div>
            </section>

            <section class="grid grid-cols-1 gap-4 pb-16 sm:grid-cols-3">
                <div class="rounded-2xl border border-gray-200 bg-white p-6 shadow-sm">
                    <div class="flex h-12 w-12 items-center justify-center rounded-xl bg-brand-50 text-brand-500">
                        <Users class="h-6 w-6" />
                    </div>
                    <h2 class="mt-4 text-base font-semibold text-gray-800">Patients &amp; histories</h2>
                    <p class="mt-1.5 text-sm text-gray-600">
                        Register patients and capture full PDA medical histories at intake.
                    </p>
                </div>

                <div class="rounded-2xl border border-gray-200 bg-white p-6 shadow-sm">
                    <div class="flex h-12 w-12 items-center justify-center rounded-xl bg-brand-50 text-brand-500">
                        <ScanLine class="h-6 w-6" />
                    </div>
                    <h2 class="mt-4 text-base font-semibold text-gray-800">Dental chart</h2>
                    <p class="mt-1.5 text-sm text-gray-600">
                        Tap-to-mark twin-arch chart with the PDA condition and restoration legend.
                    </p>
                </div>

                <div class="rounded-2xl border border-gray-200 bg-white p-6 shadow-sm">
                    <div class="flex h-12 w-12 items-center justify-center rounded-xl bg-brand-50 text-brand-500">
                        <CalendarDays class="h-6 w-6" />
                    </div>
                    <h2 class="mt-4 text-base font-semibold text-gray-800">Appointments</h2>
                    <p class="mt-1.5 text-sm text-gray-600">
                        Day-view scheduling with confirm, reschedule, cancel, and attendance.
                    </p>
                </div>
            </section>

            <footer class="border-t border-gray-200 py-8 text-center">
                <p class="text-sm text-gray-500">
                    {{ clinic.name }}<template v-if="clinic.address"> · {{ clinic.address }}</template>
                </p>
                <p class="mt-1 text-xs text-gray-400">© {{ new Date().getFullYear() }}</p>
            </footer>
        </div>
    </div>
</template>
