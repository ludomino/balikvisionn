import { Controller } from "@hotwired/stimulus"

// Aperçu des photos sélectionnées avant l'envoi du formulaire
// juste une lecture locale des fichiers via URL.createObjectURL
export default class extends Controller {
  static targets = ["input", "list"]

  show() {
    this.listTarget.innerHTML = ""

    Array.from(this.inputTarget.files).forEach((file) => {
      if (!file.type.startsWith("image/")) return

      const url = URL.createObjectURL(file)
      const img = document.createElement("img")
      img.src = url
      img.alt = file.name
      img.className = "admin-form-photo-preview-thumb"
      img.addEventListener("load", () => URL.revokeObjectURL(url))

      this.listTarget.appendChild(img)
    })
  }
}
