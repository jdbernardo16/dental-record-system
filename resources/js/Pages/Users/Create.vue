<script setup>
import { Head, Link, useForm } from '@inertiajs/vue3'
import { route } from '../../../../vendor/tightenco/ziggy'
import AppLayout from '@/Layouts/AppLayout.vue'
import Button from '@/Components/Button.vue'
import Input from '@/Components/Input.vue'
import { useToastStore } from '@/Stores/toast'

defineOptions({ layout: AppLayout })

const props = defineProps({
    roles: { type: Array, required: true },
})

const toastStore = useToastStore()

const form = useForm({
    name: '',
    email: '',
    password: '',
    role: '',
})

const submit = () => {
    form.post(route('users.store'), {
        preserveScroll: true,
        onSuccess: () => toastStore.show('User created.'),
    })
}
</script>

<template>
    <Head title="Add user" />

    <div class="mx-auto max-w-2xl space-y-6">
        <div>
            <h1 class="text-2xl font-semibold text-gray-800">Add user</h1>
            <p class="mt-1 text-sm text-gray-500">Create a new clinic staff account.</p>
        </div>

        <form class="space-y-5 rounded-2xl border border-gray-200 bg-white p-6 shadow-sm" @submit.prevent="submit">
            <Input
                v-model="form.name"
                label="Full name"
                placeholder="Dra. Maria Cruz"
                required
                autofocus
                :error="form.errors.name"
            />
            <Input
                v-model="form.email"
                type="email"
                label="Email address"
                placeholder="cruz@clinic.test"
                required
                :error="form.errors.email"
            />
            <Input
                v-model="form.password"
                type="password"
                label="Password"
                placeholder="At least 8 characters"
                required
                :error="form.errors.password"
            />
            <div>
                <label for="role" class="mb-1.5 block text-sm font-medium text-gray-700">
                    Role
                    <span class="text-status-cancelled">*</span>
                </label>
                <select
                    id="role"
                    v-model="form.role"
                    required
                    :aria-invalid="form.errors.role ? 'true' : 'false'"
                    class="h-11 w-full rounded-lg border border-gray-300 bg-transparent px-4 py-2.5 text-sm text-gray-800 shadow-sm focus:border-brand-300 focus:outline-hidden focus:ring-2 focus:ring-brand-500/10"
                    :class="{ 'border-status-cancelled': form.errors.role }"
                >
                    <option value="" disabled>Select a role</option>
                    <option v-for="role in roles" :key="role" :value="role">{{ role }}</option>
                </select>
                <p v-if="form.errors.role" class="mt-1.5 text-xs text-status-cancelled">{{ form.errors.role }}</p>
            </div>

            <div class="flex items-center justify-end gap-3 pt-2">
                <Link :href="route('users.index')">
                    <Button variant="outline" size="sm" :disabled="form.processing">Cancel</Button>
                </Link>
                <Button type="submit" size="sm" :disabled="form.processing">
                    {{ form.processing ? 'Saving…' : 'Create user' }}
                </Button>
            </div>
        </form>
    </div>
</template>
