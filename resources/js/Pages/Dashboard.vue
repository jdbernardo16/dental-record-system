<script setup>
import { Head } from '@inertiajs/vue3';
import AppLayout from '@/Layouts/AppLayout.vue';

defineOptions({ layout: AppLayout });
</script>

<template>
    <Head title="Dashboard" />

    <div class="space-y-6">
        <h1 class="text-2xl font-semibold text-gray-800">Dashboard</h1>

        <div class="rounded-2xl border border-gray-200 bg-white p-6 shadow-sm">
            <p class="text-gray-700">
                Welcome, {{ $page.props.auth.user.name }}
            </p>
        </div>
    </div>
</template>
