<script setup>
import { Head, Link, useForm } from '@inertiajs/vue3'
import { route } from '../../../../vendor/tightenco/ziggy'
import AppLayout from '@/Layouts/AppLayout.vue'
import { Button } from '@/Components/ui/button'
import FormField from '@/Components/FormField.vue'
import { Input } from '@/Components/ui/input'
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from '@/Components/ui/select'
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
            <FormField id="name" label="Full name" required :error="form.errors.name">
                <template #default="{ id }">
                    <Input
                        :id="id"
                        v-model="form.name"
                        placeholder="Dra. Maria Cruz"
                        required
                        autofocus
                        :aria-invalid="form.errors.name ? 'true' : 'false'"
                    />
                </template>
            </FormField>
            <FormField id="username" label="Username" required :error="form.errors.username">
                <template #default="{ id }">
                    <Input
                        :id="id"
                        v-model="form.username"
                        placeholder="cruz"
                        required
                        :aria-invalid="form.errors.username ? 'true' : 'false'"
                    />
                </template>
            </FormField>
            <FormField id="email" label="Email address" required :error="form.errors.email">
                <template #default="{ id }">
                    <Input
                        :id="id"
                        v-model="form.email"
                        type="email"
                        placeholder="cruz@clinic.test"
                        required
                        :aria-invalid="form.errors.email ? 'true' : 'false'"
                    />
                </template>
            </FormField>
            <FormField id="password" label="Password" required :error="form.errors.password">
                <template #default="{ id }">
                    <Input
                        :id="id"
                        v-model="form.password"
                        type="password"
                        placeholder="At least 8 characters"
                        required
                        :aria-invalid="form.errors.password ? 'true' : 'false'"
                    />
                </template>
            </FormField>
            <FormField id="role" label="Role" required :error="form.errors.role">
                <template #default="{ id }">
                    <Select v-model="form.role" name="role" required>
                        <SelectTrigger
                            :id="id"
                            class="w-full"
                            :aria-invalid="form.errors.role ? 'true' : 'false'"
                        >
                            <SelectValue placeholder="Select a role" />
                        </SelectTrigger>
                        <SelectContent>
                            <SelectItem v-for="role in roles" :key="role" :value="role">
                                {{ role }}
                            </SelectItem>
                        </SelectContent>
                    </Select>
                </template>
            </FormField>

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
