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
	# O Docker cria o diretorio do bind mount como root quando ele ainda nao
	# existe. O entrypoint oficial do PG 18 faz mkdir de PGDATA
	# (/var/lib/postgresql/18/docker) depois do gosu, ja com o UID do host, e
	# falha com "Permission denied" se o mount continuar do root.
	# Ajusta so esse diretorio (nao -R, para nao reescrever um PGDATA ja
	# inicializado). No Colima/virtiofs o chown pode falhar; nesse caso o
	# diretorio precisa nascer no host com o UID certo.
	if [ -d /var/lib/postgresql ]; then
		chown "${HOST_UID}:${HOST_GID}" /var/lib/postgresql 2>/dev/null || true
	fi
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
