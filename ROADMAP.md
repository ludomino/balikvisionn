# Feuille de route — Balikvisionn

*Dernière mise à jour : 2026-10-23*

## État actuel

- Stack à jour : Ruby 3.4.10, Rails 8.1.3.1 (fusionné sur `master`)
- Modèle de données de base en place : `Category` → `Subcategory` → `Photo` (mosaïque avec `colspan`)
- Tests manuels : Catégories create/update/delete OK. Sous-catégories : create OK, **update/delete KO** (bug connu, priorité axe 1)
- Direction visuelle validée (menu latéral fixe, page catégorie en liste de sous-catégories 4:5, accueil en sélection de favoris curée en admin, pages sous-catégories avec mosaïque 4:5 + lightbox) — voir Axes 8 à 10
- Structure confirmée : partie ADMIN (back-office) et partie USER (front-office) distinctes

## Principes transverses (s'appliquent à tous les axes ci-dessous)

1. **TDD strict** : chaque fonctionnalité (ou correctif) s'accompagne de son test écrit *au moment* où elle est développée — jamais reporté à la fin. Pour un bug, le test qui le reproduit s'écrit avant le correctif.
2. **Accessibilité (a11y)** : sémantique HTML stricte, ARIA, alt text sur toutes les photos, navigation clavier complète.
3. **Protection des images** : mesures dissuasives (anti clic-droit, anti-glisser, anti-hotlink) — à noter : aucune de ces mesures n'est infranchissable pour un utilisateur déterminé (devtools, capture d'écran) ; un filigrane Cloudinary reste la seule protection réellement robuste si nécessaire.
4. **Ratio 4:5 sur toute photo affichée** (ajouté le 2026-10-23) : aucune photo du site, publique ou admin, n'est présentée hors de son ratio natif 4:5 — `aspect-ratio: 4/5` + `object-fit: cover` partout (cards, couvertures, mosaïque, lightbox, aperçus admin), sans recadrage carré ni paysage.

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


---

## Axe 4 — Pages Front-Office manquantes

**Fonctionnalités**
- [x] Page "À propos" (biographie éditable depuis l'admin)
- [x] Contact par mail (formulaire ou lien)
- [x] Finalisation accueil : grille 6 catégories, label au survol (+ tap mobile)
- [x] Finalisation pages sous-catégories : mosaïque + lightbox plein écran avec navigation précédent/suivant
- [x] SEO & partage social : meta description par page, Open Graph (`og:image`, `og:title`), sitemap.xml généré dynamiquement (`request`/`url_for`, aucun domaine codé en dur)
- [x] Anti-spam sur le formulaire de contact (champ honeypot)

**Tests**
- [x] Rendu de chaque page (présence des catégories, navigation, ouverture lightbox)
- [x] Envoi du formulaire de contact (`ActionMailer::TestHelper`)
- [x] Champ honeypot rejette bien une soumission bot

**Accessibilité**
- [x] Sémantique HTML (`<nav>`, `<main>`, `<section>`, landmarks ARIA)
- [x] Lightbox : `role="dialog"`, `aria-modal="true"`, focus trap, fermeture Échap, restitution du focus, navigation clavier (flèches)
- [x] `alt` obligatoire sur chaque photo affichée
- [x] Contraste suffisant des labels de catégorie sur fond photo (halo de texte + fond semi-opaque sur `.card-category-text`)

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
- [x] Refonte visuelle de l'éditeur mosaïque (poignée de drag, boutons de taille 1/2/3 et suppression en overlay) — confirmé conforme lors de l'audit du 2026-10-23

**Tests**
- [x] Rendu du tableau de bord (indicateurs, alerte conditionnelle)

**Accessibilité**
- [x] Formulaires admin : labels associés, focus visible, erreurs annoncées (`aria-live`)
- [x] Contraste du texte secondaire vérifié au ratio WCAG AA (couleur réelle `$text-muted: #f4f4f4`, ratio 15:1 à 19:1 selon le fond — largement conforme)

**Responsive**
- [x] Adaptation mobile et tablette du back-office (Dashboard, CategoryForm, SubcategoryForm, PhotoEditor, AboutForm, CategoryShow) et du site public (Accueil, CategoryShow, À propos + Contact) — breakpoint mobile à `640px`, palier intermédiaire à `900px` pour `SubcategoryForm` et la page À propos (dont le layout desktop ne tenait pas tel quel en tablette), tablette ≥900px identique au desktop


---

## Axe 6 — Responsive & audit transverse

*Terminé le 2026-09-24*

**Fonctionnalités**
- [x] Adaptation mobile (grille empilée, label affiché au tap)

**Tests**
- [x] Tests système à plusieurs largeurs de viewport (`responsive_test.rb`)
- [x] Vérification de l'affichage du label au tap sur mobile (émulation tactile Chrome, `responsive_test.rb`)

**Accessibilité**
- [x] Audit complet (axe-core, WCAG 2A/2AA, 7 pages publiques + admin) — 4 violations réelles trouvées et corrigées (`accessibility_test.rb`)
- [x] Zoom texte 200 % sans casser la mise en page (en-têtes en `min-height`, vérifié manuellement)
- [x] Zones tactiles ≥ 44×44px — exception documentée : contrôles overlay de l'éditeur mosaïque en `span-1` (~22-30px), un vrai 44px ferait se chevaucher les boutons sur des vignettes de ~100-120px

**Sécurité images**
- [x] Blocage du menu contextuel "enregistrer l'image" en appui long (tactile) — `-webkit-touch-callout: none` + `user-select: none`, étendu à toutes les images publiques


---

## Axe 7 — Environnement de Préproduction (recette client)

*Ajouté le 2026-09-24 — objectif : offrir au client un environnement de démonstration fidèle à la prod, pour recette avant toute mise en ligne officielle*

**Infrastructure**
- [x] Créer le service Web de préprod sur Render — `balikvisionn-staging`, région Frankfurt
- [x] Créer le projet Postgres de préprod sur Neon (plan gratuit — persistant, sans expiration, contrairement au Postgres gratuit de Render qui expire à 30 jours)
- [x] `config/environments/staging.rb` (base `production.rb`, logs plus verbeux)
- [x] Variables d'environnement dédiées : `RAILS_MASTER_KEY`, `DATABASE_URL` (URL "pooled" Neon côté app, URL directe côté migrations, `prepared_statements: false` dans `database.yml`), `CLOUDINARY_URL` (isolation automatique par environnement via `folder: <%= Rails.env %>` dans `storage.yml` — pas de compte/dossier séparé nécessaire)
- [x] Domaine/sous-domaine de préprod dédié — sous-domaine fourni par Render (`balikvisionn-staging.onrender.com`), pas de nom de domaine personnalisé

**Protection & indexation**
- [x] Non-indexation par les moteurs de recherche — header `X-Robots-Tag: noindex, nofollow` vérifié sur les réponses authentifiées
- [x] Authentification HTTP basique le temps de la recette

**Déploiement**
- [x] Déploiement automatique vers la préprod à chaque push sur la branche d'intégration — Render pointe désormais sur `master`
- [ ] `bin/rails test` + `bin/rails test:system` exécutés en CI avant chaque déploiement — reporté à l'Axe 12 (mise en place du CI via GitHub Actions) ; en attendant, tests lancés manuellement en local avant chaque push

**Recette**
- [x] Première recette client sur la préprod, effectuée — retours consolidés à l'origine des Axes 8 à 10 (navigation, admin, page d'accueil) ; décidé de laisser l'environnement vierge et de recueillir les retours du client directement


---

## Axe 8 — Navigation & architecture de l'information (public)

*Ajouté le 2026-10-23 — refonte de la navigation publique (menu latéral fixe) et de l'arborescence catégorie/sous-catégorie, suite à la maquette validée.*

**Fonctionnalités**
- [ ] Nouveau composant menu latéral fixe (desktop) : toutes les catégories + sous-catégories toujours dépliées, « À propos » et réseaux sociaux inclus
- [ ] Version mobile : menu hors-écran (off-canvas) déclenché par un burger, même contenu que desktop
- [ ] Retirer le `header nav` centré actuel (`_navbar.scss`, `layouts/application.html.erb`) au profit du layout sidebar + contenu
- [ ] Nouvelle route + vue publique pour une sous-catégorie unique (`GET /categories/:category_id/subcategories/:id`), extraite de l'actuel `categories#show`
- [ ] `categories#show` devient la page « liste des sous-catégories » : grille de cards ratio 4:5 (nom centré, pas de compteur de photos)
- [ ] Nouvelle page sous-catégorie : reprend la mosaïque actuelle, retire la bannière cover et le `border-radius`, chaque tuile en ratio 4:5 (cf. principe transverse n°4)
- [ ] Page d'accueil : remplacée par la sélection de favoris — voir Axe 10, ne pas implémenter de grille « 6 catégories » fixe
- [ ] Lightbox : ajouter `title` + description en bas à gauche, cadrage photo en 4:5
- [ ] Page À propos : photo recadrée en ratio 4:5, remplace l'avatar circulaire actuel (public ET admin)
- [ ] Filtrer les sous-catégories en statut brouillon hors des pages publiques (listings + sitemap)

**Tests**
- [ ] Rendu de la page catégorie (grille de cards, lien vers chaque sous-catégorie)
- [ ] Rendu de la nouvelle page sous-catégorie (mosaïque, pas de bannière)
- [ ] Sous-catégorie en brouillon : inaccessible par URL directe, absente des listings
- [ ] Menu latéral : présence de toutes les catégories/sous-catégories, lien À propos, liens réseaux sociaux
- [ ] `sitemap.xml` exclut les sous-catégories brouillon
- [ ] Rendu en 4:5 sans déformation sur chaque composant image public (cards, mosaïque, lightbox)

**Accessibilité**
- [ ] Menu latéral : navigation clavier complète, focus visible, `aria-current` sur l'élément actif
- [ ] Menu mobile off-canvas : focus trap, fermeture Échap, restitution du focus

**Responsive**
- [ ] Menu latéral desktop / off-canvas mobile, breakpoint cohérent avec l'existant (640px)


---

## Axe 9 — Admin : brouillons, mise en avant, couverture de sous-catégorie

*Ajouté le 2026-10-23*

**Fonctionnalités**
- [ ] Migration `subcategories` : ajouter `status` (`draft`/`published`, défaut `draft`)
- [ ] Migration `subcategories` : ajouter l'attachment `cover` (`has_one_attached :cover`)
- [ ] Migration `photos` : ajouter `title` (string) — pas de colonne `featured` : voir le modèle `HomeFeature` en Axe 10
- [ ] Formulaire sous-catégorie : champ « Image de couverture » (même pattern que `CategoryForm`)
- [ ] Formulaire sous-catégorie : bouton « Enregistrer comme brouillon » à côté d'« Annuler »
- [ ] Badge « Brouillon » sur le formulaire et sur la grille des sous-catégories (même pattern que le badge « Sans couverture » déjà en place)
- [ ] Éditeur mosaïque : bouton ★ par photo — ajoute/retire la photo des favoris de la home (logique détaillée en Axe 10)
- [ ] Éditeur mosaïque : champ « Titre » par photo, en plus de l'alt text existant
- [ ] Migration `photos` : ajouter `rowspan` (cf. décision Roadmap V2 du 2026-09-17, réactivée ici) — chaque taille 1/2/3 devient un bloc N×N (`colspan` = `rowspan`), ce qui garde chaque tuile en ratio 4:5 exact (cf. principe transverse n°4), sans nécessiter de bascule paysage/portrait
- [ ] Éditeur mosaïque : les boutons de taille 1/2/3 pilotent désormais `colspan` ET `rowspan` ensemble
- [ ] Grille mosaïque : `grid-auto-flow: dense` pour que les blocs de tailles différentes se packent sans trou
- [ ] Aperçus admin (couverture catégorie, couverture sous-catégorie, photo À propos) recadrés en 4:5 — remplace les dimensions actuelles (ex. 400×220, 400×130)
- [ ] Tableau de bord : carte stat « Brouillons en cours »
- [ ] Tableau de bord : section « Brouillons en cours » (liste + lien « Reprendre → »), à la place du bloc « derniers messages » omis en V1
- [ ] Tableau de bord : bouton « + Nouveau brouillon »

**Tests**
- [ ] Migration `status` : défaut `draft`, transition vers `published`
- [ ] Sous-catégorie brouillon : exclue des routes publiques (redondant avec Axe 8, à vérifier côté modèle/scope)
- [ ] Bouton ★ : ajoute/retire bien l'entrée `HomeFeature` associée (Axe 10)
- [ ] `colspan`/`rowspan` : les trois tailles produisent bien un ratio 4:5 à l'affichage
- [ ] Packing `grid-auto-flow: dense` : aucun trou visible avec un nombre impair de tuiles/tailles mélangées

**Accessibilité**
- [ ] Alternative clavier au bouton ★ et au champ titre (déjà le cas pour le drag existant)
- [ ] Badge brouillon annoncé correctement par les lecteurs d'écran (pas seulement une couleur)

**Responsive**
- [ ] Tableau de bord, formulaire sous-catégorie et éditeur mosaïque : adaptation mobile cohérente avec l'existant (Axe 5)


---

## Axe 10 — Page d'accueil : sélection de favoris (catégories & photos)

*Ajouté le 2026-10-23 — remplace la home « grille des 6 catégories » par une sélection curée en admin.*

**Fonctionnalités**
- [ ] Nouveau modèle `HomeFeature` : association polymorphe `featurable` (`Category` ou `Photo`), colonne `position` pour l'ordre d'affichage
- [ ] Migration associée + validations (unicité par `featurable`, présence de `position`)
- [ ] `dependent: :destroy` (ou vérification à l'affichage) pour qu'une catégorie/photo supprimée retire automatiquement son favori
- [ ] Sur la grille des catégories (admin) : bouton ★ pour ajouter/retirer une catégorie des favoris de la home — construit directement en code, sans maquette dédiée (décision du 2026-10-23)
- [ ] Nouvel écran admin « Favoris de la home » : liste ordonnable (glisser-déposer, même pattern que l'éditeur mosaïque) mêlant catégories et photos sélectionnées, avec aperçu et retrait — construit directement en code, sans maquette dédiée
- [ ] Tableau de bord : raccourci vers cet écran
- [ ] Page d'accueil : grille affichant les `HomeFeature` dans l'ordre défini, chaque tuile en ratio 4:5
- [ ] Lien de chaque tuile : `category_path` si `featurable_type == "Category"`, sinon route de la sous-catégorie parente de la photo (`featurable.subcategory`)

**Tests**
- [ ] Création/suppression d'un `HomeFeature` depuis une catégorie et depuis une photo
- [ ] Réordonnancement persisté en base
- [ ] Rendu de la home : lien catégorie vs lien sous-catégorie selon le type
- [ ] Suppression d'une catégorie/sous-catégorie favorite : le favori disparaît proprement de la home

**Accessibilité**
- [ ] Alternative clavier au glisser-déposer de l'écran « Favoris de la home » (même pattern que l'éditeur mosaïque : monter/descendre)


---

## Axe 11 — Qualité & couverture globale

- [ ] Mesurer la couverture de tests réelle (SimpleCov), combler les trous identifiés
- [ ] Vérifier qu'aucune route admin n'est accessible sans authentification
- [ ] Revue de sécurité générale (paramètres filtrés, protection CSRF)


---

## Axe 12 — Préparation au déploiement

- [ ] Choix définitif de l'hébergement (VPS + Kamal vs PaaS)
- [ ] Base de données de production : démarrer sur Neon (plan gratuit) tant que le trafic reste faible ; bascule vers le plan Launch (pay-as-you-go, PITR 7 jours) déclenchée par un critère concret — juste avant de partager l'URL avec le client, ou dès que perdre des données au-delà de 6h devient risqué — pas un abonnement payant dès le premier jour (Crunchy Bridge en plan B si le comportement à l'usage ne convient pas)
- [ ] Configuration production réelle : domaine, `force_ssl`, `RAILS_MASTER_KEY`, clés Cloudinary
- [ ] Vérifier headers anti-hotlink et CSP avec le vrai domaine
- [ ] Mise en place du CI (`bin/ci`) via GitHub Actions — exécution automatique de `bin/rails test` + `bin/rails test:system` avant chaque déploiement (item reporté depuis l'Axe 7)
- [ ] Conformité légale française : mentions légales, politique de confidentialité (RGPD, collecte email via contact)
- [ ] Protection anti-abus (`Rack::Attack`) sur les endpoints publics sensibles (contact, connexion admin)


---

## Axe 13 — Mise en production

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

- [x] ~~Orientation portrait pour la mosaïque~~ — **remplacé, voir Axe 9** : la contrainte 4:5 imposée sur toutes les photos du site (2026-10-23) réactive la colonne `rowspan` envisagée ici, mais sans le choix exclusif paysage/portrait prévu en septembre — chaque tuile est désormais scalée en bloc N×N (`colspan` = `rowspan`), ce qui garde toujours le ratio 4:5 sans bascule globale à gérer.
