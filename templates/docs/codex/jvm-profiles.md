# JVM Profiles

JVM projects should specify both build tool and language.

## Supported profiles

```text
jvm-gradle-java
jvm-gradle-kotlin
jvm-maven-java
jvm-maven-kotlin
```


## Why split by language?

Java and Kotlin projects use different source directories and different build plugin settings.

### Gradle Java

Typical files:

```text
settings.gradle.kts
build.gradle.kts
src/main/java
src/test/java
```

### Gradle Kotlin

Typical files:

```text
settings.gradle.kts
build.gradle.kts
src/main/kotlin
src/test/kotlin
```

Requires Kotlin Gradle plugin.

### Maven Java

Typical files:

```text
pom.xml
src/main/java
src/test/java
```

### Maven Kotlin

Typical files:

```text
pom.xml
src/main/kotlin
src/test/kotlin
```

Requires `kotlin-maven-plugin` and source directory configuration.

## Verification

Verification is build-tool based:

```text
jvm-gradle-* -> ./gradlew test or gradle test
jvm-maven-*  -> ./mvnw test or mvn test
```
