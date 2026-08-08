<script setup>
import { scrollToFirstError } from '@/lib/scroll'
import { Head, Link, useForm } from '@inertiajs/vue3'
import { route } from '../../../../vendor/tightenco/ziggy'
import AppLayout from '@/Layouts/AppLayout.vue'
import { Button } from '@/Components/ui/button'
import { SelectField, TextInput } from '@/Components/Fields'
import { useToastStore } from '@/Stores/toast'

defineOptions({ layout: AppLayout })

const props = defineProps({
    roles: { type: Array, required: true },
})

const toastStore = useToastStore()

const form = useForm({
    name: '',
    username: '',
    email: '',
    password: '',
    role: '',
})

const submit = () => {
    form.post(route('users.store'), {
        preserveScroll: true,
        onSuccess: () => toastStore.show('User created.'),
        onError: () => scrollToFirstError(),
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
            <TextInput
                id="name"
                v-model="form.name"
                label="Full name"
                required
                placeholder="Dra. Maria Cruz"
                autofocus
                :error="form.errors.name"
            />
            <TextInput
                id="username"
                v-model="form.username"
                label="Username"
                required
                placeholder="cruz"
                :error="form.errors.username"
            />
            <TextInput
                id="email"
                v-model="form.email"
                type="email"
                label="Email address"
                required
                placeholder="cruz@clinic.test"
                :error="form.errors.email"
            />
            <TextInput
                id="password"
                v-model="form.password"
                type="password"
                label="Password"
                required
                placeholder="At least 8 characters"
                :error="form.errors.password"
            />
            <SelectField
                id="role"
                v-model="form.role"
                label="Role"
                required
                placeholder="Select a role"
                :options="roles.map((role) => ({ value: role, label: role }))"
                :error="form.errors.role"
            />

            <div class="flex items-center justify-end gap-3 pt-2">
                <Link :href="route('users.index')">
                    <Button variant="outline" :disabled="form.processing">Cancel</Button>
                </Link>
                <Button type="submit" :disabled="form.processing">
                    {{ form.processing ? 'Saving…' : 'Create user' }}
                </Button>
            </div>
        </form>
    </div>
</template>
