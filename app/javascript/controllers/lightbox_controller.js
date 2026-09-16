import { Controller } from "@hotwired/stimulus"

// Avant : aucune vue plein écran / Après : ouverture, navigation clavier + flèches, focus géré pour l'a11y
export default class extends Controller {
  static targets = ["overlay", "image"]
  static values = { photos: Array, index: Number }

  open(event) {
    this.lastFocusedElement = event.currentTarget
    this.indexValue = parseInt(event.params.index, 10)
    this.overlayTarget.classList.add("is-open")
    document.body.style.overflow = "hidden"
    this.showCurrentPhoto()
    this.overlayTarget.focus()
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
}
