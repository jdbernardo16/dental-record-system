<script setup>
import { CalendarGridRow } from "reka-ui";

const props = defineProps({
  asChild: { type: Boolean, required: false },
  as: { type: null, required: false },
});
</script>

<template>
  <CalendarGridRow data-slot="calendar-grid-row" v-bind="props">
    <slot />
  </CalendarGridRow>
</template>
