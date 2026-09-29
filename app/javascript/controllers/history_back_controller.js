import { Controller } from "@hotwired/stimulus"

// Link "Voltar": volta no histórico quando a página anterior é deste site.
// Quem chega direto (QR code do rótulo, link compartilhado) não tem para onde
// voltar aqui dentro, então segue o href do link, que é o destino de fallback.
export default class extends Controller {
  go(event) {
    if (this.#hasPreviousPageOnThisSite()) {
      event.preventDefault()
      window.history.back()
    }
  }

  #hasPreviousPageOnThisSite() {
    // Navegação pelo Turbo Drive (fetch + pushState): o navegador não atualiza
    // document.referrer, mas o Turbo numera as entradas do histórico que cria.
    // Índice > 0 = existe uma entrada anterior criada por este site nesta aba.
    const turboIndex = window.history.state?.turbo?.restorationIndex ?? 0
    if (turboIndex > 0) return true

    // Página carregada de verdade (índice 0): aí o referrer é o desta página.
    return window.history.length > 1 && this.#referrerIsThisSite()
  }

  #referrerIsThisSite() {
    try {
      return document.referrer !== "" && new URL(document.referrer).origin === window.location.origin
    } catch {
      return false
    }
  }
}
