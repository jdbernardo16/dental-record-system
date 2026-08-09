import { describe, expect, it } from 'vitest'
import { decodeSvgPayload, encodeSvgPayload } from '@/lib/svgWire'

const SAMPLE_SVG =
    '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 300 150"><path d="M10 80 Q 95 10 180 80 T 290 80" stroke="black" stroke-width="2" fill="none"/></svg>'

describe('svgWire codec', () => {
    it('encodes an SVG so the payload never contains the literal <svg tag (WAF regression)', () => {
        const encoded = encodeSvgPayload(SAMPLE_SVG)

        expect(encoded).toBeTruthy()
        expect(encoded).not.toContain('<svg')
    })

    it('decode(encode(svg)) round-trips back to the original SVG', () => {
        expect(decodeSvgPayload(encodeSvgPayload(SAMPLE_SVG))).toBe(SAMPLE_SVG)
    })

    it('handles null and empty payloads', () => {
        expect(encodeSvgPayload(null)).toBeNull()
        expect(encodeSvgPayload('')).toBe('')
        expect(decodeSvgPayload(null)).toBeNull()
        expect(decodeSvgPayload('')).toBe('')
    })
})
