# License Server

Imagem Docker para execução do **PostgreSQL para Protheus**, em ambiente containerizado.

## Descrição

Este projeto monta uma imagem Docker PostgreSQL, preparado para o Protheus. A imagem é útil para ambientes de desenvolvimento, testes ou orquestração (Kubernetes, Docker Compose, etc.).

### Características

- **Base:** postgres
- **PostgreSQL:** porta TCP 5432
- **Configuração dinâmica:** Banco de dados, usuário e senha definidos via variáveis de ambiente `DATABASE_NAME`, `DATABASE_USER` e `DATABASE_PASS`

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

- `feliperaposo/protheus-postgresql:16`
- `feliperaposo/protheus-postgresql:latest`

## Estrutura interna (referência)

- **Entrypoint:** `/docker-entrypoint-initdb.d/postgres_protheus.sh`
- **Configuração:** `/etc/postgresql.conf`

## Licença

Este projeto está sob a [GNU General Public License v3.0](LICENSE).

## Mantenedor

Felipe Raposo — [feliperaposo@gmail.com](mailto:feliperaposo@gmail.com)
