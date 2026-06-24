import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [ "button" ]

  handleKeydown(event) {
    // TODO: Investigate `metakey` refreshing with CMD+R on Mac
    // const pressedCtrl = event.metaKey || event.ctrlKey
    const pressedCtrl = event.ctrlKey
    const pressedKey = event.key.toLowerCase()

    if (pressedCtrl) {
      const buttonTarget = this.buttonTargets.find((el) => el.dataset.hotkey === pressedKey)
      if (buttonTarget) {
        event.preventDefault()
        buttonTarget.focus()
        buttonTarget.click()
      }
    }
  }
}