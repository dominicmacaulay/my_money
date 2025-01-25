import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="conditional-input"
export default class extends Controller {
  static targets = ["trigger", "conditionalInput"]
  static values = { condition: String }

  connect() {
    this.conditionalInputTarget.classList.add("hidden")
    this.triggerTarget.addEventListener("change", this.checkCondition.bind(this))
  }

  checkCondition() {
    if (this.triggerTarget.value === this.conditionValue) {
      this.conditionalInputTarget.classList.remove("hidden")
    } else {
      this.conditionalInputTarget.classList.add("hidden")
    }
  }
}
