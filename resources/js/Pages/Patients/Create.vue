<script setup>
import { Head, Link, useForm } from '@inertiajs/vue3'
import { route } from '../../../../vendor/tightenco/ziggy'
import AppLayout from '@/Layouts/AppLayout.vue'
import { Button } from '@/Components/ui/button'
import FormField from '@/Components/FormField.vue'
import { Input } from '@/Components/ui/input'
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from '@/Components/ui/select'
import { useToastStore } from '@/Stores/toast'

defineOptions({ layout: AppLayout })

const props = defineProps({
    sexOptions: { type: Array, required: true },
    civilStatusOptions: { type: Array, required: true },
})

const toastStore = useToastStore()

const form = useForm({
    first_name: '',
    middle_name: '',
    last_name: '',
    sex: '',
    birth_date: '',
    civil_status: '',
    nationality: 'Filipino',
    occupation: '',
    contact_number: '',
    address: '',
    email_address: '',
    emergency_contact_person: '',
    emergency_contact_number: '',
    religion: '',
    nickname: '',
    home_phone: '',
    office_phone: '',
    fax_number: '',
    dental_insurance: '',
    effective_date: '',
    guardian_name: '',
    guardian_occupation: '',
})

const submit = () => {
    form.post(route('patients.store'), {
        preserveScroll: true,
        onSuccess: () => toastStore.show('Patient registered.'),
    })
}
</script>

<template>
    <Head title="Register patient" />

    <div class="mx-auto max-w-2xl space-y-6">
        <div>
            <h1 class="text-2xl font-semibold text-gray-800">Register patient</h1>
            <p class="mt-1 text-sm text-gray-500">Enter the patient's personal and contact details.</p>
        </div>

        <form class="space-y-6 rounded-2xl border border-gray-200 bg-white p-6 shadow-sm" @submit.prevent="submit">
            <section class="space-y-5">
                <h2 class="text-sm font-semibold text-gray-800">Identity</h2>
                <FormField id="first_name" label="First name" required :error="form.errors.first_name">
                    <template #default="{ id }">
                        <Input
                            :id="id"
                            v-model="form.first_name"
                            placeholder="Liza"
                            required
                            autofocus
                            :aria-invalid="form.errors.first_name ? 'true' : 'false'"
                        />
                    </template>
                </FormField>
                <FormField id="middle_name" label="Middle name" :error="form.errors.middle_name">
                    <template #default="{ id }">
                        <Input
                            :id="id"
                            v-model="form.middle_name"
                            placeholder="Optional"
                            :aria-invalid="form.errors.middle_name ? 'true' : 'false'"
                        />
                    </template>
                </FormField>
                <FormField id="last_name" label="Last name" required :error="form.errors.last_name">
                    <template #default="{ id }">
                        <Input
                            :id="id"
                            v-model="form.last_name"
                            placeholder="Reyes"
                            required
                            :aria-invalid="form.errors.last_name ? 'true' : 'false'"
                        />
                    </template>
                </FormField>
                <FormField id="sex" label="Sex" required :error="form.errors.sex">
                    <template #default="{ id }">
                        <Select v-model="form.sex" name="sex" required>
                            <SelectTrigger
                                :id="id"
                                class="w-full"
                                :aria-invalid="form.errors.sex ? 'true' : 'false'"
                            >
                                <SelectValue placeholder="Select sex" />
                            </SelectTrigger>
                            <SelectContent>
                                <SelectItem v-for="option in sexOptions" :key="option.value" :value="option.value">
                                    {{ option.label }}
                                </SelectItem>
                            </SelectContent>
                        </Select>
                    </template>
                </FormField>
                <FormField id="birth_date" label="Birth date" required :error="form.errors.birth_date">
                    <template #default="{ id }">
                        <Input
                            :id="id"
                            v-model="form.birth_date"
                            type="date"
                            required
                            :aria-invalid="form.errors.birth_date ? 'true' : 'false'"
                        />
                    </template>
                </FormField>
                <FormField id="civil_status" label="Civil status" required :error="form.errors.civil_status">
                    <template #default="{ id }">
                        <Select v-model="form.civil_status" name="civil_status" required>
                            <SelectTrigger
                                :id="id"
                                class="w-full"
                                :aria-invalid="form.errors.civil_status ? 'true' : 'false'"
                            >
                                <SelectValue placeholder="Select civil status" />
                            </SelectTrigger>
                            <SelectContent>
                                <SelectItem
                                    v-for="option in civilStatusOptions"
                                    :key="option.value"
                                    :value="option.value"
                                >
                                    {{ option.label }}
                                </SelectItem>
                            </SelectContent>
                        </Select>
                    </template>
                </FormField>
                <FormField id="nationality" label="Nationality" required :error="form.errors.nationality">
                    <template #default="{ id }">
                        <Input
                            :id="id"
                            v-model="form.nationality"
                            required
                            :aria-invalid="form.errors.nationality ? 'true' : 'false'"
                        />
                    </template>
                </FormField>
            </section>

            <hr class="border-gray-100" />

            <section class="space-y-5">
                <h2 class="text-sm font-semibold text-gray-800">Contact</h2>
                <FormField id="occupation" label="Occupation" :error="form.errors.occupation">
                    <template #default="{ id }">
                        <Input
                            :id="id"
                            v-model="form.occupation"
                            placeholder="Optional"
                            :aria-invalid="form.errors.occupation ? 'true' : 'false'"
                        />
                    </template>
                </FormField>
                <FormField id="contact_number" label="Contact number" required :error="form.errors.contact_number">
                    <template #default="{ id }">
                        <Input
                            :id="id"
                            v-model="form.contact_number"
                            placeholder="0917 123 4567"
                            required
                            :aria-invalid="form.errors.contact_number ? 'true' : 'false'"
                        />
                    </template>
                </FormField>
                <FormField id="address" label="Address" required :error="form.errors.address">
                    <template #default="{ id }">
                        <Input
                            :id="id"
                            v-model="form.address"
                            placeholder="House number, street, barangay, city"
                            required
                            :aria-invalid="form.errors.address ? 'true' : 'false'"
                        />
                    </template>
                </FormField>
                <FormField id="email_address" label="Email address" :error="form.errors.email_address">
                    <template #default="{ id }">
                        <Input
                            :id="id"
                            v-model="form.email_address"
                            type="email"
                            placeholder="Optional"
                            :aria-invalid="form.errors.email_address ? 'true' : 'false'"
                        />
                    </template>
                </FormField>
            </section>

            <hr class="border-gray-100" />

            <section class="space-y-5">
                <h2 class="text-sm font-semibold text-gray-800">Emergency contact</h2>
                <FormField
                    id="emergency_contact_person"
                    label="Contact person"
                    required
                    :error="form.errors.emergency_contact_person"
                >
                    <template #default="{ id }">
                        <Input
                            :id="id"
                            v-model="form.emergency_contact_person"
                            placeholder="John Reyes"
                            required
                            :aria-invalid="form.errors.emergency_contact_person ? 'true' : 'false'"
                        />
                    </template>
                </FormField>
                <FormField
                    id="emergency_contact_number"
                    label="Contact number"
                    required
                    :error="form.errors.emergency_contact_number"
                >
                    <template #default="{ id }">
                        <Input
                            :id="id"
                            v-model="form.emergency_contact_number"
                            placeholder="0917 987 6543"
                            required
                            :aria-invalid="form.errors.emergency_contact_number ? 'true' : 'false'"
                        />
                    </template>
                </FormField>
            </section>

            <hr class="border-gray-100" />

            <section class="space-y-5">
                <h2 class="text-sm font-semibold text-gray-800">PDA additional details</h2>
                <p class="text-xs text-gray-500">Optional fields from the PDA patient information record.</p>
                <FormField id="religion" label="Religion" :error="form.errors.religion">
                    <template #default="{ id }">
                        <Input
                            :id="id"
                            v-model="form.religion"
                            placeholder="Optional"
                            :aria-invalid="form.errors.religion ? 'true' : 'false'"
                        />
                    </template>
                </FormField>
                <FormField id="nickname" label="Nickname" :error="form.errors.nickname">
                    <template #default="{ id }">
                        <Input
                            :id="id"
                            v-model="form.nickname"
                            placeholder="Optional"
                            :aria-invalid="form.errors.nickname ? 'true' : 'false'"
                        />
                    </template>
                </FormField>
                <FormField id="home_phone" label="Home phone" :error="form.errors.home_phone">
                    <template #default="{ id }">
                        <Input
                            :id="id"
                            v-model="form.home_phone"
                            placeholder="02 8123 4567"
                            :aria-invalid="form.errors.home_phone ? 'true' : 'false'"
                        />
                    </template>
                </FormField>
                <FormField id="office_phone" label="Office phone" :error="form.errors.office_phone">
                    <template #default="{ id }">
                        <Input
                            :id="id"
                            v-model="form.office_phone"
                            placeholder="02 8765 4321"
                            :aria-invalid="form.errors.office_phone ? 'true' : 'false'"
                        />
                    </template>
                </FormField>
                <FormField id="fax_number" label="Fax number" :error="form.errors.fax_number">
                    <template #default="{ id }">
                        <Input
                            :id="id"
                            v-model="form.fax_number"
                            placeholder="Optional"
                            :aria-invalid="form.errors.fax_number ? 'true' : 'false'"
                        />
                    </template>
                </FormField>
                <FormField id="dental_insurance" label="Dental insurance" :error="form.errors.dental_insurance">
                    <template #default="{ id }">
                        <Input
                            :id="id"
                            v-model="form.dental_insurance"
                            placeholder="e.g. PhilHealth"
                            :aria-invalid="form.errors.dental_insurance ? 'true' : 'false'"
                        />
                    </template>
                </FormField>
                <FormField id="effective_date" label="Effective date" :error="form.errors.effective_date">
                    <template #default="{ id }">
                        <Input
                            :id="id"
                            v-model="form.effective_date"
                            type="date"
                            :aria-invalid="form.errors.effective_date ? 'true' : 'false'"
                        />
                    </template>
                </FormField>
                <FormField id="guardian_name" label="Guardian name" :error="form.errors.guardian_name">
                    <template #default="{ id }">
                        <Input
                            :id="id"
                            v-model="form.guardian_name"
                            placeholder="For minors"
                            :aria-invalid="form.errors.guardian_name ? 'true' : 'false'"
                        />
                    </template>
                </FormField>
                <FormField id="guardian_occupation" label="Guardian occupation" :error="form.errors.guardian_occupation">
                    <template #default="{ id }">
                        <Input
                            :id="id"
                            v-model="form.guardian_occupation"
                            placeholder="For minors"
                            :aria-invalid="form.errors.guardian_occupation ? 'true' : 'false'"
                        />
                    </template>
                </FormField>
            </section>

            <div class="flex items-center justify-end gap-3 pt-2">
                <Link :href="route('patients.index')">
                    <Button variant="outline" :disabled="form.processing">Cancel</Button>
                </Link>
                <Button type="submit" :disabled="form.processing">
                    {{ form.processing ? 'Saving…' : 'Register patient' }}
                </Button>
            </div>
        </form>
    </div>
</template>
