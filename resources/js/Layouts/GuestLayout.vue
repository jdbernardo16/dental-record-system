<script setup>
import { computed } from 'vue';
import { Link, usePage } from '@inertiajs/vue3';
import { ArrowLeft } from 'lucide-vue-next';
import BrandMark from '@/Components/BrandMark.vue';

const page = usePage();

const clinicName = computed(() => page.props.clinic?.name || 'Dental Clinic');
</script>

<template>
    <div
        class="relative flex min-h-screen flex-col items-center justify-center overflow-x-clip bg-gradient-to-br from-brand-700 via-brand-800 to-brand-900 px-4 py-10"
    >
        <div
            class="pointer-events-none absolute -top-24 -left-24 h-96 w-96 rounded-full bg-white/5 blur-3xl"
        ></div>
        <div
            class="pointer-events-none absolute -right-24 -bottom-32 h-112 w-112 rounded-full bg-brand-500/20 blur-3xl"
        ></div>

        <div class="relative">
            <div class="text-center">
                <BrandMark class="mx-auto h-14 w-14 text-white" />
                <p class="mt-3 text-xl font-semibold text-white">{{ clinicName }}</p>
                <p class="mt-1 text-sm text-brand-100">
                    Patient records · Dental charts · Appointments
                </p>
            </div>

            <div class="mt-8 w-full max-w-md rounded-2xl bg-white p-6 shadow-xl sm:p-8">
                <slot />
            </div>

            <Link
                href="/"
                class="mt-6 inline-flex items-center gap-1.5 text-sm text-brand-100 hover:text-white"
            >
                <ArrowLeft class="h-4 w-4" />
                Back to home
            </Link>
        </div>
    </div>
</template>
