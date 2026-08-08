<script setup>
import { scrollToFirstError } from '@/lib/scroll'
import { Button } from '@/Components/ui/button'
import { TextInput } from '@/Components/Fields'
import GuestLayout from '@/Layouts/GuestLayout.vue'
import { Head, Link, useForm } from '@inertiajs/vue3'

const form = useForm({
    name: '',
    username: '',
    email: '',
    password: '',
    password_confirmation: '',
})

const submit = () => {
    form.post(route('register'), {
        onFinish: () => form.reset('password', 'password_confirmation'),
        onError: () => scrollToFirstError(),
    })
}
</script>

<template>
    <GuestLayout>
        <Head title="Register" />

        <form @submit.prevent="submit">
            <div>
                <TextInput
                    v-model="form.name"
                    label="Name"
                    required
                    :error="form.errors.name"
                    class="w-full"
                    autofocus
                    autocomplete="name"
                />
            </div>

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
                    v-model="form.email"
                    label="Email"
                    required
                    type="email"
                    :error="form.errors.email"
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

            <div class="mt-4 flex items-center justify-end">
                <Link
                    :href="route('login')"
                    class="text-sm font-medium text-brand-600 hover:text-brand-700"
                >
                    Already registered?
                </Link>
            </div>

            <div class="mt-6">
                <Button type="submit" class="w-full" :disabled="form.processing">
                    {{ form.processing ? '…' : 'Register' }}
                </Button>
            </div>
        </form>
    </GuestLayout>
</template>
