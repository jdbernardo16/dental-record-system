<script setup>
import { storeToRefs } from 'pinia'
import { CheckCircle2, Info, TriangleAlert, XCircle } from 'lucide-vue-next'
import { useToastStore } from '../Stores/toast'

const toastStore = useToastStore()
const { message, type } = storeToRefs(toastStore)

const icons = {
    success: CheckCircle2,
    error: XCircle,
    warning: TriangleAlert,
    info: Info,
}

const iconClasses = {
    success: 'text-status-completed',
    error: 'text-status-cancelled',
    warning: 'text-status-no-show',
    info: 'text-status-confirmed',
}
</script>

<template>
    <Transition
        enter-active-class="transition duration-200 ease-out"
        enter-from-class="translate-y-2 opacity-0"
        enter-to-class="translate-y-0 opacity-100"
        leave-active-class="transition duration-150 ease-in"
        leave-from-class="translate-y-0 opacity-100"
        leave-to-class="translate-y-2 opacity-0"
    >
        <div
            v-if="message"
            role="status"
            class="fixed right-4 bottom-4 z-50 flex items-center gap-3 rounded-xl border border-gray-200 bg-white px-4 py-3 shadow-lg"
        >
            <component :is="icons[type]" class="h-5 w-5 shrink-0" :class="iconClasses[type]" />
            <span class="text-sm font-medium text-gray-700">{{ message }}</span>
            <button
                type="button"
                class="ml-2 text-gray-400 hover:text-gray-600"
                aria-label="Dismiss notification"
                @click="toastStore.hide()"
            >
                &times;
            </button>
        </div>
    </Transition>
</template>
