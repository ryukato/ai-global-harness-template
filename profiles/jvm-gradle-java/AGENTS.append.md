# JVM Gradle Java Profile

## JVM / Gradle / Java Rules

- Prefer Gradle wrapper `./gradlew` over system `gradle`.
- Use Java source layout: `src/main/java`, `src/test/java`.
- Do not edit `build/`, `.gradle/`, or IDE-generated files.
- Keep module boundaries clear.
- Avoid changing dependency versions unless required by the task.
- For Spring projects, keep domain logic out of controllers.
- Keep transaction boundaries explicit.

## Common Commands

```bash
./gradlew test
./gradlew build
```
