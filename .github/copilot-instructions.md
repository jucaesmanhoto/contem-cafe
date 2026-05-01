# Copilot instructions for contem-cafe

This file gives brief, repository-specific guidance for Copilot sessions working on this Rails app.

## Build, test, and lint commands

- Setup (one-time / first run):
  - bin/setup           # installs gems, prepares DB, clears logs/tmp, starts dev server unless --skip-server
  - bundle install

- Development server:
  - bin/dev             # uses foreman and Procfile.dev (runs web and CSS watchers)
  - bin/rails server -b 0.0.0.0

- Tests:
  - Full test suite (CI):
    - bin/rails db:test:prepare test
  - Run all unit tests locally:
    - bin/rails test
  - Run a single test file:
    - bin/rails test test/models/user_test.rb
  - Run a single test at a specific line (target a test method):
    - bin/rails test test/models/user_test.rb:12
  - System tests (Capybara + Selenium):
    - bin/rails db:test:prepare test:system
    - bin/rails test:system

- Linting:
  - bin/rubocop          # run RuboCop locally
  - CI uses: bin/rubocop -f github
  - RuboCop config: .rubocop.yml (Max Line Length: 120, several cops disabled/ignored)

- Security scans (used in CI):
  - bin/brakeman --no-pager
  - bin/bundler-audit
  - bin/importmap audit  # JS dependency checks (importmap)

## High-level architecture (big picture)

- Rails 8 application (generated from Le Wagon rails-templates).
- Standard Rails MVC app with ActiveRecord models, controllers, views under app/.
- Authentication provided by Devise.
- Frontend uses importmap-rails + Stimulus (app/javascript/controllers) and Tailwind CSS (tailwindcss-rails). Some assets remain in app/assets/*.
- Database: PostgreSQL for development and test (see config/database.yml). CI boots a Postgres service. Production in this template uses sqlite3 storage/.
- System tests use Capybara + Selenium; CI runs a dedicated `system-test` job and stores screenshots on failure.
- Several helper "bin/" wrappers are present (bin/rails, bin/rubocop, bin/brakeman, bin/bundler-audit, bin/importmap, bin/dev, bin/setup, bin/ci). These ensure consistent Ruby/Bundler environments.
- Deployment helpers: kamal (Docker), thruster (Puma acceleration) are present in Gemfile for ops-specific tasks.

## Key conventions and repo-specific patterns

- Always use the bin/* wrappers to run Ruby/rails tooling (bin/rails, bin/rubocop, bin/dev, bin/setup). This ensures the correct Ruby/bundler versions and mirrors CI usage.
- Tests use Rails' default Minitest harness (not RSpec). Use `bin/rails test <file>[:line]` to run focused tests.
- JS dependencies are managed via importmap (no package.json/webpack). Use bin/importmap for audits and importmap commands.
- RuboCop config excludes many generated or runtime directories (bin, db, config, node_modules, tmp, test). Max line length is 120.
- CI is defined at .github/workflows/ci.yml — job names: scan_ruby, scan_js, lint, test, system-test. Use it as the canonical source for which checks must pass on PRs.
- Database connection in CI and other automation frequently uses DATABASE_URL (postgres://postgres:postgres@localhost:5432).

## Where to look for specifics

- README.md (project origin note)
- Gemfile / Gemfile.lock (dependencies)
- config/database.yml (DB defaults)
- .rubocop.yml (lint rules)
- bin/* scripts (recommended entrypoints)
- .github/workflows/ci.yml (CI steps and exact commands)
- test/ (Minitest test files)

---

If anything else should be added (e.g., example DB ENV variables, local setup caveats, or notes about custom gems like `solid_*`), say which area and Copilot can add it.
