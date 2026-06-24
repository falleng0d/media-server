# Hindsight

Self-hosted Hindsight memory server for the Dark NAS stack.

This compose file runs:

- `hindsight`: the Hindsight API on internal port `8888` and Control Plane UI on internal port `9999`
- `hindsight-db`: PostgreSQL 16 with pgvector for persistent storage

Traefik routes:

- Control Plane UI: `https://hindsight.${DOMAIN}`
- API: `https://hindsight-api.${DOMAIN}`

Both routes use the existing `local-network-ipallowlist@file` middleware.

Required environment variables:

- `DOMAIN`
- `HINDSIGHT_DB_PASSWORD`
- `HINDSIGHT_API_LLM_API_KEY`
- `HINDSIGHT_API_TENANT_API_KEY`
- `HINDSIGHT_CP_ACCESS_KEY`

Optional environment variables:

- `HINDSIGHT_VERSION` defaults to `latest`
- `HINDSIGHT_DB_USER` defaults to `hindsight_user`
- `HINDSIGHT_DB_NAME` defaults to `hindsight_db`
- `HINDSIGHT_API_LLM_PROVIDER` defaults to `openai`
- `HINDSIGHT_API_LLM_MODEL` defaults to `gpt-4o-mini`
- `HINDSIGHT_API_WORKER_ID` defaults to `dark-nas-hindsight`

Security notes:

- The API uses Hindsight's built-in `ApiKeyTenantExtension`; clients must send the tenant API key as a Bearer token.
- The Control Plane UI is protected by `HINDSIGHT_CP_ACCESS_KEY`.
- Do not commit a real `.env` file; use Dokploy environment variables or another secret store.

Local validation:

```bash
docker compose -f services/hindsight/docker-compose.yml config --quiet
```
