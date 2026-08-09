<script setup>
import { computed } from 'vue'
import { DialogContent, DialogOverlay, DialogPortal, DialogRoot } from 'reka-ui'
import { cn } from '@/lib/utils'

const props = defineProps({
    show: {
        type: Boolean,
        default: false,
    },
    maxWidth: {
        type: String,
        default: '2xl',
    },
    closeable: {
        type: Boolean,
        default: true,
    },
})

const emit = defineEmits(['close'])

// Controlled reka-ui dialog. Both the dialog content and any popover inside it
// (e.g. the DateField calendar) portal to <body> and stack by z-index + DOM
// order, so a popover opened after the dialog renders above it. This replaces
// the old native <dialog>/showModal() which sat in the browser TOP LAYER and
// could never be covered by a portaled popover.
const open = computed({
    get: () => props.show,
    set: (value) => {
        if (!value && props.closeable) emit('close')
    },
})

// When not closeable, block escape / outside-pointer close at the reka-ui level.
const blockClose = (event) => {
    if (!props.closeable) event.preventDefault()
}

const maxWidthClass = computed(() => {
    return {
        sm: 'sm:max-w-sm',
        md: 'sm:max-w-md',
        lg: 'sm:max-w-lg',
        xl: 'sm:max-w-xl',
        '2xl': 'sm:max-w-2xl',
    }[props.maxWidth]
})
</script>

<template>
    <DialogRoot v-model:open="open">
        <DialogPortal>
            <DialogOverlay
                class="data-[state=open]:animate-in data-[state=closed]:animate-out data-[state=closed]:fade-out-0 data-[state=open]:fade-in-0 fixed inset-0 z-50 bg-gray-500/75"
            />
            <DialogContent
                v-bind="{
                    ...$attrs,
                }"
                :class="
                    cn(
                        'data-[state=open]:animate-in data-[state=closed]:animate-out data-[state=closed]:fade-out-0 data-[state=open]:fade-in-0 data-[state=closed]:zoom-out-95 data-[state=open]:zoom-in-95 data-[state=closed]:slide-out-to-left-1/2 data-[state=closed]:slide-out-to-top-[48%] data-[state=open]:slide-in-from-left-1/2 data-[state=open]:slide-in-from-top-[48%] fixed top-[50%] left-[50%] z-50 grid max-h-[90vh] w-full max-w-lg -translate-x-1/2 -translate-y-1/2 gap-4 overflow-y-auto rounded-lg bg-white p-0 shadow-xl duration-200 sm:w-full',
                        maxWidthClass,
                    )
                "
                @escape-key-down="blockClose"
                @pointer-down-outside="blockClose"
                @interact-outside="blockClose"
            >
                <slot />
            </DialogContent>
        </DialogPortal>
    </DialogRoot>
</template>
