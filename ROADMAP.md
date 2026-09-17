# Feuille de route — Balikvisionn

*Dernière mise à jour : 2026-09-12*

## État actuel

- Stack à jour : Ruby 3.4.10, Rails 8.1.3.1 (fusionné sur `master`)
- Modèle de données de base en place : `Category` → `Subcategory` → `Photo` (mosaïque avec `colspan`)
- Tests manuels : Catégories create/update/delete OK. Sous-catégories : create OK, **update/delete KO** (bug connu, priorité axe 1)
- Direction visuelle validée (accueil grille 6 catégories, pages sous-catégories avec mosaïque + lightbox)
- Structure confirmée : partie ADMIN (back-office) et partie USER (front-office) distinctes

## Principes transverses (s'appliquent à tous les axes ci-dessous)

1. **TDD strict** : chaque fonctionnalité (ou correctif) s'accompagne de son test écrit *au moment* où elle est développée — jamais reporté à la fin. Pour un bug, le test qui le reproduit s'écrit avant le correctif.
2. **Accessibilité (a11y)** : sémantique HTML stricte, ARIA, alt text sur toutes les photos, navigation clavier complète.
3. **Protection des images** : mesures dissuasives (anti clic-droit, anti-glisser, anti-hotlink) — à noter : aucune de ces mesures n'est infranchissable pour un utilisateur déterminé (devtools, capture d'écran) ; un filigrane Cloudinary reste la seule protection réellement robuste si nécessaire.

---

## Axe 1 — Stabilisation du Back-Office (fondations)

**Fonctionnalités**
- [x] Corriger le bug update/delete des sous-catégories
- [x] Authentification admin (générateur natif Rails 8 : `bin/rails generate authentication`)

**Tests**
- [ ] Test reproduisant le bug update/delete (rouge avant correctif)
- [x] Tests d'authentification (accès refusé sans connexion / accordé après / échec sur identifiants invalides)

**Accessibilité**
- [ ] Formulaire de connexion : labels associés, focus visible, erreurs annoncées (`aria-live`)

---

## Axe 2 — Modernisation stockage & images

**Fonctionnalités**
- [x] Remplacer `cl_image_tag`/`cl_picture_tag` par un helper natif (`attachment.url()` + transformations Cloudinary passthrough)
- [x] Étendre `colspan` sur `Photo` pour accepter 1/2/3 (migration + validations)
- [x] Validation sécurité des uploads :
  - [x] Type de fichier réel (via `Marcel`) : JPEG/PNG/WebP/HEIC uniquement, reste rejeté
  - [x] Poids max en garde-fou (20 Mo) — validation modèle + pré-check contrôleur avant `.attach`
  - [x] Redimensionnement/compression auto à l'upload (`transformation:` dans `storage.yml`, max 2500px, `quality: auto`)
- [x] Performance : lazy loading (`loading="lazy"`), format auto Cloudinary (`f_auto,q_auto`)

**Tests**
- [x] Validations de `colspan` (1/2/3 acceptés, autres rejetés)
- [x] Rendu du helper image (alt, lazy loading, cas non-attaché)
- [x] Upload rejeté si type de fichier invalide ou poids excessif

**Accessibilité**
- [x] Ajouter un champ `alt_text` (ou `description`) sur `Photo`, éditable depuis l'admin

**Sécurité images**
- [x] Filigrane évalué : écarté pour l'instant — le plafond 2500px à l'upload sert déjà de protection, priorité donnée à la présentation visuelle du portfolio. Réévaluable si besoin exprimé par le client (overlay Cloudinary, ajout rapide le cas échéant).

---

## Axe 3 — Éditeur mosaïque en Back-Office

**Fonctionnalités**
- [x] Glisser-déposer pour réordonner les photos (Stimulus + SortableJS, forceFallback pour fiabilité)
- [x] Redimensionnement de case (1/2/3)
- [x] Suppression de photo
- [x] Décision technique : Stimulus + SortableJS (cohérent avec l'architecture existante, pas de build step)

**Pistes futures (non planifiées)**
- [ ] Orientation portrait pour la mosaïque (tailles 1/2/3 en vertical, en plus de l'horizontal actuel) — nécessite une colonne `rowspan`, `grid-auto-rows` fixe côté CSS (remplace l'`aspect-ratio` actuel), et `photo_mosaic_dimensions` adapté aux deux dimensions. Décision prise (2026-09-17) : orientation exclusive (paysage OU portrait, pas les deux en même temps) plutôt que deux curseurs indépendants — plus simple et plus cohérent avec un vrai grain de photo.

**Tests**
- [x] Test système (Capybara) du drag-and-drop : position persistée en base
- [x] Test de suppression : DB + blob Cloudinary bien supprimés

**Accessibilité**
- [x] Alternative clavier au drag-and-drop (boutons monter/descendre, `<select>` pour la taille)

## Axe 4 — Pages Front-Office manquantes

**Fonctionnalités**
- [x] Page "À propos" (biographie éditable depuis l'admin)
- [x] Contact par mail (formulaire ou lien)
- [x] Finalisation accueil : grille 6 catégories, label au survol (+ tap mobile)
- [x] Finalisation pages sous-catégories : mosaïque + lightbox plein écran avec navigation précédent/suivant
- [ ] SEO & partage social : meta description par page, Open Graph (`og:image`, `og:title`), sitemap.xml
- [x] Anti-spam sur le formulaire de contact (champ honeypot)

**Tests**
- [x] Rendu de chaque page (présence des catégories, navigation, ouverture lightbox)
- [x] Envoi du formulaire de contact (`ActionMailer::TestHelper`)
- [x] Champ honeypot rejette bien une soumission bot

**Accessibilité**
- [x] Sémantique HTML (`<nav>`, `<main>`, `<section>`, landmarks ARIA)
- [x] Lightbox : `role="dialog"`, `aria-modal="true"`, focus trap, fermeture Échap, restitution du focus, navigation clavier (flèches)
- [x] `alt` obligatoire sur chaque photo affichée
- [ ] Contraste suffisant des labels de catégorie sur fond photo

**Sécurité images**
- [x] Désactivation du menu contextuel (`contextmenu` JS)
- [x] `user-select: none` / anti-glisser ajustés en CSS et HTML
- [ ] Headers anti-hotlink (vérification `Referer`, configurable côté Cloudinary)

---

## Axe 5 — Responsive & audit transverse

**Fonctionnalités**
- [ ] Adaptation mobile (grille empilée, label affiché au tap)

**Tests**
- [ ] Tests système à plusieurs largeurs de viewport
- [ ] Vérification de l'affichage du label au tap sur mobile

**Accessibilité**
- [ ] Audit complet (Lighthouse ou axe-core) sur toutes les pages
- [ ] Zoom texte 200 % sans casser la mise en page
- [ ] Zones tactiles ≥ 44×44px

**Sécurité images**
- [ ] Blocage du menu contextuel "enregistrer l'image" en appui long (tactile)

---

## Axe 6 — Qualité & couverture globale

- [ ] Mesurer la couverture de tests réelle (SimpleCov), combler les trous identifiés
- [ ] Vérifier qu'aucune route admin n'est accessible sans authentification
- [ ] Revue de sécurité générale (paramètres filtrés, protection CSRF)

---

## Axe 7 — Préparation au déploiement

- [ ] Choix définitif de l'hébergement (VPS + Kamal vs PaaS)
- [ ] Configuration production réelle : domaine, `force_ssl`, `RAILS_MASTER_KEY`, clés Cloudinary
- [ ] Vérifier headers anti-hotlink et CSP avec le vrai domaine
- [ ] Mise en place du CI (`bin/ci`) via GitHub Actions
- [ ] Conformité légale française : mentions légales, politique de confidentialité (RGPD, collecte email via contact)
- [ ] Protection anti-abus (`Rack::Attack`) sur les endpoints publics sensibles (contact, connexion admin)

---

## Axe 8 — Mise en production

- [ ] Premier déploiement
- [ ] Smoke tests manuels en conditions réelles (incluant vérif a11y et protection images)
- [ ] Sauvegardes de base de données automatiques et récurrentes (pas ponctuelles)
- [ ] Monitoring d'erreurs en production (Sentry ou Honeybadger)
