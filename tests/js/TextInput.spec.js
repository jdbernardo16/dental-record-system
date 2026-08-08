import { describe, expect, it } from 'vitest'
import { mount } from '@vue/test-utils'
import TextInput from '@/Components/Fields/TextInput.vue'

describe('TextInput', () => {
    it('renders the label and required asterisk', () => {
        const wrapper = mount(TextInput, { props: { label: 'First name', required: true } })

        expect(wrapper.text()).toContain('First name')
        expect(wrapper.find('span.text-status-cancelled').text()).toBe('*')
        expect(wrapper.find('label').attributes('for')).toBe(
            wrapper.find('input').attributes('id'),
        )
    })

    it('does not render a label when none is given', () => {
        const wrapper = mount(TextInput)
        expect(wrapper.find('label').exists()).toBe(false)
    })

    it('supports v-model two-way binding', async () => {
        const wrapper = mount(TextInput, { props: { modelValue: 'hello' } })

        const input = wrapper.find('input')
        expect(input.element.value).toBe('hello')

        await input.setValue('world')
        expect(wrapper.emitted('update:modelValue')?.[0]).toEqual(['world'])
    })

    it('renders the error message and wires aria attributes', () => {
        const wrapper = mount(TextInput, { props: { id: 'name', error: 'Name is required' } })

        expect(wrapper.text()).toContain('Name is required')

        const input = wrapper.find('input')
        expect(input.attributes('aria-invalid')).toBe('true')
        expect(input.attributes('aria-describedby')).toBe('name-error')
        expect(wrapper.find('p#name-error').text()).toBe('Name is required')
        expect(input.classes()).toContain('border-destructive')
    })

    it('renders the hint text', () => {
        const wrapper = mount(TextInput, { props: { hint: 'As shown on your ID' } })
        expect(wrapper.text()).toContain('As shown on your ID')
    })

    it('disables the input', () => {
        const wrapper = mount(TextInput, { props: { disabled: true } })
        expect(wrapper.find('input').attributes('disabled')).toBeDefined()
    })

    it('renders the placeholder', () => {
        const wrapper = mount(TextInput, { props: { placeholder: 'Juan' } })
        expect(wrapper.find('input').attributes('placeholder')).toBe('Juan')
    })

    it('forwards native attributes to the input element', () => {
        const wrapper = mount(TextInput, {
            props: { type: 'number', min: '1', max: '10', step: '1' },
            attrs: { autocomplete: 'off' },
        })

        const input = wrapper.find('input')
        expect(input.attributes('autocomplete')).toBe('off')
        expect(input.attributes('min')).toBe('1')
        expect(input.attributes('max')).toBe('10')
        expect(input.attributes('step')).toBe('1')
    })

    it('exposes a focus() method that focuses the input', async () => {
        const wrapper = mount(TextInput, { attachTo: document.body })

        wrapper.vm.focus()
        await wrapper.vm.$nextTick()

        expect(document.activeElement).toBe(wrapper.find('input').element)
        wrapper.unmount()
    })
})
