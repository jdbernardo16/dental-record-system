import { describe, expect, it } from 'vitest'
import { mount } from '@vue/test-utils'
import RadioPills from '@/Components/Fields/RadioPills.vue'

const options = [
    { value: 'M', label: 'Male' },
    { value: 'F', label: 'Female' },
]

describe('RadioPills', () => {
    it('renders the label, required asterisk and all options', () => {
        const wrapper = mount(RadioPills, {
            props: { label: 'Sex', required: true, options },
        })

        expect(wrapper.text()).toContain('Sex')
        expect(wrapper.find('span.text-status-cancelled').text()).toBe('*')
        expect(wrapper.findAll('[role="radio"]').length).toBe(2)
        expect(wrapper.text()).toContain('Male')
        expect(wrapper.text()).toContain('Female')
    })

    it('marks the matching option as checked', () => {
        const wrapper = mount(RadioPills, { props: { modelValue: 'F', options } })

        const radios = wrapper.findAll('[role="radio"]')
        expect(radios[0].attributes('aria-checked')).toBe('false')
        expect(radios[1].attributes('aria-checked')).toBe('true')
    })

    it('disables all option buttons when disabled is set', () => {
        const wrapper = mount(RadioPills, { props: { options, disabled: true } })

        const radios = wrapper.findAll('[role="radio"]')
        expect(radios).toHaveLength(2)
        expect(radios.every((r) => r.attributes('disabled') !== undefined)).toBe(true)
        expect(radios.every((r) => r.classes().includes('disabled:cursor-not-allowed'))).toBe(true)
    })

    it('emits update:modelValue with the clicked option value', async () => {
        const wrapper = mount(RadioPills, { props: { modelValue: 'M', options } })

        await wrapper.findAll('[role="radio"]')[1].trigger('click')
        expect(wrapper.emitted('update:modelValue')?.[0]).toEqual(['F'])
    })

    it('applies the selected pill styling to the active option', () => {
        const wrapper = mount(RadioPills, { props: { modelValue: 'M', options } })

        const radios = wrapper.findAll('[role="radio"]')
        expect(radios[0].classes()).toContain('bg-white')
        expect(radios[0].classes()).toContain('shadow-sm')
        expect(radios[1].classes()).toContain('text-gray-500')
        expect(radios[1].classes()).not.toContain('bg-white')
    })

    it('renders the error message and wires aria attributes', () => {
        const wrapper = mount(RadioPills, { props: { options, error: 'Pick one' } })

        expect(wrapper.text()).toContain('Pick one')

        const group = wrapper.get('[role="radiogroup"]')
        expect(group.attributes('aria-invalid')).toBe('true')
        expect(wrapper.find('[role="radiogroup"] p').exists()).toBe(false) // error is outside the group
        expect(wrapper.text()).toContain('Pick one')
    })

    it('renders the hint text', () => {
        const wrapper = mount(RadioPills, { props: { options, hint: 'As on the birth certificate' } })
        expect(wrapper.text()).toContain('As on the birth certificate')
    })
})
