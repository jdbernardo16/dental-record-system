import { afterEach, describe, expect, it } from 'vitest'
import { flushPromises, mount } from '@vue/test-utils'
import DateField from '@/Components/Fields/DateField.vue'

// The calendar popover is teleported to <body>, so tests mount with attachTo
// and query document.body for the day cells.

const mountField = (props = {}) =>
    mount(DateField, { props, attachTo: document.body })

const openPopover = async (wrapper) => {
    await wrapper.get('[data-slot="date-field-trigger"]').trigger('click')
    await flushPromises()
}

const dayTriggers = () => [...document.querySelectorAll('[data-reka-calendar-cell-trigger]')]

const dayByValue = (value) => dayTriggers().find((el) => el.getAttribute('data-value') === value)

const monthSelect = () =>
    document.querySelector('[data-slot="calendar"] select[aria-label="Select month"]')

const yearSelect = () =>
    document.querySelector('[data-slot="calendar"] select[aria-label="Select year"]')

// Native selects are teleported to <body>; drive v-model via the change event.
const changeSelect = async (el, value) => {
    el.value = value
    el.dispatchEvent(new Event('change', { bubbles: true }))
    await flushPromises()
}

afterEach(async () => {
    await new Promise((resolve) => setTimeout(resolve, 0)) // settle popper autoUpdate/rAF
    document.body.innerHTML = ''
})

describe('DateField', () => {
    it('renders the label, required asterisk and placeholder', () => {
        const wrapper = mountField({ label: 'Birth date', required: true })

        expect(wrapper.text()).toContain('Birth date')
        expect(wrapper.find('span.text-status-cancelled').text()).toBe('*')
        expect(wrapper.get('[data-slot="date-field-trigger"]').text()).toContain('Select date…')
        wrapper.unmount()
    })

    it('shows a formatted date for the given modelValue', () => {
        const wrapper = mountField({ modelValue: '2026-08-08' })

        expect(wrapper.get('[data-slot="date-field-trigger"]').text()).toContain('Aug 08, 2026')
        wrapper.unmount()
    })

    it('opens the calendar popover and renders day cells', async () => {
        const wrapper = mountField({ modelValue: '2026-08-08' })
        await openPopover(wrapper)

        // A month grid has at least 4 weeks of cells.
        expect(dayTriggers().length).toBeGreaterThan(20)
        wrapper.unmount()
    })

    it('marks the selected day with data-selected', async () => {
        const wrapper = mountField({ modelValue: '2026-08-08' })
        await openPopover(wrapper)

        const selected = dayByValue('2026-08-08')
        expect(selected).toBeTruthy()
        expect(selected.hasAttribute('data-selected')).toBe(true)
        wrapper.unmount()
    })

    it('emits the ISO date when a day is clicked and closes the popover', async () => {
        const wrapper = mountField({ modelValue: '2026-08-08' })
        await openPopover(wrapper)

        const target = dayByValue('2026-08-10')
        expect(target).toBeTruthy()
        target.click()
        await flushPromises()

        expect(wrapper.emitted('update:modelValue')?.[0]).toEqual(['2026-08-10'])
        // The popover closes after selection.
        expect(document.querySelector('[data-slot="calendar"]')).toBeNull()
        wrapper.unmount()
    })

    it('disables days outside the min/max range', async () => {
        const wrapper = mountField({
            modelValue: '2026-08-15',
            min: '2026-08-10',
            max: '2026-08-20',
        })
        await openPopover(wrapper)

        expect(dayByValue('2026-08-05').hasAttribute('data-disabled')).toBe(true)
        expect(dayByValue('2026-08-25').hasAttribute('data-disabled')).toBe(true)
        expect(dayByValue('2026-08-12').hasAttribute('data-disabled')).toBe(false)
        wrapper.unmount()
    })

    it('does not emit when a disabled day is clicked', async () => {
        const wrapper = mountField({
            modelValue: '2026-08-15',
            min: '2026-08-10',
            max: '2026-08-20',
        })
        await openPopover(wrapper)

        dayByValue('2026-08-05').click()
        await flushPromises()

        expect(wrapper.emitted('update:modelValue')).toBeUndefined()
        wrapper.unmount()
    })

    it('clears the value when Clear is clicked', async () => {
        const wrapper = mountField({ modelValue: '2026-08-08' })
        await openPopover(wrapper)

        const clear = [...document.querySelectorAll('button')].find(
            (el) => el.textContent.trim() === 'Clear',
        )
        expect(clear).toBeTruthy()
        clear.click()
        await flushPromises()

        expect(wrapper.emitted('update:modelValue')?.[0]).toEqual([null])
        wrapper.unmount()
    })

    it('renders the error message and wires aria attributes', () => {
        const wrapper = mountField({ id: 'birth_date', error: 'Birth date is required' })

        expect(wrapper.text()).toContain('Birth date is required')

        const trigger = wrapper.get('[data-slot="date-field-trigger"]')
        expect(trigger.attributes('aria-invalid')).toBe('true')
        expect(trigger.attributes('aria-describedby')).toBe('birth_date-error')
        expect(trigger.classes()).toContain('border-destructive')
        expect(wrapper.find('p#birth_date-error').text()).toBe('Birth date is required')
        wrapper.unmount()
    })

    it('renders the hint text', () => {
        const wrapper = mountField({ hint: 'MM/DD/YYYY format' })
        expect(wrapper.text()).toContain('MM/DD/YYYY format')
        wrapper.unmount()
    })

    it('disables the trigger button', () => {
        const wrapper = mountField({ disabled: true })
        expect(wrapper.get('[data-slot="date-field-trigger"]').attributes('disabled')).toBeDefined()
        wrapper.unmount()
    })

    it('renders month and year selects showing the current placeholder', async () => {
        const wrapper = mountField({ modelValue: '2026-08-08' })
        await openPopover(wrapper)

        expect(monthSelect()).toBeTruthy()
        expect(yearSelect()).toBeTruthy()
        // 12 months, January–December.
        expect(monthSelect().options).toHaveLength(12)
        expect(monthSelect().options[0].textContent).toBe('January')
        expect(monthSelect().options[11].textContent).toBe('December')
        expect(monthSelect().value).toBe('8')
        // Year range starts 120 years back (birth date use case) through today.
        expect(yearSelect().value).toBe('2026')
        expect(Number(yearSelect().options[0].value)).toBe(new Date().getFullYear() - 120)
        wrapper.unmount()
    })

    it('jumps to a target month via the month select', async () => {
        const wrapper = mountField({ modelValue: '2026-08-08' })
        await openPopover(wrapper)

        await changeSelect(monthSelect(), '3')

        expect(monthSelect().value).toBe('3')
        // The grid now renders March 2026, not August 2026.
        expect(dayByValue('2026-03-10')).toBeTruthy()
        expect(dayByValue('2026-08-10')).toBeUndefined()
        wrapper.unmount()
    })

    it('jumps to a past year via the year select and keeps it after picking a day', async () => {
        const wrapper = mountField({ modelValue: '2026-08-08' })
        await openPopover(wrapper)

        await changeSelect(yearSelect(), '1997')

        expect(yearSelect().value).toBe('1997')
        // The grid now renders August 1997.
        expect(dayByValue('1997-08-10')).toBeTruthy()
        expect(dayByValue('2026-08-10')).toBeUndefined()

        // Selecting a day still works and the placeholder follows the selection.
        dayByValue('1997-08-10').click()
        await flushPromises()
        expect(wrapper.emitted('update:modelValue')?.[0]).toEqual(['1997-08-10'])

        // Re-opening the calendar shows the picked month/year in the selects.
        await wrapper.get('[data-slot="date-field-trigger"]').trigger('click')
        await flushPromises()
        expect(yearSelect().value).toBe('1997')
        expect(monthSelect().value).toBe('8')
        wrapper.unmount()
    })
})
