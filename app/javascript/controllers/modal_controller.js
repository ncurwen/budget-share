import { Controller } from "@hotwired/stimulus"

// Drives a DaisyUI <dialog> modal. Opens on connect (so a Turbo Frame can load a
// form straight into an open modal) and closes/clears the frame on dismiss.
export default class extends Controller {
  static targets = ["dialog"]

  connect() {
    if (this.hasDialogTarget) this.dialogTarget.showModal()
  }

  close() {
    if (this.hasDialogTarget) this.dialogTarget.close()
    // Clear the modal frame so reopening fetches fresh content.
    const frame = document.getElementById("modal")
    if (frame) frame.innerHTML = ""
  }
}
