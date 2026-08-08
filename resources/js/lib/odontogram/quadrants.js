/**
 * Ported from react-odontogram (MIT) — https://github.com/biomathcode/react-odontogram
 * Copyright (c) biomathcode
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 *
 * Quadrant transforms for the circle/arch layout (viewBox 0 0 409 694)
 * and FDI ↔ Universal ↔ Palmer notation conversions.
 */
export const VIEW_W = 409
export const VIEW_H = 694

export const quadrants = [
    { name: 'first', transform: '', label: 'Upper Right' },
    { name: 'second', transform: 'scale(-1, 1) translate(-409, 0)', label: 'Upper Left' },
    { name: 'third', transform: 'scale(1, -1) translate(0, -694)', label: 'Lower Right' },
    { name: 'fourth', transform: 'scale(-1, -1) translate(-409, -694)', label: 'Lower Left' },
]

export const convertFDIToNotation = (fdi, notation) => {
    const num = String(fdi).replace('teeth-', '')

    const fdiToUniversal = {
        '11': 8, '12': 7, '13': 6, '14': 5, '15': 4, '16': 3, '17': 2, '18': 1,
        '21': 9, '22': 10, '23': 11, '24': 12, '25': 13, '26': 14, '27': 15, '28': 16,
        '31': 24, '32': 23, '33': 22, '34': 21, '35': 20, '36': 19, '37': 18, '38': 17,
        '41': 25, '42': 26, '43': 27, '44': 28, '45': 29, '46': 30, '47': 31, '48': 32,
    }

    if (notation === 'Universal') return String(fdiToUniversal[num] ?? num)
    if (notation === 'Palmer') {
        if (num.length < 2) return num
        const symbols = { '1': 'UR', '2': 'UL', '3': 'LL', '4': 'LR' }
        return `${num[1]}${symbols[num[0]] ?? ''}`
    }
    return num
}

export const toothId = (quadrant, toothType) => `teeth-${quadrant}${toothType}`

/**
 * First FDI digit per quadrant index (0-3), in the order the quadrant <g>
 * groups render. The arch mirrors so the patient's right side renders on the
 * viewer's left (PDA paper-chart convention):
 *   adult   → ['1', '2', '4', '3']  → 11-18 top-left, 21-28 top-right,
 *                                     41-48 bottom-left, 31-38 bottom-right
 *   primary → ['5', '6', '8', '7']  → 51-55, 61-65, 81-85, 71-75
 */
export const quadrantFdiStart = (qi, dentition = 'adult') => {
    const starts = dentition === 'primary' ? ['5', '6', '8', '7'] : ['1', '2', '4', '3']
    return starts[qi]
}

/** Full FDI number for quadrant index qi, tooth type index i (0-based). */
export const fdiNumber = (qi, i, dentition = 'adult') => `${quadrantFdiStart(qi, dentition)}${i + 1}`

/**
 * Map a quadrant-local point (x, y) into viewBox space, undoing the quadrant's
 * mirror transform. Used to place tooth-number labels upright — a <text> inside
 * a negatively-scaled <g> renders mirrored/upside-down.
 */
export const toViewBox = (qi, x, y) => {
    switch (qi) {
        case 1: // transform: scale(-1, 1) translate(-409, 0)  →  x' = 409 - x
            return { x: VIEW_W - x, y }
        case 2: // transform: scale(1, -1) translate(0, -694)  →  y' = 694 - y
            return { x, y: VIEW_H - y }
        case 3: // transform: scale(-1, -1) translate(-409, -694) → both flipped
            return { x: VIEW_W - x, y: VIEW_H - y }
        default: // identity
            return { x, y }
    }
}
