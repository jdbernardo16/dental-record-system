<script setup>
import { ref } from 'vue'
import Sidebar from '../Components/Sidebar.vue'
import Header from '../Components/Header.vue'
import Toast from '../Components/Toast.vue'

const sidebarOpen = ref(window.innerWidth >= 1024)
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
    <Toast />
  </div>
</template>
