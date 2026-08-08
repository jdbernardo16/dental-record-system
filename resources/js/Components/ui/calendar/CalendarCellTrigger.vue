<script setup>
import { reactiveOmit } from "@vueuse/core";
import { CalendarCellTrigger, useForwardProps } from "reka-ui";
import { cn } from "@/lib/utils";

const props = defineProps({
  day: { type: null, required: true },
  month: { type: null, required: true },
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
  <CalendarCellTrigger
    data-slot="calendar-cell-trigger"
    v-bind="forwardedProps"
    :class="
      cn(
        'focus-visible:border-ring focus-visible:ring-ring/50 relative flex size-9 items-center justify-center rounded-md border border-transparent bg-transparent p-0 text-sm text-foreground shadow-xs transition-[color,box-shadow] outline-none focus-visible:ring-3 data-[selected]:bg-primary data-[selected]:text-primary-foreground data-[selected]:shadow-sm data-[disabled]:text-muted-foreground data-[disabled]:opacity-50 data-[outside-view]:text-muted-foreground data-[outside-view]:opacity-50 [&:has([data-selected])]:bg-accent first:[&:has([data-selected])]:rounded-l-md last:[&:has([data-selected])]:rounded-r-md [&:has([data-selected].day-outside)]:bg-accent/50 [&:has([data-selected].day-range-start)]:rounded-l-md [&:has([data-selected].day-range-end)]:rounded-r-md',
        props.class,
      )
    "
  >
    <slot />
  </CalendarCellTrigger>
</template>
