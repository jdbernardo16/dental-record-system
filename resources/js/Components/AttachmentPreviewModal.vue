<script setup>
import { computed, onMounted, onUnmounted, ref, watch } from 'vue'
import { FileText, Minus, Plus, Trash2, X } from 'lucide-vue-next'
import Button from '@/Components/Button.vue'

const props = defineProps({
    show: { type: Boolean, default: false },
    attachment: { type: Object, default: null },
    categoryLabels: { type: Object, default: () => ({}) },
    xrayLabels: { type: Object, default: () => ({}) },
    canDelete: { type: Boolean, default: false },
})

const emit = defineEmits(['close', 'delete'])

const scale = ref(1)
const MIN_SCALE = 0.5
const MAX_SCALE = 3

watch(
    () => props.show,
    (open) => {
        if (open) scale.value = 1
    },
)

const isPdf = computed(() => props.attachment?.category === 'pdf')
const isImage = computed(() => ['image', 'xray'].includes(props.attachment?.category))

const categoryLabel = computed(() => props.categoryLabels[props.attachment?.category] ?? props.attachment?.category ?? '—')
const xrayLabel = computed(() => props.xrayLabels[props.attachment?.xray_type] ?? props.attachment?.xray_type ?? null)

const formatSize = (bytes) => {
    if (!bytes) return '—'
    if (bytes >= 1024 * 1024) return (bytes / (1024 * 1024)).toFixed(1) + ' MB'
    return Math.max(1, Math.round(bytes / 1024)) + ' KB'
}

const formatDate = (value) => {
    if (!value) return '—'
    return new Date(value).toLocaleDateString()
}

const zoomIn = () => {
    scale.value = Math.min(MAX_SCALE, Math.round((scale.value + 0.25) * 100) / 100)
}

const zoomOut = () => {
    scale.value = Math.max(MIN_SCALE, Math.round((scale.value - 0.25) * 100) / 100)
}

const onKeydown = (event) => {
    if (event.key === 'Escape') emitClose()
}

onMounted(() => window.addEventListener('keydown', onKeydown))
onUnmounted(() => window.removeEventListener('keydown', onKeydown))

const emitClose = () => {
    scale.value = 1
    emit('close')
}
</script>

<template>
    <Teleport to="body">
        <div
            v-if="show && attachment"
            class="fixed inset-0 z-50 flex flex-col bg-gray-950/95"
            role="dialog"
            aria-modal="true"
        >
            <div class="flex items-center justify-between gap-4 border-b border-white/10 px-4 py-3 sm:px-6">
                <div class="min-w-0">
                    <p class="truncate text-sm font-semibold text-white">{{ attachment.original_name }}</p>
                    <p class="mt-0.5 truncate text-xs text-gray-400">
                        {{ categoryLabel }}<template v-if="xrayLabel"> · {{ xrayLabel }}</template>
                        · {{ formatSize(attachment.file_size) }}
                    </p>
                </div>
                <button
                    type="button"
                    aria-label="Close preview"
                    class="flex h-11 w-11 shrink-0 items-center justify-center rounded-lg text-gray-300 transition hover:bg-white/10 hover:text-white"
                    @click="emitClose"
                >
                    <X class="h-5 w-5" />
                </button>
            </div>

            <div class="flex min-h-0 flex-1 flex-col gap-4 p-4 sm:flex-row sm:p-6">
                <div class="flex min-h-0 flex-1 items-center justify-center overflow-auto bg-gray-900/60 rounded-xl">
                    <template v-if="isImage">
                        <div class="flex h-full w-full items-center justify-center overflow-auto p-4">
                            <img
                                :src="attachment.storage_url"
                                :alt="attachment.original_name"
                                class="max-h-full max-w-full object-contain transition-transform duration-150"
                                :style="{ transform: 'scale(' + scale + ')' }"
                            />
                        </div>
                    </template>
                    <iframe
                        v-else-if="isPdf"
                        :src="attachment.storage_url"
                        title="PDF preview"
                        class="h-[80vh] w-full"
                    />
                    <div v-else class="flex flex-col items-center gap-3 p-10 text-center">
                        <FileText class="h-16 w-16 text-gray-500" />
                        <p class="text-sm text-gray-400">No inline preview for this file type.</p>
                        <a :href="attachment.storage_url" target="_blank" class="text-sm font-medium text-brand-400 hover:text-brand-300">
                            Open in new tab
                        </a>
                    </div>
                </div>

                <aside class="w-full shrink-0 space-y-5 rounded-xl border border-white/10 bg-gray-900 p-5 sm:w-72">
                    <div>
                        <p class="text-xs font-semibold tracking-wide text-gray-400 uppercase">File details</p>
                        <dl class="mt-3 space-y-3 text-sm">
                            <div class="flex items-start justify-between gap-3">
                                <dt class="text-gray-400">Category</dt>
                                <dd class="text-right font-medium text-white">{{ categoryLabel }}</dd>
                            </div>
                            <div v-if="xrayLabel" class="flex items-start justify-between gap-3">
                                <dt class="text-gray-400">X-ray type</dt>
                                <dd class="text-right font-medium text-white">{{ xrayLabel }}</dd>
                            </div>
                            <div class="flex items-start justify-between gap-3">
                                <dt class="text-gray-400">Size</dt>
                                <dd class="text-right font-medium text-white">{{ formatSize(attachment.file_size) }}</dd>
                            </div>
                            <div class="flex items-start justify-between gap-3">
                                <dt class="text-gray-400">Uploaded by</dt>
                                <dd class="text-right font-medium text-white">{{ attachment.uploaded_by?.name ?? '—' }}</dd>
                            </div>
                            <div class="flex items-start justify-between gap-3">
                                <dt class="text-gray-400">Date</dt>
                                <dd class="text-right font-medium text-white">{{ formatDate(attachment.created_at) }}</dd>
                            </div>
                        </dl>
                    </div>

                    <div v-if="attachment.notes">
                        <p class="text-xs font-semibold tracking-wide text-gray-400 uppercase">Notes</p>
                        <p class="mt-2 text-sm leading-relaxed text-gray-300">{{ attachment.notes }}</p>
                    </div>

                    <div v-if="isImage" class="flex items-center gap-3">
                        <button
                            type="button"
                            aria-label="Zoom out"
                            class="flex h-11 w-11 items-center justify-center rounded-full bg-gray-800 text-white transition hover:bg-gray-700"
                            @click="zoomOut"
                        >
                            <Minus class="h-5 w-5" />
                        </button>
                        <span class="w-12 text-center text-sm font-medium tabular-nums text-gray-300">
                            {{ Math.round(scale * 100) }}%
                        </span>
                        <button
                            type="button"
                            aria-label="Zoom in"
                            class="flex h-11 w-11 items-center justify-center rounded-full bg-gray-800 text-white transition hover:bg-gray-700"
                            @click="zoomIn"
                        >
                            <Plus class="h-5 w-5" />
                        </button>
                    </div>

                    <div v-if="canDelete" class="pt-1">
                        <Button
                            variant="outline"
                            class="w-full border-white/10 text-status-cancelled hover:bg-status-cancelled/10"
                            @click="$emit('delete', attachment)"
                        >
                            <Trash2 class="h-4 w-4" />
                            Delete attachment
                        </Button>
                    </div>
                </aside>
            </div>
        </div>
    </Teleport>
</template>
