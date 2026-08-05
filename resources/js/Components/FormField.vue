<script setup>
import { computed, useId } from 'vue'
import { Label } from '@/Components/ui/label'

defineOptions({ inheritAttrs: false })

const props = defineProps({
    label: { type: String, default: null },
    error: { type: String, default: null },
    required: { type: Boolean, default: false },
    hint: { type: String, default: null },
    id: { type: String, default: null },
})

const generatedId = useId()
const controlId = computed(() => props.id || generatedId)
</script>

<template>
    <div>
        <Label v-if="label" :for="controlId" class="mb-1.5 block text-sm font-medium text-gray-700">
            {{ label }}
            <span v-if="required" class="text-status-cancelled">*</span>
        </Label>
        <slot :id="controlId" />
        <p v-if="hint" class="mt-1.5 text-xs text-gray-500">{{ hint }}</p>
        <p v-if="error" class="mt-1.5 text-xs font-medium text-status-cancelled">{{ error }}</p>
    </div>
</template>
