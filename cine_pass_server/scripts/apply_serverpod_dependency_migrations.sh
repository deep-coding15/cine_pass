#!/usr/bin/env bash
# Apply SQL from Serverpod pub packages so CI/test DB has dependency schemas before
# the project's cine_pass migration runs.
#
# 1) serverpod_auth_idp definition.sql = merged snapshot: serverpod + serverpod_auth_core
#    + serverpod_auth_idp (do NOT chain multiple full definitions — duplicates tables).
# 2) Legacy serverpod_auth (bigint user / email tables) lives only in serverpod_auth_server;
#    its definition.sql repeats serverpod tables, so we apply only the first segment
#    (before duplicate serverpod_cloud_storage) plus the module row in serverpod_migrations.
#
# Update version folder names when bumping serverpod_* in pubspec.

set -euo pipefail

PUB_CACHE="${PUB_CACHE:-$HOME/.pub-cache}"
ROOT="$PUB_CACHE/hosted/pub.dev"

PGHOST="${PGHOST:-localhost}"
PGPORT="${PGPORT:-9090}"
PGUSER="${PGUSER:-postgres}"
PGDATABASE="${PGDATABASE:-cine_pass_test}"

export PGHOST PGPORT PGUSER PGDATABASE

AUTH_SERVER_PKG="$ROOT/serverpod_auth_server-3.4.0/migrations/20260129181059877"
IDP_PKG="$ROOT/serverpod_auth_idp_server-3.4.0/migrations/20260213194423028"

apply() {
  local f="$1"
  if [[ ! -f "$f" ]]; then
    echo "Missing migration file: $f" >&2
    exit 1
  fi
  echo "Applying $(basename "$(dirname "$f")")/$(basename "$f") ..."
  psql -v ON_ERROR_STOP=1 -f "$f"
}

apply "$IDP_PKG/definition.sql"

# Legacy tables: serverpod_auth_key, serverpod_email_*, serverpod_user_info, …
TMP_LEGACY="$(mktemp)"
{
  # Stops before duplicate serverpod core tables (CloudStorageEntry at line 116).
  sed -n '1,114p' "$AUTH_SERVER_PKG/definition.sql"
  echo ""
  echo "--"
  echo "-- MIGRATION VERSION FOR serverpod_auth (legacy)"
  echo "--"
  echo "INSERT INTO \"serverpod_migrations\" (\"module\", \"version\", \"timestamp\")"
  echo "    VALUES ('serverpod_auth', '20260129181059877', now())"
  echo "    ON CONFLICT (\"module\")"
  echo "    DO UPDATE SET \"version\" = '20260129181059877', \"timestamp\" = now();"
  echo ""
  echo "COMMIT;"
} >"$TMP_LEGACY"
echo "Applying serverpod_auth_server legacy segment + migration row ..."
psql -v ON_ERROR_STOP=1 -f "$TMP_LEGACY"
rm -f "$TMP_LEGACY"

echo "Serverpod dependency migrations applied."
