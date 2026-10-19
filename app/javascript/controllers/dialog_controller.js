import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="dialog"
// Opens a native <dialog> modally, so it escapes containers like .accordion that trap position: fixed.
export default class extends Controller {
  static targets = ["dialog"]

  connect() {
    this.beforeCache = this.close.bind(this)
    document.addEventListener("turbo:before-cache", this.beforeCache)
  }

  disconnect() {
    document.removeEventListener("turbo:before-cache", this.beforeCache)
  }

  open() {
    this.dialogTarget.showModal()
  }

  close() {
    this.dialogTarget.close()
  }

  // Clicks on the backdrop land on the <dialog> itself rather than its content.
  closeOnBackdrop(event) {
    if (event.target === this.dialogTarget) this.close()
  }
}
