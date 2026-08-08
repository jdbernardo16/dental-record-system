/**
 * Ported from react-odontogram (MIT) — https://github.com/biomathcode/react-odontogram
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
