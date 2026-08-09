import { describe, expect, it, vi } from 'vitest'
import { mount } from '@vue/test-utils'
import { defineComponent } from 'vue'

vi.mock('@inertiajs/vue3', async (importOriginal) => {
    const actual = await importOriginal()
    return {
        ...actual,
        usePage: () => ({
            props: {
                auth: { can: { manageUsers: true, managePatients: true, manageAppointments: true } },
                can: { reports: true, settings: true },
            },
        }),
    }
})

vi.mock('../../vendor/tightenco/ziggy', () => ({
    route: (name) => {
        if (!name) return { current: () => '' } // isActive() calls route().current() with no args
        return `/${String(name).replace(/\.\*/g, '').replace(/\./g, '/')}`
    },
}))

import Sidebar from '../../resources/js/Components/Sidebar.vue'

const LinkStub = defineComponent({
    name: 'Link',
    props: { href: { type: String, required: true } },
    template: '<a :href="href"><slot /></a>',
})

const mountSidebar = (props = {}) =>
    mount(Sidebar, {
        props: { open: false, ...props },
        global: { stubs: { Link: LinkStub } },
    })

describe('Sidebar', () => {
    it('emits close when a nav link is clicked', async () => {
        const wrapper = mountSidebar({ open: true })
        const links = wrapper.findAll('a')
        expect(links.length).toBeGreaterThan(0)
        await links[0].trigger('click')
        expect(wrapper.emitted('close')).toHaveLength(1)
    })

    it('is always full width on desktop and never renders the rail class', () => {
        const wrapper = mountSidebar({ open: false })
        const aside = wrapper.get('aside')
        expect(aside.classes()).toContain('w-72')
        expect(aside.classes()).toContain('lg:static')
        expect(aside.classes()).toContain('lg:translate-x-0')
        expect(aside.classes()).not.toContain('lg:w-24')
        expect(wrapper.text()).toContain('Dashboard')
    })

    it('renders off-canvas when closed and closes via backdrop click', async () => {
        const wrapper = mountSidebar({ open: false })
        const aside = wrapper.get('aside')
        expect(aside.classes()).toContain('-translate-x-full')
        expect(aside.classes()).not.toContain('translate-x-0')

        const openWrapper = mountSidebar({ open: true })
        await openWrapper.get('.fixed.inset-0').trigger('click')
        expect(openWrapper.emitted('close')).toHaveLength(1)
    })
})
