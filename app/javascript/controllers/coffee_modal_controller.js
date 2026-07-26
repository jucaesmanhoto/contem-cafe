import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["dialog"]

  open(event) {
    event.preventDefault()
    event.stopPropagation()
    this.dialogTarget.showModal()
  }

  close() {
    this.dialogTarget.close()
  }
}
