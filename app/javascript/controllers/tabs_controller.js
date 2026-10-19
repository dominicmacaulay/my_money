import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="tabs"
// Each tab target pairs with the panel target at the same index.
export default class extends Controller {
  static targets = ["tab", "panel"]
  static classes = ["active"]

  select(event) {
    this._show(this.tabTargets.indexOf(event.currentTarget))
  }

  // Arrow keys move between tabs, per the WAI-ARIA tabs pattern.
  navigate(event) {
    const offsets = { ArrowLeft: -1, ArrowRight: 1 }
    if (!(event.key in offsets)) return

    event.preventDefault()
    const count = this.tabTargets.length
    const index = (this.tabTargets.indexOf(event.currentTarget) + offsets[event.key] + count) % count

    this._show(index)
    this.tabTargets[index].focus()
  }

  _show(selected) {
    this.tabTargets.forEach((tab, index) => {
      const active = index === selected

      tab.classList.toggle(this.activeClass, active)
      tab.setAttribute("aria-selected", active)
      tab.tabIndex = active ? 0 : -1
    })

    this.panelTargets.forEach((panel, index) => {
      panel.hidden = index !== selected
    })
  }
}
