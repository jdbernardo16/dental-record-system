import { describe, expect, it } from 'vitest'
import { mount } from '@vue/test-utils'
import CheckboxField from '@/Components/Fields/CheckboxField.vue'

describe('CheckboxField', () => {
    it('renders the label next to the checkbox', () => {
        const wrapper = mount(CheckboxField, { props: { label: 'Send reminders' } })

        expect(wrapper.text()).toContain('Send reminders')
        expect(wrapper.get('[role="checkbox"]').exists()).toBe(true)
    })

    it('toggles modelValue when clicked', async () => {
        const wrapper = mount(CheckboxField, { props: { modelValue: false } })

        await wrapper.get('[role="checkbox"]').trigger('click')
        expect(wrapper.emitted('update:modelValue')?.[0]).toEqual([true])

        await wrapper.setProps({ modelValue: true })
        await wrapper.get('[role="checkbox"]').trigger('click')
        expect(wrapper.emitted('update:modelValue')?.[1]).toEqual([false])
    })

    it('renders the error message and wires aria attributes', () => {
        const wrapper = mount(CheckboxField, { props: { id: 'reminders', error: 'Required' } })

        expect(wrapper.text()).toContain('Required')

        const checkbox = wrapper.get('[role="checkbox"]')
        expect(checkbox.attributes('aria-invalid')).toBe('true')
        expect(checkbox.attributes('aria-describedby')).toBe('reminders-error')
        expect(wrapper.find('p#reminders-error').text()).toBe('Required')
    })

    it('renders the hint text', () => {
        const wrapper = mount(CheckboxField, { props: { hint: 'We will text you' } })
        expect(wrapper.text()).toContain('We will text you')
    })

    it('disables the checkbox', () => {
        const wrapper = mount(CheckboxField, { props: { disabled: true } })
        expect(wrapper.get('[role="checkbox"]').attributes('disabled')).toBeDefined()
    })
})
