# JVM Gradle Kotlin Profile

## JVM / Gradle / Kotlin Rules

- Prefer Gradle wrapper `./gradlew` over system `gradle`.
- Use Kotlin source layout: `src/main/kotlin`, `src/test/kotlin`.
- Prefer Gradle Kotlin DSL: `settings.gradle.kts`, `build.gradle.kts`.
- Do not edit `build/`, `.gradle/`, or IDE-generated files.
- Keep module boundaries clear.
- Avoid changing dependency versions unless required by the task.
- For Kotlin/Spring projects, keep domain logic out of controllers.
- Keep coroutine boundaries and transaction boundaries explicit.

## Common Commands

```bash
./gradlew test
./gradlew build
```
