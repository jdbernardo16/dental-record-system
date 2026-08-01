<script setup>
import { Head, Link, router, useForm } from '@inertiajs/vue3'
import { Trash2 } from 'lucide-vue-next'
import { route } from '../../../../vendor/tightenco/ziggy'
import AppLayout from '@/Layouts/AppLayout.vue'
import Badge from '@/Components/Badge.vue'
import Button from '@/Components/Button.vue'
import Input from '@/Components/Input.vue'
import { useToastStore } from '@/Stores/toast'

defineOptions({ layout: AppLayout })

const props = defineProps({
    user: { type: Object, required: true },
    roles: { type: Array, required: true },
    can: { type: Object, default: () => ({}) },
})

const toastStore = useToastStore()

const form = useForm({
    name: props.user.name,
    email: props.user.email,
    password: '',
    role: props.user.roles[0]?.name ?? '',
    is_active: props.user.is_active,
})

const roleColor = (role) =>
    ({
        Administrator: 'dark',
        Dentist: 'info',
        Assistant: 'light',
        Receptionist: 'warning',
    })[role] ?? 'light'

const submit = () => {
    form.patch(route('users.update', props.user.id), {
        preserveScroll: true,
        onSuccess: () => toastStore.show('User updated.'),
    })
}

const confirmDelete = () => {
    if (window.confirm(`Delete ${props.user.name}? This cannot be undone.`)) {
        router.delete(route('users.destroy', props.user.id))
    }
}
</script>

<template>
    <Head :title="`Edit ${user.name}`" />

    <div class="mx-auto max-w-2xl space-y-6">
        <div>
            <h1 class="text-2xl font-semibold text-gray-800">Edit user</h1>
            <p class="mt-1 text-sm text-gray-500">{{ user.name }} — update account details and role.</p>
        </div>

        <form v-if="can.update" class="space-y-5 rounded-2xl border border-gray-200 bg-white p-6 shadow-sm" @submit.prevent="submit">
            <Input
                v-model="form.name"
                label="Full name"
                required
                autofocus
                :error="form.errors.name"
            />
            <Input
                v-model="form.email"
                type="email"
                label="Email address"
                required
                :error="form.errors.email"
            />
            <Input
                v-model="form.password"
                type="password"
                label="Password"
                placeholder="Leave blank to keep unchanged"
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
                    <option v-for="role in roles" :key="role" :value="role">{{ role }}</option>
                </select>
                <p v-if="form.errors.role" class="mt-1.5 text-xs text-status-cancelled">{{ form.errors.role }}</p>
            </div>

            <div class="flex items-center justify-between rounded-xl bg-gray-50 px-4 py-3">
                <div>
                    <p class="text-sm font-medium text-gray-800">Account active</p>
                    <p class="text-xs text-gray-500">Deactivated users cannot sign in to the system.</p>
                </div>
                <label class="relative inline-flex cursor-pointer items-center">
                    <input
                        v-model="form.is_active"
                        type="checkbox"
                        class="peer sr-only"
                        aria-label="Account active"
                    />
                    <div
                        class="relative h-6 w-11 rounded-full bg-gray-300 transition-colors after:absolute after:top-0.5 after:left-0.5 after:h-5 after:w-5 after:rounded-full after:bg-white after:shadow-sm after:transition-transform peer-checked:bg-brand-500 peer-checked:after:translate-x-5"
                    ></div>
                </label>
            </div>

            <div class="flex items-center justify-end gap-3 pt-2">
                <Link :href="route('users.index')">
                    <Button variant="outline" size="sm" :disabled="form.processing">Cancel</Button>
                </Link>
                <Button type="submit" size="sm" :disabled="form.processing">
                    {{ form.processing ? 'Saving…' : 'Save changes' }}
                </Button>
            </div>
        </form>

        <div v-else class="space-y-5 rounded-2xl border border-gray-200 bg-white p-6 shadow-sm">
            <dl class="divide-y divide-gray-100">
                <div class="flex items-center justify-between py-3 first:pt-0 last:pb-0">
                    <dt class="text-sm font-medium text-gray-500">Full name</dt>
                    <dd class="text-sm font-medium text-gray-800">{{ user.name }}</dd>
                </div>
                <div class="flex items-center justify-between py-3">
                    <dt class="text-sm font-medium text-gray-500">Email address</dt>
                    <dd class="text-sm text-gray-800">{{ user.email }}</dd>
                </div>
                <div class="flex items-center justify-between py-3">
                    <dt class="text-sm font-medium text-gray-500">Role</dt>
                    <dd>
                        <Badge size="sm" :color="roleColor(user.roles[0]?.name)">
                            {{ user.roles[0]?.name ?? 'None' }}
                        </Badge>
                    </dd>
                </div>
                <div class="flex items-center justify-between py-3">
                    <dt class="text-sm font-medium text-gray-500">Status</dt>
                    <dd>
                        <Badge size="sm" :color="user.is_active ? 'success' : 'error'">
                            {{ user.is_active ? 'Active' : 'Inactive' }}
                        </Badge>
                    </dd>
                </div>
            </dl>
            <div class="pt-2">
                <Link
                    :href="route('users.index')"
                    class="inline-flex h-11 items-center justify-center rounded-lg border border-gray-300 bg-white px-5 py-3 text-sm font-medium text-gray-700 hover:bg-gray-50"
                >
                    Back to users
                </Link>
            </div>
        </div>

        <div v-if="can.delete" class="flex items-center justify-between rounded-2xl border border-status-cancelled/20 bg-status-cancelled/5 p-6">
            <div>
                <p class="text-sm font-semibold text-gray-800">Danger zone</p>
                <p class="mt-0.5 text-sm text-gray-500">Permanently remove this account.</p>
            </div>
            <Button variant="outline" size="sm" class="border-status-cancelled/30 text-status-cancelled hover:bg-status-cancelled/10" @click="confirmDelete">
                <Trash2 class="h-4 w-4" />
                Delete user
            </Button>
        </div>
    </div>
</template>
