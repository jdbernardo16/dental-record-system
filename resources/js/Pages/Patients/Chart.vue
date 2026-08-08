<script setup>
import { computed, ref, watch } from 'vue'
import { Head, router } from '@inertiajs/vue3'
import { History, X } from 'lucide-vue-next'
import { route } from '../../../../vendor/tightenco/ziggy'
import AppLayout from '@/Layouts/AppLayout.vue'
import Badge from '@/Components/Badge.vue'
import { Button } from '@/Components/ui/button'
import ToothChart, { wholeToothOnly } from '@/Components/ToothChart.vue'
import { useToastStore } from '@/Stores/toast'

defineOptions({ layout: AppLayout })

const props = defineProps({
    patient: { type: Object, required: true },
    dentition: { type: String, default: 'adult' },
    state: { type: Object, required: true },
    asOf: { type: String, default: null },
    history: { type: Array, default: () => [] },
    options: { type: Object, required: true },
    can: { type: Object, default: () => ({}) },
})

const toastStore = useToastStore()

const selectedCondition = ref(null)
const selectedRestoration = ref(null)
const showHistory = ref(false)
const applying = ref(false)

// reset the armed tools when the dentition or the as-of snapshot changes
watch(
    () => [props.dentition, props.asOf],
    () => {
        selectedCondition.value = null
        selectedRestoration.value = null
    },
)

const pickTool = (kind, key) => {
    if (kind === 'condition') {
        selectedCondition.value = selectedCondition.value === key ? null : key
        selectedRestoration.value = null
    } else {
        selectedRestoration.value = selectedRestoration.value === key ? null : key
        selectedCondition.value = null
    }
}

const applyTooth = ({ tooth, surface }) => {
    if (applying.value) return

    // restorations are recorded on a present tooth (condition is required by the backend)
    const tool = selectedRestoration.value
        ? { condition: 'present', restoration_type: selectedRestoration.value }
        : { condition: selectedCondition.value }
    if (!tool.condition) return

    applying.value = true
    router.post(
        route('dental-chart.store'),
        {
            patient_id: props.patient.id,
            tooth_number: tooth,
            dentition: props.dentition,
            surface,
            recorded_at: new Date().toISOString().slice(0, 10),
            ...tool,
        },
        {
            preserveScroll: true,
            onSuccess: () => toastStore.show(`Tooth ${tooth} updated.`),
            onFinish: () => (applying.value = false),
        },
    )
}

const switchDentition = (key) => {
    router.get(route('patients.chart', [props.patient.id, { dentition: key }]), {}, {
        preserveState: true,
        preserveScroll: true,
    })
}

const viewAsOf = (date) => {
    router.get(route('patients.chart', [props.patient.id, { as_of: date }]), {}, { preserveState: true })
}

const clearAsOf = () => {
    router.get(route('patients.chart', props.patient.id), {}, { preserveState: true })
}

const fullName = () =>
    [props.patient.first_name, props.patient.middle_name, props.patient.last_name].filter(Boolean).join(' ')

const conditionLabel = (key) => props.options.conditions?.[key]?.label ?? key
const restorationLabel = (key) => props.options.restorations?.[key]?.label ?? key

/** Editing UI is only shown when the user may update and is viewing the current state. */
const editing = computed(() => props.can.update && !props.asOf)

const hasToolSelected = computed(() => Boolean(selectedCondition.value || selectedRestoration.value))

const hintText = computed(() => {
    if (!hasToolSelected.value) {
        return 'Step 1: tap a condition or restoration below · Step 2: tap the tooth (or its surface) to record it.'
    }
    let text = 'Now tap a tooth (or its surface) to record the selected item.'
    if (selectedCondition.value && wholeToothOnly().includes(selectedCondition.value)) {
        text += ' This condition applies to the whole tooth only.'
    }
    return text
})

const chipClass = (selected) => [
    'min-h-11 inline-flex items-center gap-2 rounded-full border px-4 text-sm font-medium transition',
    selected
        ? 'border-brand-500 bg-brand-50 text-brand-700 ring-2 ring-brand-500'
        : 'border-gray-200 bg-white text-gray-600 hover:bg-gray-50',
]
</script>

<template>
    <Head :title="`Dental chart — ${fullName()}`" />

    <div class="mx-auto max-w-5xl space-y-6">
        <div class="flex flex-wrap items-center justify-between gap-4">
            <div class="flex min-w-0 flex-wrap items-center gap-2">
                <h1 class="text-2xl font-semibold text-gray-800">{{ fullName() }}</h1>
                <Badge size="sm" color="light">{{ patient.patient_number }}</Badge>
            </div>
            <div class="flex flex-wrap items-center gap-2">
                <div class="inline-flex gap-1 rounded-full bg-gray-100 p-1" role="radiogroup" aria-label="Dentition">
                    <button
                        v-for="(meta, key) in options.dentitions"
                        :key="key"
                        type="button"
                        role="radio"
                        :aria-checked="dentition === key"
                        :class="[
                            'min-h-11 rounded-full px-4 text-sm font-medium transition',
                            dentition === key ? 'bg-white text-gray-900 shadow-sm' : 'text-gray-500',
                        ]"
                        @click="switchDentition(key)"
                    >
                        {{ meta.label }}
                    </button>
                </div>
                <Button variant="outline" size="sm" @click="showHistory = !showHistory">
                    <History class="h-4 w-4" />
                    History
                </Button>
            </div>
        </div>

        <div
            v-if="asOf"
            class="flex flex-wrap items-center justify-between gap-3 rounded-xl border border-brand-200 bg-brand-50 px-4 py-3"
        >
            <p class="text-sm font-medium text-brand-700">Showing state as of {{ asOf }}</p>
            <Button variant="outline" size="sm" @click="clearAsOf">Back to current</Button>
        </div>

        <div class="rounded-2xl border border-gray-200 bg-white p-4 shadow-sm sm:p-6">
            <ToothChart
                :state="state"
                :dentition="dentition"
                :readonly="!editing"
                :selected-condition="selectedCondition"
                :selected-restoration="selectedRestoration"
                :options="options"
                @apply-tooth="applyTooth"
            />

            <p v-if="!history.length" class="mt-4 text-center text-sm text-gray-500">
                No chart entries yet — tap a condition then a tooth to begin.
            </p>

            <div
                v-if="editing && !hasToolSelected"
                class="mt-4 rounded-xl border border-dashed border-brand-300 bg-brand-50 px-4 py-3 text-sm font-medium text-brand-700"
            >
                {{ hintText }}
            </div>
            <div v-else-if="editing" class="mt-4 rounded-xl bg-gray-50 px-4 py-3 text-sm text-gray-600">
                {{ hintText }}
            </div>
        </div>

        <div v-if="editing" class="rounded-2xl border border-gray-200 bg-white p-6 shadow-sm">
            <h3 class="text-xs font-semibold tracking-wide text-gray-400 uppercase">Conditions</h3>
            <div class="mt-3 flex flex-wrap gap-2">
                <button
                    v-for="(meta, key) in options.conditions"
                    :key="key"
                    type="button"
                    :title="meta.code"
                    :class="chipClass(selectedCondition === key)"
                    @click="pickTool('condition', key)"
                >
                    <span
                        class="h-4 w-4 shrink-0 rounded-full"
                        :style="{ background: `var(--color-${meta.color})` }"
                    />
                    {{ meta.label }}
                </button>
            </div>

            <h3 class="mt-6 text-xs font-semibold tracking-wide text-gray-400 uppercase">Restorations</h3>
            <div class="mt-3 flex flex-wrap gap-2">
                <button
                    v-for="(meta, key) in options.restorations"
                    :key="key"
                    type="button"
                    :title="meta.code"
                    :class="chipClass(selectedRestoration === key)"
                    @click="pickTool('restoration', key)"
                >
                    <span
                        class="h-4 w-4 shrink-0 rounded-full"
                        :style="{ background: `var(--color-${meta.color})` }"
                    />
                    {{ meta.label }}
                </button>
            </div>
        </div>
    </div>

    <!-- History drawer -->
    <div class="fixed inset-0 z-40" :class="{ 'pointer-events-none': !showHistory }">
        <div
            v-if="showHistory"
            class="absolute inset-0 bg-gray-900/40"
            @click="showHistory = false"
        />
        <aside
            class="absolute inset-y-0 right-0 flex w-80 max-w-full flex-col bg-white shadow-xl transition-transform duration-300"
            :class="showHistory ? 'translate-x-0' : 'translate-x-full'"
        >
            <header class="flex items-center justify-between border-b border-gray-100 px-5 py-4">
                <div>
                    <h3 class="text-sm font-semibold text-gray-800">Chart history</h3>
                    <p class="mt-0.5 text-xs text-gray-500">{{ history.length }} entries</p>
                </div>
                <button
                    type="button"
                    class="rounded-lg p-2 text-gray-400 transition hover:bg-gray-100 hover:text-gray-600"
                    aria-label="Close history"
                    @click="showHistory = false"
                >
                    <X class="h-5 w-5" />
                </button>
            </header>

            <ul v-if="history.length" class="flex-1 divide-y divide-gray-100 overflow-y-auto">
                <li v-for="entry in history" :key="entry.id" :class="{ 'opacity-50': asOf && entry.recorded_at > asOf }">
                    <button
                        type="button"
                        class="w-full px-5 py-4 text-left transition hover:bg-gray-50"
                        :title="`Show state as of ${entry.recorded_at}`"
                        @click="viewAsOf(entry.recorded_at)"
                    >
                        <div class="flex flex-wrap items-center gap-2">
                            <Badge size="sm" color="light">{{ entry.recorded_at }}</Badge>
                            <Badge size="sm" color="primary">Tooth {{ entry.tooth_number }}</Badge>
                        </div>
                        <div class="mt-2 flex flex-wrap items-center gap-x-2 gap-y-1 text-sm">
                            <span class="font-medium text-gray-800">{{ conditionLabel(entry.condition) }}</span>
                            <span v-if="entry.restoration_type" class="text-gray-500">
                                + {{ restorationLabel(entry.restoration_type) }}
                            </span>
                        </div>
                        <p class="mt-1 text-xs text-gray-500">by {{ entry.recorded_by?.name ?? '—' }}</p>
                        <p v-if="entry.notes" class="mt-1 text-xs text-gray-600">{{ entry.notes }}</p>
                    </button>
                </li>
            </ul>
            <p v-else class="flex-1 px-5 py-10 text-center text-sm text-gray-500">No entries recorded yet.</p>
        </aside>
    </div>
</template>
