# Backend Architecture Boundaries

Backend scaffolds should match the selected profile and project context. Do not force FastAPI, Ports & Adapters, or a specific framework into every Python project.

## Optional Ports & Adapters Shape

For Python API scaffolds that select this style, keep boundaries explicit:

```text
src/app/
  main.py
  domain/
  application/
  adapters/
    inbound/
    outbound/
  config/
  shared/
```

## Boundary Meanings

- `domain`: pure business concepts, entities, value objects, and domain rules.
- `application`: use cases, orchestration, and ports/interfaces.
- `adapters/inbound`: HTTP routes, CLI entrypoints, workers, or other inbound delivery mechanisms.
- `adapters/outbound`: database access, external APIs, object storage, HTTP clients, and other explicitly selected infrastructure integrations.
- `config`: environment and application configuration.
- `shared`: cross-cutting helpers that do not belong in domain logic.

## Rules

- Keep framework details out of `domain`.
- Keep persistence and external system details out of domain objects.
- Keep inbound adapters thin where practical.
- Add outbound integrations only when explicitly requested or selected by profile.
