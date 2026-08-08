<script setup>
import { reactiveOmit } from "@vueuse/core";
import { CalendarCell, useForwardProps } from "reka-ui";
import { cn } from "@/lib/utils";

const props = defineProps({
  date: { type: null, required: true },
  asChild: { type: Boolean, required: false },
  as: { type: null, required: false },
  class: {
    type: [Boolean, null, String, Object, Array],
    required: false,
    skipCheck: true,
  },
});

const delegatedProps = reactiveOmit(props, "class");

const forwardedProps = useForwardProps(delegatedProps);
</script>

<template>
  <CalendarCell
    data-slot="calendar-cell"
    v-bind="forwardedProps"
    :class="
      cn(
        'relative size-9 p-0 text-center text-sm focus-within:relative focus-within:z-20 [&:has([data-selected])]:bg-accent first:[&:has([data-selected])]:rounded-l-md last:[&:has([data-selected])]:rounded-r-md [&:has([data-selected].day-outside)]:bg-accent/50 [&:has([data-selected].day-range-start)]:rounded-l-md [&:has([data-selected].day-range-end)]:rounded-r-md',
        props.class,
      )
    "
  >
    <slot />
  </CalendarCell>
</template>
