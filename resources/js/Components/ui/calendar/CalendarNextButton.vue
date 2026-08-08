<script setup>
import { ChevronRight } from "@lucide/vue";
import { reactiveOmit } from "@vueuse/core";
import { CalendarNext, useForwardProps } from "reka-ui";
import { cn } from "@/lib/utils";

const props = defineProps({
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
  <CalendarNext
    data-slot="calendar-next-button"
    v-bind="forwardedProps"
    :class="
      cn(
        'focus-visible:border-ring focus-visible:ring-ring/50 flex size-9 items-center justify-center rounded-md text-muted-foreground transition-[color,box-shadow] outline-none hover:bg-accent hover:text-accent-foreground focus-visible:ring-3 disabled:pointer-events-none disabled:opacity-50',
        props.class,
      )
    "
  >
    <slot />
    <ChevronRight />
  </CalendarNext>
</template>
