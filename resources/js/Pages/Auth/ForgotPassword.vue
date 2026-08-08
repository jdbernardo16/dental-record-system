<script setup>
import { Button } from '@/Components/ui/button'
import { TextInput } from '@/Components/Fields'
import GuestLayout from '@/Layouts/GuestLayout.vue'
import { Head, useForm } from '@inertiajs/vue3'
import { scrollToFirstError } from '@/lib/scroll'

defineProps({
    status: {
        type: String,
    },
})

const form = useForm({
    email: '',
})

const submit = () => {
    form.post(route('password.email'), {
        onError: () => scrollToFirstError(),
    })
}
</script>

<template>
    <GuestLayout>
        <Head title="Forgot Password" />

        <div class="mb-4 text-sm text-gray-600">
            Forgot your password? No problem. Just let us know your email
            address and we will email you a password reset link that will allow
            you to choose a new one.
        </div>

        <div v-if="status" class="mb-4 text-sm font-medium text-green-600">
            {{ status }}
        </div>

        <form @submit.prevent="submit">
            <TextInput
                v-model="form.email"
                label="Email"
                required
                type="email"
                :error="form.errors.email"
                class="w-full"
                autofocus
                autocomplete="username"
            />

            <div class="mt-6">
                <Button type="submit" class="w-full" :disabled="form.processing">
                    {{ form.processing ? '…' : 'Email Password Reset Link' }}
                </Button>
            </div>
        </form>
    </GuestLayout>
</template>
