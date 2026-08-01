<script setup>
import { ref } from 'vue'
import Sidebar from '../Components/Sidebar.vue'
import Header from '../Components/Header.vue'

const sidebarOpen = ref(false)
</script>

<template>
  <div class="flex h-screen overflow-hidden bg-gray-50">
    <Sidebar :open="sidebarOpen" @close="sidebarOpen = false" />
    <div class="flex flex-1 flex-col overflow-y-auto">
      <Header @toggle="sidebarOpen = !sidebarOpen" />
      <main class="flex-1 p-4 sm:p-6 lg:p-8">
        <slot />
      </main>
    </div>
  </div>
</template>
