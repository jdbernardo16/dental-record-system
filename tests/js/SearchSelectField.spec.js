import { afterEach, describe, expect, it } from 'vitest'
import { flushPromises, mount } from '@vue/test-utils'
import SearchSelectField from '@/Components/Fields/SearchSelectField.vue'

// reka-ui ComboboxContent is teleported to <body> and only mounts while the
// popover is open, so tests mount with attachTo and query document.body.
// reka-ui's Combobox opens on input focus; item selection and filtering use
// the internal Listbox machinery, so tests drive the keyboard path (keydown
// Enter on the item) which exercises the same select flow as SelectField.

const options = [
    { value: 1, label: 'Dela Cruz, Juan — 2026-0001' },
    { value: 2, label: 'Santos, Maria — 2026-0002' },
    { value: 3, label: 'Reyes, Ana — 2026-0003' },
]

let wrapper
const mountField = (props = {}) => {
    wrapper = mount(SearchSelectField, {
        props: { options, ...props },
        attachTo: document.body,
    })
    return wrapper
}

const openList = async (wrapper) => {
    const input = wrapper.get('input')
    await input.trigger('focus')
    await flushPromises()
}

const selectItem = async (label) => {
    const item = [...document.querySelectorAll('[data-slot="combobox-item"]')].find(
        (el) => el.textContent.trim() === label,
    )
    expect(item).toBeTruthy()
    item.dispatchEvent(new MouseEvent('click', { bubbles: true, cancelable: true, button: 0 }))
    await flushPromises()
}

afterEach(async () => {
    wrapper?.unmount()
    wrapper = null
    await new Promise((resolve) => setTimeout(resolve, 20)) // settle popper autoUpdate/rAF
    document.body.innerHTML = ''
})

describe('SearchSelectField', () => {
    it('shows the label, placeholder and renders options when opened', async () => {
        const wrapper = mountField({ label: 'Patient', placeholder: 'Search…' })
        expect(wrapper.text()).toContain('Patient')

        await openList(wrapper)
        const items = [...document.querySelectorAll('[data-slot="combobox-item"]')]
        expect(items.map((el) => el.textContent.trim())).toEqual([
            'Dela Cruz, Juan — 2026-0001',
            'Santos, Maria — 2026-0002',
            'Reyes, Ana — 2026-0003',
        ])
    })

    it('emits update:modelValue with the selected value', async () => {
        const wrapper = mountField()
        await openList(wrapper)
        await selectItem('Santos, Maria — 2026-0002')
        expect(wrapper.emitted('update:modelValue')).toEqual([[2]])
    })

    it('shows the selected label in the input and renders a clear button', async () => {
        const wrapper = mountField({ modelValue: 3 })
        const input = wrapper.get('input').element
        expect(input.value).toBe('Reyes, Ana — 2026-0003')
        expect(wrapper.get('button[aria-label="Clear selection"]')).toBeTruthy()
    })

    it('clears the selection when the X button is clicked', async () => {
        const wrapper = mountField({ modelValue: 1 })
        await wrapper.get('button[aria-label="Clear selection"]').trigger('click')
        expect(wrapper.emitted('update:modelValue')).toEqual([['']])
    })

    it('shows an error message when provided', () => {
        const wrapper = mountField({ error: 'Please choose a patient.' })
        expect(wrapper.text()).toContain('Please choose a patient.')
        expect(wrapper.get('input').attributes('aria-invalid')).toBe('true')
    })
})
