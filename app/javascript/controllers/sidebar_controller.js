import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["nav", "backdrop"]

  get focusableElements() {
    return Array.from(this.navTarget.querySelectorAll("a, button"))
  }

  open(event) {
    this.lastFocusedElement = event.currentTarget
    this.navTarget.classList.add("is-open")
    this.backdropTarget.classList.add("is-open")
    document.body.style.overflow = "hidden"
    this.focusableElements[0]?.focus()
  }

  close() {
    // Le focus est restitué AVANT de masquer le panneau (et non après) :
    // ainsi, au moment où .sidebar-close sort de l'écran (transition CSS),
    // ce n'est déjà plus lui l'élément actif, donc aucune fenêtre où le
    // focus pourrait se retrouver ailleurs pendant la transition.
    if (this.lastFocusedElement) this.lastFocusedElement.focus()
    this.navTarget.classList.remove("is-open")
    this.backdropTarget.classList.remove("is-open")
    document.body.style.overflow = ""
  }

  trapFocus(event) {
    if (!this.navTarget.classList.contains("is-open")) return

    const elements = this.focusableElements
    const first = elements[0]
    const last = elements[elements.length - 1]

    if (event.shiftKey && document.activeElement === first) {
      event.preventDefault()
      last.focus()
    } else if (!event.shiftKey && document.activeElement === last) {
      event.preventDefault()
      first.focus()
    }
  }
}
