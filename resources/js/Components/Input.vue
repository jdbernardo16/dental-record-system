<script setup>
defineProps({
    modelValue: { type: [String, Number], default: '' },
    label: { type: String, default: null },
    type: { type: String, default: 'text' },
    placeholder: { type: String, default: null },
    error: { type: String, default: null },
    required: { type: Boolean, default: false },
})

defineEmits(['update:modelValue'])
</script>

<template>
    <div>
        <label
            v-if="label"
            class="mb-1.5 block text-sm font-medium text-gray-700"
        >
            {{ label }}
            <span v-if="required" class="text-status-cancelled">*</span>
        </label>
        <input
            :value="modelValue"
            :type="type"
            :placeholder="placeholder"
            :required="required"
            class="h-11 w-full rounded-lg border bg-transparent px-4 py-2.5 text-sm text-gray-800 shadow-sm placeholder:text-gray-400 focus:border-brand-300 focus:outline-hidden focus:ring-2 focus:ring-brand-500/10"
            :class="error ? 'border-status-cancelled' : 'border-gray-300'"
            @input="$emit('update:modelValue', $event.target.value)"
        />
        <p v-if="error" class="mt-1.5 text-xs text-status-cancelled">{{ error }}</p>
    </div>
</template>
