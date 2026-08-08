<script setup>
import { computed, useId } from 'vue'
import { Checkbox } from '@/Components/ui/checkbox'

const props = defineProps({
    modelValue: { type: Array, default: () => [] },
    label: { type: String, default: null },
    error: { type: String, default: null },
    hint: { type: String, default: null },
    required: { type: Boolean, default: false },
    options: { type: Array, default: () => [] },
    columns: { type: Number, default: 1 },
    name: { type: String, default: null },
})

const emits = defineEmits(['update:modelValue'])

const generatedId = useId()
const groupId = computed(() => props.name || `checkbox-group-${generatedId}`)

const isChecked = (value) => props.modelValue.includes(value)

const toggle = (value) => {
    if (isChecked(value)) {
        emits('update:modelValue', props.modelValue.filter((item) => item !== value))
    } else {
        emits('update:modelValue', [...props.modelValue, value])
    }
}
</script>

<template>
    <div>
        <p
            v-if="label"
            :id="`${groupId}-label`"
            class="mb-1.5 text-sm font-medium text-gray-700"
        >
            {{ label }}
            <span v-if="required" class="text-status-cancelled">*</span>
        </p>
        <div
            role="group"
            :aria-labelledby="label ? `${groupId}-label` : undefined"
            :aria-invalid="error ? 'true' : 'false'"
            :aria-describedby="error ? `${groupId}-error` : undefined"
            class="grid gap-2"
            :style="{ gridTemplateColumns: 'repeat(' + columns + ', minmax(0, 1fr))' }"
        >
            <label
                v-for="option in options"
                :key="option.value"
                class="flex cursor-pointer items-center gap-2"
            >
                <Checkbox
                    :id="`${groupId}-${option.value}`"
                    :name="name"
                    :model-value="isChecked(option.value)"
                    :aria-invalid="error ? 'true' : 'false'"
                    :aria-describedby="error ? `${groupId}-error` : undefined"
                    @update:model-value="() => toggle(option.value)"
                />
                <span class="text-sm font-medium text-gray-700">{{ option.label }}</span>
            </label>
        </div>
        <p v-if="hint" class="mt-1.5 text-xs text-gray-500">{{ hint }}</p>
        <p
            v-if="error"
            :id="`${groupId}-error`"
            class="mt-1.5 text-xs font-medium text-status-cancelled"
        >
            {{ error }}
        </p>
    </div>
</template>
