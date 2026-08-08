<script setup>
import { Button } from '@/Components/ui/button'
import { TextInput } from '@/Components/Fields'
import Modal from '@/Components/Modal.vue'
import { useForm } from '@inertiajs/vue3'
import { nextTick, ref } from 'vue'

const confirmingUserDeletion = ref(false)
const passwordInput = ref(null)

const form = useForm({
    password: '',
})

const confirmUserDeletion = () => {
    confirmingUserDeletion.value = true

    nextTick(() => passwordInput.value.focus())
}

const deleteUser = () => {
    form.delete(route('profile.destroy'), {
        preserveScroll: true,
        onSuccess: () => closeModal(),
        onError: () => passwordInput.value.focus(),
        onFinish: () => form.reset(),
    })
}

const closeModal = () => {
    confirmingUserDeletion.value = false

    form.clearErrors()
    form.reset()
}
</script>

<template>
    <section class="space-y-6">
        <header>
            <h2 class="text-lg font-medium text-gray-900">
                Delete Account
            </h2>

            <p class="mt-1 text-sm text-gray-600">
                Once your account is deleted, all of its resources and data will
                be permanently deleted. Before deleting your account, please
                download any data or information that you wish to retain.
            </p>
        </header>

        <Button variant="destructive" @click="confirmUserDeletion">
            Delete Account
        </Button>

        <Modal :show="confirmingUserDeletion" @close="closeModal">
            <div class="p-6">
                <h2
                    class="text-lg font-medium text-gray-900"
                >
                    Are you sure you want to delete your account?
                </h2>

                <p class="mt-1 text-sm text-gray-600">
                    Once your account is deleted, all of its resources and data
                    will be permanently deleted. Please enter your password to
                    confirm you would like to permanently delete your account.
                </p>

                <div class="mt-6 w-3/4">
                    <TextInput
                        ref="passwordInput"
                        v-model="form.password"
                        label="Password"
                        type="password"
                        placeholder="Password"
                        :error="form.errors.password"
                        @keyup.enter="deleteUser"
                    />
                </div>

                <div class="mt-6 flex justify-end">
                    <Button variant="outline" @click="closeModal">
                        Cancel
                    </Button>

                    <Button
                        class="ms-3"
                        variant="destructive"
                        :disabled="form.processing"
                        @click="deleteUser"
                    >
                        {{ form.processing ? '…' : 'Delete Account' }}
                    </Button>
                </div>
            </div>
        </Modal>
    </section>
</template>
