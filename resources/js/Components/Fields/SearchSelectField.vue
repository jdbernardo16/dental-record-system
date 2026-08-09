<script setup>
import { computed, ref, useId } from "vue";
import { Check, X } from "@lucide/vue";
import {
    ComboboxAnchor,
    ComboboxContent,
    ComboboxEmpty,
    ComboboxInput,
    ComboboxItem,
    ComboboxItemIndicator,
    ComboboxPortal,
    ComboboxRoot,
    ComboboxViewport,
} from "reka-ui";
import { Label } from "@/Components/ui/label";

defineOptions({ inheritAttrs: false });

const props = defineProps({
    modelValue: { type: [String, Number], default: "" },
    label: { type: String, default: null },
    error: { type: String, default: null },
    hint: { type: String, default: null },
    required: { type: Boolean, default: false },
    placeholder: { type: String, default: "Search…" },
    // [{ value, label, disabled? }] — filtered client-side by label text
    options: { type: Array, default: () => [] },
    id: { type: String, default: null },
    disabled: { type: Boolean, default: false },
});

const emits = defineEmits(["update:modelValue"]);

const generatedId = useId();
const selectId = computed(() => props.id || generatedId);
const searchTerm = ref("");

const optionLabel = (value) =>
    props.options.find((o) => String(o.value) === String(value))?.label ?? "";

const displayValue = (value) => optionLabel(value);

// reka-ui Combobox mutates its v-model on selection; route through a
// computed so the parent's prop is never written directly.
const selectedValue = computed({
    get: () => props.modelValue ?? "",
    set: (value) => emits("update:modelValue", value ?? ""),
});

const clear = () => {
    emits("update:modelValue", "");
    searchTerm.value = "";
};

const hasValue = computed(
    () => props.modelValue !== "" && props.modelValue !== null,
);
</script>

<template>
    <div>
        <Label v-if="label" :for="selectId" class="mb-1.5 block text-sm font-medium text-gray-700">
            {{ label }}
            <span v-if="required" class="text-status-cancelled">*</span>
        </Label>
        <!-- reka-ui 2.x defaults openOnFocus/openOnClick to false; the
             combobox must opt in to open on interaction. -->
        <ComboboxRoot v-model="selectedValue" v-model:search-term="searchTerm" :disabled="disabled" open-on-focus open-on-click>
            <ComboboxAnchor class="relative block">
                <ComboboxInput
                    data-slot="combobox-input"
                    :id="selectId"
                    :display-value="displayValue"
                    :placeholder="placeholder"
                    :disabled="disabled"
                    :class="[
                        'flex h-11 w-full items-center rounded-md border bg-white px-3 text-sm shadow-xs outline-none transition-[color,box-shadow] placeholder:text-muted-foreground focus-visible:border-ring focus-visible:ring-ring/50 focus-visible:ring-3 disabled:cursor-not-allowed disabled:opacity-50',
                        hasValue ? 'pr-9' : '',
                        error ? 'border-destructive' : 'border-input',
                    ]"
                    :aria-invalid="error ? 'true' : 'false'"
                    :aria-describedby="error ? `${selectId}-error` : undefined"
                />
                <button
                    v-if="hasValue"
                    type="button"
                    aria-label="Clear selection"
                    title="Clear selection"
                    class="absolute top-1/2 right-2 -translate-y-1/2 flex h-6 w-6 items-center justify-center rounded-md text-muted-foreground hover:bg-gray-100 hover:text-foreground"
                    @mousedown.prevent
                    @click="clear"
                >
                    <X class="h-4 w-4" />
                </button>
            </ComboboxAnchor>
            <ComboboxPortal>
                <ComboboxContent
                    data-slot="combobox-content"
                    position="popper"
                    class="relative z-50 max-h-(--reka-combobox-content-available-height) min-w-[8rem] overflow-x-hidden overflow-y-auto rounded-md border bg-popover text-popover-foreground shadow-md data-[state=open]:animate-in data-[state=closed]:animate-out data-[state=closed]:fade-out-0 data-[state=open]:fade-in-0 data-[state=closed]:zoom-out-95 data-[state=open]:zoom-in-95 data-[side=bottom]:translate-y-1 data-[side=left]:-translate-x-1 data-[side=right]:translate-x-1 data-[side=top]:-translate-y-1"
                >
                    <ComboboxViewport class="min-w-(--reka-combobox-trigger-width) w-full p-1">
                        <ComboboxEmpty data-slot="combobox-empty" class="px-2 py-6 text-center text-sm text-gray-500">
                            No matches found.
                        </ComboboxEmpty>
                        <ComboboxItem
                            data-slot="combobox-item"
                            v-for="option in options"
                            :key="option.value"
                            :value="option.value"
                            :disabled="option.disabled"
                            class="focus:bg-accent focus:text-accent-foreground data-[disabled]:pointer-events-none data-[disabled]:opacity-50 relative flex w-full cursor-default items-center gap-2 rounded-sm py-1.5 pr-8 pl-2 text-sm outline-hidden select-none data-[highlighted]:bg-accent data-[highlighted]:text-accent-foreground"
                        >
                            <span class="absolute right-2 flex size-3.5 items-center justify-center">
                                <ComboboxItemIndicator>
                                    <Check class="size-4" />
                                </ComboboxItemIndicator>
                            </span>
                            {{ option.label }}
                        </ComboboxItem>
                    </ComboboxViewport>
                </ComboboxContent>
            </ComboboxPortal>
        </ComboboxRoot>
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
