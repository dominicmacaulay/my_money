// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import "./controllers"
import './initializers/frame_missing_handler'
import './initializers/honeybadger'
import './initializers/turbo_confirm'

// Shoelace
import { registerIconLibrary } from "@shoelace-style/shoelace/dist/utilities/icon-library"
registerIconLibrary('system', {resolver: (_name) => ''}) // No Icons needed for this project

import '@shoelace-style/shoelace/dist/components/dropdown/dropdown' // Dropdown component
import '@shoelace-style/shoelace/dist/components/menu/menu' // Menu component
import '@shoelace-style/shoelace/dist/components/menu-item/menu-item' // Menu-item component

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

