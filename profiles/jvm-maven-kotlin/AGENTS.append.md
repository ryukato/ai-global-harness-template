# JVM Maven Kotlin Profile

## JVM / Maven / Kotlin Rules

- Prefer Maven wrapper `./mvnw` over system `mvn`.
- Use Kotlin source layout: `src/main/kotlin`, `src/test/kotlin`.
- Do not edit `target/` or IDE-generated files.
- Keep module boundaries clear.
- Avoid changing dependency versions unless required by the task.
- For Kotlin/Spring projects, keep domain logic out of controllers.
- Keep coroutine boundaries and transaction boundaries explicit.

## Common Commands

```bash
./mvnw test
./mvnw package
```
