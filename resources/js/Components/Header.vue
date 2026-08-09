<script setup>
import { computed, onMounted, onUnmounted, ref } from 'vue'
import { Link, usePage } from '@inertiajs/vue3'
import { route } from '../../../vendor/tightenco/ziggy'
import { ChevronDown, CircleUserRound, LogOut, Menu } from 'lucide-vue-next'

defineEmits(['toggle'])

const page = usePage()
const user = computed(() => page.props.auth?.user)

const initials = computed(() =>
    String(user.value?.name || 'U')
        .split(' ')
        .map((part) => part[0])
        .slice(0, 2)
        .join('')
        .toUpperCase(),
)

const dropdownOpen = ref(false)
const dropdownRef = ref(null)

const toggleDropdown = () => {
    dropdownOpen.value = !dropdownOpen.value
}

const closeDropdown = () => {
    dropdownOpen.value = false
}

const handleClickOutside = (event) => {
    if (dropdownRef.value && !dropdownRef.value.contains(event.target)) {
        closeDropdown()
    }
}

onMounted(() => document.addEventListener('click', handleClickOutside))
onUnmounted(() => document.removeEventListener('click', handleClickOutside))
</script>

<template>
    <header
        class="sticky top-0 z-30 flex h-16 w-full shrink-0 items-center justify-between border-b border-gray-200 bg-white px-4 sm:px-6"
    >
        <button
            type="button"
            class="flex h-11 w-11 items-center justify-center rounded-lg text-gray-500 hover:bg-gray-100 lg:hidden"
            aria-label="Toggle sidebar"
            @click="$emit('toggle')"
        >
            <Menu class="h-6 w-6" />
        </button>

        <div ref="dropdownRef" class="relative ml-auto">
            <button
                type="button"
                class="flex h-11 items-center gap-2.5 rounded-lg px-2 hover:bg-gray-100"
                @click="toggleDropdown"
            >
                <span
                    class="flex h-9 w-9 shrink-0 items-center justify-center rounded-full bg-brand-500 text-sm font-semibold text-white"
                >
                    {{ initials }}
                </span>
                <span class="hidden text-sm font-medium text-gray-700 sm:block">
                    {{ user?.name }}
                </span>
                <ChevronDown
                    class="h-4 w-4 text-gray-500 transition-transform duration-200"
                    :class="{ 'rotate-180': dropdownOpen }"
                />
            </button>

            <div
                v-if="dropdownOpen"
                class="absolute right-0 mt-2 flex w-64 flex-col rounded-2xl border border-gray-200 bg-white p-3 shadow-lg"
            >
                <div class="border-b border-gray-100 px-3 pb-3">
                    <span class="block text-sm font-medium text-gray-700">{{ user?.name }}</span>
                    <span class="mt-0.5 block text-xs text-gray-500">{{ user?.email }}</span>
                </div>
                <div class="flex flex-col gap-1 pt-3">
                    <Link
                        :href="route('profile.edit')"
                        class="flex items-center gap-3 rounded-lg px-3 py-2 text-sm font-medium text-gray-700 hover:bg-gray-100"
                        @click="closeDropdown"
                    >
                        <CircleUserRound class="h-5 w-5 text-gray-500" />
                        Edit profile
                    </Link>
                    <Link
                        :href="route('logout')"
                        method="post"
                        as="button"
                        class="flex w-full items-center gap-3 rounded-lg px-3 py-2 text-sm font-medium text-gray-700 hover:bg-gray-100"
                        @click="closeDropdown"
                    >
                        <LogOut class="h-5 w-5 text-gray-500" />
                        Sign out
                    </Link>
                </div>
            </div>
        </div>
    </header>
</template>
