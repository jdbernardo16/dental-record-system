import { describe, expect, it } from 'vitest'
import { readFileSync } from 'node:fs'
import { resolve } from 'node:path'
import { jdcColors } from '@/lib/colors'

/**
 * Guards against design-token drift between the CSS custom properties
 * (resources/css/app.css @theme block) and the JS mirror used by charts
 * (resources/js/lib/colors.js). If a token value changes in one place,
 * this test fails until the other is updated.
 */

const appCss = readFileSync(resolve(__dirname, '../../resources/css/app.css'), 'utf8')

function cssToken(name) {
    // Matches: --color-brand-500:  oklch(0.706 0.144 232.4);
    const re = new RegExp(`--color-${name}:\\s+([^;]+);`)
    const match = appCss.match(re)
    if (!match) return null
    return match[1].trim().replace(/\s+/g, ' ')
}

describe('jdcColors mirrors app.css @theme tokens', () => {
    it('syncs the brand scale', () => {
        for (const [shade, value] of Object.entries(jdcColors.brand)) {
            expect(cssToken(`brand-${shade}`), `brand-${shade}`).toBe(value)
        }
    })

    it('syncs the gray/neutral scale', () => {
        for (const [shade, value] of Object.entries(jdcColors.gray)) {
            expect(cssToken(`gray-${shade}`), `gray-${shade}`).toBe(value)
        }
    })

    it('syncs the status semantic aliases', () => {
        // jdcColors.status keys are the legacy status names (pending, confirmed,
        // completed, cancelled, no-show) which alias to semantic colors in app.css.
        expect(cssToken('status-pending')).toBe('var(--color-status-warning)')
        expect(cssToken('status-confirmed')).toBe('var(--color-status-info)')
        expect(cssToken('status-completed')).toBe('var(--color-status-success)')
        expect(cssToken('status-cancelled')).toBe('var(--color-status-error)')
        expect(cssToken('status-no-show')).toBe('var(--color-status-error)')

        // And the underlying semantic tokens must match the JS values.
        expect(cssToken('status-warning')).toBe(jdcColors.status.pending)
        expect(cssToken('status-info')).toBe(jdcColors.status.confirmed)
        expect(cssToken('status-success')).toBe(jdcColors.status.completed)
        expect(cssToken('status-error')).toBe(jdcColors.status.cancelled)
    })
})
