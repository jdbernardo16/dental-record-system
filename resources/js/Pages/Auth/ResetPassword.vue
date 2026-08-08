<script setup>
import { scrollToFirstError } from '@/lib/scroll'
import { Button } from '@/Components/ui/button'
import { TextInput } from '@/Components/Fields'
import GuestLayout from '@/Layouts/GuestLayout.vue'
import { Head, useForm } from '@inertiajs/vue3'

const props = defineProps({
    email: {
        type: String,
        required: true,
    },
    token: {
        type: String,
        required: true,
    },
})

const form = useForm({
    token: props.token,
    email: props.email,
    password: '',
    password_confirmation: '',
})

const submit = () => {
    form.post(route('password.store'), {
        onFinish: () => form.reset('password', 'password_confirmation'),
        onError: () => scrollToFirstError(),
    })
}
</script>

<template>
    <GuestLayout>
        <Head title="Reset Password" />

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

            <div class="mt-4">
                <TextInput
                    v-model="form.password"
                    label="Password"
                    required
                    type="password"
                    :error="form.errors.password"
                    class="w-full"
                    autocomplete="new-password"
                />
            </div>

            <div class="mt-4">
                <TextInput
                    v-model="form.password_confirmation"
                    label="Confirm Password"
                    required
                    type="password"
                    :error="form.errors.password_confirmation"
                    class="w-full"
                    autocomplete="new-password"
                />
            </div>

            <div class="mt-6">
                <Button type="submit" class="w-full" :disabled="form.processing">
                    {{ form.processing ? '…' : 'Reset Password' }}
                </Button>
            </div>
        </form>
    </GuestLayout>
</template>
