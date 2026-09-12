# Balikvision

## Stack
- Ruby 3.4.10 (migré depuis 3.1.2 ✅)
- Rails 7.0.4 (migration vers 8.1 en préparation, branche `upgrade/rails-8.1`)
- PostgreSQL, Cloudinary (Active Storage), Hotwire (Turbo/Stimulus)

## Commandes
- Lancer les tests : `bin/rails test`
- Après tout changement de Gemfile : `bundle install`
- Après une migration : `bin/rails db:migrate`

## Conventions
- Commits au format Conventional Commits (feat/fix/chore/refactor/docs/test/style)
- `master` reste toujours fonctionnel — les changements risqués passent par une branche dédiée

## Historique
- 2026-09 : upgrade Ruby 3.1.2 → 3.4.10, compatibilité Gemfile, réparation de l'historique de migrations (table `photos`)
