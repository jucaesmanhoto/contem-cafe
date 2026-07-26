import { Controller } from "@hotwired/stimulus"

// Formats Brazilian phone/WhatsApp numbers as (DD) 9XXXX-XXXX while typing.
export default class extends Controller {
  format(event) {
    const digits = event.target.value.replace(/\D/g, "").slice(0, 11)

    let formatted = digits
    if (digits.length > 0) {
      formatted = `(${digits.slice(0, 2)}`
    }
    if (digits.length >= 3) {
      formatted += `) ${digits.slice(2, 7)}`
    }
    if (digits.length >= 8) {
      formatted += `-${digits.slice(7, 11)}`
    }

    event.target.value = formatted
  }
}
