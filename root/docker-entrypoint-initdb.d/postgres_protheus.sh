#!/bin/bash

# Cria usuário e banco de dados protheus, de acordo com documentação TOTVS em:
# https://tdn.totvs.com/display/tec/DBAccess+-+Collation%2C+Character+Type+e+Encoding

DATABASE_NAME=${PROTHEUS_DB:-"protheus"}
DATABASE_USER=${PROTHEUS_USER:-"protheus"}
DATABASE_PASS=${PROTHEUS_PASSWORD:-"protheus"}

echo "Creating database '$DATABASE_NAME' and user '$DATABASE_USER'"
psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
    CREATE USER "$DATABASE_USER" WITH
    	LOGIN
    	NOSUPERUSER
    	INHERIT
    	CREATEDB
    	NOCREATEROLE
    	NOREPLICATION
    	CONNECTION LIMIT -1
    	ENCRYPTED PASSWORD '$DATABASE_PASS';
    CREATE DATABASE "$DATABASE_NAME" WITH
    	OWNER="$DATABASE_USER"
    	TEMPLATE=template0
    	ENCODING='WIN1252'
    	LC_COLLATE='C'
    	LC_CTYPE='pt_BR.CP1252'
    	CONNECTION LIMIT = -1;
EOSQL
