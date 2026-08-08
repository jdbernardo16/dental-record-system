import { describe, expect, it } from 'vitest'
import { mount } from '@vue/test-utils'
import CheckboxGroup from '@/Components/Fields/CheckboxGroup.vue'

const options = [
    { value: 'hypertension', label: 'Hypertension' },
    { value: 'diabetes', label: 'Diabetes' },
    { value: 'asthma', label: 'Asthma' },
]

describe('CheckboxGroup', () => {
    it('renders the options with labels', () => {
        const wrapper = mount(CheckboxGroup, { props: { options } })

        expect(wrapper.text()).toContain('Hypertension')
        expect(wrapper.text()).toContain('Diabetes')
        expect(wrapper.text()).toContain('Asthma')
        expect(wrapper.findAll('[role="checkbox"]')).toHaveLength(3)
    })

    it('emits an array with the value added when toggling an unchecked option', async () => {
        const wrapper = mount(CheckboxGroup, { props: { options, modelValue: [] } })

        await wrapper.findAll('[role="checkbox"]')[0].trigger('click')
        expect(wrapper.emitted('update:modelValue')?.[0]).toEqual([['hypertension']])
    })

    it('emits an array with the value removed when toggling a checked option', async () => {
        const wrapper = mount(CheckboxGroup, {
            props: { options, modelValue: ['hypertension', 'asthma'] },
        })

        await wrapper.findAll('[role="checkbox"]')[0].trigger('click')
        expect(wrapper.emitted('update:modelValue')?.[0]).toEqual([['asthma']])
    })

    it('renders the label with the required asterisk', () => {
        const wrapper = mount(CheckboxGroup, { props: { options, label: 'Conditions', required: true } })

        expect(wrapper.text()).toContain('Conditions')
        expect(wrapper.text()).toContain('*')
    })

    it('renders the error message and wires aria attributes', () => {
        const wrapper = mount(CheckboxGroup, { props: { options, name: 'conditions', error: 'Required' } })

        expect(wrapper.text()).toContain('Required')

        const group = wrapper.get('[role="group"]')
        expect(group.attributes('aria-invalid')).toBe('true')
        expect(group.attributes('aria-describedby')).toBe('conditions-error')

        const checkbox = wrapper.get('[role="checkbox"]')
        expect(checkbox.attributes('aria-invalid')).toBe('true')
        expect(checkbox.attributes('aria-describedby')).toBe('conditions-error')

        expect(wrapper.find('p#conditions-error').text()).toBe('Required')
    })

    it('renders the hint text', () => {
        const wrapper = mount(CheckboxGroup, { props: { options, hint: 'Select all that apply' } })
        expect(wrapper.text()).toContain('Select all that apply')
    })
})
