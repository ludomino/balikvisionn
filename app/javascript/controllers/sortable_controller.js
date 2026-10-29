import { Controller } from "@hotwired/stimulus"
import Sortable from "sortablejs"

// Glisser-déposer générique pour réordonner une liste ; persiste via une requête PATCH
export default class extends Controller {
  static values = { url: String, handle: String, idsParam: { type: String, default: "photo_ids" } }

  connect() {
    this.sortable = Sortable.create(this.element, {
      animation: 150,
      forceFallback: true,
      handle: this.hasHandleValue ? this.handleValue : undefined,
      onEnd: () => this.persistOrder()
    })
  }

  disconnect() {
    this.sortable?.destroy()
  }

  persistOrder() {
    const ids = Array.from(this.element.children).map((el) => el.dataset.id)

    fetch(this.urlValue, {
      method: "PATCH",
      headers: {
        "Content-Type": "application/json",
        "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]').content
      },
      body: JSON.stringify({ [this.idsParamValue]: ids })
    })
  }
}
