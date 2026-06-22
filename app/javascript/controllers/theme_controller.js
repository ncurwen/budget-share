import { Controller } from "@hotwired/stimulus"

// Toggles the DaisyUI theme on <html data-theme> and remembers the choice.
export default class extends Controller {
  connect() {
    const saved = localStorage.getItem("theme")
    if (saved) this.element.setAttribute("data-theme", saved)
  }

  toggle() {
    const next = this.element.getAttribute("data-theme") === "dark" ? "light" : "dark"
    this.element.setAttribute("data-theme", next)
    localStorage.setItem("theme", next)
  }
}
