import { defineStore } from 'pinia'

export const useWizardStore = defineStore('wizard', {
    state: () => ({
        step: 0,
        patientId: null,
        completed: {}, // stepKey -> true
    }),
    actions: {
        start(patientId, resumeStep) {
            this.patientId = patientId
            this.step = resumeStep
            this.completed = {}
        },
        go(step) {
            this.step = step
        },
        markComplete(stepKey) {
            this.completed[stepKey] = true
        },
        reset() {
            this.step = 0
            this.patientId = null
            this.completed = {}
        },
    },
})
