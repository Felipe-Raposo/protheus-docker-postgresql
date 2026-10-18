#!/bin/bash
set -e

# Com HOST_UID/HOST_GID definidos (ex.: bind mount no macOS/Colima), o entrypoint
# oficial roda com o UID/GID do host. Assim ele nao tenta chown no PGDATA, o que
# falha em compartilhamentos virtiofs. O container precisa iniciar como root para
# o daemon nao tentar chown no caminho do bind mount.
run_postgres_entrypoint() {
	exec docker-entrypoint.sh "$@"
}

if [ -n "${HOST_UID:-}" ] && [ -n "${HOST_GID:-}" ] && [ "$(id -u)" = '0' ]; then
	run_postgres_entrypoint() {
		exec gosu "${HOST_UID}:${HOST_GID}" docker-entrypoint.sh "$@"
	}
fi

# Entrypoint wrapper: reconcilia usuario/banco/senha do Protheus a CADA start
# (idempotente), cobrindo volumes ja inicializados onde o /docker-entrypoint-initdb.d
# nao roda novamente. Em seguida delega para o entrypoint oficial do Postgres.
(
	if ! /usr/local/bin/protheus-reconcile.sh --wait; then
		echo "****** ERRO: reconciliacao do banco Protheus FALHOU; verifique as credenciais/logs. ******" >&2
		echo "****** O healthcheck manterá o container unhealthy até que o banco seja criado. ******" >&2
	fi
) &

run_postgres_entrypoint "$@"
