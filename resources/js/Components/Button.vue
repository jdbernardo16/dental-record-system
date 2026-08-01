<script setup>
import { computed } from 'vue'

const props = defineProps({
    variant: { type: String, default: 'primary' },
    size: { type: String, default: 'md' },
    type: { type: String, default: 'button' },
    disabled: { type: Boolean, default: false },
    className: { type: String, default: '' },
})

defineEmits(['click'])

const sizeClasses = {
    sm: 'px-4 py-2.5 text-sm',
    md: 'px-5 py-3 text-sm',
}

const variantClasses = {
    primary: 'bg-brand-500 text-white shadow-sm hover:bg-brand-600 disabled:bg-brand-300',
    outline:
        'bg-white text-gray-700 ring-1 ring-inset ring-gray-300 hover:bg-gray-50',
}

const classes = computed(() => [
    'inline-flex items-center justify-center gap-2 rounded-lg font-medium transition',
    sizeClasses[props.size],
    variantClasses[props.variant],
    { 'cursor-not-allowed opacity-50': props.disabled },
    props.className,
])
</script>

<template>
    <button :type="type" :disabled="disabled" :class="classes" @click="$emit('click', $event)">
        <slot />
    </button>
</template>
