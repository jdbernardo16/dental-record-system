import { copyFileSync } from 'node:fs'

// vite-plugin-pwa emits the service worker and manifest into the Vite build
// output (public/build). Copy them to the public root so the service worker
// gets root scope (offline works for every route) and the manifest has a
// clean URL. Regenerated on every build; commit alongside public/build.
copyFileSync('public/build/sw.js', 'public/sw.js')
copyFileSync('public/build/manifest.webmanifest', 'public/manifest.webmanifest')

console.log('PWA: copied sw.js + manifest.webmanifest to public/')
