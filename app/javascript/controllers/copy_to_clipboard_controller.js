import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["source", "feedback"]

  async copy() {
    const text = this.sourceTarget.value ?? this.sourceTarget.textContent

    try {
      if (navigator.clipboard && window.isSecureContext) {
        await navigator.clipboard.writeText(text)
      } else {
        const helperInput = document.createElement("textarea")
        helperInput.value = text
        helperInput.setAttribute("readonly", "")
        helperInput.style.position = "absolute"
        helperInput.style.left = "-9999px"
        document.body.appendChild(helperInput)
        helperInput.select()
        document.execCommand("copy")
        document.body.removeChild(helperInput)
      }

      this.showFeedback("Link copiado!")
    } catch (error) {
      this.showFeedback("Não foi possível copiar automaticamente. Selecione o link e copie manualmente.")
    }
  }

  showFeedback(message) {
    if (!this.hasFeedbackTarget) return

    this.feedbackTarget.textContent = message
    this.feedbackTarget.classList.add("is-visible")
  }
}
