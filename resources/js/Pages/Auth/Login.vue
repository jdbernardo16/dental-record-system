<script setup>
import Button from '@/Components/Button.vue';
import Checkbox from '@/Components/Checkbox.vue';
import GuestLayout from '@/Layouts/GuestLayout.vue';
import Input from '@/Components/Input.vue';
import { Head, Link, useForm } from '@inertiajs/vue3';

defineProps({
    canResetPassword: {
        type: Boolean,
    },
    status: {
        type: String,
    },
});

const form = useForm({
    email: '',
    password: '',
    remember: false,
});

const submit = () => {
    form.post(route('login'), {
        onFinish: () => form.reset('password'),
    });
};
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
                <Input
                    id="email"
                    v-model="form.email"
                    type="email"
                    label="Email"
                    required
                    autocomplete="username"
                    :error="form.errors.email"
                />
            </div>

            <div class="mt-4">
                <Input
                    id="password"
                    v-model="form.password"
                    type="password"
                    label="Password"
                    required
                    autocomplete="current-password"
                    :error="form.errors.password"
                />
            </div>

            <div class="mt-4 flex items-center justify-between">
                <label class="flex items-center gap-2">
                    <Checkbox name="remember" v-model:checked="form.remember" />
                    <span class="text-sm text-gray-600">Remember me</span>
                </label>

                <Link
                    v-if="canResetPassword"
                    :href="route('password.request')"
                    class="text-sm font-medium text-brand-600 hover:text-brand-700"
                >
                    Forgot your password?
                </Link>
            </div>

            <div class="mt-6">
                <Button
                    type="submit"
                    className="w-full"
                    :disabled="form.processing"
                >
                    {{ form.processing ? 'Signing in…' : 'Log in' }}
                </Button>
            </div>
        </form>
    </GuestLayout>
</template>
