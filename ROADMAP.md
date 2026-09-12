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
- [ ] Corriger le bug update/delete des sous-catégories
- [ ] Authentification admin (générateur natif Rails 8 : `bin/rails generate authentication`)

**Tests**
- [ ] Test reproduisant le bug update/delete (rouge avant correctif)
- [ ] Tests d'authentification (accès refusé sans connexion / accordé après / échec sur identifiants invalides)

**Accessibilité**
- [ ] Formulaire de connexion : labels associés, focus visible, erreurs annoncées (`aria-live`)

---

## Axe 2 — Modernisation stockage & images

**Fonctionnalités**
- [ ] Remplacer `cl_image_tag`/`cl_picture_tag` par l'API native ActiveStorage (`variant`/`representation`)
- [ ] Étendre `colspan` sur `Photo` pour accepter 1/2/3 (migration + validations)
- [ ] Validation sécurité des uploads : type de fichier réel, poids/dimensions max
- [ ] Performance : lazy loading (`loading="lazy"`), format auto Cloudinary (`f_auto,q_auto`)

**Tests**
- [ ] Validations de `colspan` (1/2/3 acceptés, autres rejetés)
- [ ] Dimensions correctes des variants générés
- [ ] Upload rejeté si type de fichier invalide ou poids excessif

**Accessibilité**
- [ ] Ajouter un champ `alt_text` (ou `description`) sur `Photo`, éditable depuis l'admin

**Sécurité images**
- [ ] Évaluer l'ajout d'un filigrane via transformation d'URL Cloudinary (optionnel, à trancher)

---

## Axe 3 — Éditeur mosaïque en Back-Office

**Fonctionnalités**
- [ ] Glisser-déposer pour réordonner les photos
- [ ] Redimensionnement de case (1/2/3)
- [ ] Suppression de photo
- [ ] Décision technique : Stimulus + SortableJS vs composant React (dnd-kit)

**Tests**
- [ ] Test système (Capybara) du drag-and-drop : position persistée en base
- [ ] Test de suppression : DB + blob Cloudinary bien supprimés

**Accessibilité**
- [ ] Alternative clavier au drag-and-drop (boutons monter/descendre, `<select>` pour la taille)

---

## Axe 4 — Pages Front-Office manquantes

**Fonctionnalités**
- [ ] Page "À propos" (biographie éditable depuis l'admin)
- [ ] Contact par mail (formulaire ou lien)
- [ ] Finalisation accueil : grille 6 catégories, label au survol (+ tap mobile)
- [ ] Finalisation pages sous-catégories : mosaïque + lightbox plein écran avec navigation précédent/suivant
- [ ] SEO & partage social : meta description par page, Open Graph (`og:image`, `og:title`), sitemap.xml
- [ ] Anti-spam sur le formulaire de contact (champ honeypot)

**Tests**
- [ ] Rendu de chaque page (présence des 6 catégories, navigation, ouverture lightbox)
- [ ] Envoi du formulaire de contact (`ActionMailer::TestHelper`)
- [ ] Champ honeypot rejette bien une soumission bot

**Accessibilité**
- [ ] Sémantique HTML (`<nav>`, `<main>`, `<section>`, landmarks ARIA)
- [ ] Lightbox : `role="dialog"`, `aria-modal="true"`, focus trap, fermeture Échap, restitution du focus, navigation clavier (flèches)
- [ ] `alt` obligatoire sur chaque photo affichée
- [ ] Contraste suffisant des labels de catégorie sur fond photo

**Sécurité images**
- [ ] Désactivation du menu contextuel (`contextmenu` JS)
- [ ] Overlay transparent anti-glisser par-dessus l'image
- [ ] `user-select: none` / `pointer-events` ajustés en CSS
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
