<script setup>
import { computed, useId } from 'vue'

const props = defineProps({
    modelValue: { type: [String, Number], default: null },
    label: { type: String, default: null },
    error: { type: String, default: null },
    hint: { type: String, default: null },
    required: { type: Boolean, default: false },
    options: { type: Array, default: () => [] },
    name: { type: String, default: null },
    disabled: { type: Boolean, default: false },
})

const emits = defineEmits(['update:modelValue'])

const generatedId = useId()
const groupName = computed(() => props.name || `radio-${generatedId}`)

const isSelected = (value) => String(props.modelValue) === String(value)
</script>

<template>
    <div>
        <p
            v-if="label"
            :id="`${groupName}-label`"
            class="mb-1.5 text-sm font-medium text-gray-700"
        >
            {{ label }}
            <span v-if="required" class="text-status-cancelled">*</span>
        </p>
        <div
            role="radiogroup"
            :aria-labelledby="label ? `${groupName}-label` : undefined"
            :aria-invalid="error ? 'true' : 'false'"
            :aria-describedby="error ? `${groupName}-error` : undefined"
            class="inline-flex flex-wrap gap-1 rounded-full bg-gray-100 p-1"
        >
            <button
                v-for="option in options"
                :key="option.value"
                type="button"
                role="radio"
                :disabled="disabled"
                :aria-checked="isSelected(option.value) ? 'true' : 'false'"
                :class="[
                    'min-h-11 rounded-full px-4 text-sm font-medium transition',
                    isSelected(option.value) ? 'bg-white text-gray-900 shadow-sm' : 'text-gray-500',
                    'disabled:cursor-not-allowed disabled:opacity-50',
                ]"
                @click="emits('update:modelValue', option.value)"
            >
                {{ option.label }}
            </button>
        </div>
        <p v-if="hint" class="mt-1.5 text-xs text-gray-500">{{ hint }}</p>
        <p
            v-if="error"
            :id="`${groupName}-error`"
            class="mt-1.5 text-xs font-medium text-status-cancelled"
        >
            {{ error }}
        </p>
    </div>
</template>
