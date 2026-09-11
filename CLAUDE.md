# Balikvision

## Stack
- Rails 8.1 / Ruby 3.4 (en cours de migration depuis Rails 7.0.4 / Ruby 3.1.2)
- PostgreSQL, Cloudinary (Active Storage), Hotwire (Turbo/Stimulus)

## Commandes
- Lancer les tests : `bin/rails test`
- Après tout changement de Gemfile : `bundle install`
- Après une migration : `bin/rails db:migrate`

## Conventions
- Commits au format Conventional Commits (feat/fix/chore/refactor/docs/test/style)
- `main` reste toujours fonctionnel — les changements risqués passent par une branche dédiée
