<script setup>
import { reactiveOmit } from "@vueuse/core";
import { CalendarRoot, useForwardPropsEmits } from "reka-ui";
import { cn } from "@/lib/utils";

const props = defineProps({
  modelValue: { type: null, required: false },
  defaultValue: { type: null, required: false },
  defaultPlaceholder: { type: null, required: false },
  placeholder: { type: null, required: false },
  pagedNavigation: { type: Boolean, required: false },
  preventDeselect: { type: Boolean, required: false },
  weekStartsOn: { type: Number, required: false },
  weekdayFormat: { type: String, required: false },
  calendarLabel: { type: String, required: false },
  fixedWeeks: { type: Boolean, required: false },
  maxValue: { type: null, required: false },
  minValue: { type: null, required: false },
  numberOfMonths: { type: Number, required: false },
  disabled: { type: Boolean, required: false },
  readonly: { type: Boolean, required: false },
  initialFocus: { type: Boolean, required: false },
  multiple: { type: Boolean, required: false },
  isDateDisabled: { type: Function, required: false },
  isDateUnavailable: { type: Function, required: false },
  disableDaysOutsideCurrentView: { type: Boolean, required: false },
  nextPage: { type: Function, required: false },
  prevPage: { type: Function, required: false },
  dir: { type: String, required: false },
  locale: { type: String, required: false },
  class: {
    type: [Boolean, null, String, Object, Array],
    required: false,
    skipCheck: true,
  },
});
const emits = defineEmits(["update:modelValue", "update:placeholder"]);

const delegatedProps = reactiveOmit(props, "class");

const forwarded = useForwardPropsEmits(delegatedProps, emits);
</script>

<template>
  <CalendarRoot
    v-slot="{ grid }"
    data-slot="calendar"
    v-bind="forwarded"
    :class="cn('p-3', props.class)"
  >
    <slot :grid="grid" />
  </CalendarRoot>
</template>
