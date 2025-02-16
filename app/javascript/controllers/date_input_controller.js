import { Controller } from "@hotwired/stimulus"

import flatpickr from "flatpickr"

// Connects to data-controller="date-input"
export default class extends Controller {
  connect() {
    flatpickr(this.element, {
      allowInput: true
    })
  }
}
