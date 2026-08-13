import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { delay: { type: Number, default: 3000 } }

  connect() {
    if (this.delayValue > 0) {
      this.timeout = setTimeout(() => this.hide(), this.delayValue);
    }
  }

  disconnect() {
    clearTimeout(this.timeout);
  }

  hide() {
    this.element.remove();
  }
}
