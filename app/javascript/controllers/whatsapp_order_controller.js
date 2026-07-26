import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["coffee", "name", "phone", "details"]
  static values = { number: String, referrerName: String }

  send() {
    const form = this.element.querySelector("form")
    if (form && !form.reportValidity()) return

    const checkedCoffee = this.coffeeTargets.find((radio) => radio.checked)
    if (!checkedCoffee) {
      const [firstRadio] = this.coffeeTargets
      if (firstRadio) {
        firstRadio.setCustomValidity("Escolha um café para pedir pelo WhatsApp.")
        firstRadio.reportValidity()
        firstRadio.setCustomValidity("")
      }
      return
    }

    const coffeeName = checkedCoffee.dataset.coffeeName
    const coffeePrice = checkedCoffee.dataset.coffeeDiscountedPrice

    const lines = [
      `Oi! Aqui é ${this.nameTarget.value}. ${this.referrerNameValue} me deu um desconto de presente e quero pedir um pacotinho de Musa - ${coffeeName} por ${coffeePrice}.`,
      this.hasDetailsTarget && this.detailsTarget.value ? `Observações: ${this.detailsTarget.value}` : null
    ].filter(Boolean)

    const message = lines.join("\n")
    window.open(`https://wa.me/${this.numberValue}?text=${encodeURIComponent(message)}`, "_blank")
  }
}
