import Dialog from "@stimulus-components/dialog"

export default class extends Dialog {
  #loadingHTML = ""

  // The content frame lives INSIDE the dialog: the persistent modal shell wraps a
  // <turbo-frame> that new/edit forms load into. Inline/confirm dialogs have no
  // inner frame, so `frame == null` and all frame-specific behaviour is skipped.
  get frame() {
    return this.element.querySelector("turbo-frame")
  }

  connect() {
    super.connect()

    // Parent adds turbo:before-render → forceClose, closing dialogs before every page
    // render including broadcast morph refreshes. Replace it with a version that only
    // closes during actual navigation (renderMethod !== "morph"), so morphs let the
    // dialog stay open while the rest of the page updates.
    //
    // This depends on the parent binding `forceClose` to the instance in initialize()
    // and registering that exact reference on turbo:before-render in connect(). If a
    // future upstream version stops binding it, removeEventListener would silently
    // no-op and the parent's blanket close would survive — so feature-detect the bound
    // own-property and warn rather than break morph-aware closing in silence.
    if (Object.hasOwn(this, "forceClose")) {
      document.removeEventListener("turbo:before-render", this.forceClose)
    } else {
      console.warn("[dialog-component] parent Dialog no longer binds forceClose; morph-aware close may be broken")
    }
    document.addEventListener("turbo:before-render", this.#closeUnlessMorph)

    // Escape closes the dialog. open() uses non-modal show() (see below), which forgoes
    // the native <dialog> Escape handling, so wire it manually. A single guarded
    // listener — rather than toggling on open/close — survives native closes via the ✕
    // button or backdrop form, which bypass close() and would otherwise strand it.
    document.addEventListener("keydown", this.#handleKeydown)

    // Open the instant the content frame starts fetching so a slow form load shows
    // the dialog + spinner immediately instead of a dead click. Prefetch fires this
    // event on the link (outside the shell), so only the frame's own navigation —
    // and the in-dialog form submit, a harmless no-op while open — reach here.
    if (this.frame) {
      this.element.addEventListener("turbo:before-fetch-request", this.#openOnFetch)
    }
  }

  disconnect() {
    document.removeEventListener("turbo:before-render", this.#closeUnlessMorph)
    document.removeEventListener("keydown", this.#handleKeydown)
    this.element.removeEventListener("turbo:before-fetch-request", this.#openOnFetch)
    super.disconnect()
  }

  open() {
    // Use non-modal show() instead of showModal() so the dialog does not enter the browser top layer.
    this.dialogTarget.show()
  }

  forceClose() {
    if (!this.hasDialogTarget) return
    super.forceClose()
  }

  dialogTargetConnected(dialog) {
    if (this.frame) {
      // Cache the spinner markup so we can restore it when the dialog reopens,
      // ensuring a reopened dialog shows the throbber, never stale form content.
      this.#loadingHTML = this.frame.innerHTML
      dialog.addEventListener("turbo:submit-end", this.#closeOnSuccessfulSubmit)
    }
  }

  dialogTargetDisconnected(dialog) {
    if (this.frame) {
      dialog.removeEventListener("turbo:submit-end", this.#closeOnSuccessfulSubmit)
    }
  }

  // Only a frame navigation (opening the dialog) targets the frame itself; an
  // in-dialog form submit targets its <form>. Reset to the spinner + open only
  // for the former — so submitting never wipes the form, and resetting at open
  // (not close) means closing fades the form out without the spinner flashing in.
  #openOnFetch = (event) => {
    if (event.target !== this.frame) return
    this.frame.innerHTML = this.#loadingHTML
    this.open()
  }

  #closeUnlessMorph = (event) => {
    if (event.detail.renderMethod === "morph") return
    this.forceClose()
  }

  #handleKeydown = (event) => {
    if (event.key !== "Escape") return
    if (!this.dialogTarget.open) return
    event.preventDefault()
    this.close()
  }

  // A failed submit (422) keeps the dialog open: it re-renders the frame with the
  // form errors and never closes, leaving the errors in place (no reset on close).
  #closeOnSuccessfulSubmit = (event) => {
    if (!event.detail.success) return
    this.close()
  }
}
