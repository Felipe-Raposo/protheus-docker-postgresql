#!/bin/bash
set -e

# Entrypoint wrapper: reconcilia usuario/banco/senha do Protheus a CADA start
# (idempotente), cobrindo volumes ja inicializados onde o /docker-entrypoint-initdb.d
# nao roda novamente. Em seguida delega para o entrypoint oficial do Postgres.
(
	if ! /usr/local/bin/protheus-reconcile.sh --wait; then
		echo "****** ERRO: reconciliacao do banco Protheus FALHOU; verifique as credenciais/logs. ******" >&2
		echo "****** O healthcheck manterá o container unhealthy até que o banco seja criado. ******" >&2
	fi
) &

exec docker-entrypoint.sh "$@"
