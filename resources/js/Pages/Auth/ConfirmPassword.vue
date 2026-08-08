<script setup>
import { scrollToFirstError } from '@/lib/scroll'
import { Button } from '@/Components/ui/button'
import { TextInput } from '@/Components/Fields'
import GuestLayout from '@/Layouts/GuestLayout.vue'
import { Head, useForm } from '@inertiajs/vue3'

const form = useForm({
    password: '',
})

const submit = () => {
    form.post(route('password.confirm'), {
        onFinish: () => form.reset(),
        onError: () => scrollToFirstError(),
    })
}
</script>

<template>
    <GuestLayout>
        <Head title="Confirm Password" />

        <div class="mb-4 text-sm text-gray-600">
            This is a secure area of the application. Please confirm your
            password before continuing.
        </div>

        <form @submit.prevent="submit">
            <TextInput
                v-model="form.password"
                label="Password"
                required
                type="password"
                :error="form.errors.password"
                class="w-full"
                autocomplete="current-password"
                autofocus
            />

            <div class="mt-6">
                <Button type="submit" class="w-full" :disabled="form.processing">
                    {{ form.processing ? '…' : 'Confirm' }}
                </Button>
            </div>
        </form>
    </GuestLayout>
</template>
