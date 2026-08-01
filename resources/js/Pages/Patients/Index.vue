<script setup>
import { ref, watch } from 'vue'
import { Head, Link, router } from '@inertiajs/vue3'
import { ChevronLeft, ChevronRight, Eye, Pencil, Plus, Search, Trash2 } from 'lucide-vue-next'
import { route } from '../../../../vendor/tightenco/ziggy'
import AppLayout from '@/Layouts/AppLayout.vue'
import Button from '@/Components/Button.vue'
import Input from '@/Components/Input.vue'
import { useToastStore } from '@/Stores/toast'

defineOptions({ layout: AppLayout })

const props = defineProps({
    patients: { type: Object, required: true },
    filters: { type: Object, default: () => ({}) },
    can: { type: Object, default: () => ({}) },
})

const toastStore = useToastStore()

const search = ref(props.filters.search ?? '')
let debounceTimer = null

watch(search, (value) => {
    clearTimeout(debounceTimer)
    debounceTimer = setTimeout(() => {
        router.get(route('patients.index'), { search: value || undefined }, {
            preserveState: true,
            replace: true,
        })
    }, 300)
})

const sexLabel = (sex) => ({ male: 'Male', female: 'Female' })[sex] ?? sex

const fullName = (patient) =>
    [patient.first_name, patient.middle_name, patient.last_name].filter(Boolean).join(' ')

const initials = (name) =>
    String(name)
        .split(' ')
        .map((part) => part[0])
        .slice(0, 2)
        .join('')
        .toUpperCase()

const confirmDelete = (patient) => {
    if (window.confirm(`Delete ${fullName(patient)}? The record can be restored by an administrator.`)) {
        router.delete(route('patients.destroy', patient.id), {
            onSuccess: () => toastStore.show('Patient deleted.'),
        })
    }
}

const goTo = (url) => {
    router.get(url, {}, { preserveState: true })
}
</script>

<template>
    <Head title="Patients" />

    <div class="space-y-6">
        <div class="flex flex-wrap items-center justify-between gap-4">
            <div>
                <h1 class="text-2xl font-semibold text-gray-800">Patients</h1>
                <p class="mt-1 text-sm text-gray-500">Search the registry and manage patient records.</p>
            </div>
            <Link v-if="can.create" :href="route('patients.create')" class="inline-block">
                <Button variant="primary" size="sm">
                    <Plus class="h-4 w-4" />
                    Register patient
                </Button>
            </Link>
        </div>

        <div class="max-w-md">
            <Input
                v-model="search"
                label="Search"
                placeholder="Name, patient number, or contact…"
            />
        </div>

        <div class="overflow-hidden rounded-2xl border border-gray-200 bg-white shadow-sm">
            <div v-if="patients.data.length" class="overflow-x-auto">
                <table class="min-w-full divide-y divide-gray-200">
                    <thead class="bg-gray-50">
                        <tr>
                            <th scope="col" class="px-6 py-3.5 text-left text-xs font-semibold tracking-wide text-gray-500 uppercase">
                                Patient
                            </th>
                            <th scope="col" class="px-6 py-3.5 text-left text-xs font-semibold tracking-wide text-gray-500 uppercase">
                                Age
                            </th>
                            <th scope="col" class="px-6 py-3.5 text-left text-xs font-semibold tracking-wide text-gray-500 uppercase">
                                Sex
                            </th>
                            <th scope="col" class="px-6 py-3.5 text-left text-xs font-semibold tracking-wide text-gray-500 uppercase">
                                Contact
                            </th>
                            <th scope="col" class="px-6 py-3.5 text-right text-xs font-semibold tracking-wide text-gray-500 uppercase">
                                Actions
                            </th>
                        </tr>
                    </thead>
                    <tbody class="divide-y divide-gray-100">
                        <tr v-for="patient in patients.data" :key="patient.id" class="hover:bg-gray-50">
                            <td class="px-6 py-4">
                                <Link :href="route('patients.show', patient.id)" class="flex items-center gap-3">
                                    <span class="flex h-9 w-9 shrink-0 items-center justify-center rounded-full bg-brand-500 text-xs font-semibold text-white">
                                        {{ initials(fullName(patient)) }}
                                    </span>
                                    <span>
                                        <span class="block text-sm font-medium text-gray-800">{{ fullName(patient) }}</span>
                                        <span class="block text-xs text-gray-400">{{ patient.patient_number }}</span>
                                    </span>
                                </Link>
                            </td>
                            <td class="px-6 py-4 text-sm text-gray-500">{{ patient.age }}</td>
                            <td class="px-6 py-4 text-sm text-gray-500">{{ sexLabel(patient.sex) }}</td>
                            <td class="px-6 py-4 text-sm text-gray-500">{{ patient.contact_number }}</td>
                            <td class="px-6 py-4">
                                <div class="flex items-center justify-end gap-1">
                                    <Link
                                        :href="route('patients.show', patient.id)"
                                        class="inline-flex h-9 items-center gap-2 rounded-lg px-3 text-sm font-medium text-gray-600 hover:bg-gray-100 hover:text-gray-800"
                                    >
                                        <Eye class="h-4 w-4" />
                                        View
                                    </Link>
                                    <Link
                                        v-if="can.update"
                                        :href="route('patients.edit', patient.id)"
                                        class="inline-flex h-9 items-center gap-2 rounded-lg px-3 text-sm font-medium text-gray-600 hover:bg-gray-100 hover:text-gray-800"
                                    >
                                        <Pencil class="h-4 w-4" />
                                        Edit
                                    </Link>
                                    <button
                                        v-if="can.delete"
                                        type="button"
                                        class="inline-flex h-9 items-center gap-2 rounded-lg px-3 text-sm font-medium text-status-cancelled hover:bg-status-cancelled/10"
                                        @click="confirmDelete(patient)"
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

            <div v-else class="flex flex-col items-center gap-2 px-6 py-16 text-center">
                <Search class="h-8 w-8 text-gray-300" />
                <p class="text-sm font-medium text-gray-700">No patients found</p>
                <p class="text-sm text-gray-500">Try a different search term or register a new patient.</p>
            </div>

            <div
                v-if="patients.data.length && (patients.prev_page_url || patients.next_page_url)"
                class="flex items-center justify-between border-t border-gray-100 px-6 py-4"
            >
                <Button
                    variant="outline"
                    size="sm"
                    :disabled="!patients.prev_page_url"
                    @click="goTo(patients.prev_page_url)"
                >
                    <ChevronLeft class="h-4 w-4" />
                    Previous
                </Button>
                <span class="text-sm text-gray-500">
                    Page {{ patients.current_page }} of {{ patients.last_page }}
                </span>
                <Button
                    variant="outline"
                    size="sm"
                    :disabled="!patients.next_page_url"
                    @click="goTo(patients.next_page_url)"
                >
                    Next
                    <ChevronRight class="h-4 w-4" />
                </Button>
            </div>
        </div>
    </div>
</template>
