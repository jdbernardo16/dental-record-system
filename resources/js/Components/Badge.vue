<script setup>
import { computed } from 'vue'

const props = defineProps({
    variant: { type: String, default: 'light' },
    size: { type: String, default: 'md' },
    color: { type: String, default: 'primary' },
})

const baseStyles = 'inline-flex items-center justify-center gap-1 rounded-full font-medium'

const sizeClasses = {
    sm: 'px-2.5 py-0.5 text-xs',
    md: 'px-2.5 py-0.5 text-sm',
}

const variants = {
    light: {
        primary: 'bg-brand-50 text-brand-600',
        success: 'bg-status-success-light text-status-success',
        warning: 'bg-status-warning-light text-status-warning',
        error: 'bg-status-error-light text-status-error',
        info: 'bg-status-info-light text-status-info',
        light: 'bg-gray-100 text-gray-600',
        dark: 'bg-gray-500 text-white',
    },
    solid: {
        primary: 'bg-brand-500 text-white',
        success: 'bg-status-success text-white',
        warning: 'bg-status-warning text-white',
        error: 'bg-status-error text-white',
        info: 'bg-status-info text-white',
        light: 'bg-gray-400 text-white',
        dark: 'bg-gray-700 text-white',
    },
}

const classes = computed(() => [
    baseStyles,
    sizeClasses[props.size],
    variants[props.variant][props.color],
])
</script>

<template>
    <span :class="classes">
        <slot />
    </span>
</template>
