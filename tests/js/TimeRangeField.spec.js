import { afterEach, describe, expect, it } from 'vitest'
import { flushPromises, mount } from '@vue/test-utils'
import { defineComponent, h, nextTick } from 'vue'
import { Time } from '@internationalized/date'
import TimeRangeField from '@/Components/Fields/TimeRangeField.vue'
import { TimeRangeFieldRoot } from 'reka-ui'

const mountField = (props = {}) => mount(TimeRangeField, { props })

const rootOf = (wrapper) => wrapper.findComponent(TimeRangeFieldRoot)

// A reactive parent mirrors a real v-model usage: emitted update:start /
// update:end values round-trip back into props, which is what drives the
// picker/clear-driven segment refresh.
const ReactiveHost = defineComponent({
    data: () => ({ start: '09:30', end: null }),
    render() {
        return h(TimeRangeField, {
            id: 'appointment_time',
            start: this.start,
            end: this.end,
            'onUpdate:start': (value) => (this.start = value),
            'onUpdate:end': (value) => (this.end = value),
        })
    },
})

// The picker popover is teleported to <body> (same as DateField's calendar).
const openPicker = async (wrapper) => {
    await wrapper.get('button[aria-label="Pick time"]').trigger('click')
    await flushPromises()
}

const pickButton = (side, part, value) =>
    document.querySelector(
        `[data-slot="time-range-picker"] [data-side="${side}"][data-part="${part}"] button[data-value="${value}"]`,
    )

const picker = () => document.querySelector('[data-slot="time-range-picker"]')

// reka-ui renders each segment as an element carrying
// data-reka-time-field-segment="<part>" and
// data-reka-time-range-field-segment-type="start|end".
const segment = (side, part) =>
    document.querySelector(
        `[data-reka-time-range-field-segment-type="${side}"][data-reka-time-field-segment="${part}"]`,
    )

afterEach(async () => {
    await new Promise((resolve) => setTimeout(resolve, 0)) // settle popper autoUpdate/rAF
    document.body.innerHTML = ''
})

// Segments live in the component DOM, so the reactive host must be attached
// for document.querySelector to reach them.
const mountHost = (props = {}) =>
    mount(ReactiveHost, { ...props, attachTo: document.body })

describe('TimeRangeField', () => {
    it('renders the label, required asterisk and error text', () => {
        const wrapper = mountField({
            id: 'appointment_time',
            label: 'Time',
            required: true,
            error: 'The start time field is required.',
        })

        expect(wrapper.text()).toContain('Time')
        expect(wrapper.find('span.text-status-cancelled').text()).toBe('*')
        expect(wrapper.text()).toContain('The start time field is required.')

        const control = wrapper.get('[data-slot="time-range-field"]')
        expect(control.attributes('aria-invalid')).toBe('true')
        expect(control.attributes('aria-describedby')).toBe(
            'appointment_time-error',
        )
        expect(
            wrapper.get('[data-slot="time-range-control"]').classes(),
        ).toContain('border-destructive')
        expect(wrapper.find('p#appointment_time-error').text()).toBe(
            'The start time field is required.',
        )
        wrapper.unmount()
    })

    it('renders the hint text', () => {
        const wrapper = mountField({ hint: '24-hour format' })
        expect(wrapper.text()).toContain('24-hour format')
        wrapper.unmount()
    })

    it('binds HH:mm strings into internal Time values and renders segments', () => {
        const wrapper = mountField({
            id: 'appointment_time',
            start: '09:30',
            end: '17:00',
        })

        const modelValue = rootOf(wrapper).props('modelValue')
        expect(modelValue.start).toBeInstanceOf(Time)
        expect(modelValue.start.hour).toBe(9)
        expect(modelValue.start.minute).toBe(30)
        expect(modelValue.end).toBeInstanceOf(Time)
        expect(modelValue.end.hour).toBe(17)
        expect(modelValue.end.minute).toBe(0)

        // Segments render in 12-hour form with AM/PM segments.
        const control = wrapper.get('[data-slot="time-range-field"]')
        expect(control.text()).toContain('AM')
        expect(control.text()).toContain('PM')
        expect(control.text()).toContain('30')

        // The internal hidden input carries the range value.
        const hidden = wrapper.get('input#appointment_time')
        expect(hidden.attributes('value')).toContain('09:30')
        expect(hidden.attributes('value')).toContain('17:00')
        wrapper.unmount()
    })

    it('emits HH:mm strings when the root emits an updated model value', async () => {
        const wrapper = mountField({ start: null, end: null })

        rootOf(wrapper).vm.$emit('update:modelValue', {
            start: new Time(9, 30),
            end: new Time(10, 0),
        })
        await nextTick()

        expect(wrapper.emitted('update:start')?.[0]).toEqual(['09:30'])
        expect(wrapper.emitted('update:end')?.[0]).toEqual(['10:00'])
        wrapper.unmount()
    })

    it('emits null for a missing side of the range', async () => {
        const wrapper = mountField({ start: '09:30', end: null })

        rootOf(wrapper).vm.$emit('update:modelValue', {
            start: new Time(11, 15),
            end: undefined,
        })
        await nextTick()

        expect(wrapper.emitted('update:start')?.[0]).toEqual(['11:15'])
        expect(wrapper.emitted('update:end')?.[0]).toEqual([null])
        wrapper.unmount()
    })

    it('shows the clear button only when start or end is set and resets both on click', async () => {
        const wrapper = mountField({ start: '09:00', end: null })

        const clear = wrapper.get('button[aria-label="Clear time"]')
        clear.trigger('click')
        await nextTick()

        expect(wrapper.emitted('update:start')?.[0]).toEqual([null])
        expect(wrapper.emitted('update:end')?.[0]).toEqual([null])
        wrapper.unmount()
    })

    it('hides the clear button when both values are null', () => {
        const wrapper = mountField({ start: null, end: null })
        expect(wrapper.find('button[aria-label="Clear time"]').exists()).toBe(
            false,
        )
        wrapper.unmount()
    })

    it('treats invalid or empty strings as null without crashing', async () => {
        const wrapper = mountField({ start: '25:99', end: '', id: 'bad_time' })

        const modelValue = rootOf(wrapper).props('modelValue')
        expect(modelValue.start).toBeUndefined()
        expect(modelValue.end).toBeUndefined()

        // Garbage input never crashes and round-trips as null.
        rootOf(wrapper).vm.$emit('update:modelValue', {
            start: undefined,
            end: undefined,
        })
        await nextTick()
        expect(wrapper.emitted('update:start')?.[0]).toEqual([null])
        expect(wrapper.emitted('update:end')?.[0]).toEqual([null])
        wrapper.unmount()
    })

    it('rejects seconds-padded values (HH:mm:ss) as null', async () => {
        const wrapper = mountField({
            id: 'appointment_time',
            start: '09:30:00',
            end: null,
        })

        // Not parsed into a Time — treated as null.
        const modelValue = rootOf(wrapper).props('modelValue')
        expect(modelValue.start).toBeUndefined()
        expect(modelValue.end).toBeUndefined()

        // Renders empty placeholder segments instead of the invalid string.
        const control = wrapper.get('[data-slot="time-range-field"]')
        expect(control.text()).toContain('––')
        expect(control.text()).not.toContain('09:30')

        // No crash and the round-trip emits null.
        rootOf(wrapper).vm.$emit('update:modelValue', {
            start: undefined,
            end: undefined,
        })
        await nextTick()
        expect(wrapper.emitted('update:start')?.[0]).toEqual([null])
        wrapper.unmount()
    })

    it('rejects out-of-range 24:00 as null', () => {
        const wrapper = mountField({ start: '24:00', end: null })

        expect(rootOf(wrapper).props('modelValue').start).toBeUndefined()
        wrapper.unmount()
    })

    it('parses unpadded 9:5 and emits it zero-padded as 09:05', async () => {
        const wrapper = mountField({ start: '9:5' })

        const modelValue = rootOf(wrapper).props('modelValue')
        expect(modelValue.start.hour).toBe(9)
        expect(modelValue.start.minute).toBe(5)

        rootOf(wrapper).vm.$emit('update:modelValue', {
            start: new Time(9, 5),
            end: undefined,
        })
        await nextTick()
        expect(wrapper.emitted('update:start')?.[0]).toEqual(['09:05'])
        wrapper.unmount()
    })

    it('renders no error text when error is null', () => {
        const wrapper = mountField({
            id: 'appointment_time',
            label: 'Time',
            error: null,
        })

        expect(wrapper.find('p#appointment_time-error').exists()).toBe(false)
        expect(
            wrapper.get('[data-slot="time-range-field"]').attributes(
                'aria-invalid',
            ),
        ).toBe('false')
        wrapper.unmount()
    })

    it('disables the control when disabled is set', () => {
        const wrapper = mountField({ disabled: true, start: '09:00' })
        const control = wrapper.get('[data-slot="time-range-field"]')
        expect(control.attributes('aria-disabled')).toBe('true')
        expect(
            wrapper.get('[data-slot="time-range-control"]').classes(),
        ).toContain('data-disabled:opacity-50')
        wrapper.unmount()
    })

    it('opens the picker popover from the clock button', async () => {
        const wrapper = mountField({ start: '09:30', end: null })
        await openPicker(wrapper)

        expect(picker()).toBeTruthy()
        expect(picker().textContent).toContain('Start')
        expect(picker().textContent).toContain('End')
        wrapper.unmount()
    })

    it('picking an hour emits update:start keeping the current minute', async () => {
        const wrapper = mountField({ start: '09:30', end: null })
        await openPicker(wrapper)

        pickButton('start', 'hour', '02').click()
        await flushPromises()
        pickButton('start', 'period', 'PM').click()
        await flushPromises()

        expect(wrapper.emitted('update:start')?.[0]).toEqual(['02:30'])
        expect(wrapper.emitted('update:start')?.[1]).toEqual(['14:30'])
        wrapper.unmount()
    })

    it('picking an hour on an empty start emits 14:00 via 02 PM', async () => {
        const wrapper = mountField({ start: null, end: null })
        await openPicker(wrapper)

        pickButton('start', 'hour', '02').click()
        await flushPromises()
        pickButton('start', 'period', 'PM').click()
        await flushPromises()

        expect(wrapper.emitted('update:start')?.[0]).toEqual(['02:00'])
        expect(wrapper.emitted('update:start')?.[1]).toEqual(['14:00'])
        wrapper.unmount()
    })

    it('picking a minute keeps the current hour', async () => {
        const wrapper = mountField({ start: '09:00', end: null })
        await openPicker(wrapper)

        pickButton('start', 'minute', '30').click()
        await flushPromises()

        expect(wrapper.emitted('update:start')?.[0]).toEqual(['09:30'])
        wrapper.unmount()
    })

    it('end column buttons emit update:end', async () => {
        const wrapper = mountField({ start: '09:00', end: null })
        await openPicker(wrapper)

        pickButton('end', 'hour', '05').click()
        await flushPromises()
        pickButton('end', 'period', 'PM').click()
        await flushPromises()
        pickButton('end', 'minute', '45').click()
        await flushPromises()

        expect(wrapper.emitted('update:end')?.[0]).toEqual(['05:00'])
        expect(wrapper.emitted('update:end')?.[1]).toEqual(['17:00'])
        expect(wrapper.emitted('update:end')?.[2]).toEqual(['17:45'])
        wrapper.unmount()
    })

    it('offers a 12-hour AM/PM picker', async () => {
        const wrapper = mountField({ start: null, end: null })
        await openPicker(wrapper)

        const hourList = document.querySelectorAll(
            '[data-slot="time-range-picker"] [data-side="start"][data-part="hour"] button',
        )
        expect(hourList.length).toBe(12)
        expect(hourList[0].getAttribute('data-value')).toBe('12')

        expect(pickButton('start', 'period', 'AM')).toBeTruthy()
        expect(pickButton('start', 'period', 'PM')).toBeTruthy()
        wrapper.unmount()
    })

    it('toggles AM/PM converting the hour to 24-hour', async () => {
        const wrapper = mountField({ start: '09:30', end: null })
        await openPicker(wrapper)

        pickButton('start', 'period', 'PM').click()
        await flushPromises()

        expect(wrapper.emitted('update:start')?.[0]).toEqual(['21:30'])
        wrapper.unmount()
    })

    it('handles 12 AM and 12 PM boundaries', async () => {
        const wrapper = mountField({ start: '00:00', end: '12:00' })
        await openPicker(wrapper)

        // 00:00 displays as 12 AM; 12:00 as 12 PM.
        expect(pickButton('start', 'hour', '12').className).toContain(
            'bg-brand-500',
        )
        expect(pickButton('start', 'period', 'AM').className).toContain(
            'bg-brand-500',
        )
        expect(pickButton('end', 'hour', '12').className).toContain(
            'bg-brand-500',
        )
        expect(pickButton('end', 'period', 'PM').className).toContain(
            'bg-brand-500',
        )
        wrapper.unmount()
    })

    it('keeps the popover open after a selection', async () => {
        const wrapper = mountField({ start: '09:30', end: null })
        await openPicker(wrapper)

        pickButton('start', 'hour', '02').click()
        await flushPromises()

        expect(picker()).toBeTruthy()
        wrapper.unmount()
    })

    it('highlights the currently selected values in the picker', async () => {
        const wrapper = mountField({ start: '09:30', end: '17:00' })
        await openPicker(wrapper)

        expect(pickButton('start', 'hour', '09').className).toContain(
            'bg-brand-500',
        )
        expect(pickButton('start', 'minute', '30').className).toContain(
            'bg-brand-500',
        )
        expect(pickButton('start', 'period', 'AM').className).toContain(
            'bg-brand-500',
        )
        expect(pickButton('end', 'hour', '05').className).toContain(
            'bg-brand-500',
        )
        expect(pickButton('end', 'minute', '00').className).toContain(
            'bg-brand-500',
        )
        expect(pickButton('end', 'period', 'PM').className).toContain(
            'bg-brand-500',
        )
        // A non-selected value is not highlighted.
        expect(pickButton('start', 'hour', '10').className).not.toContain(
            'bg-brand-500',
        )
        expect(pickButton('start', 'period', 'PM').className).not.toContain(
            'bg-brand-500',
        )
        wrapper.unmount()
    })

    it('disables the picker trigger when disabled and does not open', async () => {
        const wrapper = mountField({ disabled: true, start: '09:00' })

        const trigger = wrapper.get('button[aria-label="Pick time"]')
        expect(trigger.attributes('disabled')).toBeDefined()

        await trigger.trigger('click')
        await flushPromises()
        expect(picker()).toBeNull()
        wrapper.unmount()
    })

    it('segments reflect picker selections', async () => {
        const wrapper = mountHost()
        await openPicker(wrapper)

        pickButton('start', 'hour', '02').click()
        await flushPromises()
        pickButton('start', 'period', 'PM').click()
        await flushPromises()
        pickButton('start', 'minute', '30').click()
        await flushPromises()

        // 14:30 renders in 12-hour form: hour "2", minute "30", period "PM"
        // (reka-ui names the AM/PM segment part "dayPeriod").
        expect(segment('start', 'hour').textContent.trim()).toBe('2')
        expect(segment('start', 'minute').textContent.trim()).toBe('30')
        expect(segment('start', 'dayPeriod').textContent.trim()).toBe('PM')
        wrapper.unmount()
    })

    it('picker stays open after selecting an hour', async () => {
        const wrapper = mountHost()
        await openPicker(wrapper)

        const trigger = document.querySelector(
            'button[aria-label="Pick time"]',
        )
        const popover = picker()
        expect(trigger).toBeTruthy()
        expect(popover).toBeTruthy()

        pickButton('start', 'hour', '02').click()
        await flushPromises()

        // Root cause: the trigger must live OUTSIDE the keyed root so the
        // segment remount does not recreate the anchor (a recreated anchor is
        // what dismisses the popover in a real browser).
        expect(
            document.querySelector('button[aria-label="Pick time"]'),
        ).toBe(trigger)

        // The popover stays open; minute buttons and Done stay reachable.
        expect(picker()).toBe(popover)
        expect(picker().textContent).toContain('Done')
        expect(pickButton('start', 'minute', '30')).toBeTruthy()

        // Segments still reflect the pick (02 AM → hour "2").
        expect(segment('start', 'hour').textContent.trim()).toBe('2')
        wrapper.unmount()
    })

    it('clear resets the segment display when the value came from props', async () => {
        const wrapper = mountHost()

        wrapper.get('button[aria-label="Clear time"]').trigger('click')
        await flushPromises()

        expect(segment('start', 'hour').textContent).toBe('––')
        expect(segment('start', 'minute').textContent).toBe('––')
        wrapper.unmount()
    })

    it('clear resets the segment display after picker selections', async () => {
        const wrapper = mountHost()
        await openPicker(wrapper)
        pickButton('start', 'hour', '02').click()
        await flushPromises()

        wrapper.get('button[aria-label="Clear time"]').trigger('click')
        await flushPromises()

        expect(segment('start', 'hour').textContent).toBe('––')
        expect(segment('start', 'minute').textContent).toBe('––')
        wrapper.unmount()
    })

    it('Done button closes the picker popover', async () => {
        const wrapper = mountField({ start: '09:30', end: null })
        await openPicker(wrapper)
        expect(picker()).toBeTruthy()

        const done = [
            ...document.querySelectorAll(
                '[data-slot="time-range-picker"] button',
            ),
        ].find((el) => el.textContent.trim() === 'Done')
        expect(done).toBeTruthy()

        done.click()
        await flushPromises()

        expect(picker()).toBeNull()
        wrapper.unmount()
    })

    it('picker lists carry the no-scrollbar utility', async () => {
        const wrapper = mountField({ start: '09:30', end: null })
        await openPicker(wrapper)

        const hourList = document.querySelector(
            '[data-slot="time-range-picker"] [data-side="start"][data-part="hour"]',
        )
        const minuteList = document.querySelector(
            '[data-slot="time-range-picker"] [data-side="end"][data-part="minute"]',
        )
        expect(hourList.className).toContain('no-scrollbar')
        expect(minuteList.className).toContain('no-scrollbar')
        wrapper.unmount()
    })
})
