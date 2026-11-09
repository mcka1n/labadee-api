# Upgrade execution record

Completed locally on November 9, 2026, on branch `upgrade/rails-8.1`.
The running native container reports Ruby 3.4.12, Rails 8.1.4.1, Mongoid 9.1.1,
MongoDB 8.0.34, platform `aarch64-linux`, and non-root UID 1000.

## Recovery and data boundaries

- Original revision: `7dd3bdd513758376f40ebdf5ea517d3f80211aa8`.
- Original code and lockfile: tag `upgrade/original-rails-5.0`.
- Local Git backup: `/private/tmp/labadee-api-before-upgrade.bundle` (mode 0600).
- No `labadee*` databases were present on the laptop's MongoDB instance when
  checked. Its service and data directory were not changed.
- Fresh, separate Docker volumes were used for MongoDB 3.4, 4.4, and 8.0.
  No server major version was pointed at another version's data directory.
- The final Compose project is `labadee`; archived checkpoint testing uses
  `labadee-upgrade`. Legacy runtimes are for isolated recovery/testing only.

Every checkpoint below passed before its commit/tag was created. Recovery tags
are `upgrade/rails-VERSION`, `upgrade/ruby-VERSION`, `upgrade/mongoid-VERSION`,
and `upgrade/mongodb-8.0.34`. Framework defaults were checked separately where
supported; Zeitwerk checks began at Rails 6.0. See the root README for commands.

## Verified checkpoints

| Rails | Ruby | Mongoid | MongoDB | Tests / assertions |
|---|---|---|---|---|
| 5.0.0 | 2.5.5 | 6.1.1 | 3.4.24 | 31 / 179 |
| 5.0.7.2 | 2.5.5 | 6.1.1 | 3.4.24 | 31 / 179 |
| 5.1.7 | 2.5.5 | 6.4.8 | 4.4.29 | 31 / 179 |
| 5.2.8.1 | 2.5.5 | 7.6.2 | 4.4.29 | 31 / 179 |
| 6.0.6.1 | 2.5.5 | 7.6.2 | 4.4.29 | 31 / 154 |
| 6.1.7.10 | 2.5.5 | 7.6.2 | 4.4.29 | 31 / 154 |
| 6.1.7.10 | 2.7.8 | 7.6.2 | 4.4.29 | 31 / 154 |
| 6.1.7.10 | 2.7.8 | 8.0.13 | 4.4.29 | 31 / 154 |
| 6.1.7.10 | 2.7.8 | 8.1.13 | 4.4.29 | 31 / 154 |
| 6.1.7.10 | 2.7.8 | 9.0.12 | 4.4.29 | 31 / 154 |
| 6.1.7.10 | 2.7.8 | 9.1.1 | 4.4.29 | 31 / 154 |
| 6.1.7.10 | 3.1.7 | 9.1.1 | 4.4.29 | 31 / 154 |
| 6.1.7.10 | 3.1.7 | 9.1.1 | 8.0.34 | 31 / 154 |
| 7.0.10 | 3.1.7 | 9.1.1 | 8.0.34 | 31 / 154 |
| 7.1.6 | 3.1.7 | 9.1.1 | 8.0.34 | 31 / 154 |
| 7.2.4 | 3.1.7 | 9.1.1 | 8.0.34 | 31 / 154 |
| 7.2.4 | 3.4.12 | 9.1.1 | 8.0.34 | 31 / 154 |
| 8.0.5.2 | 3.4.12 | 9.1.1 | 8.0.34 | 31 / 154 |
| 8.1.4.1 | 3.4.12 | 9.1.1 | 8.0.34 | 31 / 154 |
| Final hardening/native image | 3.4.12 | 9.1.1 | 8.0.34 | **45 / 262** |

All listed gates had zero failures, errors, and skips. The assertion count
changed at Rails 6.0 because the deprecated MIME-type regex assertion became a
single exact `media_type` assertion; the same 31 contract cases were retained.
The final suite adds 14 security, configuration, setup, and logging cases.

## Compatibility decisions and failures caught

- Rails 5.0.0 requires Bundler below 2, but the original lockfile recorded 2.1.2.
  Bundler 1.17.3 bootstrapped the original locked application gems.
- The original Rails/OpenSSL combination needed an original-version-only
  cipher-key truncation shim. Rails 5.0.7.2 supplied the upstream repair and the
  shim was deleted. Minitest 5.9.1 matched the original reporter API; later
  checkpoints used 5.15.0 and finally 5.27.0.
- The driver selected with Mongoid 6.4 rejected MongoDB 3.4's wire protocol.
  The gate caught this, and a fresh MongoDB 4.4 volume was used.
- Despite old `String` declarations, association fields were stored as BSON
  ObjectIds. Tests preserve the actual BSON storage and string JSON IDs.
  Coordinates remain `[longitude, latitude]`.
- Obsolete filter callbacks, middleware string references, static-file settings,
  duplicate sample CORS configuration, and Spring hooks were removed. Logger is
  required explicitly rather than relying on concurrent-ruby's old side effect.
- Active Model Serializers 0.10.16 was verified before Rails 6.1. Devise 4.7.2
  called the removed `ActiveSupport::Dependencies.reference` API on Rails 7;
  Devise 5.0.4 resolved it and all HTTP authentication tests passed.
- Bundler 2.3.27, parser dependencies, and geocoding updates were independently
  verified before Ruby transitions. Ruby 3.4 exposed Minitest 5.15's removed
  `mutex_m` stdlib dependency; updating Minitest resolved it without a shim.
- `bin/rails app:update` ran at every Rails step. Generated SQL, asset, session,
  deployment, and frontend scaffolding was reviewed and excluded where unused.
  Defaults were explicitly adopted and tested. Active Record and unused storage,
  text, mailbox, and cable engines remain disabled and are covered by a test.
- Versions were resolved through named dependency updates and locked. The final
  lockfile supports Linux ARM64, Linux x86-64, and Apple Silicon macOS. Actual
  execution was verified on Linux x86-64 checkpoints and the native Linux ARM64
  image; native macOS Ruby execution was not separately tested.

## Explicit security and error corrections

Successful supported v1 routes and response fields were preserved. These
negative-request corrections were made separately from framework checkpoints:

- Only owners may update/delete events; other authenticated users receive 403.
- Event parameters allow data fields, not ownership or internal timestamps.
- Attendee reads are scoped to the event in the URL.
- Missing/malformed IDs return JSON 404; invalid updates return field errors/422.
- Structured credentials cannot be used as MongoDB selectors.
- CORS permits supported API methods and HEAD.
- Unique indexes enforce existing uniqueness rules. Seeds use private environment
  credentials, preserve existing credentials on repeat runs, and refuse production.
- Rails filters credentials from parameters and request paths. The real HTTP
  walkthrough additionally caught MongoDB DEBUG command logs bypassing those
  filters. ODM/driver logging now has a separate WARN-level logger. A regression
  test and a repeat HTTP/log inspection verified credentials are absent.

The old `/sign_in` root redirect, HTML forms, and extra unimplemented Devise and
attendee routes remain outside the supported API contract. No new UI, SQL
backend, authentication protocol, data conversion, or hosted deployment was added.

## Final verification

- Native Docker build completed with frozen dependencies and a non-root runtime.
- **45 tests, 262 assertions; zero failures/errors/skips.**
- Zeitwerk and eager loading passed; production configuration connected to the
  isolated test database successfully.
- `bundler-audit` refreshed 1,353 advisories (database updated 2026-11-09,
  commit `bc80fbb16e7b8de1cad903bc061d1da65e15edcb`): **no vulnerabilities**.
- Brakeman 8.1.0: **zero warnings and zero errors**, with no ignored findings.
- Native `bin/setup` ran twice successfully, preserving seeded credentials.
- Real HTTP registration, login/token rotation, old-token rejection, event
  create/list/show/update/delete, attendance create/list/show, duplicate rejection,
  and missing-record responses passed through Puma. Temporary smoke users were
  removed afterward. A repeat log inspection found no credential values.
- The API is running at `127.0.0.1:3000`; MongoDB has no host port published.
- GitHub CI and monthly Dependabot/audit schedules are configured. Equivalent
  checks ran locally; no GitHub push or remote workflow run was performed.

## Primary references

- [Rails upgrade guide](https://guides.rubyonrails.org/upgrading_ruby_on_rails.html)
- [Rails maintenance policy](https://rubyonrails.org/maintenance)
- [Rails 8.1.4.1 security release](https://rubyonrails.org/2026/11/4/Rails-8.0.5.2-and-8.1.4.1-have-been-released)
- [Ruby maintenance branches](https://www.ruby-lang.org/en/downloads/branches/)
- [Mongoid compatibility](https://www.mongodb.com/docs/drivers/compatibility/?driver-language=ruby&ruby-driver-framework=mongoid)
- [Mongoid release notes](https://www.mongodb.com/docs/mongoid/current/reference/release-notes/)
- [Devise API-mode guidance](https://github.com/heartcombo/devise#rails-api-mode)
