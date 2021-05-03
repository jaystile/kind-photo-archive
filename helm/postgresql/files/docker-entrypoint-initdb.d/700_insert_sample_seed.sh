#!/bin/bash
set -e

PGPASSWORD="${PROJECT_PASSWORD}"
psql -v ON_ERROR_STOP=1 --echo-all --username "${PROJECT_ADMIN}" --dbname "${PROJECT_DB}" <<-EOSQL
    INSERT INTO sample (display_name) VALUES ('A seeded sample record');
EOSQL