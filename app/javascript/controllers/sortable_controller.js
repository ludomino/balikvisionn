import { Controller } from "@hotwired/stimulus"
import Sortable from "sortablejs"

// Glisser-déposer pour réordonner les photos ; persiste via reorder (PATCH)
export default class extends Controller {
  static values = { url: String }

  connect() {
    this.sortable = Sortable.create(this.element, {
      animation: 150,
      forceFallback: true, // événements souris purs plutôt que l'API HTML5 (fiabilité + testable en Capybara)
      onEnd: () => this.persistOrder()
    })
  }

  disconnect() {
    this.sortable?.destroy()
  }

  persistOrder() {
    const photoIds = Array.from(this.element.children).map((el) => el.dataset.id)

    fetch(this.urlValue, {
      method: "PATCH",
      headers: {
        "Content-Type": "application/json",
        "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]').content
      },
      body: JSON.stringify({ photo_ids: photoIds })
    })
  }
}
