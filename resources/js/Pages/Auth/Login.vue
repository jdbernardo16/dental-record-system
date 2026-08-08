<script setup>
import { scrollToFirstError } from '@/lib/scroll'
import { Button } from '@/Components/ui/button'
import { CheckboxField, TextInput } from '@/Components/Fields'
import GuestLayout from '@/Layouts/GuestLayout.vue'
import { Head, Link, useForm } from '@inertiajs/vue3'

defineProps({
    canResetPassword: {
        type: Boolean,
    },
    status: {
        type: String,
    },
})

const form = useForm({
    username: '',
    password: '',
    remember: false,
})

const submit = () => {
    form.post(route('login'), {
        onFinish: () => form.reset('password'),
        onError: () => scrollToFirstError(),
    })
}
</script>

<template>
    <GuestLayout>
        <Head title="Log in" />

        <div
            v-if="status"
            class="mb-4 rounded-lg bg-status-completed/10 px-4 py-3 text-sm font-medium text-status-completed"
        >
            {{ status }}
        </div>

        <form @submit.prevent="submit">
            <h2 class="text-lg font-semibold text-gray-800">Welcome back</h2>
            <p class="mt-0.5 text-sm text-gray-500">Sign in to your account.</p>

            <div class="mt-4">
                <TextInput
                    v-model="form.username"
                    label="Username"
                    required
                    :error="form.errors.username"
                    class="w-full"
                    autocomplete="username"
                />
            </div>

            <div class="mt-4">
                <TextInput
                    v-model="form.password"
                    label="Password"
                    required
                    type="password"
                    :error="form.errors.password"
                    class="w-full"
                    autocomplete="current-password"
                />
            </div>

            <div class="mt-4 flex items-center justify-between">
                <CheckboxField v-model="form.remember" label="Remember me" />

                <Link
                    v-if="canResetPassword"
                    :href="route('password.request')"
                    class="text-sm font-medium text-brand-600 hover:text-brand-700"
                >
                    Forgot your password?
                </Link>
            </div>

            <div class="mt-6">
                <Button type="submit" class="w-full" :disabled="form.processing">
                    {{ form.processing ? 'Signing in…' : 'Log in' }}
                </Button>
            </div>
        </form>
    </GuestLayout>
</template>
