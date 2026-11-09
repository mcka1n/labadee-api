# Labadee Events API

Labadee - Events API takes its name from a port/beach located on the northern
coast of Haiti.

I started this small project while I was visiting this beautiful beach in Haiti,
I got inspired by the warm blue waters, the hundreds of *events* and tours near
the beach and of course by the friendly people from the flea markets.

The maintained local stack uses Rails 8.1.4.1, Ruby 3.4.12, Mongoid 9.1.1,
and MongoDB 8.0.34. MongoDB is the only database; Active Record and unused
Rails storage, frontend, and SQL-backed job/cache systems are not enabled.

## Run locally with Docker Compose

Start Docker Desktop, then generate private local credentials:

```sh
bin/configure
```

This uses the Ruby already installed on macOS. If Ruby is unavailable, use:

```sh
docker run --rm --user "$(id -u):$(id -g)" -v "$PWD:/app" -w /app ruby:3.4.12-slim ruby bin/configure
```

The command creates `.env` with a random `SECRET_KEY_BASE` and `SEED_PASSWORD`.
It refuses to overwrite an existing file. Keep `.env` private; it is excluded
from Git and Docker images. `.env.example` describes the available settings.

```sh
docker compose build app
docker compose run --rm app bin/setup
docker compose up -d app
```

The API listens on `http://127.0.0.1:3000`. MongoDB is available only inside
Compose. Its named `mongo_8_0` volume is separate from any installed Homebrew
MongoDB database. Development and tests use separate databases.

`bin/setup` checks dependencies, creates Mongoid indexes, and runs repeatable
local seeds. The seeded email defaults to `developer@example.test`; its password
is the `SEED_PASSWORD` in `.env`. Repeating setup preserves the existing user's
password and the existing client's key. Seeds refuse to run in production.

Retrieve your local API client key when needed:

```sh
docker compose exec app bin/rails runner 'puts Client.find_by(name: ENV.fetch("SEED_CLIENT_NAME")).key'
```

Stop services with `docker compose down`. This keeps the named database volume.
After editing source code, run `docker compose up -d --build app` to rebuild it.

## v1 authentication and endpoints

Every API request requires the query parameter `key`. All supported requests
except registration and login also require the user's query parameter `token`.
Login returns a fresh token and invalidates the previous one. Preserve and URL
encode these values in clients; Rails filters them from application logs.

- `POST /v1/users` with `{ "user": { "email": "...", "password": "..." } }`
  returns `201` with `auth_token` and `email`.
- `POST /v1/users/sign_in` with the same credentials returns `200` with
  `success`, `auth_token`, and `email`; invalid credentials return `401`.
- `GET /v1/events` and `GET /v1/events/:id` read events.
- `POST /v1/events` with `{ "event": { "name": "..." } }` creates an event
  for the authenticated user and retains the existing `200` success status.
- `PUT` or `PATCH /v1/events/:id` updates an event; `DELETE` returns `204`.
- `GET /v1/events/:event_id/attendees`,
  `GET /v1/events/:event_id/attendees/:id`, and
  `POST /v1/events/:event_id/attendees` list, show, and create attendance.

Responses preserve string IDs, event fields, nested attendees, and field-keyed
validation errors. Stored association keys remain BSON ObjectIds. Coordinates
use MongoDB's `[longitude, latitude]` order. Geocoding uses the configured
provider; automated tests never call it over the network.

Security and error corrections are separate from the framework checkpoints:
only event owners can update/delete events; ownership and internal timestamps
cannot be assigned through event parameters; attendee lookups are scoped to the
event in the URL; missing records return `404`; invalid updates return `422`;
and structured query values cannot be used as credentials. CORS supports the
implemented API methods. These changes intentionally tighten invalid requests
without changing successful v1 request/response formats.

Additional HTML and Devise routes inherited from the old app are not supported
API contracts. This upgrade does not add attendee update/delete, a users index,
a UI, an authentication redesign, or a hosted deployment. The root's old
`/sign_in` redirect remains a legacy route, not a health endpoint.

## Verification

```sh
docker compose run --rm app bin/check
docker compose run --rm app bundle-audit check --update
docker compose run --rm app brakeman --no-pager --exit-on-warn --exit-on-error
```

`bin/check` runs Minitest against MongoDB, checks Zeitwerk, and verifies eager
loading and MongoDB connectivity under production configuration with the
isolated test database. Test cleanup refuses databases whose names do not end
in `_test`. No actual email or external geocoding is used in tests.

CI uses the same pinned Docker images and checks. Dependabot checks Ruby,
Docker, and Actions dependencies monthly; a scheduled CI run also refreshes the
security audit monthly. These workflows become active when pushed to GitHub.

Indexes and seeds can be rerun independently:

```sh
docker compose run --rm app bin/rails db:mongoid:create_indexes
docker compose run --rm app bin/rails db:seed
```

For native Ruby execution, use `.ruby-version`, install the locked Bundler,
and set `SECRET_KEY_BASE`, `MONGODB_URI`, and `MONGODB_TEST_URI`. Native database
URIs must reference different development and test databases. Compose supplies
these URIs automatically. Deployment hosting, TLS, and production operations
remain outside this local setup.

## Upgrade history and recovery

The [execution record](docs/upgrade/README.md) documents the tested Rails, Ruby,
Mongoid, and database transitions, original defects, and compatibility decisions.
The original revision is tagged `upgrade/original-rails-5.0`; passing Rails
checkpoints are tagged `upgrade/rails-VERSION` and Ruby transitions have matching
`upgrade/ruby-VERSION` tags.

To inspect an earlier passing checkpoint, first save any local edits, check out
its tag, and use that revision's `compose.upgrade.yml`:

```sh
git switch --detach upgrade/rails-6.1.7.10
docker compose -p labadee-upgrade -f compose.upgrade.yml build app
docker compose -p labadee-upgrade -f compose.upgrade.yml run --rm app bin/rails test
```

Return with `git switch upgrade/rails-8.1`. Each checkpoint uses its matching
runtime and a separate database volume per server version. Do not attach a new
MongoDB major version to an old version's data directory. Existing laptop
MongoDB data was not modified; the upgraded development database starts fresh.
