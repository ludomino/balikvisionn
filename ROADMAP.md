# Feuille de route — Balikvisionn

*Dernière mise à jour : 2026-09-24*

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
- [x] Test reproduisant le bug update/delete (couverture confirmée le 2026-09-17 : `admin/subcategories_controller_test.rb` + `system/subcategories_test.rb`, 11 runs / 0 failures)
- [x] Tests d'authentification (accès refusé sans connexion / accordé après / échec sur identifiants invalides)

**Accessibilité**
- [x] Formulaire de connexion : labels associés, focus visible, erreurs annoncées (`aria-live`)

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

## Axe 5 — Interface Back-Office : tableau de bord & finitions admin

*Ajouté suite à validation des maquettes le 2026-09-17 (thème sombre #0a0a0a, accent kaki, Archivo)*
*Dernière mise à jour : 2026-09-12* → 2026-09-22

**Fonctionnalités**
- [x] Tableau de bord admin (nouvelle page d'accueil back-office)
  - [x] Indicateurs clés (nb catégories, sous-catégories, photos publiées)
  - [x] Alerte "catégories sans photo de couverture"
  - [x] Raccourcis (nouvelle catégorie / nouvelle sous-catégorie / modifier À propos)
  - [x] Grille de synthèse des catégories
  - [ ] *(bloc "derniers messages" + badge non-lus de la maquette volontairement omis — dépend de la V2, cf. Roadmap V2 en fin de fichier)*
- [x] Refonte visuelle des formulaires existants (`CategoryForm`, `SubcategoryForm`, `AboutForm`) sur le thème admin validé
- [x] Refonte visuelle de la vue catégorie admin (fil d'ariane, actions modifier/supprimer, grille sous-catégories)
- [ ] Refonte visuelle de l'éditeur mosaïque (poignée de drag, boutons de taille 1/2/3 et suppression en overlay)

**Tests**
- [x] Rendu du tableau de bord (indicateurs, alerte conditionnelle)

**Accessibilité**
- [x] Formulaires admin : labels associés, focus visible, erreurs annoncées (`aria-live`)
- [x] Contraste du texte secondaire vérifié au ratio WCAG AA (couleur réelle `$text-muted: #f4f4f4`, ratio 15:1 à 19:1 selon le fond — largement conforme)

**Responsive**
- [x] Adaptation mobile et tablette du back-office (Dashboard, CategoryForm, SubcategoryForm, PhotoEditor, AboutForm, CategoryShow) et du site public (Accueil, CategoryShow, À propos + Contact) — breakpoint mobile à `640px`, palier intermédiaire à `900px` pour `SubcategoryForm` et la page À propos (dont le layout desktop ne tenait pas tel quel en tablette), tablette ≥900px identique au desktop

---

## Axe 6 — Responsive & audit transverse

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

## Axe 7 — Environnement de Préproduction (recette client)

*Ajouté le 2026-09-24 — objectif : offrir au client un environnement de démonstration fidèle à la prod, pour recette avant toute mise en ligne officielle*

**Infrastructure**
- [ ] Créer le service Web de préprod sur Render
- [ ] Créer le projet Postgres de préprod sur Neon (plan gratuit — persistant, sans expiration, contrairement au Postgres gratuit de Render qui expire à 30 jours)
- [ ] `config/environments/staging.rb` (base `production.rb`, logs plus verbeux)
- [ ] Variables d'environnement dédiées : `RAILS_MASTER_KEY`, `DATABASE_URL` (URL "pooled" Neon, avec `prepared_statements: false` côté `database.yml`), `CLOUDINARY_URL` (dossier Cloudinary séparé de la prod, jamais partagé)
- [ ] Domaine/sous-domaine de préprod dédié

**Protection & indexation**
- [ ] Non-indexation par les moteurs de recherche (`X-Robots-Tag: noindex` ou robots.txt dédié à l'environnement)
- [ ] Authentification HTTP basique le temps de la recette

**Déploiement**
- [ ] Déploiement automatique vers la préprod à chaque push sur la branche d'intégration
- [ ] `bin/rails test` + `bin/rails test:system` exécutés en CI avant chaque déploiement

**Recette**
- [ ] Première recette client sur la préprod, retours consolidés avant l'Axe 8

---

## Axe 8 — Qualité & couverture globale

- [ ] Mesurer la couverture de tests réelle (SimpleCov), combler les trous identifiés
- [ ] Vérifier qu'aucune route admin n'est accessible sans authentification
- [ ] Revue de sécurité générale (paramètres filtrés, protection CSRF)

---

## Axe 9 — Préparation au déploiement

- [ ] Choix définitif de l'hébergement (VPS + Kamal vs PaaS)
- [ ] Base de données de production : démarrer sur Neon (plan gratuit) tant que le trafic reste faible ; bascule vers le plan Launch (pay-as-you-go, PITR 7 jours) déclenchée par un critère concret — juste avant de partager l'URL avec le client, ou dès que perdre des données au-delà de 6h devient risqué — pas un abonnement payant dès le premier jour (Crunchy Bridge en plan B si le comportement à l'usage ne convient pas)
- [ ] Configuration production réelle : domaine, `force_ssl`, `RAILS_MASTER_KEY`, clés Cloudinary
- [ ] Vérifier headers anti-hotlink et CSP avec le vrai domaine
- [ ] Mise en place du CI (`bin/ci`) via GitHub Actions
- [ ] Conformité légale française : mentions légales, politique de confidentialité (RGPD, collecte email via contact)
- [ ] Protection anti-abus (`Rack::Attack`) sur les endpoints publics sensibles (contact, connexion admin)

---

## Axe 10 — Mise en production

- [ ] Premier déploiement
- [ ] Smoke tests manuels en conditions réelles (incluant vérif a11y et protection images)
- [ ] Sauvegardes de base de données automatiques et récurrentes (pas ponctuelles)
- [ ] Monitoring d'erreurs en production (Sentry ou Honeybadger)


---

## Roadmap V2 — Améliorations futures

- [ ] **Gestion des messages de contact**
  - [ ] Persistance : migration + modèle `Contact` en ActiveRecord (`read_at`, `archived_at`) — actuellement un simple objet de formulaire, rien n'est stocké
  - [ ] `ContactsController` : enregistrer le message en base en plus de l'envoi mail
  - [ ] Page "Messages de contact" en admin (liste, non lus mis en évidence, répondre par mail, archiver) — maquette déjà validée (`ContactMessages.dc.html` + `ContactMessagesMobile.dc.html`)
  - [ ] Réactiver, sur le tableau de bord (Axe 5), le bloc "derniers messages" et le badge non-lus, omis en V1
  - [ ] Tests : modèle (persistance, statut), contrôleur (message enregistré + mail envoyé), marquer lu/archiver

- [ ] **Orientation portrait pour la mosaïque** (tailles 1/2/3 en vertical, en plus de l'horizontal actuel) — nécessite une colonne `rowspan`, `grid-auto-rows` fixe côté CSS (remplace l'`aspect-ratio` actuel), et `photo_mosaic_dimensions` adapté aux deux dimensions. Décision prise (2026-09-17) : orientation exclusive (paysage OU portrait, pas les deux en même temps) plutôt que deux curseurs indépendants — plus simple et plus cohérent avec un vrai grain de photo.
