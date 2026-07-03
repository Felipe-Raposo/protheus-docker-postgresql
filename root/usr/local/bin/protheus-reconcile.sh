#!/bin/bash
set -euo pipefail

# Cria/atualiza o usuário e o banco do Protheus de forma idempotente, de acordo
# com a documentação TOTVS (Collation, Character Type e Encoding):
# https://tdn.totvs.com/display/tec/DBAccess+-+Collation%2C+Character+Type+e+Encoding
#
# Pode ser executado:
#   - pelo initdb (primeira inicializacao, via /docker-entrypoint-initdb.d), ou
#   - a cada start (via entrypoint), garantindo que a senha permaneca sincronizada
#     mesmo em volumes ja inicializados.

DATABASE_NAME=${PROTHEUS_DB:-"protheus"}
DATABASE_USER=${PROTHEUS_USER:-"protheus"}
DATABASE_PASS=${PROTHEUS_PASSWORD:-"protheus"}

# Com "--wait", aguarda o servidor aceitar conexoes (uso no start normal, em background).
if [[ "${1:-}" == "--wait" ]]; then
	until pg_isready -U "$POSTGRES_USER" -d "$POSTGRES_DB" -q; do
		sleep 1
	done
fi

echo "Reconciliando banco '$DATABASE_NAME' e usuario '$DATABASE_USER'"

# PGPASSWORD como fallback caso o pg_hba local nao seja 'trust'.
PGPASSWORD="${POSTGRES_PASSWORD:-}" psql -v ON_ERROR_STOP=1 \
	--username "$POSTGRES_USER" --dbname "$POSTGRES_DB" \
	-v db_name="$DATABASE_NAME" -v db_user="$DATABASE_USER" -v db_pass="$DATABASE_PASS" <<'EOSQL'
-- Cria o usuario apenas se ainda nao existir.
SELECT format('CREATE ROLE %I WITH LOGIN NOSUPERUSER INHERIT CREATEDB NOCREATEROLE NOREPLICATION CONNECTION LIMIT -1', :'db_user')
WHERE NOT EXISTS (SELECT FROM pg_roles WHERE rolname = :'db_user')
\gexec

-- Garante LOGIN e sincroniza a senha em todo start (format %L faz o escaping seguro).
SELECT format('ALTER ROLE %I WITH LOGIN PASSWORD %L', :'db_user', :'db_pass')
\gexec

-- Cria o banco apenas se ainda nao existir (CREATE DATABASE nao roda dentro de DO/transacao).
SELECT format('CREATE DATABASE %I OWNER %I TEMPLATE template0 ENCODING ''WIN1252'' LC_COLLATE ''C'' LC_CTYPE ''pt_BR.CP1252'' CONNECTION LIMIT -1', :'db_name', :'db_user')
WHERE NOT EXISTS (SELECT FROM pg_database WHERE datname = :'db_name')
\gexec
EOSQL

echo "Banco '$DATABASE_NAME' e usuario '$DATABASE_USER' reconciliados."
