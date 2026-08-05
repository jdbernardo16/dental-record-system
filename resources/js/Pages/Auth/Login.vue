<script setup>
import { Button } from '@/Components/ui/button'
import { Checkbox } from '@/Components/ui/checkbox'
import FormField from '@/Components/FormField.vue'
import GuestLayout from '@/Layouts/GuestLayout.vue'
import { Input } from '@/Components/ui/input'
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
                <FormField id="username" label="Username" required :error="form.errors.username">
                    <template #default="{ id }">
                        <Input
                            :id="id"
                            v-model="form.username"
                            type="text"
                            class="w-full"
                            required
                            autocomplete="username"
                            :aria-invalid="form.errors.username ? 'true' : 'false'"
                        />
                    </template>
                </FormField>
            </div>

            <div class="mt-4">
                <FormField id="password" label="Password" required :error="form.errors.password">
                    <template #default="{ id }">
                        <Input
                            :id="id"
                            v-model="form.password"
                            type="password"
                            class="w-full"
                            required
                            autocomplete="current-password"
                            :aria-invalid="form.errors.password ? 'true' : 'false'"
                        />
                    </template>
                </FormField>
            </div>

            <div class="mt-4 flex items-center justify-between">
                <label class="flex items-center gap-2">
                    <Checkbox v-model="form.remember" name="remember" />
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
                <Button type="submit" class="w-full" :disabled="form.processing">
                    {{ form.processing ? 'Signing in…' : 'Log in' }}
                </Button>
            </div>
        </form>
    </GuestLayout>
</template>
