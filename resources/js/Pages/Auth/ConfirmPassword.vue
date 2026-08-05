<script setup>
import { Button } from '@/Components/ui/button'
import FormField from '@/Components/FormField.vue'
import GuestLayout from '@/Layouts/GuestLayout.vue'
import { Input } from '@/Components/ui/input'
import { Head, useForm } from '@inertiajs/vue3'

const form = useForm({
    password: '',
})

const submit = () => {
    form.post(route('password.confirm'), {
        onFinish: () => form.reset(),
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
            <FormField id="password" label="Password" required :error="form.errors.password">
                <template #default="{ id }">
                    <Input
                        :id="id"
                        v-model="form.password"
                        type="password"
                        class="w-full"
                        required
                        autocomplete="current-password"
                        autofocus
                        :aria-invalid="form.errors.password ? 'true' : 'false'"
                    />
                </template>
            </FormField>

            <div class="mt-6">
                <Button type="submit" class="w-full" :disabled="form.processing">
                    {{ form.processing ? '…' : 'Confirm' }}
                </Button>
            </div>
        </form>
    </GuestLayout>
</template>
