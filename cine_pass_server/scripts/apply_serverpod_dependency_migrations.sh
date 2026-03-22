#!/usr/bin/env bash
# Apply SQL definitions from Serverpod pub packages so that the test database has
# core + auth tables before the project's own migration (cine_pass) runs.
#
# Serverpod only runs migrations from the server project's migrations/ folder; it does
# not auto-apply dependency packages' migrations. Local dev DBs are often seeded once;
# CI starts from an empty volume, so we must bootstrap dependency schemas here.
#
# Each package's definition.sql is a *merged* snapshot (includes dependency tables).
# Applying several definitions in a row fails (e.g. serverpod_cloud_storage already exists).
# The latest serverpod_auth_idp definition.sql merges serverpod + serverpod_auth_core +
# serverpod_auth_idp; that is enough for this app (uses Email/Google idp).
#
# Update the versioned folder when bumping serverpod_auth_idp_server (see
# migrations/migration_registry.txt last line).

set -euo pipefail

PUB_CACHE="${PUB_CACHE:-$HOME/.pub-cache}"
ROOT="$PUB_CACHE/hosted/pub.dev"

PGHOST="${PGHOST:-localhost}"
PGPORT="${PGPORT:-9090}"
PGUSER="${PGUSER:-postgres}"
PGDATABASE="${PGDATABASE:-cine_pass_test}"

export PGHOST PGPORT PGUSER PGDATABASE

apply() {
  local f="$1"
  if [[ ! -f "$f" ]]; then
    echo "Missing migration file: $f" >&2
    exit 1
  fi
  echo "Applying $(basename "$(dirname "$f")")/$(basename "$f") ..."
  psql -v ON_ERROR_STOP=1 -f "$f"
}

# Single merged definition (do not chain serverpod + auth_* definitions).
apply "$ROOT/serverpod_auth_idp_server-3.4.0/migrations/20260213194423028/definition.sql"

echo "Serverpod dependency migrations applied."
