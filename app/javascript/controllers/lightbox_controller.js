import { Controller } from "@hotwired/stimulus"

// Avant : aucune vue plein écran / Après : ouverture, navigation clavier + flèches, focus piégé pour l'a11y
export default class extends Controller {
  static targets = ["overlay", "image"]
  static values = { photos: Array, index: Number }

  get focusableElements() {
    return Array.from(this.overlayTarget.querySelectorAll("button"))
  }

  open(event) {
    this.lastFocusedElement = event.currentTarget
    this.indexValue = parseInt(event.params.index, 10)
    this.overlayTarget.classList.add("is-open")
    document.body.style.overflow = "hidden"
    this.showCurrentPhoto()
    // Avant : focus sur l'overlay lui-même / Après : focus direct sur le premier bouton, cohérent avec le piège de focus dès la première touche Tab
    this.focusableElements[0].focus()
  }

  close() {
    this.overlayTarget.classList.remove("is-open")
    document.body.style.overflow = ""
    if (this.lastFocusedElement) this.lastFocusedElement.focus()
  }

  next() {
    this.indexValue = (this.indexValue + 1) % this.photosValue.length
    this.showCurrentPhoto()
  }

  previous() {
    this.indexValue = (this.indexValue - 1 + this.photosValue.length) % this.photosValue.length
    this.showCurrentPhoto()
  }

  showCurrentPhoto() {
    const photo = this.photosValue[this.indexValue]
    this.imageTarget.src = photo.url
    this.imageTarget.alt = photo.alt
  }

  // Avant : Tab pouvait sortir de la modale / Après : Tab boucle entre les boutons de l'overlay, Shift+Tab dans l'autre sens
  trapFocus(event) {
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
