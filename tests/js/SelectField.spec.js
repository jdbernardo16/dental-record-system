import { afterEach, describe, expect, it } from 'vitest'
import { flushPromises, mount } from '@vue/test-utils'
import SelectField from '@/Components/Fields/SelectField.vue'

// reka-ui SelectContent is teleported to <body> and only mounts while the
// popover is open, so tests mount with attachTo and query document.body.
// reka-ui's Select opens on pointerdown and selects items via its internal
// `select.select` custom event. In happy-dom, dispatching a synthetic
// `pointerup` does not trigger reka's listener, so tests use the keyboard
// path (keydown Enter on the item) which exercises the same select flow.

const options = [
    { value: 'admin', label: 'Administrator' },
    { value: 'dentist', label: 'Dentist' },
    { value: 'frontdesk', label: 'Front Desk' },
]

const mountField = (props = {}) =>
    mount(SelectField, { props: { options, ...props }, attachTo: document.body })

const openSelect = async (wrapper) => {
    const trigger = wrapper.get('[data-slot="select-trigger"]').element
    trigger.dispatchEvent(new MouseEvent('pointerdown', { button: 0, bubbles: true, cancelable: true }))
    await flushPromises()
}

const selectItem = async (label) => {
    const item = [...document.querySelectorAll('[data-slot="select-item"]')].find(
        (el) => el.textContent.trim() === label,
    )
    expect(item).toBeTruthy()
    item.dispatchEvent(new KeyboardEvent('keydown', { key: 'Enter', bubbles: true, cancelable: true }))
    await flushPromises()
}

afterEach(async () => {
    await new Promise((resolve) => setTimeout(resolve, 0)) // settle popper autoUpdate/rAF
    document.body.innerHTML = ''
})

describe('SelectField', () => {
    it('renders the label and required asterisk', () => {
        const wrapper = mountField({ label: 'Role', required: true })

        expect(wrapper.text()).toContain('Role')
        expect(wrapper.find('span.text-status-cancelled').text()).toBe('*')
        wrapper.unmount()
    })

    it('renders all options with their labels after opening', async () => {
        const wrapper = mountField({ label: 'Role' })
        await openSelect(wrapper)

        const items = [...document.querySelectorAll('[data-slot="select-item"]')]
        expect(items.map((el) => el.textContent.trim())).toEqual([
            'Administrator',
            'Dentist',
            'Front Desk',
        ])
        wrapper.unmount()
    })

    it('shows the placeholder when no value is set', () => {
        const wrapper = mountField({ placeholder: 'Pick one' })
        expect(wrapper.get('[data-slot="select-trigger"]').text()).toContain('Pick one')
        wrapper.unmount()
    })

    it('shows the selected label in the trigger once options are mounted', async () => {
        const wrapper = mountField({ modelValue: 'dentist' })
        await openSelect(wrapper)

        expect(wrapper.get('[data-slot="select-trigger"]').text()).toContain('Dentist')
        wrapper.unmount()
    })

    it('emits update:modelValue with the selected value', async () => {
        const wrapper = mountField()
        await openSelect(wrapper)
        await selectItem('Dentist')

        expect(wrapper.emitted('update:modelValue')?.[0]).toEqual(['dentist'])
        wrapper.unmount()
    })

    it('shows the none label in the trigger when noneLabel is set and the value is empty', async () => {
        const wrapper = mountField({ noneLabel: 'No dentist assigned' })
        await openSelect(wrapper)

        expect(wrapper.get('[data-slot="select-trigger"]').text()).toContain('No dentist assigned')
        wrapper.unmount()
    })

    it('emits an empty string when the none item is selected', async () => {
        const wrapper = mountField({ noneLabel: 'None' })
        await openSelect(wrapper)
        await selectItem('None')

        expect(wrapper.emitted('update:modelValue')?.[0]).toEqual([''])
        wrapper.unmount()
    })

    it('renders the none item unselected and the trigger label when a real value is selected', async () => {
        const wrapper = mountField({ modelValue: 'dentist', noneLabel: 'No dentist assigned' })
        await openSelect(wrapper)

        const items = [...document.querySelectorAll('[data-slot="select-item"]')]
        expect(items.map((el) => el.textContent.trim())).toEqual([
            'No dentist assigned',
            'Administrator',
            'Dentist',
            'Front Desk',
        ])

        const noneItem = items.find((el) => el.textContent.trim() === 'No dentist assigned')
        expect(noneItem.getAttribute('data-state')).toBe('unchecked')
        expect(wrapper.get('[data-slot="select-trigger"]').text()).toContain('Dentist')
        wrapper.unmount()
    })

    it('shows the placeholder when the value is empty and no noneLabel is given', async () => {
        const wrapper = mountField({ modelValue: '', placeholder: 'Pick one' })
        await openSelect(wrapper)

        expect(wrapper.get('[data-slot="select-trigger"]').text()).toContain('Pick one')
        wrapper.unmount()
    })

    it('renders grouped options inside optgroups', async () => {
        const grouped = [
            { value: 'php', label: 'PHP', group: 'Languages' },
            { value: 'js', label: 'JavaScript', group: 'Languages' },
            { value: 'other', label: 'Other' },
        ]
        const wrapper = mountField({ options: grouped })
        await openSelect(wrapper)

        const labels = [...document.querySelectorAll('[data-slot="select-label"]')].map(
            (el) => el.textContent.trim(),
        )
        expect(labels).toEqual(['Languages'])
        wrapper.unmount()
    })

    it('renders the error message and wires aria attributes', () => {
        const wrapper = mountField({ id: 'role', error: 'Role is required' })

        expect(wrapper.text()).toContain('Role is required')

        const trigger = wrapper.get('[data-slot="select-trigger"]')
        expect(trigger.attributes('aria-invalid')).toBe('true')
        expect(trigger.attributes('aria-describedby')).toBe('role-error')
        expect(trigger.classes()).toContain('border-destructive')
        expect(wrapper.find('p#role-error').text()).toBe('Role is required')
        wrapper.unmount()
    })

    it('renders the hint text', () => {
        const wrapper = mountField({ hint: 'Assign a clinic role' })
        expect(wrapper.text()).toContain('Assign a clinic role')
        wrapper.unmount()
    })
})
