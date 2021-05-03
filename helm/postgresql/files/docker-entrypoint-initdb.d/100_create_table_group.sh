#!/bin/bash
set -e

PGPASSWORD="${PROJECT_PASSWORD}"
psql -v ON_ERROR_STOP=1 --echo-all --username "${PROJECT_ADMIN}" --dbname "${PROJECT_DB}" <<-EOSQL
    CREATE TABLE sample (
	id uuid DEFAULT uuid_generate_v4 (),
    display_name VARCHAR,
    PRIMARY KEY(id)
);
EOSQL