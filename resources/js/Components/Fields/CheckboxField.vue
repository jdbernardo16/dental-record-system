<script setup>
import { computed, useId } from 'vue'
import { Checkbox } from '@/Components/ui/checkbox'

const props = defineProps({
    modelValue: { type: Boolean, default: false },
    label: { type: String, default: null },
    error: { type: String, default: null },
    hint: { type: String, default: null },
    required: { type: Boolean, default: false },
    id: { type: String, default: null },
    disabled: { type: Boolean, default: false },
})

const emits = defineEmits(['update:modelValue'])

const generatedId = useId()
const checkboxId = computed(() => props.id || generatedId)
</script>

<template>
    <div>
        <label class="flex items-center gap-2">
            <Checkbox
                :id="checkboxId"
                :model-value="modelValue"
                :disabled="disabled"
                :required="required"
                :aria-invalid="error ? 'true' : 'false'"
                :aria-describedby="error ? `${checkboxId}-error` : undefined"
                @update:model-value="(value) => emits('update:modelValue', value)"
            />
            <span
                v-if="label"
                class="text-sm font-medium text-gray-700"
                :class="disabled && 'cursor-not-allowed opacity-50'"
            >
                {{ label }}
                <span v-if="required" class="text-status-cancelled">*</span>
            </span>
        </label>
        <p v-if="hint" class="mt-1.5 text-xs text-gray-500">{{ hint }}</p>
        <p
            v-if="error"
            :id="`${checkboxId}-error`"
            class="mt-1.5 text-xs font-medium text-status-cancelled"
        >
            {{ error }}
        </p>
    </div>
</template>
