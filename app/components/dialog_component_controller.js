import Dialog from "@stimulus-components/dialog"

export default class extends Dialog {
  // A turbo-loaded dialog is rendered inside an enclosing <turbo-frame> (e.g.
  // the layout's shared "modal" frame); an inline dialog has none. The frame is
  // discovered from the DOM, so no frame id is configured or required — inline
  // dialogs simply have `frame == null` and skip all frame-specific behaviour.
  get frame() {
    return this.element.closest("turbo-frame")
  }

  connect() {
    super.connect()
    // Parent adds turbo:before-render → forceClose, closing dialogs before every page
    // render including broadcast morph refreshes. Replace it with a version that only
    // closes during actual navigation (renderMethod !== "morph"), so morphs let the
    // dialog stay open while the rest of the page updates.
    document.removeEventListener("turbo:before-render", this.forceClose)
    document.addEventListener("turbo:before-render", this.#closeUnlessMorph)
  }

  disconnect() {
    document.removeEventListener("turbo:before-render", this.#closeUnlessMorph)
    document.removeEventListener("keydown", this.#handleKeydown)
    super.disconnect()
  }

  open() {
    // Use non-modal show() instead of showModal() so the dialog does not enter the browser top layer.
    this.dialogTarget.show()
    document.addEventListener("keydown", this.#handleKeydown)
  }

  close() {
    document.removeEventListener("keydown", this.#handleKeydown)
    super.close()
  }

  forceClose() {
    if (!this.hasDialogTarget) return
    document.removeEventListener("keydown", this.#handleKeydown)
    super.forceClose()
  }

  dialogTargetConnected(dialog) {
    if (dialog.dataset.dialogAutoOpen === "true") {
      // One-shot: clear the flag so a later reconnection (e.g. when a
      // turbo_permanent frame carries the closed dialog to another page)
      // doesn't re-open it.
      dialog.dataset.dialogAutoOpen = "false"
      this.open()
    }
    if (this.frame) {
      dialog.addEventListener("turbo:submit-end", this.#closeOnSuccessfulSubmit)
    }
  }

  dialogTargetDisconnected(dialog) {
    if (this.frame) {
      dialog.removeEventListener("turbo:submit-end", this.#closeOnSuccessfulSubmit)
    }
  }

  #closeUnlessMorph = (event) => {
    if (event.detail.renderMethod === "morph") return
    this.forceClose()
  }

  #handleKeydown = (event) => {
    if (event.key !== "Escape") return
    event.preventDefault()
    this.close()
  }

  #closeOnSuccessfulSubmit = (event) => {
    if (!event.detail.success) return
    this.dialogTarget.addEventListener("close", this.#resetFrame, { once: true })
    this.close()
  }

  #resetFrame = () => {
    const frame = this.frame
    if (frame) frame.innerHTML = ""
  }
}
