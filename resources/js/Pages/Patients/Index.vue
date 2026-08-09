<script setup>
import { computed, ref, watch } from "vue";
import { Head, Link, router, useForm } from "@inertiajs/vue3";
import {
    ChevronLeft,
    ChevronRight,
    Download,
    Eye,
    Pencil,
    Plus,
    Search,
    SlidersHorizontal,
    Trash2,
    Upload,
    X,
} from "lucide-vue-next";
import { route } from "../../../../vendor/tightenco/ziggy";
import AppLayout from "@/Layouts/AppLayout.vue";
import Badge from "@/Components/Badge.vue";
import ConfirmDeleteModal from "@/Components/ConfirmDeleteModal.vue";
import {
    DateField,
    RadioPills,
    SelectField,
    TextInput,
} from "@/Components/Fields";
import Drawer from "@/Components/Drawer.vue";
import Modal from "@/Components/Modal.vue";
import { Button } from "@/Components/ui/button";
import { scrollToFirstError } from "@/lib/scroll";
import { useToastStore } from "@/Stores/toast";

defineOptions({ layout: AppLayout });

const props = defineProps({
    patients: { type: Object, required: true },
    filters: { type: Object, default: () => ({}) },
    can: { type: Object, default: () => ({}) },
    importPreview: { type: Object, default: null },
    importResult: { type: Object, default: null },
});

const toastStore = useToastStore();

const search = ref(props.filters.search ?? "");

// Backend-driven filter/sort state ('' = filter unset, mirroring props).
const filters = ref({
    sex: props.filters.sex ?? "",
    civil_status: props.filters.civil_status ?? "",
    age_min: props.filters.age_min ?? "",
    age_max: props.filters.age_max ?? "",
    date_from: props.filters.date_from ?? "",
    date_to: props.filters.date_to ?? "",
    sort: props.filters.sort ?? "created_at",
    direction: props.filters.direction ?? "desc",
});

const sexOptions = [
    { value: "male", label: "Male" },
    { value: "female", label: "Female" },
];

const civilStatusOptions = [
    { value: "single", label: "Single" },
    { value: "married", label: "Married" },
    { value: "widowed", label: "Widowed" },
    { value: "separated", label: "Separated" },
    { value: "divorced", label: "Divorced" },
    { value: "annulled", label: "Annulled" },
    { value: "other", label: "Other" },
];

const sortOptions = [
    { value: "name", label: "Name" },
    { value: "patient_number", label: "Patient number" },
    { value: "age", label: "Age" },
    { value: "sex", label: "Sex" },
    { value: "created_at", label: "Date registered" },
];

const directionOptions = [
    { value: "asc", label: "Ascending" },
    { value: "desc", label: "Descending" },
];

// Sort/direction are always sent explicitly so the backend applies exactly
// what the user picked (e.g. sort=name&direction=desc).
const queryParams = () => ({
    search: search.value || undefined,
    sex: filters.value.sex || undefined,
    civil_status: filters.value.civil_status || undefined,
    age_min: filters.value.age_min || undefined,
    age_max: filters.value.age_max || undefined,
    date_from: filters.value.date_from || undefined,
    date_to: filters.value.date_to || undefined,
    sort: filters.value.sort,
    direction: filters.value.direction,
});

// Shared navigation: always reads the current `filters` ref + search text.
const navigate = () => {
    router.get(route("patients.index"), queryParams(), {
        preserveState: true,
        replace: true,
    });
};

let debounceTimer = null;

// Debounced re-apply for the search box only; filter/sort changes are
// committed explicitly via the drawer's Apply/Clear buttons.
watch(search, () => {
    clearTimeout(debounceTimer);
    debounceTimer = setTimeout(navigate, 300);
});

// Drawer state. Edits land in `draft` and only reach the URL via Apply.
const showFilters = ref(false);

const draftDefaults = () => ({
    sex: "",
    civil_status: "",
    age_min: "",
    age_max: "",
    date_from: "",
    date_to: "",
    sort: "created_at",
    direction: "desc",
});

const draft = ref(draftDefaults());

const openFilters = () => {
    draft.value = {
        sex: props.filters.sex ?? "",
        civil_status: props.filters.civil_status ?? "",
        age_min: props.filters.age_min ?? "",
        age_max: props.filters.age_max ?? "",
        date_from: props.filters.date_from ?? "",
        date_to: props.filters.date_to ?? "",
        sort: props.filters.sort ?? "created_at",
        direction: props.filters.direction ?? "desc",
    };
    showFilters.value = true;
};

const applyFilters = () => {
    filters.value = { ...draft.value };
    navigate();
    showFilters.value = false;
};

// Clears and applies in one go, keeping the drawer open so the user sees the
// reset state. The current search text is preserved (it lives in `search`).
const clearFilters = () => {
    draft.value = draftDefaults();
    filters.value = { ...draft.value };
    navigate();
};

// Badge on the Filter button: counts every non-default filter/sort value.
const activeFilterCount = computed(() => {
    const f = filters.value;
    return (
        (f.sex !== "" ? 1 : 0) +
        (f.civil_status !== "" ? 1 : 0) +
        (f.age_min !== "" ? 1 : 0) +
        (f.age_max !== "" ? 1 : 0) +
        (f.date_from !== "" ? 1 : 0) +
        (f.date_to !== "" ? 1 : 0) +
        (f.sort !== "created_at" ? 1 : 0) +
        (f.direction !== "desc" ? 1 : 0)
    );
});

// Export honors whatever filters are currently applied (server-sanitized).
const exportUrl = computed(() =>
    route("patients.export-csv", {
        search: props.filters.search || undefined,
        sex: props.filters.sex || undefined,
        civil_status: props.filters.civil_status || undefined,
        age_min: props.filters.age_min || undefined,
        age_max: props.filters.age_max || undefined,
        date_from: props.filters.date_from || undefined,
        date_to: props.filters.date_to || undefined,
        sort: props.filters.sort ?? "created_at",
        direction: props.filters.direction ?? "desc",
    }),
);

const sexLabel = (sex) => ({ male: "Male", female: "Female" })[sex] ?? sex;

const fullName = (patient) =>
    [patient.first_name, patient.middle_name, patient.last_name]
        .filter(Boolean)
        .join(" ");

const listName = (patient) => {
    const middle = patient.middle_name
        ? ` ${patient.middle_name.charAt(0)}`
        : "";
    return [patient.last_name, `${patient.first_name}${middle}`]
        .filter(Boolean)
        .join(", ");
};

const initials = (name) =>
    String(name)
        .split(" ")
        .map((part) => part[0])
        .slice(0, 2)
        .join("")
        .toUpperCase();

const targetPatient = ref(null);
const showDelete = ref(false);
const deleting = ref(false);

const openDelete = (patient) => {
    targetPatient.value = patient;
    showDelete.value = true;
};

const deletePatient = () => {
    deleting.value = true;
    router.delete(route("patients.destroy", targetPatient.value.id), {
        onSuccess: () => {
            toastStore.show("Patient deleted.");
            showDelete.value = false;
        },
        onFinish: () => (deleting.value = false),
    });
};

const deleteMessage = computed(() =>
    targetPatient.value
        ? `Delete ${fullName(targetPatient.value)}? The record can be restored by an administrator.`
        : "",
);

const goTo = (url) => {
    router.get(url, {}, { preserveState: true });
};

const importOpen = ref(false);
const importStep = ref(1);
const importForm = useForm({ file: null });
const confirmForm = useForm({ token: "" });
const fileError = ref("");

const importBadgeColor = (status) =>
    ({
        new: "success",
        duplicate: "warning",
        invalid: "error",
    })[status] ?? "light";

const importRowName = (row) =>
    [row.data?.first_name, row.data?.last_name].filter(Boolean).join(" ");

const openImport = () => {
    importForm.reset();
    confirmForm.reset();
    fileError.value = "";
    importStep.value = 1;
    importOpen.value = true;
};

const closeImport = () => {
    importOpen.value = false;
    importForm.reset();
    confirmForm.reset();
    fileError.value = "";
};

const onFileChange = (event) => {
    const file = event.target.files[0];
    importForm.file = file ?? null;
    fileError.value = "";

    if (!file) return;

    const filename = file.name.toLowerCase();

    if (!filename.endsWith(".csv") && !filename.endsWith(".txt")) {
        fileError.value = "Please choose a .csv or .txt file.";
        return;
    }

    if (file.size > 2 * 1024 * 1024) {
        fileError.value = "File must be 2 MB or smaller.";
    }
};

const uploadCsv = () => {
    if (fileError.value) return;

    importForm.post(route("patients.import-preview"), {
        preserveScroll: true,
        preserveUrl: true,
        only: ["importPreview"],
        onSuccess: () => {
            if (props.importPreview) importStep.value = 2;
        },
        onError: () => scrollToFirstError(),
    });
};

const confirmImport = () => {
    confirmForm.token = props.importPreview?.token ?? "";
    confirmForm.post(route("patients.import"), {
        preserveScroll: true,
        onSuccess: () => {
            if (props.importResult) importStep.value = 3;
        },
        onError: () => scrollToFirstError(),
    });
};
</script>

<template>
    <Head title="Patients" />

    <div class="space-y-6">
        <div class="flex flex-wrap items-center justify-between gap-4">
            <div>
                <h1 class="text-2xl font-semibold text-gray-800">Patients</h1>
                <p class="mt-1 text-sm text-gray-500">
                    Search the registry and manage patient records.
                </p>
            </div>
            <div class="flex flex-wrap items-center gap-3">
                <a
                    :href="exportUrl"
                    class="inline-flex"
                    aria-label="Export patients to CSV"
                >
                    <Button variant="outline" size="sm">
                        <Download class="h-4 w-4" />
                        Export
                    </Button>
                </a>
                <Button
                    v-if="can.import"
                    variant="outline"
                    size="sm"
                    @click="openImport"
                >
                    <Upload class="h-4 w-4" />
                    Import
                </Button>
                <Link
                    v-if="can.create"
                    :href="route('patients.create')"
                    class="inline-block"
                >
                    <Button variant="default" size="sm">
                        <Plus class="h-4 w-4" />
                        Register patient
                    </Button>
                </Link>
            </div>
        </div>

        <div class="flex flex-wrap items-end gap-3">
            <div class="flex-1">
                <TextInput
                    v-model="search"
                    label="Search"
                    placeholder="Name, patient number, or contact…"
                />
            </div>
            <div>
                <Button
                    variant="outline"
                    size="sm"
                    :aria-label="
                        activeFilterCount
                            ? `Filter patients (${activeFilterCount} active)`
                            : 'Filter patients'
                    "
                    @click="openFilters"
                >
                    <SlidersHorizontal class="h-4 w-4" />
                    Filter
                    <span
                        v-if="activeFilterCount"
                        class="flex h-4 min-w-4 items-center justify-center rounded-full bg-brand-500 px-1 text-xs font-semibold text-white"
                    >
                        {{ activeFilterCount }}
                    </span>
                </Button>
            </div>
        </div>

        <div
            class="overflow-hidden rounded-2xl border border-gray-200 bg-white shadow-sm"
        >
            <div v-if="patients.data.length" class="overflow-x-auto">
                <table class="min-w-full divide-y divide-gray-200">
                    <thead class="bg-gray-50">
                        <tr>
                            <th
                                scope="col"
                                class="px-6 py-3.5 text-left text-xs font-semibold tracking-wide text-gray-500 uppercase"
                            >
                                Patient
                            </th>
                            <th
                                scope="col"
                                class="px-6 py-3.5 text-left text-xs font-semibold tracking-wide text-gray-500 uppercase"
                            >
                                Age
                            </th>
                            <th
                                scope="col"
                                class="px-6 py-3.5 text-left text-xs font-semibold tracking-wide text-gray-500 uppercase"
                            >
                                Sex
                            </th>
                            <th
                                scope="col"
                                class="px-6 py-3.5 text-left text-xs font-semibold tracking-wide text-gray-500 uppercase"
                            >
                                Contact
                            </th>
                            <th
                                scope="col"
                                class="px-6 py-3.5 text-right text-xs font-semibold tracking-wide text-gray-500 uppercase"
                            >
                                Actions
                            </th>
                        </tr>
                    </thead>
                    <tbody class="divide-y divide-gray-100">
                        <tr
                            v-for="patient in patients.data"
                            :key="patient.id"
                            class="hover:bg-gray-50"
                        >
                            <td class="px-6 py-4">
                                <Link
                                    :href="route('patients.show', patient.id)"
                                    class="flex items-center gap-3"
                                >
                                    <span
                                        class="flex h-9 w-9 shrink-0 items-center justify-center rounded-full bg-brand-500 text-xs font-semibold text-white"
                                    >
                                        {{ initials(fullName(patient)) }}
                                    </span>
                                    <span>
                                        <span
                                            class="block text-sm font-medium text-gray-800"
                                            >{{ listName(patient) }}</span
                                        >
                                        <span
                                            class="block text-xs text-gray-400"
                                            >{{ patient.patient_number }}</span
                                        >
                                    </span>
                                </Link>
                            </td>
                            <td class="px-6 py-4 text-sm text-gray-500">
                                {{ patient.age }}
                            </td>
                            <td class="px-6 py-4 text-sm text-gray-500">
                                {{ sexLabel(patient.sex) }}
                            </td>
                            <td class="px-6 py-4 text-sm text-gray-500">
                                {{ patient.contact_number }}
                            </td>
                            <td class="px-6 py-4">
                                <div
                                    class="flex items-center justify-end gap-1"
                                >
                                    <Link
                                        :href="
                                            route('patients.show', patient.id)
                                        "
                                        :aria-label="`View ${listName(patient)}`"
                                        class="inline-flex h-9 w-9 items-center justify-center rounded-lg text-gray-600 hover:bg-gray-100 hover:text-gray-800"
                                    >
                                        <Eye class="h-4 w-4" />
                                    </Link>
                                    <Link
                                        v-if="can.update"
                                        :href="
                                            route('patients.edit', patient.id)
                                        "
                                        :aria-label="`Edit ${listName(patient)}`"
                                        class="inline-flex h-9 w-9 items-center justify-center rounded-lg text-gray-600 hover:bg-gray-100 hover:text-gray-800"
                                    >
                                        <Pencil class="h-4 w-4" />
                                    </Link>
                                    <button
                                        v-if="can.delete"
                                        type="button"
                                        :aria-label="`Delete ${listName(patient)}`"
                                        class="inline-flex h-9 w-9 items-center justify-center rounded-lg text-status-cancelled hover:bg-status-cancelled/10"
                                        @click="openDelete(patient)"
                                    >
                                        <Trash2 class="h-4 w-4" />
                                    </button>
                                </div>
                            </td>
                        </tr>
                    </tbody>
                </table>
            </div>

            <div
                v-else
                class="flex flex-col items-center gap-2 px-6 py-16 text-center"
            >
                <Search class="h-8 w-8 text-gray-300" />
                <p class="text-sm font-medium text-gray-700">
                    No patients found
                </p>
                <p class="text-sm text-gray-500">
                    Try a different search term or register a new patient.
                </p>
            </div>

            <div
                v-if="
                    patients.data.length &&
                    (patients.prev_page_url || patients.next_page_url)
                "
                class="flex items-center justify-between border-t border-gray-100 px-6 py-4"
            >
                <Button
                    variant="outline"
                    size="sm"
                    :disabled="!patients.prev_page_url"
                    aria-label="Previous page"
                    @click="goTo(patients.prev_page_url)"
                >
                    <ChevronLeft class="h-4 w-4" />
                </Button>
                <span class="text-sm text-gray-500">
                    Page {{ patients.current_page }} of {{ patients.last_page }}
                </span>
                <Button
                    variant="outline"
                    size="sm"
                    :disabled="!patients.next_page_url"
                    aria-label="Next page"
                    @click="goTo(patients.next_page_url)"
                >
                    <ChevronRight class="h-4 w-4" />
                </Button>
            </div>
        </div>

        <ConfirmDeleteModal
            :show="showDelete"
            :processing="deleting"
            :message="deleteMessage"
            @confirm="deletePatient"
            @close="showDelete = false"
        />

        <Modal :show="importOpen" max-width="lg" @close="closeImport">
            <template #title>Import patients</template>

            <div class="p-6">
                <div v-if="importStep === 1" class="space-y-5">
                    <div class="space-y-3">
                        <div>
                            <h2 class="text-lg font-semibold text-gray-800">
                                Import patients
                            </h2>
                            <p class="mt-1 text-sm text-gray-500">
                                Upload a CSV file with patient demographics. Up
                                to 500 rows and 2 MB.
                            </p>
                        </div>
                        <div>
                            <a
                                :href="route('patients.import-template')"
                                class="inline-flex shrink-0 items-center gap-1.5 text-sm font-medium text-brand-600 hover:text-brand-700"
                            >
                                <Download class="h-4 w-4" />
                                Download template
                            </a>
                        </div>
                    </div>

                    <input
                        type="file"
                        accept=".csv,.txt"
                        class="block w-full cursor-pointer rounded-lg border border-gray-300 text-sm text-gray-700 file:mr-3 file:cursor-pointer file:rounded-l-lg file:border-0 file:bg-gray-100 file:px-4 file:py-2.5 file:text-sm file:font-medium file:text-gray-600 hover:file:bg-gray-200"
                        @change="onFileChange"
                    />

                    <p v-if="fileError" class="text-sm text-status-error">
                        {{ fileError }}
                    </p>

                    <p
                        v-if="importForm.errors.file"
                        class="text-sm text-status-error"
                    >
                        {{ importForm.errors.file }}
                    </p>

                    <div class="flex justify-end gap-3">
                        <Button variant="outline" size="sm" @click="closeImport"
                            >Cancel</Button
                        >
                        <Button
                            variant="default"
                            size="sm"
                            :disabled="
                                Boolean(
                                    importForm.processing ||
                                    !importForm.file ||
                                    fileError,
                                )
                            "
                            @click="uploadCsv"
                        >
                            <Upload class="h-4 w-4" />
                            Upload
                        </Button>
                    </div>
                </div>

                <div
                    v-if="importStep === 2 && props.importPreview"
                    class="space-y-5"
                >
                    <div>
                        <h2 class="text-lg font-semibold text-gray-800">
                            Review import
                        </h2>
                        <p class="mt-1 text-sm text-gray-500">
                            {{ props.importPreview.summary.new }} new ·
                            {{ props.importPreview.summary.duplicate }}
                            duplicates ·
                            {{ props.importPreview.summary.invalid }} invalid
                            (of {{ props.importPreview.total }} rows)
                        </p>
                    </div>

                    <div
                        class="overflow-hidden rounded-lg border border-gray-200"
                    >
                        <table class="min-w-full divide-y divide-gray-200">
                            <thead class="bg-gray-50">
                                <tr>
                                    <th
                                        class="px-4 py-2.5 text-left text-xs font-semibold tracking-wide text-gray-500 uppercase"
                                    >
                                        Row
                                    </th>
                                    <th
                                        class="px-4 py-2.5 text-left text-xs font-semibold tracking-wide text-gray-500 uppercase"
                                    >
                                        Name
                                    </th>
                                    <th
                                        class="px-4 py-2.5 text-left text-xs font-semibold tracking-wide text-gray-500 uppercase"
                                    >
                                        Status
                                    </th>
                                </tr>
                            </thead>
                            <tbody class="divide-y divide-gray-100">
                                <tr
                                    v-for="row in props.importPreview.rows"
                                    :key="row.row_number"
                                >
                                    <td
                                        class="px-4 py-2.5 text-sm text-gray-500"
                                    >
                                        {{ row.row_number }}
                                    </td>
                                    <td
                                        class="px-4 py-2.5 text-sm font-medium text-gray-800"
                                    >
                                        {{ importRowName(row) }}
                                    </td>
                                    <td class="px-4 py-2.5">
                                        <Badge
                                            size="sm"
                                            :color="
                                                importBadgeColor(row.status)
                                            "
                                        >
                                            {{ row.status }}
                                        </Badge>
                                        <p
                                            v-if="
                                                row.status === 'invalid' &&
                                                row.errors.length
                                            "
                                            class="mt-1 text-xs text-status-error"
                                        >
                                            {{ row.errors[0] }}
                                        </p>
                                    </td>
                                </tr>
                            </tbody>
                        </table>
                    </div>

                    <p
                        v-if="confirmForm.errors.token"
                        class="rounded-lg bg-status-cancelled/10 px-4 py-3 text-sm font-medium text-status-cancelled"
                    >
                        {{ confirmForm.errors.token }}
                    </p>

                    <div class="flex items-center justify-between gap-3">
                        <Button
                            variant="outline"
                            size="sm"
                            @click="importStep = 1"
                            >Back</Button
                        >
                        <Button
                            variant="default"
                            size="sm"
                            :disabled="
                                props.importPreview.summary.new === 0 ||
                                confirmForm.processing
                            "
                            @click="confirmImport"
                        >
                            Confirm import
                        </Button>
                    </div>
                </div>

                <div
                    v-if="importStep === 3 && props.importResult"
                    class="space-y-5"
                >
                    <div>
                        <h2 class="text-lg font-semibold text-gray-800">
                            Import complete
                        </h2>
                        <p class="mt-1 text-sm text-gray-500">
                            {{ props.importResult.imported }} imported ·
                            {{ props.importResult.skipped_duplicate }} skipped ·
                            {{ props.importResult.failed }} failed
                        </p>
                    </div>

                    <div class="flex justify-end">
                        <Button variant="default" size="sm" @click="closeImport"
                            >Done</Button
                        >
                    </div>
                </div>
            </div>
        </Modal>

        <Drawer :show="showFilters" @close="showFilters = false">
            <template #title>Filter patients</template>

            <div
                class="flex items-center justify-between border-b border-gray-100 px-6 py-4"
            >
                <h2 class="text-lg font-semibold text-gray-800">
                    Filter patients
                </h2>
                <button
                    type="button"
                    class="flex h-11 w-11 items-center justify-center rounded-lg text-gray-500 transition hover:bg-gray-100"
                    :aria-label="'Close filters'"
                    @click="showFilters = false"
                >
                    <X class="h-5 w-5" />
                </button>
            </div>

            <div class="space-y-5 px-6 py-5">
                <div>
                    <SelectField
                        v-model="draft.sort"
                        label="Sort by"
                        :options="sortOptions"
                    />
                </div>
                <div>
                    <RadioPills
                        v-model="draft.direction"
                        label="Direction"
                        name="filter-direction"
                        :options="directionOptions"
                    />
                </div>
                <div>
                    <SelectField
                        v-model="draft.sex"
                        label="Sex"
                        :options="sexOptions"
                        noneLabel="All sexes"
                    />
                </div>
                <div>
                    <SelectField
                        v-model="draft.civil_status"
                        label="Civil status"
                        :options="civilStatusOptions"
                        noneLabel="All statuses"
                    />
                </div>
                <div class="grid grid-cols-2 gap-3">
                    <TextInput
                        v-model="draft.age_min"
                        label="Age min"
                        type="number"
                        min="0"
                    />
                    <TextInput
                        v-model="draft.age_max"
                        label="Age max"
                        type="number"
                        min="0"
                    />
                </div>
                <div class="grid grid-cols-2 gap-3">
                    <DateField v-model="draft.date_from" label="From" />
                    <DateField v-model="draft.date_to" label="To" />
                </div>
            </div>

            <div
                class="flex items-center justify-end gap-2 border-t border-gray-100 px-6 py-4"
            >
                <Button variant="outline" size="sm" @click="clearFilters">
                    Clear
                </Button>
                <Button size="sm" @click="applyFilters">Apply</Button>
            </div>
        </Drawer>
    </div>
</template>
