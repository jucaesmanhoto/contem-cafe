# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

Always use the `bin/*` wrappers rather than calling `rails`/`rubocop`/etc. directly — they ensure consistent Ruby/Bundler versions and mirror what CI runs.

- Setup: `bin/setup` (installs gems, prepares DB, clears logs/tmp, starts dev server unless `--skip-server`)
- Dev server: `bin/dev` (foreman + `Procfile.dev`: runs `rails server`, `tailwindcss:watch`, and `dartsass:watch` concurrently)
- Tests (Minitest, not RSpec):
  - Full suite as CI runs it: `bin/rails db:test:prepare test`
  - All unit tests: `bin/rails test`
  - Single file: `bin/rails test test/models/user_test.rb`
  - Single test by line: `bin/rails test test/models/user_test.rb:12`
  - System tests (Capybara + Selenium): `bin/rails test:system`
- Lint: `bin/rubocop` (CI runs `bin/rubocop -f github`); config in `.rubocop.yml`, max line length 120, many cops disabled
- Security scans (also run in CI): `bin/brakeman --no-pager`, `bin/bundler-audit`, `bin/importmap audit`

CI (`.github/workflows/ci.yml`) has 5 jobs: `scan_ruby`, `scan_js`, `lint`, `test`, `system-test`. Postgres is used as the test DB service; `DATABASE_URL=postgres://postgres:postgres@localhost:5432`.

## Architecture

Rails 8.1 app (generated from Le Wagon `rails-templates`) for **Contém Café**, a coffee roastery site. Public-facing marketing/product pages plus an internal admin panel for managing coffee roasting data.

- **Auth**: Devise on `User`. `ApplicationController` requires login by default (`before_action :authenticate_user!`); public controllers/actions explicitly `skip_before_action :authenticate_user!` (e.g. `PagesController`, `CoffeesController#show`, `FarmsController#show`). When adding a new public page/action, you must add this skip or it will 404/redirect to login.
- **Admin panel**: [Avo](https://avohq.io) gem, mounted at root via `mount_avo` in `config/routes.rb`. Resource definitions live in `app/avo/resources/*.rb` (one per model: `Batch`, `BatchDatum`, `Coffee`, `Farm`, `User`) and declare the fields/associations shown in the admin UI — this is where you add/edit fields visible to admins, not in the plain `app/controllers/avo/*` controllers (which are mostly Avo-generated scaffolding).
- **Domain model** (roasting data pipeline):
  - `Farm` → has_many `Coffee` (dependent: destroy)
  - `Coffee` → belongs_to `Farm`; has photo attachment (ActiveStorage); auto-generates a `slug` from `name` and a `stock_status` on create
  - `Batch` → belongs_to `Coffee`; one roast session's summary metrics (times/temperatures/quantities in seconds/celsius/grams)
  - `BatchDatum` → belongs_to `Batch`; fine-grained time-series readings within one roast (temperature, rate-of-rise, power, air flow, drum rotation) — this is per-roast telemetry, distinct from the summary fields on `Batch`
  - `User` → Devise-authenticated; has a `role` enum (`user`/`manager`/`admin`) used to gate Avo/admin access
- **Slugs, not IDs, in URLs**: `Coffee` and `Farm` both override `to_param` to return `slug` (falling back to `id`). Controllers look up records with `find_by(slug: params[:id]) || find(params[:id])`. QR codes on physical product labels link to `/farms/:slug` and `/farms/:slug/coffees/:slug`, so slug generation (`before_validation :set_slug` via `name.parameterize`) must stay stable once printed.
- **Frontend**: importmap-rails + Stimulus (`app/javascript/controllers/`) — no `package.json`/webpack/node bundler. Styling is Tailwind CSS (`tailwindcss-rails`) plus legacy Bootstrap 5 and Sass (`dartsass-rails`) for some views; both watchers run in dev via `Procfile.dev`.
- **Database**: PostgreSQL in development/test (`config/database.yml`); production uses SQLite (`storage/*.sqlite3`) with separate databases for cache/queue/cable (`solid_cache`/`solid_queue`/`solid_cable`).
- **Routes** (`config/routes.rb`): most pages are simple top-level `get` routes with Portuguese paths (e.g. `quero-cafe`, `pesquisa-satisfacao`, `sobre-o-cafe`) matching user-facing copy. `resources :farms` nests `resources :coffees` for the QR-code product pages.
- Deployment via Kamal (Docker) + Thruster (Puma acceleration); see `DEPLOY_ORACLE_GUIDE.md` for the Oracle Cloud deployment process.

## Conventions

- User-facing strings, route paths, and comments are frequently in Portuguese (pt-BR) — match existing language when editing nearby text.
- Tests use Rails' default Minitest, not RSpec/FactoryBot. The generator config sets `fixture: false`, so tests build their own records rather than relying on YAML fixtures.
