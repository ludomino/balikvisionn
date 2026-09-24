import { Controller } from "@hotwired/stimulus"

// Bascule l'affichage du champ "texte alternatif" en overlay sur une carte de la mosaïque
export default class extends Controller {
  static targets = ["altPanel"]

  toggleAlt() {
    this.altPanelTarget.hidden = !this.altPanelTarget.hidden
  }
}
