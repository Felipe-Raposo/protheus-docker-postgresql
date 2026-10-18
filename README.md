# Protheus Docker PostgreSQL 18

Imagem Docker para execução do **PostgreSQL para Protheus**, em ambiente containerizado.

## Descrição

Este projeto monta uma imagem Docker PostgreSQL, preparado para o Protheus. A imagem é útil para ambientes de desenvolvimento, testes ou orquestração (Kubernetes, Docker Compose, etc.).

### Características

- **Base:** postgres:18
- **PostgreSQL:** porta TCP 5432
- **Configuração dinâmica:** Banco de dados, usuário e senha definidos via variáveis de ambiente `PROTHEUS_DB`, `PROTHEUS_USER` e `PROTHEUS_PASSWORD`

## Pré-requisitos

- Docker (com BuildKit habilitado para build)

## Build

```bash
# Build local das tags de versão
make build
```

## Publicação da imagem

```bash
# Build e push das tags de versão
make release

# Incluir também a tag latest
make release_latest
```

Gera as tags:

- `feliperaposo/protheus-postgresql:18`
- `feliperaposo/protheus-postgresql:latest`

## Volume de dados

A partir do PostgreSQL 18, a imagem oficial grava os dados em `/var/lib/postgresql/18/docker` (`PGDATA`) e declara o volume em `/var/lib/postgresql`. Monte o volume nesse diretório:

```yaml
volumes:
    - ./volume/data/psql:/var/lib/postgresql
```

Montagens antigas em `/var/lib/postgresql/data` não são mais suportadas.

## Atualização a partir do PostgreSQL 16

Os arquivos de dados não são compatíveis entre versões principais. Para migrar um volume existente, faça dump no container antigo e restore no novo:

```bash
# No container PostgreSQL 16
docker exec -t <container_16> pg_dumpall -U postgres > protheus.sql

# No container PostgreSQL 18 (volume novo, vazio)
docker exec -i <container_18> psql -U postgres < protheus.sql
```

## Estrutura interna (referência)

- **Entrypoint:** `/usr/local/bin/protheus-entrypoint.sh` (wrapper que reconcilia o banco e delega ao entrypoint oficial)
- **Reconciliação:** `/usr/local/bin/protheus-reconcile.sh` — cria o usuário/banco do Protheus (na primeira inicialização, via `/docker-entrypoint-initdb.d`) e **sincroniza a senha a cada start** de forma idempotente, mesmo em volumes já inicializados
- **Configuração:** `/etc/postgresql.conf`
- **Dados (`PGDATA`):** `/var/lib/postgresql/18/docker`

## Licença

Este projeto está sob a [GNU General Public License v3.0](LICENSE).

## Mantenedor

Felipe Raposo — [feliperaposo@gmail.com](mailto:feliperaposo@gmail.com)
