import { describe, expect, it } from 'vitest'
import { teethPaths as portedTeethPaths } from '@/lib/odontogram'

describe('odontogram teethPaths', () => {
    it('defines 8 tooth types in the expected order', () => {
        expect(portedTeethPaths).toHaveLength(8)
        expect(portedTeethPaths.map((t) => t.name)).toEqual(['1', '2', '3', '4', '5', '6', '7', '8'])
        expect(portedTeethPaths.map((t) => t.type)).toEqual([
            'Central Incisor', 'Lateral Incisor', 'Canine', 'First Premolar',
            'Second Premolar', 'First Molar', 'Second Molar', 'Third Molar',
        ])
    })

    it('has valid SVG path strings for every tooth', () => {
        for (const tooth of portedTeethPaths) {
            expect(tooth.outlinePath).toMatch(/^M/)
            expect(tooth.shadowPath).toMatch(/^M/)
            expect(typeof tooth.outlinePath).toBe('string')
            expect(typeof tooth.shadowPath).toBe('string')
        }
    })

    it('renders molar/premolar highlights as arrays, incisors as strings', () => {
        expect(Array.isArray(portedTeethPaths[0].lineHighlightPath)).toBe(false) // central incisor
        expect(Array.isArray(portedTeethPaths[1].lineHighlightPath)).toBe(false) // lateral incisor
        expect(Array.isArray(portedTeethPaths[2].lineHighlightPath)).toBe(true)  // canine
        expect(Array.isArray(portedTeethPaths[3].lineHighlightPath)).toBe(true)  // 1st premolar
        expect(Array.isArray(portedTeethPaths[4].lineHighlightPath)).toBe(true)  // 2nd premolar
        expect(Array.isArray(portedTeethPaths[5].lineHighlightPath)).toBe(true)  // 1st molar
        expect(Array.isArray(portedTeethPaths[6].lineHighlightPath)).toBe(true)  // 2nd molar
        expect(Array.isArray(portedTeethPaths[7].lineHighlightPath)).toBe(true)  // 3rd molar
    })

    it('has non-trivial path data', () => {
        for (const tooth of portedTeethPaths) {
            expect(tooth.outlinePath.length).toBeGreaterThan(100)
            expect(tooth.shadowPath.length).toBeGreaterThan(50)
        }
    })

    it('matches the MIT reference source byte-for-byte (drift guard)', async () => {
        // The reference data.ts (docs/reference/odontogram/) is the upstream
        // file. It exports the circle layout (`teethPaths`, 8 entries) that
        // this module was ported from, plus the unused square layout
        // (`NewTeethPaths`). Compare every path field of the circle layout
        // exactly. NOTE: aliased imports — a destructured `teethPaths` here
        // would shadow the module import and make this test tautological.
        const { teethPaths: referenceTeethPaths } = await import('../../../docs/reference/odontogram/data.ts')
        expect(referenceTeethPaths).toHaveLength(8)
        for (let i = 0; i < referenceTeethPaths.length; i++) {
            const ported = portedTeethPaths[i]
            const src = referenceTeethPaths[i]
            expect(ported.outlinePath, `tooth ${i + 1} outlinePath`).toBe(src.outlinePath)
            expect(ported.shadowPath, `tooth ${i + 1} shadowPath`).toBe(src.shadowPath)
            expect(ported.lineHighlightPath, `tooth ${i + 1} lineHighlightPath`).toEqual(src.lineHighlightPath)
        }
    })
})
