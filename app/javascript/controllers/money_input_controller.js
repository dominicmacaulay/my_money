import { Controller } from "@hotwired/stimulus"
import AutoNumeric from 'autonumeric'


// Connects to data-controller="money-input"
export default class extends Controller {
  static values = { maxDigits: Number }

  connect() {
    this.value = parseFloat(this.element.value) * 100

    this.autoNumeric = new AutoNumeric(this.element, {
      currencySymbol: "$",
      noEventListeners: true,
      caretPositionOnFocus: "end",
      modifyValueOnWheel: false
    })

    this.maxDigits = this.autoNumeric.settings.maximumValue.length

    this.element.addEventListener("keydown", this.handleKeydown.bind(this))
    this.element.addEventListener("click", this.handleClick.bind(this))
  }

  handleClick(event) {
    event.preventDefault()

    const value = this.element.value
    this.element.value = ''
    this.element.value = value
  }

  handleKeydown(event) {
    event.preventDefault()

    if (isFinite(event.key) && this.value.toString().length < this.maxDigits) {
      const digit = parseInt(event.key)

      // shift the current value forward by one space and add the digit in the new space
      // e.g. 123 -> 1230 + 4 -> 1234
      this.value = this.value * 10 + digit

      this.updateInputValue()
    }

    if (event.key === "Backspace") {

      this.value = Math.floor(this.value / 10)

      this.updateInputValue()
    }
  }

  updateInputValue() {
    this.autoNumeric.set(this.value / 100)
  }
}
