import { nextTick } from 'vue'

/**
 * Scroll helpers for Inertia forms.
 *
 * The app layout scrolls an inner container (`main`'s parent), not the window,
 * so window.scrollTo is useless inside authed pages — target that container
 * and fall back to the window on guest pages (auth screens scroll normally).
 */
const scrollContainer = () => {
    const main = document.querySelector('main')
    return main?.parentElement ?? window
}

/** Smooth-scroll the current viewport back to the top. */
export function scrollToTop() {
    const el = scrollContainer()
    el.scrollTo?.({ top: 0, behavior: 'smooth' })
}

/**
 * After a failed submit, wait for the inline errors to render, then scroll the
 * first invalid field into view and focus it (without double-scrolling).
 */
export async function scrollToFirstError() {
    await nextTick()
    const el = document.querySelector('[aria-invalid="true"], .border-status-cancelled')
    if (!el) return
    el.scrollIntoView({ behavior: 'smooth', block: 'center' })
    if (typeof el.focus === 'function') el.focus({ preventScroll: true })
}

/** Unique error messages from an Inertia useForm errors object (max `limit`). */
export function errorList(errors, limit = 3) {
    return [...new Set(Object.values(errors).filter(Boolean))].slice(0, limit)
}
