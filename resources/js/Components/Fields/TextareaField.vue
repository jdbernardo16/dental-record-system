<script setup>
import { computed, useId } from 'vue'
import { cn } from '@/lib/utils'
import { Label } from '@/Components/ui/label'

defineOptions({ inheritAttrs: false })

const props = defineProps({
    modelValue: { type: [String, Number], default: '' },
    label: { type: String, default: null },
    error: { type: String, default: null },
    hint: { type: String, default: null },
    required: { type: Boolean, default: false },
    placeholder: { type: String, default: null },
    rows: { type: Number, default: 4 },
    id: { type: String, default: null },
    disabled: { type: Boolean, default: false },
})

const emits = defineEmits(['update:modelValue'])

const generatedId = useId()
const inputId = computed(() => props.id || generatedId)
</script>

<template>
    <div>
        <Label v-if="label" :for="inputId" class="mb-1.5 block text-sm font-medium text-gray-700">
            {{ label }}
            <span v-if="required" class="text-status-cancelled">*</span>
        </Label>
        <textarea
            :id="inputId"
            v-bind="$attrs"
            :value="modelValue"
            :placeholder="placeholder"
            :rows="rows"
            :disabled="disabled"
            :required="required"
            :aria-invalid="error ? 'true' : 'false'"
            :aria-describedby="error ? `${inputId}-error` : undefined"
            data-slot="textarea-field"
            :class="
                cn(
                    'border-input placeholder:text-muted-foreground focus-visible:border-ring focus-visible:ring-ring/50 focus-visible:ring-3 aria-invalid:ring-destructive/20 dark:aria-invalid:ring-destructive/40 aria-invalid:border-destructive min-h-16 w-full rounded-md border bg-transparent px-3 py-2 text-base shadow-xs transition-[color,box-shadow] outline-none disabled:pointer-events-none disabled:cursor-not-allowed disabled:opacity-50 md:text-sm',
                    error && 'border-destructive',
                )
            "
            @input="emits('update:modelValue', $event.target.value)"
        />
        <p v-if="hint" class="mt-1.5 text-xs text-gray-500">{{ hint }}</p>
        <p
            v-if="error"
            :id="`${inputId}-error`"
            class="mt-1.5 text-xs font-medium text-status-cancelled"
        >
            {{ error }}
        </p>
    </div>
</template>
