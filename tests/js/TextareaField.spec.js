import { describe, expect, it } from 'vitest'
import { mount } from '@vue/test-utils'
import TextareaField from '@/Components/Fields/TextareaField.vue'

describe('TextareaField', () => {
    it('renders the label and required asterisk', () => {
        const wrapper = mount(TextareaField, { props: { label: 'Complaint', required: true } })

        expect(wrapper.text()).toContain('Complaint')
        expect(wrapper.find('span.text-status-cancelled').text()).toBe('*')
        expect(wrapper.find('label').attributes('for')).toBe(
            wrapper.find('textarea').attributes('id'),
        )
    })

    it('supports v-model two-way binding', async () => {
        const wrapper = mount(TextareaField, { props: { modelValue: 'toothache' } })

        const textarea = wrapper.find('textarea')
        expect(textarea.element.value).toBe('toothache')

        await textarea.setValue('pain on the lower right')
        expect(wrapper.emitted('update:modelValue')?.[0]).toEqual(['pain on the lower right'])
    })

    it('renders the error message and wires aria attributes', () => {
        const wrapper = mount(TextareaField, { props: { id: 'complaint', error: 'Required' } })

        expect(wrapper.text()).toContain('Required')

        const textarea = wrapper.find('textarea')
        expect(textarea.attributes('aria-invalid')).toBe('true')
        expect(textarea.attributes('aria-describedby')).toBe('complaint-error')
        expect(wrapper.find('p#complaint-error').text()).toBe('Required')
        expect(textarea.classes()).toContain('border-destructive')
    })

    it('renders the hint text', () => {
        const wrapper = mount(TextareaField, { props: { hint: 'Describe the symptoms' } })
        expect(wrapper.text()).toContain('Describe the symptoms')
    })

    it('uses the rows prop', () => {
        const wrapper = mount(TextareaField, { props: { rows: 6 } })
        expect(wrapper.find('textarea').attributes('rows')).toBe('6')
    })

    it('disables the textarea', () => {
        const wrapper = mount(TextareaField, { props: { disabled: true } })
        expect(wrapper.find('textarea').attributes('disabled')).toBeDefined()
    })

    it('renders the placeholder', () => {
        const wrapper = mount(TextareaField, { props: { placeholder: 'Optional notes…' } })
        expect(wrapper.find('textarea').attributes('placeholder')).toBe('Optional notes…')
    })
})
