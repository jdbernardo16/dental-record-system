<script setup>
import { computed, ref } from 'vue'
import { Link, usePage } from '@inertiajs/vue3'
import { route } from '../../../vendor/tightenco/ziggy'
import {
    BarChart3,
    CalendarDays,
    LayoutDashboard,
    Settings,
    ShieldCheck,
    Stethoscope,
    Users,
} from 'lucide-vue-next'
import Badge from '../Components/Badge.vue'

defineProps({
    open: { type: Boolean, default: false },
})

defineEmits(['close'])

const page = usePage()

const hovered = ref(false)

const canManageUsers = computed(() => page.props.auth?.can?.manageUsers ?? false)
const canManagePatients = computed(() => page.props.auth?.can?.managePatients ?? false)
const canManageAppointments = computed(() => page.props.auth?.can?.manageAppointments ?? false)

const navGroups = computed(() => [
    {
        title: 'Menu',
        items: [
            { name: 'Dashboard', icon: LayoutDashboard, href: route('dashboard'), routeName: 'dashboard' },
            ...(canManagePatients.value
                ? [{
                    name: 'Patients',
                    icon: Users,
                    href: route('patients.index'),
                    routes: ['patients.index', 'patients.create', 'patients.show', 'patients.edit'],
                }]
                : [{ name: 'Patients', icon: Users, badge: 'Phase 2' }]),
            ...(canManageAppointments.value
                ? [{
                    name: 'Appointments',
                    icon: CalendarDays,
                    href: route('appointments.index'),
                    routes: ['appointments.index'],
                }]
                : [{ name: 'Appointments', icon: CalendarDays, badge: 'No access' }]),
            ...(canManageUsers.value
                ? [{ name: 'Users', icon: ShieldCheck, href: route('users.index'), routeName: 'users.index' }]
                : [{ name: 'Users', icon: ShieldCheck, badge: 'Admin' }]),
            { name: 'Reports', icon: BarChart3, badge: 'Phase 3' },
            { name: 'Settings', icon: Settings, badge: 'Phase 3' },
        ],
    },
])

const isActive = (item) =>
    (item.routes ?? [item.routeName]).filter(Boolean).some((name) => route().current(name))
</script>

<template>
    <div>
        <div
            v-if="open"
            class="fixed inset-0 z-40 bg-gray-900/50 lg:hidden"
            @click="$emit('close')"
        ></div>

        <aside
            @mouseenter="hovered = true"
            @mouseleave="hovered = false"
            :class="[
                'fixed top-0 left-0 z-50 flex h-full flex-col border-r border-gray-200 bg-white transition-all duration-300 ease-in-out',
                open ? 'w-72 translate-x-0' : 'w-72 -translate-x-full',
                'lg:static lg:translate-x-0',
                open || hovered ? 'lg:w-72' : 'lg:w-24',
            ]"
        >
            <div
                :class="[
                    'flex h-16 shrink-0 items-center gap-3 border-b border-gray-100 px-5',
                    !open && !hovered ? 'lg:justify-center lg:px-0' : '',
                ]"
            >
                <span class="flex h-10 w-10 shrink-0 items-center justify-center rounded-xl bg-brand-500">
                    <Stethoscope class="h-5 w-5 text-white" />
                </span>
                <span
                    v-if="open || hovered"
                    class="whitespace-nowrap text-base font-semibold text-gray-900"
                >
                    Dental Clinic
                </span>
            </div>

            <nav class="no-scrollbar flex-1 overflow-y-auto px-4 py-6">
                <div v-for="group in navGroups" :key="group.title" class="mb-6 last:mb-0">
                    <h2
                        v-if="open || hovered"
                        class="mb-3 text-xs font-medium uppercase leading-5 tracking-wide text-gray-400"
                    >
                        {{ group.title }}
                    </h2>
                    <ul class="flex flex-col gap-1.5">
                        <li v-for="item in group.items" :key="item.name">
                            <Link
                                v-if="item.href"
                                :href="item.href"
                                :class="[
                                    'menu-item group',
                                    isActive(item) ? 'menu-item-active' : 'menu-item-inactive',
                                    !open && !hovered ? 'lg:justify-center' : '',
                                ]"
                            >
                                <span
                                    :class="
                                        isActive(item)
                                            ? 'menu-item-icon-active'
                                            : 'menu-item-icon-inactive'
                                    "
                                >
                                    <component :is="item.icon" class="h-5 w-5" />
                                </span>
                                <span
                                    v-if="open || hovered"
                                    class="flex-1 text-left whitespace-nowrap"
                                >
                                    {{ item.name }}
                                </span>
                            </Link>
                            <button
                                v-else
                                type="button"
                                disabled
                                :title="`${item.name} — coming in ${item.badge}`"
                                class="menu-item menu-item-inactive w-full cursor-not-allowed opacity-50 disabled:hover:bg-transparent"
                                :class="{ 'lg:justify-center': !open && !hovered }"
                            >
                                <span class="menu-item-icon-inactive">
                                    <component :is="item.icon" class="h-5 w-5" />
                                </span>
                                <span
                                    v-if="open || hovered"
                                    class="flex flex-1 items-center justify-between gap-2"
                                >
                                    <span class="whitespace-nowrap">{{ item.name }}</span>
                                    <Badge
                                        :color="item.badge === 'Admin' ? 'info' : 'light'"
                                        size="sm"
                                    >
                                        {{ item.badge }}
                                    </Badge>
                                </span>
                            </button>
                        </li>
                    </ul>
                </div>
            </nav>
        </aside>
    </div>
</template>
