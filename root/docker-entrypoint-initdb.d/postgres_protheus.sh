#!/bin/bash
set -euo pipefail

# Executado apenas na primeira inicializacao (PGDATA vazio), pelo entrypoint oficial.
# A logica real (idempotente) fica em protheus-reconcile.sh, reaproveitada tambem
# pelo entrypoint em todo start.
/usr/local/bin/protheus-reconcile.sh
