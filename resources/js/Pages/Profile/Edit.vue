<script setup>
import AppLayout from '@/Layouts/AppLayout.vue'
import DeleteUserForm from './Partials/DeleteUserForm.vue'
import UpdatePasswordForm from './Partials/UpdatePasswordForm.vue'
import UpdateProfileInformationForm from './Partials/UpdateProfileInformationForm.vue'
import { Head } from '@inertiajs/vue3'

defineOptions({ layout: AppLayout })

defineProps({
    mustVerifyEmail: {
        type: Boolean,
    },
    status: {
        type: String,
    },
})
</script>

<template>
    <Head title="Profile" />

    <div class="mx-auto max-w-3xl space-y-6">
        <div>
            <h1 class="text-2xl font-semibold text-gray-800">Profile</h1>
            <p class="mt-1 text-sm text-gray-500">Manage your account information and password.</p>
        </div>

        <div class="rounded-2xl border border-gray-200 bg-white p-6 shadow-sm">
            <UpdateProfileInformationForm
                :must-verify-email="mustVerifyEmail"
                :status="status"
            />
        </div>

        <div class="rounded-2xl border border-gray-200 bg-white p-6 shadow-sm">
            <UpdatePasswordForm />
        </div>

        <div class="rounded-2xl border border-gray-200 bg-white p-6 shadow-sm">
            <DeleteUserForm />
        </div>
    </div>
</template>
