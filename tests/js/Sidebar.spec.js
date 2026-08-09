import { describe, expect, it, vi } from 'vitest'
import { mount } from '@vue/test-utils'
import { defineComponent, nextTick, reactive, ref } from 'vue'

const mockPageUrl = ref('/dashboard')

vi.mock('@inertiajs/vue3', async (importOriginal) => {
    const actual = await importOriginal()
    return {
        ...actual,
        usePage: () =>
            reactive({
                props: {
                    auth: { can: { manageUsers: true, managePatients: true, manageAppointments: true } },
                    can: { reports: true, settings: true },
                },
                url: mockPageUrl,
            }),
    }
})

const mockRouteHrefs = {
    dashboard: '/dashboard',
    'wizard.index': '/wizard',
    'patients.index': '/patients',
    'appointments.index': '/appointments',
    'users.index': '/users',
    'reports.index': '/reports',
    'settings.index': '/settings',
}

vi.mock('../../vendor/tightenco/ziggy', () => ({
    route: (name) => {
        if (name) return mockRouteHrefs[name] ?? `/${String(name).replace(/\./g, '/')}`
        const currentName =
            Object.entries(mockRouteHrefs).find(([, href]) => href === mockPageUrl.value)?.[0] ?? ''
        return {
            current: (checkName) => {
                if (checkName === undefined) return currentName
                if (currentName === checkName) return true
                if (checkName.endsWith('.*')) return currentName.startsWith(checkName.slice(0, -2))
                return false
            },
        }
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

const linkByText = (wrapper, text) =>
    wrapper.findAll('a').find((a) => a.text().includes(text))

describe('Sidebar', () => {
    it('emits close when a nav link is clicked', async () => {
        const wrapper = mountSidebar({ open: true })
        const links = wrapper.findAll('a')
        expect(links.length).toBeGreaterThan(0)
        await links[0].trigger('click')
        expect(wrapper.emitted('close')).toHaveLength(1)
    })

    it('expands with labels when open and collapses to the rail when closed', () => {
        const open = mountSidebar({ open: true })
        const openAside = open.get('aside')
        expect(openAside.classes()).toContain('w-72')
        expect(openAside.classes()).toContain('translate-x-0')
        expect(openAside.classes()).toContain('lg:w-72')
        expect(open.text()).toContain('Dashboard')

        const closed = mountSidebar({ open: false })
        const closedAside = closed.get('aside')
        expect(closedAside.classes()).toContain('-translate-x-full')
        expect(closedAside.classes()).toContain('lg:translate-x-0')
        expect(closedAside.classes()).toContain('lg:w-24')
        expect(closed.text()).not.toContain('Dashboard')
    })

    it('closes via backdrop click', async () => {
        const wrapper = mountSidebar({ open: true })
        await wrapper.get('.fixed.inset-0').trigger('click')
        expect(wrapper.emitted('close')).toHaveLength(1)
    })

    it('emits close when the X button is clicked', async () => {
        const wrapper = mountSidebar({ open: true })
        await wrapper.get('button[aria-label="Close sidebar"]').trigger('click')
        expect(wrapper.emitted('close')).toHaveLength(1)
    })

    it('moves the active highlight when navigating (SPA)', async () => {
        const wrapper = mountSidebar({ open: true })
        expect(linkByText(wrapper, 'Dashboard').classes()).toContain('menu-item-active')

        mockPageUrl.value = '/appointments'
        await nextTick()

        expect(linkByText(wrapper, 'Appointments').classes()).toContain('menu-item-active')
        expect(linkByText(wrapper, 'Dashboard').classes()).not.toContain('menu-item-active')
    })
})
