/**
 * Signature SVG helpers.
 *
 * signature_pad serializes the pad canvas to an SVG whose viewBox/width/height
 * come from the canvas *bitmap* size. When a pad mounts inside a hidden
 * container (v-show wizard steps, dialogs mid-animation) the bitmap is 0×0
 * and the resulting SVG is `viewBox="0 0 0 0" width="0" height="0"` — it
 * renders blank and is rejected by the backend guard (SignatureStorageService).
 *
 * normalizeSvg rewrites a zero-size SVG's geometry from the actual path data,
 * so a captured stroke still round-trips even if the canvas was not sized yet.
 */

const ZERO_VIEWBOX = /viewBox=["']0+ 0+ 0+ 0+["']/

/**
 * Rewrite a zero-size signature SVG to the bounding box of its paths.
 * Returns the input unchanged when the SVG is fine or truly empty.
 */
export function normalizeSvg(svg) {
    if (!svg || !ZERO_VIEWBOX.test(svg)) return svg

    const probe = document.createElementNS('http://www.w3.org/2000/svg', 'svg')
    probe.innerHTML = svg

    let bbox
    try {
        bbox = probe.getBBox()
    } catch {
        return svg
    }

    if (!bbox || (bbox.width === 0 && bbox.height === 0)) return svg

    const pad = 4
    const x = Math.floor(bbox.x - pad)
    const y = Math.floor(bbox.y - pad)
    const width = Math.ceil(bbox.width + pad * 2)
    const height = Math.ceil(bbox.height + pad * 2)

    return svg
        .replace(/viewBox=["'][^"']*["']/, `viewBox="${x} ${y} ${width} ${height}"`)
        .replace(/\swidth=["'][^"']*["']/, ` width="${width}"`)
        .replace(/\sheight=["'][^"']*["']/, ` height="${height}"`)
}
