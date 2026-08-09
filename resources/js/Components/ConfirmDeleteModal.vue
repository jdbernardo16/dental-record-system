<script setup>
import { Trash2 } from 'lucide-vue-next'
import Modal from '@/Components/Modal.vue'
import { Button } from '@/Components/ui/button'

defineProps({
    show: { type: Boolean, default: false },
    title: { type: String, default: 'Delete record' },
    message: { type: String, required: true },
    confirmLabel: { type: String, default: 'Delete' },
    processing: { type: Boolean, default: false },
})

const emit = defineEmits(['confirm', 'close'])
</script>

<template>
    <Modal :show="show" max-width="sm" @close="emit('close')">
        <div class="p-6">
            <div class="flex items-start gap-3">
                <span
                    class="flex h-10 w-10 shrink-0 items-center justify-center rounded-full bg-status-cancelled/10 text-status-cancelled"
                >
                    <Trash2 class="h-5 w-5" />
                </span>
                <div>
                    <h2 class="text-lg font-semibold text-gray-800">{{ title }}</h2>
                    <p class="mt-1 text-sm text-gray-500">{{ message }}</p>
                </div>
            </div>
            <div class="mt-6 flex items-center justify-end gap-2">
                <Button
                    variant="outline"
                    size="sm"
                    type="button"
                    :disabled="processing"
                    @click="emit('close')"
                >
                    Cancel
                </Button>
                <Button
                    variant="destructive"
                    size="sm"
                    type="button"
                    :disabled="processing"
                    @click="emit('confirm')"
                >
                    <Trash2 class="h-4 w-4" />
                    {{ processing ? 'Deleting…' : confirmLabel }}
                </Button>
            </div>
        </div>
    </Modal>
</template>
