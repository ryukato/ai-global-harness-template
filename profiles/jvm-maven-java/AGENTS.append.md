# JVM Maven Java Profile

## JVM / Maven / Java Rules

- Prefer Maven wrapper `./mvnw` over system `mvn`.
- Use Java source layout: `src/main/java`, `src/test/java`.
- Do not edit `target/` or IDE-generated files.
- Keep module boundaries clear.
- Avoid changing dependency versions unless required by the task.
- For Spring projects, keep domain logic out of controllers.
- Keep transaction boundaries explicit.

## Common Commands

```bash
./mvnw test
./mvnw package
```
