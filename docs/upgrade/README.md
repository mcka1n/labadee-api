# Upgrade execution record

Original revision: `7dd3bdd513758376f40ebdf5ea517d3f80211aa8`.
Recovery tag: `upgrade/original-rails-5.0`.
A Git bundle was saved locally to `/private/tmp/labadee-api-before-upgrade.bundle`.
No `labadee*` databases were present on the laptop's MongoDB instance when checked.
Existing MongoDB services and data directories are not used by the upgrade.

The original lockfile recorded Bundler 2.1.2 despite Rails 5.0 requiring Bundler
below 2. The bootstrap uses Bundler 1.17.3 and keeps all original gem versions.

Run legacy checkpoints with:

```sh
docker compose -p labadee-upgrade -f compose.upgrade.yml build app
docker compose -p labadee-upgrade -f compose.upgrade.yml run --rm app bin/rails test
```

Legacy images run as linux/amd64 for archived Ruby/MongoDB compatibility on
Apple Silicon. These obsolete runtimes are for isolated local testing only.

## Existing defects to distinguish from supported behavior

- Event update/delete and attendee creation dereference missing records.
- Attendee lookup is not scoped to the event in the URL.
- Event parameters accept every attribute; update/delete lack ownership checks.
- Attendee update/delete and HTML form routes are generated but not implemented.
- Devise generates additional routes without API-specific implementations.
- The root redirects to `/sign_in`, which is not a defined route.
- Only passwords were filtered from logs; query-string API credentials were not.
- CORS is configured twice and the API policy omits PUT/PATCH/DELETE.
- `bin/setup` assumes SQL database setup and seeds contain a fixed password.

Execution results and necessary compatibility changes are recorded below as
each checkpoint is verified. No checkpoint is considered passing until its
tests have actually run.

## Verified baseline

Rails 5.0.0 / Ruby 2.5.5 / Mongoid 6.1.1 / MongoDB 3.4.24:
**31 tests, 179 assertions, no failures/errors/skips**.

Two original-toolchain repairs were required: an original-version-only OpenSSL
cipher-key truncation shim (removed at Rails 5.0.7.2), and Minitest 5.9.1 for the
Rails 5.0.0 reporter. No original application gem was otherwise changed.
The observed foreign keys are BSON ObjectIds (Mongoid's association definitions
override the declared String fields); JSON serializers expose strings. Geocoder
stores coordinates in MongoDB longitude/latitude order. Both contracts are tested.

## Checkpoints

| Rails | Ruby | Mongoid | MongoDB | Regression gate |
|---|---|---|---|---|
| 5.0.0 | 2.5.5 | 6.1.1 | 3.4.24 | 31 tests / 179 assertions, passing |
| 5.0.7.2 | 2.5.5 | 6.1.1 | 3.4.24 | 31 tests / 179 assertions, passing |

Rails 5.0.7.2 removes the temporary cipher shim. Deprecated callback names,
static-file settings, and string middleware references were updated, and the
unrelated sample CORS policy was removed. `app:update` was run and its generated
SQL/assets/session scaffolding was reviewed and excluded because these frameworks
are disabled or the original session behavior must be preserved.

| 5.1.7 | 2.5.5 | 6.4.8 | 4.4.29 | 31 tests / 179 assertions, passing before and after defaults |

At Rails 5.1 the compatible driver resolved to 2.21, which rejects MongoDB
3.4's wire protocol. The gate caught this before advancement. A separate fresh
MongoDB 4.4.29 volume was used, leaving the 3.4 volume intact. Defaults 5.1 were
then enabled and the complete suite passed again.

| 5.2.8.1 | 2.5.5 | 7.6.2 | 4.4.29 | 31 tests / 179 assertions, passing before and after defaults |

Rails 5.2 and Mongoid 7 preserve BSON foreign keys and all JSON contracts.
Minitest was moved to 5.15.0 after leaving the release-era Rails reporter.
The hardcoded secret token was removed; remaining Rails 5 secrets configuration
now reads the environment only. Defaults 5.2 passed separately.

| 6.0.6.1 | 2.5.5 | 7.6.2 | 4.4.29 | 31 tests / 154 assertions; Zeitwerk passing |

Rails 6.0 passed before and after enabling defaults 6.0. Logger is now required
explicitly because newer concurrent-ruby no longer loads it for old Rails.
The Content-Type assertion now checks `media_type` directly, removing a
framework deprecation and one redundant assertion per response (same coverage).
Zeitwerk eager loading passed.

| 6.1.7.10 | 2.5.5 | 7.6.2 | 4.4.29 | 31 tests / 154 assertions, passing before and after defaults |

Active Model Serializers 0.10.16 preserved the v1 response contracts.
Defaults 6.1 passed separately. Spring and its binstub hooks were removed.

Bundler 2.3.27 was verified independently on Rails 6.1 / Ruby 2.5.5:
31 tests / 154 assertions, passing. The lockfile changed only its Bundler version.
