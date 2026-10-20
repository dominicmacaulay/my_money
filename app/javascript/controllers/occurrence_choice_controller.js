import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="occurrence-choice"
// The dialog's buttons pick which occurrences to update, so this carries over whether
// the button that opened it was "Update and New".
export default class extends Controller {
  static targets = ["submitAndNew"]

  remember(event) {
    this.submitAndNewTarget.value = event.currentTarget.value
  }
}
