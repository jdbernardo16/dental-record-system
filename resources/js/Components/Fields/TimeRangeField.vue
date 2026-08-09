<script setup>
import { Clock, X } from "lucide-vue-next";
import { computed, nextTick, ref, useId, watch } from "vue";
import { Time } from "@internationalized/date";
import {
    PopoverContent,
    PopoverPortal,
    PopoverRoot,
    PopoverTrigger,
    TimeRangeFieldInput,
    TimeRangeFieldRoot,
} from "reka-ui";
import { cn } from "@/lib/utils";
import { Label } from "@/Components/ui/label";
import { Button } from "@/Components/ui/button";

defineOptions({ inheritAttrs: false });

const props = defineProps({
    start: { type: String, default: null }, // 'HH:mm' or null
    end: { type: String, default: null }, // 'HH:mm' or null
    label: { type: String, default: null },
    error: { type: String, default: null },
    hint: { type: String, default: null },
    required: { type: Boolean, default: false },
    id: { type: String, default: null },
    disabled: { type: Boolean, default: false },
});

const emits = defineEmits(["update:start", "update:end"]);

const generatedId = useId();
const fieldId = computed(() => props.id || generatedId);

// 'HH:mm' → reka-ui Time (reka-ui's range model is
// { start: Time | undefined, end: Time | undefined }); empty/invalid → null.
// Anything other than exactly two parts (e.g. 'HH:mm:ss') is rejected — the
// wire format is date_format:H:i, so seconds must never be silently dropped.
const toTime = (value) => {
    if (!value) return null;
    const parts = value.split(":");
    if (parts.length !== 2) return null;
    const [hour, minute] = parts.map(Number);
    if (
        !Number.isInteger(hour) ||
        !Number.isInteger(minute) ||
        hour < 0 ||
        hour > 23 ||
        minute < 0 ||
        minute > 59
    ) {
        return null;
    }
    return new Time(hour, minute);
};

// reka-ui Time.toString() yields 'HH:mm:ss', but the wire format is
// 'HH:mm' (date_format:H:i) — format manually, zero-padded.
const toHm = (time) =>
    time
        ? `${String(time.hour).padStart(2, "0")}:${String(time.minute).padStart(2, "0")}`
        : null;

const rangeValue = computed({
    get: () => ({
        start: toTime(props.start) ?? undefined,
        end: toTime(props.end) ?? undefined,
    }),
    set: ({ start, end }) => {
        emits("update:start", toHm(start));
        emits("update:end", toHm(end));
    },
});

// Mirror of the latest range, updated immediately on every change — the
// picker stays correct even before the parent re-applies the emitted values
// as props (e.g. two quick picks in a row).
const mirror = ref({ start: undefined, end: undefined });

watch(
    () => [props.start, props.end],
    ([start, end]) => {
        mirror.value = {
            start: toTime(start) ?? undefined,
            end: toTime(end) ?? undefined,
        };
    },
    { immediate: true },
);

const hasValue = computed(() => Boolean(props.start || props.end));

// reka-ui's TimeRangeFieldRoot captures modelValue once at mount and never
// re-syncs when the prop changes externally afterwards — so picker/clear
// driven changes would leave the segments visually stale. Bumping this key
// remounts the root (after the parent prop round-trip has flushed) so it
// re-initializes its segments from the fresh modelValue. Typing must NOT
// remount — segment edits already update reka-ui's internal state and a
// remount would steal focus mid-typing.
const remountKey = ref(0);

const remountAfterChange = () => {
    nextTick(() => {
        remountKey.value++;
    });
};

const clearValue = () => {
    mirror.value = { start: undefined, end: undefined };
    emits("update:start", null);
    emits("update:end", null);
    remountAfterChange();
};

const open = ref(false);

// Picker lists (12-hour with AM/PM, 5-minute steps — the wire format stays
// 'HH:mm' 24-hour via toHm, so date_format:H:i is unaffected).
const hours = ["12", "01", "02", "03", "04", "05", "06", "07", "08", "09", "10", "11"];
const minutes = Array.from({ length: 12 }, (_, i) =>
    String(i * 5).padStart(2, "0"),
);
const periods = ["AM", "PM"];

const timeOf = (side) => mirror.value[side];

// 12-hour clock display helpers (reka-ui's internal Time stays 0–23).
const toHour12 = (hour24) => (hour24 % 12 === 0 ? 12 : hour24 % 12);

const periodOf = (side) => {
    const t = mirror.value[side];
    return t ? (t.hour < 12 ? "AM" : "PM") : "AM";
};

// Rebuild one side of the range from the current values and push it back
// through the same rangeValue model so the segments stay in sync.
const pick = (side, part, value) => {
    const current = mirror.value;
    const existing = current[side];
    let next;

    if (part === "hour") {
        // 12-hour pick → 24-hour: 12 AM → 0, 12 PM → 12.
        const hour12 = Number(value);
        const hour24 = (hour12 % 12) + (periodOf(side) === "PM" ? 12 : 0);
        next = new Time(hour24, existing?.minute ?? 0);
    } else if (part === "minute") {
        next = new Time(existing?.hour ?? 0, Number(value));
    } else {
        // part === 'period' (AM/PM toggle)
        const hour24 = existing?.hour ?? 0;
        const base = hour24 % 12; // 0–11
        next = new Time(base + (value === "PM" ? 12 : 0), existing?.minute ?? 0);
    }

    mirror.value = { ...current, [side]: next };
    rangeValue.value = { ...current, [side]: next };
    remountAfterChange();
};

const isSelected = (side, part, value) => {
    const t = timeOf(side);
    if (!t) return false;
    if (part === "hour") return toHour12(t.hour) === Number(value);
    if (part === "minute") return t.minute === Number(value);
    return (t.hour < 12 ? "AM" : "PM") === value;
};

// attrs fall through to the reka-ui root (role="group") via $attrs merge.
</script>

<template>
    <div>
        <Label
            v-if="label"
            :for="fieldId"
            class="mb-1.5 block text-sm font-medium text-gray-700"
        >
            {{ label }}
            <span v-if="required" class="text-status-cancelled">*</span>
        </Label>
        <PopoverRoot v-model:open="open">
            <!-- Bordered control wrapper — deliberately OUTSIDE the keyed
                 root so the Clear/Pick buttons (and the PopoverTrigger anchor)
                 survive the segment remount after picker/clear changes. -->
            <div
                data-slot="time-range-control"
                :data-disabled="disabled ? '' : undefined"
                :class="
                    cn(
                        'border-input focus-visible:border-ring focus-visible:ring-ring/50 focus-visible:ring-3 aria-invalid:ring-destructive/20 dark:aria-invalid:ring-destructive/40 aria-invalid:border-destructive data-[invalid]:border-destructive data-disabled:cursor-not-allowed data-disabled:opacity-50 flex h-11 w-full items-center gap-1.5 rounded-md border bg-transparent px-0 text-base shadow-xs transition-[color,box-shadow] outline-none md:text-sm',
                        error && 'border-destructive',
                    )
                "
            >
                <TimeRangeFieldRoot
                    :key="remountKey"
                    v-model="rangeValue"
                    :granularity="'minute'"
                    :hour-cycle="12"
                    :disabled="disabled"
                    :id="fieldId"
                    :required="required"
                    :aria-invalid="error ? 'true' : 'false'"
                    :aria-describedby="error ? `${fieldId}-error` : undefined"
                    data-slot="time-range-field"
                    class="flex flex-1 items-center gap-1.5 pl-3 outline-none"
                >
                    <template #default="{ segments }">
                        <div
                            v-for="item in segments.start"
                            :key="`start-${item.part}`"
                            class="flex items-center"
                            :class="
                                start ? 'text-gray-800' : 'text-muted-foreground'
                            "
                        >
                            <TimeRangeFieldInput
                                :part="item.part"
                                type="start"
                                class="rounded-sm caret-transparent outline-none transition-[color,box-shadow] focus-visible:bg-accent focus-visible:text-accent-foreground focus-visible:ring-3 focus-visible:ring-ring/50"
                            >
                                {{ item.value }}
                            </TimeRangeFieldInput>
                        </div>
                        <span
                            aria-hidden="true"
                            class="pointer-events-none select-none text-muted-foreground"
                            >–</span
                        >
                        <div
                            v-for="item in segments.end"
                            :key="`end-${item.part}`"
                            class="flex items-center"
                            :class="
                                end ? 'text-gray-800' : 'text-muted-foreground'
                            "
                        >
                            <TimeRangeFieldInput
                                :part="item.part"
                                type="end"
                                class="rounded-sm caret-transparent outline-none transition-[color,box-shadow] focus-visible:bg-accent focus-visible:text-accent-foreground focus-visible:ring-3 focus-visible:ring-ring/50"
                            >
                                {{ item.value }}
                            </TimeRangeFieldInput>
                        </div>
                    </template>
                </TimeRangeFieldRoot>
                <div class="flex shrink-0 items-center gap-1.5 pr-2">
                    <button
                        v-if="hasValue"
                        type="button"
                        :disabled="disabled"
                        aria-label="Clear time"
                        class="flex size-6 items-center justify-center rounded-sm text-gray-500 transition hover:text-status-cancelled focus-visible:ring-3 focus-visible:ring-ring/50 outline-none"
                        @click="clearValue"
                    >
                        <X class="size-4" />
                    </button>
                    <PopoverTrigger as-child :disabled="disabled">
                        <button
                            type="button"
                            :disabled="disabled"
                            aria-label="Pick time"
                            class="flex size-6 items-center justify-center rounded-sm text-gray-500 transition hover:text-gray-800 focus-visible:ring-3 focus-visible:ring-ring/50 outline-none disabled:pointer-events-none disabled:opacity-50"
                        >
                            <Clock class="size-4" />
                        </button>
                    </PopoverTrigger>
                </div>
            </div>
            <PopoverPortal>
                <PopoverContent
                    align="start"
                    :side-offset="6"
                    data-slot="time-range-picker"
                    class="bg-popover text-popover-foreground data-[state=open]:animate-in data-[state=closed]:animate-out data-[state=closed]:fade-out-0 data-[state=open]:fade-in-0 data-[state=closed]:zoom-out-95 data-[state=open]:zoom-in-95 data-[side=bottom]:slide-in-from-top-2 data-[side=left]:slide-in-from-right-2 data-[side=right]:slide-in-from-left-2 data-[side=top]:slide-in-from-bottom-2 z-50 w-auto rounded-md border shadow-md"
                >
                    <div class="p-3">
                        <div class="flex gap-5">
                            <div
                                v-for="side in ['start', 'end']"
                                :key="side"
                            >
                                <p
                                    class="mb-1.5 text-xs font-medium text-gray-500"
                                >
                                    {{ side === 'start' ? 'Start' : 'End' }}
                                </p>
                                <div class="flex gap-2">
                                    <div
                                        v-for="part in ['hour', 'minute']"
                                        :key="part"
                                        :data-side="side"
                                        :data-part="part"
                                        class="no-scrollbar max-h-40 overflow-y-auto rounded-md border border-input p-1"
                                    >
                                        <button
                                            v-for="value in part === 'hour' ? hours : minutes"
                                            :key="value"
                                            type="button"
                                            :data-value="value"
                                            :aria-pressed="
                                                isSelected(side, part, value)
                                                    ? 'true'
                                                    : 'false'
                                            "
                                            :class="
                                                cn(
                                                    'block w-11 rounded-sm px-2 py-1 text-center text-sm transition',
                                                    isSelected(side, part, value)
                                                        ? 'bg-brand-500 text-white'
                                                        : 'text-gray-700 hover:bg-gray-50',
                                                )
                                            "
                                            @click="pick(side, part, value)"
                                        >
                                            {{ value }}
                                        </button>
                                    </div>
                                </div>
                                <div
                                    class="mt-1.5 flex rounded-md border border-input p-0.5"
                                    role="group"
                                    :data-side="side"
                                    :data-part="'period'"
                                    :aria-label="`${side} period`"
                                >
                                    <button
                                        v-for="period in periods"
                                        :key="period"
                                        type="button"
                                        :data-value="period"
                                        :aria-pressed="
                                            periodOf(side) === period
                                                ? 'true'
                                                : 'false'
                                        "
                                        :class="
                                            cn(
                                                'flex-1 rounded-sm px-3 py-0.5 text-xs font-medium transition',
                                                periodOf(side) === period
                                                    ? 'bg-brand-500 text-white'
                                                    : 'text-gray-700 hover:bg-gray-50',
                                            )
                                        "
                                        @click="pick(side, 'period', period)"
                                    >
                                        {{ period }}
                                    </button>
                                </div>
                            </div>
                        </div>
                        <div
                            class="mt-3 flex justify-end border-t border-gray-100 pt-2.5"
                        >
                            <Button
                                size="sm"
                                type="button"
                                @click="open = false"
                            >
                                Done
                            </Button>
                        </div>
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
