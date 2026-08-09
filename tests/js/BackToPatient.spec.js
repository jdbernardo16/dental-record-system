import { describe, expect, it, vi } from 'vitest'
import { mount } from '@vue/test-utils'
import { defineComponent } from 'vue'

vi.mock('../../vendor/tightenco/ziggy', () => ({
    route: (name, params) => {
        if (name === 'patients.show') return `/patients/${params}`
        return `/${String(name).replace(/\./g, '/')}`
    },
}))

import BackToPatient from '../../resources/js/Components/BackToPatient.vue'

const LinkStub = defineComponent({
    name: 'Link',
    props: { href: { type: String, required: true } },
    template: '<a :href="href"><slot /></a>',
})

const mountBackToPatient = (props = {}) =>
    mount(BackToPatient, {
        props: { patientId: 42, ...props },
        global: { stubs: { Link: LinkStub } },
    })

describe('BackToPatient', () => {
    it('renders a link back to the given patient record', () => {
        const wrapper = mountBackToPatient()

        const link = wrapper.get('a')
        expect(link.attributes('href')).toContain('/patients/42')
        expect(link.text()).toContain('Back to patient')
    })
})
