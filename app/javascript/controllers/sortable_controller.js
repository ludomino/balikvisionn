import { Controller } from "@hotwired/stimulus"
import Sortable from "sortablejs"

// Glisser-déposer générique pour réordonner une liste ; persiste via une requête PATCH.
//
// Alternative clavier : si la poignée (handleValue) est un élément focusable
// (ex. un <button>), Flèche haut/bas la déplace d'une position sans glisser-
// déposer — pas de nouveau bouton, juste la poignée existante rendue
// opérable au clavier. Une zone aria-live annonce la nouvelle position.
export default class extends Controller {
  static values = { url: String, handle: String, idsParam: { type: String, default: "photo_ids" } }

  connect() {
    this.sortable = Sortable.create(this.element, {
      animation: 150,
      forceFallback: true,
      handle: this.hasHandleValue ? this.handleValue : undefined,
      onEnd: () => this.persistOrder()
    })
    this.onKeydown = this.onKeydown.bind(this)
    this.element.addEventListener("keydown", this.onKeydown)
    this.announcer = this.createAnnouncer()
  }

  disconnect() {
    this.sortable?.destroy()
    this.element.removeEventListener("keydown", this.onKeydown)
    this.announcer?.remove()
  }

  onKeydown(event) {
    if (event.key !== "ArrowUp" && event.key !== "ArrowDown") return
    if (this.hasHandleValue && !event.target.closest(this.handleValue)) return

    const item = event.target.closest("[data-id]")
    if (!item) return

    const sibling = event.key === "ArrowUp" ? item.previousElementSibling : item.nextElementSibling
    if (!sibling) return

    event.preventDefault()

    if (event.key === "ArrowUp") {
      item.parentNode.insertBefore(item, sibling)
    } else {
      item.parentNode.insertBefore(sibling, item)
    }

    event.target.focus()
    this.persistOrder()
    this.announcePosition(item)
  }

  createAnnouncer() {
    const el = document.createElement("div")
    el.setAttribute("role", "status")
    el.setAttribute("aria-live", "polite")
    el.className = "visually-hidden"
    this.element.after(el)
    return el
  }

  announcePosition(item) {
    const position = Array.from(this.element.children).indexOf(item) + 1
    const total = this.element.children.length
    this.announcer.textContent = `Déplacé en position ${position} sur ${total}`
  }

  persistOrder() {
    const ids = Array.from(this.element.children).map((el) => el.dataset.id)
    // En environnement de test, allow_forgery_protection=false fait que
    // csrf_meta_tags ne rend aucune balise meta ; le lookup est donc
    // défensif plutôt que de planter silencieusement dans onKeydown.
    const csrfToken = document.querySelector('meta[name="csrf-token"]')?.content

    fetch(this.urlValue, {
      method: "PATCH",
      headers: {
        "Content-Type": "application/json",
        ...(csrfToken ? { "X-CSRF-Token": csrfToken } : {})
      },
      body: JSON.stringify({ [this.idsParamValue]: ids })
    })
  }
}
