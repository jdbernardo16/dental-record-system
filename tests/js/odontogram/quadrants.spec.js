import { describe, expect, it } from 'vitest'
import { convertFDIToNotation, toothId, quadrants, VIEW_W, VIEW_H } from '@/lib/odontogram'

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
})
