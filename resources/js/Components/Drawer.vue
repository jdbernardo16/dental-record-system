<script setup>
import { computed } from 'vue'
import { DialogContent, DialogOverlay, DialogPortal, DialogRoot, DialogTitle } from 'reka-ui'

const props = defineProps({
    show: {
        type: Boolean,
        default: false,
    },
    closeable: {
        type: Boolean,
        default: true,
    },
})

const emit = defineEmits(['close'])

// Controlled reka-ui dialog sliding in from the right edge. Mirrors Modal.vue
// so the drawer shares the same stacking context as any portaled popovers
// (e.g. the DateField calendar) inside it.
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
                class="data-[state=open]:animate-in data-[state=closed]:animate-out data-[state=closed]:fade-out-0 data-[state=open]:fade-in-0 data-[state=closed]:slide-out-to-right-1/2 data-[state=open]:slide-in-from-right-1/2 fixed inset-y-0 right-0 z-50 flex w-full max-w-md flex-col overflow-y-auto bg-white shadow-xl duration-200"
                @escape-key-down="blockClose"
                @pointer-down-outside="blockClose"
                @interact-outside="blockClose"
            >
                <DialogTitle class="sr-only">
                    <slot name="title" />
                </DialogTitle>
                <slot />
            </DialogContent>
        </DialogPortal>
    </DialogRoot>
</template>
