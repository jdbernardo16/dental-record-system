<script setup>
import { CalendarHeading } from "reka-ui";

const props = defineProps({
  asChild: { type: Boolean, required: false },
  as: { type: null, required: false },
});
</script>

<template>
  <CalendarHeading
    data-slot="calendar-heading"
    class="text-sm font-medium"
    v-bind="props"
  >
    <slot />
  </CalendarHeading>
</template>
