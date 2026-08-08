<script setup>
import { CalendarHeader } from "reka-ui";

const props = defineProps({
  asChild: { type: Boolean, required: false },
  as: { type: null, required: false },
});
</script>

<template>
  <CalendarHeader
    data-slot="calendar-header"
    class="relative flex w-full items-center justify-center pt-1"
    v-bind="props"
  >
    <slot />
  </CalendarHeader>
</template>
