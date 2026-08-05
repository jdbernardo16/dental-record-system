<script setup>
import { Head, Link, router } from '@inertiajs/vue3'
import { Pencil, Plus, Trash2 } from 'lucide-vue-next'
import { route } from '../../../../vendor/tightenco/ziggy'
import AppLayout from '@/Layouts/AppLayout.vue'
import Badge from '@/Components/Badge.vue'
import Button from '@/Components/Button.vue'

defineOptions({ layout: AppLayout })

const props = defineProps({
    users: { type: Array, required: true },
    can: { type: Object, default: () => ({}) },
})

const roleColor = (role) =>
    ({
        Administrator: 'dark',
        Dentist: 'info',
        Assistant: 'light',
        Receptionist: 'warning',
    })[role] ?? 'light'

const initials = (name) =>
    String(name)
        .split(' ')
        .map((part) => part[0])
        .slice(0, 2)
        .join('')
        .toUpperCase()

const confirmDelete = (user) => {
    if (window.confirm(`Delete ${user.name}? This cannot be undone.`)) {
        router.delete(route('users.destroy', user.id))
    }
}
</script>

<template>
    <Head title="Users" />

    <div class="space-y-6">
        <div class="flex flex-wrap items-center justify-between gap-4">
            <div>
                <h1 class="text-2xl font-semibold text-gray-800">Users</h1>
                <p class="mt-1 text-sm text-gray-500">Manage clinic staff accounts and roles.</p>
            </div>
            <Link v-if="can.create" :href="route('users.create')" class="inline-block">
                <Button variant="primary" size="sm">
                    <Plus class="h-4 w-4" />
                    Add user
                </Button>
            </Link>
        </div>

        <div class="overflow-hidden rounded-2xl border border-gray-200 bg-white shadow-sm">
            <div class="overflow-x-auto">
                <table class="min-w-full divide-y divide-gray-200">
                    <thead class="bg-gray-50">
                        <tr>
                            <th scope="col" class="px-6 py-3.5 text-left text-xs font-semibold tracking-wide text-gray-500 uppercase">
                                Name
                            </th>
                            <th scope="col" class="px-6 py-3.5 text-left text-xs font-semibold tracking-wide text-gray-500 uppercase">
                                Username
                            </th>
                            <th scope="col" class="px-6 py-3.5 text-left text-xs font-semibold tracking-wide text-gray-500 uppercase">
                                Email
                            </th>
                            <th scope="col" class="px-6 py-3.5 text-left text-xs font-semibold tracking-wide text-gray-500 uppercase">
                                Role
                            </th>
                            <th scope="col" class="px-6 py-3.5 text-left text-xs font-semibold tracking-wide text-gray-500 uppercase">
                                Status
                            </th>
                            <th scope="col" class="px-6 py-3.5 text-right text-xs font-semibold tracking-wide text-gray-500 uppercase">
                                Actions
                            </th>
                        </tr>
                    </thead>
                    <tbody class="divide-y divide-gray-100">
                        <tr v-for="user in users" :key="user.id" class="hover:bg-gray-50">
                            <td class="px-6 py-4">
                                <div class="flex items-center gap-3">
                                    <span class="flex h-9 w-9 shrink-0 items-center justify-center rounded-full bg-brand-500 text-xs font-semibold text-white">
                                        {{ initials(user.name) }}
                                    </span>
                                    <span class="text-sm font-medium text-gray-800">{{ user.name }}</span>
                                </div>
                            </td>
                            <td class="px-6 py-4 text-sm text-gray-500">{{ user.username }}</td>
                            <td class="px-6 py-4 text-sm text-gray-500">{{ user.email }}</td>
                            <td class="px-6 py-4">
                                <Badge size="sm" :color="roleColor(user.roles[0]?.name)">
                                    {{ user.roles[0]?.name ?? 'None' }}
                                </Badge>
                            </td>
                            <td class="px-6 py-4">
                                <Badge size="sm" :color="user.is_active ? 'success' : 'error'" :variant="user.is_active ? 'light' : 'solid'">
                                    {{ user.is_active ? 'Active' : 'Inactive' }}
                                </Badge>
                            </td>
                            <td class="px-6 py-4">
                                <div class="flex items-center justify-end gap-2">
                                    <Link
                                        :href="route('users.edit', user.id)"
                                        class="inline-flex h-9 items-center gap-2 rounded-lg px-3 text-sm font-medium text-gray-600 hover:bg-gray-100 hover:text-gray-800"
                                    >
                                        <Pencil class="h-4 w-4" />
                                        Edit
                                    </Link>
                                    <button
                                        v-if="can.delete"
                                        type="button"
                                        class="inline-flex h-9 items-center gap-2 rounded-lg px-3 text-sm font-medium text-status-cancelled hover:bg-status-cancelled/10"
                                        @click="confirmDelete(user)"
                                    >
                                        <Trash2 class="h-4 w-4" />
                                        Delete
                                    </button>
                                </div>
                            </td>
                        </tr>
                    </tbody>
                </table>
            </div>
        </div>
    </div>
</template>
