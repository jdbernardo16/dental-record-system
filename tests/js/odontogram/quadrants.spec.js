import { describe, expect, it } from 'vitest'
import { convertFDIToNotation, toothId, quadrants, VIEW_W, VIEW_H, quadrantFdiStart, fdiNumber, toViewBox } from '@/lib/odontogram'

describe('odontogram quadrants', () => {
    it('has 4 quadrants covering all 32 FDI teeth', () => {
        expect(quadrants).toHaveLength(4)
        expect(quadrants.map((q) => q.name)).toEqual(['first', 'second', 'third', 'fourth'])
        expect(quadrants.map((q) => q.label)).toEqual(['Upper Right', 'Upper Left', 'Lower Right', 'Lower Left'])
    })

    it('defines mirror transforms for each quadrant', () => {
        expect(quadrants[0].transform).toBe('')
        expect(quadrants[1].transform).toBe('scale(-1, 1) translate(-409, 0)')
        expect(quadrants[2].transform).toBe('scale(1, -1) translate(0, -694)')
        expect(quadrants[3].transform).toBe('scale(-1, -1) translate(-409, -694)')
    })

    it('builds correct FDI ids for all 32 teeth', () => {
        const ids = []
        for (let q = 1; q <= 4; q++) {
            for (let t = 1; t <= 8; t++) {
                ids.push(toothId(q, t))
            }
        }
        expect(ids).toHaveLength(32)
        expect(ids[0]).toBe('teeth-11')
        expect(ids[7]).toBe('teeth-18')
        expect(ids[8]).toBe('teeth-21')
        expect(ids[31]).toBe('teeth-48')
    })

    it('converts FDI to Universal numbering', () => {
        expect(convertFDIToNotation('teeth-11', 'Universal')).toBe('8')
        expect(convertFDIToNotation('teeth-18', 'Universal')).toBe('1')
        expect(convertFDIToNotation('teeth-21', 'Universal')).toBe('9')
        expect(convertFDIToNotation('teeth-48', 'Universal')).toBe('32')
        expect(convertFDIToNotation('teeth-36', 'Universal')).toBe('19')
    })

    it('converts FDI to Palmer notation', () => {
        expect(convertFDIToNotation('teeth-11', 'Palmer')).toBe('1UR')
        expect(convertFDIToNotation('teeth-21', 'Palmer')).toBe('1UL')
        expect(convertFDIToNotation('teeth-31', 'Palmer')).toBe('1LL')
        expect(convertFDIToNotation('teeth-41', 'Palmer')).toBe('1LR')
    })

    it('returns plain FDI when notation is FDI', () => {
        expect(convertFDIToNotation('teeth-24', 'FDI')).toBe('24')
    })

    it('handles inputs without the teeth- prefix', () => {
        expect(convertFDIToNotation('11', 'Universal')).toBe('8')
        expect(convertFDIToNotation('48', 'Universal')).toBe('32')
    })

    it('falls back to the raw number for unmapped codes', () => {
        expect(convertFDIToNotation('teeth-55', 'Universal')).toBe('55')
    })

    it('keeps the arch viewBox dimensions', () => {
        expect(VIEW_W).toBe(409)
        expect(VIEW_H).toBe(694)
    })

    it('maps adult quadrants so the patient right side is on the viewer left', () => {
        // Quadrant 0 renders top-left (mirrored), quadrant 1 top-right, etc.
        expect(quadrantFdiStart(0, 'adult')).toBe('1') // upper right  → 11-18 top-left
        expect(quadrantFdiStart(1, 'adult')).toBe('2') // upper left   → 21-28 top-right
        expect(quadrantFdiStart(2, 'adult')).toBe('4') // lower right  → 41-48 bottom-left
        expect(quadrantFdiStart(3, 'adult')).toBe('3') // lower left   → 31-38 bottom-right
    })

    it('maps primary quadrants to the 5x/6x/8x/7x ranges', () => {
        expect(quadrantFdiStart(0, 'primary')).toBe('5')
        expect(quadrantFdiStart(1, 'primary')).toBe('6')
        expect(quadrantFdiStart(2, 'primary')).toBe('8')
        expect(quadrantFdiStart(3, 'primary')).toBe('7')
    })

    it('builds full FDI numbers per quadrant', () => {
        expect(fdiNumber(0, 0, 'adult')).toBe('11')
        expect(fdiNumber(0, 7, 'adult')).toBe('18')
        expect(fdiNumber(2, 7, 'adult')).toBe('48')
        expect(fdiNumber(3, 0, 'adult')).toBe('31')
        expect(fdiNumber(0, 4, 'primary')).toBe('55')
        expect(fdiNumber(2, 4, 'primary')).toBe('85')
    })

    it('converts quadrant-local points to upright viewBox space', () => {
        // Identity quadrant: unchanged
        expect(toViewBox(0, 100, 50)).toEqual({ x: 100, y: 50 })
        // scale(-1, 1) translate(-409, 0): x' = 409 - x
        expect(toViewBox(1, 200, 50)).toEqual({ x: 209, y: 50 })
        // scale(1, -1) translate(0, -694): y' = 694 - y
        expect(toViewBox(2, 200, 50)).toEqual({ x: 200, y: 644 })
        // scale(-1, -1) translate(-409, -694): both flipped
        expect(toViewBox(3, 200, 50)).toEqual({ x: 209, y: 644 })
    })
})
