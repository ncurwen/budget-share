import { Controller } from "@hotwired/stimulus"

// Auto-dismisses flash toasts after a short delay.
export default class extends Controller {
  connect() {
    this.timeout = setTimeout(() => this.element.remove(), 4000)
  }

  disconnect() {
    clearTimeout(this.timeout)
  }
}
