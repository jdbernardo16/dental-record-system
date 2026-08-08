<script setup>
import { CalendarHeadCell } from "reka-ui";

const props = defineProps({
  asChild: { type: Boolean, required: false },
  as: { type: null, required: false },
});
</script>

<template>
  <CalendarHeadCell
    data-slot="calendar-head-cell"
    class="text-muted-foreground w-9 rounded-md text-xs font-normal"
    v-bind="props"
  >
    <slot />
  </CalendarHeadCell>
</template>
