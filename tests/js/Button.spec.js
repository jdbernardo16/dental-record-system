import { describe, expect, it } from 'vitest'
import { mount } from '@vue/test-utils'
import { Button, buttonVariants } from '@/Components/ui/button'

describe('buttonVariants size map', () => {
    it('keeps the default size proportions', () => {
        expect(buttonVariants({ size: 'default' })).toContain('min-h-11 px-4 py-2')
    })

    it('sm matches the legacy Button.vue proportions', () => {
        expect(buttonVariants({ size: 'sm' })).toContain('px-4 py-2.5 text-sm')
        expect(buttonVariants({ size: 'sm' })).not.toContain('h-8')
    })

    it('md aliases the legacy Button.vue md size', () => {
        expect(buttonVariants({ size: 'md' })).toContain('px-5 py-3 text-sm')
    })

    it('keeps the xs, lg and icon sizes intact', () => {
        expect(buttonVariants({ size: 'xs' })).toContain('text-xs')
        expect(buttonVariants({ size: 'lg' })).toContain('px-6')
        expect(buttonVariants({ size: 'icon' })).toContain('size-9')
    })

    it('maps variants to JDC token colors', () => {
        expect(buttonVariants({ variant: 'default' })).toContain('bg-brand-500')
        expect(buttonVariants({ variant: 'outline' })).toContain('border border-gray-300')
        expect(buttonVariants({ variant: 'destructive' })).toContain('bg-status-error')
        expect(buttonVariants({ variant: 'ghost' })).toContain('hover:bg-gray-100')
        expect(buttonVariants({ variant: 'link' })).toContain('text-brand-500')
        expect(buttonVariants({ variant: 'secondary' })).toContain('bg-secondary-500')
    })
})

describe('Button', () => {
    it('renders a button with the merged variant and size classes', () => {
        const wrapper = mount(Button, {
            props: { size: 'md', variant: 'outline' },
            slots: { default: 'Save' },
        })

        const button = wrapper.get('button')
        expect(button.text()).toBe('Save')
        for (const cls of ['px-5', 'py-3', 'text-sm', 'border', 'bg-white']) {
            expect(button.classes()).toContain(cls)
        }
    })

    it('defaults to the default variant and size', () => {
        const wrapper = mount(Button, { slots: { default: 'Go' } })

        const button = wrapper.get('button')
        expect(button.classes()).toContain('bg-brand-500')
        expect(button.classes()).toContain('min-h-11')
    })
})
