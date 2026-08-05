<script setup>
import { Button } from '@/Components/ui/button'
import FormField from '@/Components/FormField.vue'
import GuestLayout from '@/Layouts/GuestLayout.vue'
import { Input } from '@/Components/ui/input'
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
    })
}
</script>

<template>
    <GuestLayout>
        <Head title="Register" />

        <form @submit.prevent="submit">
            <div>
                <FormField id="name" label="Name" required :error="form.errors.name">
                    <template #default="{ id }">
                        <Input
                            :id="id"
                            v-model="form.name"
                            type="text"
                            class="w-full"
                            required
                            autofocus
                            autocomplete="name"
                            :aria-invalid="form.errors.name ? 'true' : 'false'"
                        />
                    </template>
                </FormField>
            </div>

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
                <FormField id="email" label="Email" required :error="form.errors.email">
                    <template #default="{ id }">
                        <Input
                            :id="id"
                            v-model="form.email"
                            type="email"
                            class="w-full"
                            required
                            autocomplete="username"
                            :aria-invalid="form.errors.email ? 'true' : 'false'"
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
                            autocomplete="new-password"
                            :aria-invalid="form.errors.password ? 'true' : 'false'"
                        />
                    </template>
                </FormField>
            </div>

            <div class="mt-4">
                <FormField
                    id="password_confirmation"
                    label="Confirm Password"
                    required
                    :error="form.errors.password_confirmation"
                >
                    <template #default="{ id }">
                        <Input
                            :id="id"
                            v-model="form.password_confirmation"
                            type="password"
                            class="w-full"
                            required
                            autocomplete="new-password"
                            :aria-invalid="form.errors.password_confirmation ? 'true' : 'false'"
                        />
                    </template>
                </FormField>
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
