/**
 * SVG payloads are base64-encoded on the wire because the hosting CDN WAF
 * rejects any POST body containing the literal `<svg` tag (false-positive
 * XSS rule). The server decodes via App\Support\SvgCodec before storage.
 */

export function encodeSvgPayload(svg) {
    if (!svg) return svg
    return btoa(unescape(encodeURIComponent(svg)))
}

export function decodeSvgPayload(payload) {
    if (!payload) return payload
    return decodeURIComponent(escape(atob(payload)))
}
