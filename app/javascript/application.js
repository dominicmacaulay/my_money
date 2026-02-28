// Entry point for importmap-rails
import "@hotwired/turbo-rails"
import "controllers"
import "initializers/turbo_confirm"
import "initializers/frame_missing_handler"
import "initializers/before_morph_handler"

// Shoelace
import { registerIconLibrary } from "@shoelace-style/shoelace/dist/utilities/icon-library"
registerIconLibrary('system', {resolver: (_name) => ''}) // No Icons needed for this project

import '@shoelace-style/shoelace/dist/components/dropdown/dropdown' // Dropdown component
import '@shoelace-style/shoelace/dist/components/menu/menu' // Menu component
import '@shoelace-style/shoelace/dist/components/menu-item/menu-item' // Menu-item component
import '@shoelace-style/shoelace/dist/components/divider/divider' // Menu-item component

// Theme switching
if (window.matchMedia && window.matchMedia('(prefers-color-scheme: dark)').matches) {
  document.documentElement.classList.replace('sl-theme-light', 'sl-theme-dark')
}

window.matchMedia('(prefers-color-scheme: dark)').addEventListener('change', (event) => {
  const themeMap = {
    true: 'dark',
    false: 'light'
  }

  const oldTheme = `sl-theme-${themeMap[!event.matches]}`
  const newTheme = `sl-theme-${themeMap[event.matches]}`
  document.documentElement.classList.replace(oldTheme, newTheme)
})
