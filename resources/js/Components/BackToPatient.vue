<script setup>
import { ChevronLeft } from 'lucide-vue-next'
import { Link } from '@inertiajs/vue3'
import { route } from '../../../vendor/tightenco/ziggy'
import { Button } from '@/Components/ui/button'

defineProps({
    patientId: { type: Number, required: true },
})
</script>

<template>
    <Link :href="route('patients.show', patientId)">
        <Button variant="outline" size="sm">
            <ChevronLeft class="h-4 w-4" />
            Back to patient
        </Button>
    </Link>
</template>
