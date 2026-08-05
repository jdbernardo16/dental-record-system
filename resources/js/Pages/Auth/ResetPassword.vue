<script setup>
import { Button } from '@/Components/ui/button'
import FormField from '@/Components/FormField.vue'
import GuestLayout from '@/Layouts/GuestLayout.vue'
import { Input } from '@/Components/ui/input'
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
    })
}
</script>

<template>
    <GuestLayout>
        <Head title="Reset Password" />

        <form @submit.prevent="submit">
            <FormField id="email" label="Email" required :error="form.errors.email">
                <template #default="{ id }">
                    <Input
                        :id="id"
                        v-model="form.email"
                        type="email"
                        class="w-full"
                        required
                        autofocus
                        autocomplete="username"
                        :aria-invalid="form.errors.email ? 'true' : 'false'"
                    />
                </template>
            </FormField>

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

            <div class="mt-6">
                <Button type="submit" class="w-full" :disabled="form.processing">
                    {{ form.processing ? '…' : 'Reset Password' }}
                </Button>
            </div>
        </form>
    </GuestLayout>
</template>
