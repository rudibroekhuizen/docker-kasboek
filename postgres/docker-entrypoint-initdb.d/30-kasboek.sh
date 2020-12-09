#!/bin/bash
set -e

psql -v ON_ERROR_STOP=1 --username="$POSTGRES_USER" <<-EOSQL
  SET LC_MONETARY="nl_NL.utf8";
  CREATE DATABASE kasboek
      WITH 
      OWNER = postgres
      ENCODING = 'UTF8'
      LC_COLLATE = 'nl_NL.utf8'
      LC_CTYPE = 'nl_NL.utf8'
      TABLESPACE = pg_default
      CONNECTION LIMIT = -1;
EOSQL

psql --dbname=kasboek -v ON_ERROR_STOP=1 --username="$POSTGRES_USER" <<-EOSQL
  CREATE EXTENSION pg_trgm;
  
  CREATE SCHEMA kasboek;
  
  CREATE TABLE kasboek.transacties
  (
    id INT GENERATED ALWAYS AS IDENTITY,
    datum TIMESTAMP WITHOUT TIME ZONE,
    naam TEXT,
    rekening TEXT,
    tegenrekening TEXT,
    code character TEXT,
    af_bij TEXT,
    bedrag MONEY,
    mutatiesoort TEXT,
    mededeling TEXT,
    tsv TSVECTOR
  );
  
  CREATE TRIGGER create_tsv BEFORE INSERT OR UPDATE
  ON kasboek.transacties FOR EACH ROW EXECUTE FUNCTION
  tsvector_update_trigger(tsvector, 'pg_catalog.simple', 
  naam,
  rekening,
  tegenrekening,
  mededeling
  );
EOSQL
