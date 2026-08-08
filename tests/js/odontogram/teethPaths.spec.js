import { describe, expect, it } from 'vitest'
import { teethPaths } from '@/lib/odontogram'

describe('odontogram teethPaths', () => {
    it('defines 8 tooth types in the expected order', () => {
        expect(teethPaths).toHaveLength(8)
        expect(teethPaths.map((t) => t.name)).toEqual(['1', '2', '3', '4', '5', '6', '7', '8'])
        expect(teethPaths.map((t) => t.type)).toEqual([
            'Central Incisor', 'Lateral Incisor', 'Canine', 'First Premolar',
            'Second Premolar', 'First Molar', 'Second Molar', 'Third Molar',
        ])
    })

    it('has valid SVG path strings for every tooth', () => {
        for (const tooth of teethPaths) {
            expect(tooth.outlinePath).toMatch(/^M/)
            expect(tooth.shadowPath).toMatch(/^M/)
            expect(typeof tooth.outlinePath).toBe('string')
            expect(typeof tooth.shadowPath).toBe('string')
        }
    })

    it('renders molar/premolar highlights as arrays, incisors as strings', () => {
        expect(Array.isArray(teethPaths[0].lineHighlightPath)).toBe(false) // central incisor
        expect(Array.isArray(teethPaths[1].lineHighlightPath)).toBe(false) // lateral incisor
        expect(Array.isArray(teethPaths[2].lineHighlightPath)).toBe(true)  // canine
        expect(Array.isArray(teethPaths[3].lineHighlightPath)).toBe(true)  // 1st premolar
        expect(Array.isArray(teethPaths[5].lineHighlightPath)).toBe(true)  // 1st molar
        expect(Array.isArray(teethPaths[7].lineHighlightPath)).toBe(true)  // 3rd molar
    })

    it('has non-trivial path data', () => {
        for (const tooth of teethPaths) {
            expect(tooth.outlinePath.length).toBeGreaterThan(100)
            expect(tooth.shadowPath.length).toBeGreaterThan(50)
        }
    })

    it('matches the MIT reference source byte-for-byte (drift guard)', async () => {
        // The reference data.ts is the upstream file. It exports the circle
        // layout (teethPaths, first 8 entries) and the square layout
        // (NewTeethPaths, next 8). Import both directly and compare every path
        // field of the circle layout exactly.
        const { teethPaths, NewTeethPaths } = await import('../../../docs/reference/odontogram/data.ts')
        const reference = [...teethPaths, ...NewTeethPaths]
        expect(reference).toHaveLength(16) // reference has BOTH layouts (8 circle + 8 square)
        for (let i = 0; i < 8; i++) {
            const ported = teethPaths[i]
            const src = reference[i]
            expect(ported.outlinePath, `tooth ${i + 1} outlinePath`).toBe(src.outlinePath)
            expect(ported.shadowPath, `tooth ${i + 1} shadowPath`).toBe(src.shadowPath)
            expect(ported.lineHighlightPath, `tooth ${i + 1} lineHighlightPath`).toEqual(src.lineHighlightPath)
        }
    })
})
