<script setup>
import { CalendarDate } from '@internationalized/date'
import { CalendarDays, X } from '@lucide/vue'
import { computed, ref, useId } from 'vue'
import { PopoverContent, PopoverPortal, PopoverRoot, PopoverTrigger } from 'reka-ui'
import { cn } from '@/lib/utils'
import { Label } from '@/Components/ui/label'
import {
    Calendar,
    CalendarCell,
    CalendarCellTrigger,
    CalendarGrid,
    CalendarGridBody,
    CalendarGridHead,
    CalendarGridRow,
    CalendarHeadCell,
    CalendarHeader,
    CalendarHeading,
    CalendarNextButton,
    CalendarPrevButton,
} from '@/Components/ui/calendar'

defineOptions({ inheritAttrs: false })

const props = defineProps({
    modelValue: { type: String, default: null }, // 'YYYY-MM-DD' or null
    label: { type: String, default: null },
    error: { type: String, default: null },
    hint: { type: String, default: null },
    required: { type: Boolean, default: false },
    placeholder: { type: String, default: 'Select date…' },
    min: { type: String, default: null }, // ISO 'YYYY-MM-DD'
    max: { type: String, default: null }, // ISO 'YYYY-MM-DD'
    id: { type: String, default: null },
    disabled: { type: Boolean, default: false },
})

const emits = defineEmits(['update:modelValue'])

const generatedId = useId()
const fieldId = computed(() => props.id || generatedId)

const open = ref(false)

// reka-ui Calendar works with DateValue objects from @internationalized/date
// (CalendarDate), NOT plain JS Dates — they need .copy()/.toString().
const toCalendarDate = (iso) => {
    if (!iso) return undefined
    const [year, month, day] = iso.split('-').map(Number)
    if (!year || !month || !day) return undefined
    return new CalendarDate(year, month, day)
}

// Timezone-safe local parse (no toISOString() — that shifts to UTC).
const toLocalDate = (iso) => {
    if (!iso) return null
    const [year, month, day] = iso.split('-').map(Number)
    if (!year || !month || !day) return null
    return new Date(year, month - 1, day)
}

const calendarValue = computed({
    get: () => toCalendarDate(props.modelValue),
    set: (date) => {
        emits('update:modelValue', date ? date.toString() : null)
        open.value = false
    },
})

const minDate = computed(() => toCalendarDate(props.min))
const maxDate = computed(() => toCalendarDate(props.max))

const displayValue = computed(() => {
    if (!props.modelValue) return ''
    const date = toLocalDate(props.modelValue)
    if (!date) return props.modelValue
    return new Intl.DateTimeFormat('en-PH', { month: 'short', day: '2-digit', year: 'numeric' }).format(date)
})

const clearValue = () => {
    emits('update:modelValue', null)
    open.value = false
}
</script>

<template>
    <div>
        <Label v-if="label" :for="fieldId" class="mb-1.5 block text-sm font-medium text-gray-700">
            {{ label }}
            <span v-if="required" class="text-status-cancelled">*</span>
        </Label>
        <PopoverRoot v-model:open="open">
            <PopoverTrigger as-child :disabled="disabled">
                <button
                    :id="fieldId"
                    v-bind="$attrs"
                    type="button"
                    :disabled="disabled"
                    :aria-invalid="error ? 'true' : 'false'"
                    :aria-describedby="error ? `${fieldId}-error` : undefined"
                    data-slot="date-field-trigger"
                    :class="
                        cn(
                            'border-input placeholder:text-muted-foreground focus-visible:border-ring focus-visible:ring-ring/50 focus-visible:ring-3 aria-invalid:ring-destructive/20 dark:aria-invalid:ring-destructive/40 aria-invalid:border-destructive flex h-11 w-full items-center justify-between gap-2 rounded-md border bg-transparent px-3 text-left text-base shadow-xs transition-[color,box-shadow] outline-none disabled:pointer-events-none disabled:cursor-not-allowed disabled:opacity-50 md:text-sm',
                            error && 'border-destructive',
                            displayValue ? 'text-gray-800' : 'text-muted-foreground',
                        )
                    "
                >
                    <span>{{ displayValue || placeholder }}</span>
                    <CalendarDays class="size-4 shrink-0 opacity-50" />
                </button>
            </PopoverTrigger>
            <PopoverPortal>
                <PopoverContent
                    align="start"
                    :side-offset="6"
                    class="bg-popover text-popover-foreground data-[state=open]:animate-in data-[state=closed]:animate-out data-[state=closed]:fade-out-0 data-[state=open]:fade-in-0 data-[state=closed]:zoom-out-95 data-[state=open]:zoom-in-95 data-[side=bottom]:slide-in-from-top-2 data-[side=left]:slide-in-from-right-2 data-[side=right]:slide-in-from-left-2 data-[side=top]:slide-in-from-bottom-2 z-50 w-auto rounded-md border shadow-md"
                >
                    <Calendar v-model="calendarValue" :min-value="minDate" :max-value="maxDate">
                        <template #default="{ grid }">
                            <CalendarHeader>
                                <CalendarPrevButton />
                                <CalendarHeading />
                                <CalendarNextButton />
                            </CalendarHeader>
                            <div class="mt-3 flex flex-col gap-3">
                                <CalendarGrid>
                                    <CalendarGridHead>
                                        <CalendarHeadCell
                                            v-for="day in ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat']"
                                            :key="day"
                                        >
                                            {{ day }}
                                        </CalendarHeadCell>
                                    </CalendarGridHead>
                                    <CalendarGridBody>
                                        <!-- reka-ui exposes grid as an array of month
                                             grids; DateField renders a single month -->
                                        <CalendarGridRow
                                            v-for="(week, index) in grid[0].rows"
                                            :key="index"
                                        >
                                            <CalendarCell
                                                v-for="cell in week"
                                                :key="cell.toString()"
                                                :date="cell"
                                            >
                                                <CalendarCellTrigger :day="cell" :month="grid[0].value" />
                                            </CalendarCell>
                                        </CalendarGridRow>
                                    </CalendarGridBody>
                                </CalendarGrid>
                            </div>
                        </template>
                    </Calendar>
                    <div v-if="modelValue" class="border-t px-3 py-2">
                        <button
                            type="button"
                            class="flex items-center gap-1.5 text-xs font-medium text-gray-500 transition hover:text-status-cancelled"
                            @click="clearValue"
                        >
                            <X class="size-3.5" />
                            Clear
                        </button>
                    </div>
                </PopoverContent>
            </PopoverPortal>
        </PopoverRoot>
        <p v-if="hint" class="mt-1.5 text-xs text-gray-500">{{ hint }}</p>
        <p
            v-if="error"
            :id="`${fieldId}-error`"
            class="mt-1.5 text-xs font-medium text-status-cancelled"
        >
            {{ error }}
        </p>
    </div>
</template>
