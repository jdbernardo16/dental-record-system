<script setup>
import { computed, useId } from 'vue'
import { Label } from '@/Components/ui/label'
import {
    Select,
    SelectContent,
    SelectGroup,
    SelectItem,
    SelectLabel,
    SelectTrigger,
    SelectValue,
} from '@/Components/ui/select'

defineOptions({ inheritAttrs: false })

const props = defineProps({
    modelValue: { type: [String, Number], default: '' },
    label: { type: String, default: null },
    error: { type: String, default: null },
    hint: { type: String, default: null },
    required: { type: Boolean, default: false },
    placeholder: { type: String, default: 'Select…' },
    options: { type: Array, default: () => [] },
    id: { type: String, default: null },
    disabled: { type: Boolean, default: false },
    // Label for a special first item representing the empty value. reka-ui
    // Select cannot deselect and rejects empty-string item values, so fields
    // with a meaningful "none" state render a sentinel item whose value is
    // normalized back to '' on emit — restoring the old native
    // <option value=""> reset-to-empty behavior.
    noneLabel: { type: String, default: null },
})

const emits = defineEmits(['update:modelValue'])

const generatedId = useId()
const selectId = computed(() => props.id || generatedId)

// Sentinel value backing the noneLabel item — must be a non-empty string.
const NONE_SENTINEL = '__none__'

const isEmpty = (value) => value === '' || value === null || value === undefined

// reka-ui Select emits null when the current item is deselected; the app's
// Inertia forms expect plain strings, so normalize back to ''. When
// noneLabel is set, an empty modelValue is presented as the sentinel item so
// the trigger shows noneLabel (instead of the placeholder) and the sentinel
// item renders selected; picking the sentinel emits '' again.
const selectedValue = computed({
    get: () => (props.noneLabel && isEmpty(props.modelValue) ? NONE_SENTINEL : props.modelValue ?? ''),
    set: (value) => emits('update:modelValue', value === NONE_SENTINEL ? '' : value ?? ''),
})

// options: [{ value, label }] or [{ value, label, group }] — group by
// consecutive options that share the same group label (optgroups).
const groupedOptions = computed(() => {
    const groups = []
    let current = null

    for (const option of props.options) {
        if (option.group) {
            if (!current || current.label !== option.group) {
                current = { label: option.group, items: [] }
                groups.push(current)
            }
            current.items.push(option)
        } else {
            current = null
            groups.push({ label: null, items: [option] })
        }
    }

    return groups
})
</script>

<template>
    <div>
        <Label v-if="label" :for="selectId" class="mb-1.5 block text-sm font-medium text-gray-700">
            {{ label }}
            <span v-if="required" class="text-status-cancelled">*</span>
        </Label>
        <Select v-model="selectedValue" :disabled="disabled">
            <SelectTrigger
                :id="selectId"
                class="w-full"
                :class="error && 'border-destructive'"
                :aria-invalid="error ? 'true' : 'false'"
                :aria-describedby="error ? `${selectId}-error` : undefined"
            >
                <SelectValue :placeholder="placeholder" />
            </SelectTrigger>
            <SelectContent>
                <SelectItem v-if="noneLabel" :value="NONE_SENTINEL">{{ noneLabel }}</SelectItem>
                <template v-for="group in groupedOptions" :key="group.label ?? group.items[0].value">
                    <SelectGroup v-if="group.label">
                        <SelectLabel>{{ group.label }}</SelectLabel>
                        <SelectItem
                            v-for="option in group.items"
                            :key="option.value"
                            :value="option.value"
                            :disabled="option.disabled"
                        >
                            {{ option.label }}
                        </SelectItem>
                    </SelectGroup>
                    <template v-else>
                        <SelectItem
                            v-for="option in group.items"
                            :key="option.value"
                            :value="option.value"
                            :disabled="option.disabled"
                        >
                            {{ option.label }}
                        </SelectItem>
                    </template>
                </template>
            </SelectContent>
        </Select>
        <p v-if="hint" class="mt-1.5 text-xs text-gray-500">{{ hint }}</p>
        <p
            v-if="error"
            :id="`${selectId}-error`"
            class="mt-1.5 text-xs font-medium text-status-cancelled"
        >
            {{ error }}
        </p>
    </div>
</template>
