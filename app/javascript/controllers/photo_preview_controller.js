import { Controller } from "@hotwired/stimulus"

// Aperçu des fichiers sélectionnés avant l'envoi du formulaire
// juste une lecture locale via URL.createObjectURL, rien n'est envoyé au serveur ici
export default class extends Controller {
  static targets = ["input", "list", "name"]
  static values = { thumbClass: { type: String, default: "admin-form-photo-preview-thumb" } }

  show() {
    const files = Array.from(this.inputTarget.files)

    if (this.hasListTarget) {
      this.listTarget.innerHTML = ""

      files.forEach((file) => {
        if (!file.type.startsWith("image/")) return

        const url = URL.createObjectURL(file)
        const img = document.createElement("img")
        img.src = url
        img.alt = file.name
        img.className = this.thumbClassValue
        img.addEventListener("load", () => URL.revokeObjectURL(url))

        this.listTarget.appendChild(img)
      })
    }

    if (this.hasNameTarget) {
      const first = files[0]
      if (first) this.nameTarget.textContent = first.name
    }
  }
}
