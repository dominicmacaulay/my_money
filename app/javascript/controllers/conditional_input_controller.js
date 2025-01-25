import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="conditional-input"
export default class extends Controller {
  static targets = ["trigger", "conditionalInputWrapper", "conditionalInput"]
  static values = { condition: String }

  connect() {
    this.checkCondition()
    this.triggerTarget.addEventListener("change", this.checkCondition.bind(this))
  }

  checkCondition() {
    if (this.triggerTarget.value === this.conditionValue) {
      this.conditionalInputWrapperTarget.classList.remove("hidden")
    } else {
      this.conditionalInputWrapperTarget.classList.add("hidden")
      this.conditionalInputTarget.value = ""
    }
  }
}
