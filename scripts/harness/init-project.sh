#!/usr/bin/env bash
set -euo pipefail

HARNESS_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

TARGET_DIR=""
PROFILE=""
FORCE=false
INSTALL_HARNESS=false

print_usage() {
  cat <<'USAGE'
Usage:
  ./scripts/harness/init-project.sh /path/to/target-project --profile <profile> [--install-harness] [--force]

Profiles:
  typescript
  python-poetry
  python-uv
  jvm-gradle-java
  jvm-gradle-kotlin
  jvm-maven-java
  jvm-maven-kotlin


Options:
  --install-harness  Also install AGENTS.md, docs/codex, and scripts/codex.
  --force            Overwrite scaffold files if they already exist.
  -h, --help         Show this help.

Examples:
  ./scripts/harness/init-project.sh /tmp/dummy-ts --profile typescript --install-harness
  ./scripts/harness/init-project.sh /tmp/dummy-kotlin-gradle --profile jvm-gradle-kotlin --install-harness
  ./scripts/harness/init-project.sh /tmp/dummy-java-maven --profile jvm-maven-java --install-harness
USAGE
}

write_file() {
  local target="$1"
  local content="$2"

  mkdir -p "$(dirname "$target")"

  if [ -f "$target" ] && [ "$FORCE" != true ]; then
    echo "Skip existing: $target"
    return 0
  fi

  printf "%s" "$content" > "$target"
  echo "Created: $target"
}

init_typescript() {
  echo "Initializing TypeScript pnpm monorepo scaffold"

  mkdir -p "$TARGET_DIR"/{apps/backend/src,apps/frontend/src,libs/types/src,libs/utils/src}

  write_file "$TARGET_DIR/package.json" '{
  "name": "ai-harness-typescript-monorepo",
  "version": "0.1.0",
  "private": true,
  "packageManager": "pnpm@9.15.0",
  "type": "module",
  "scripts": {
    "lint": "pnpm -r run lint",
    "typecheck": "pnpm -r run typecheck",
    "test": "pnpm -r run test",
    "build": "pnpm -r run build"
  },
  "devDependencies": {
    "@eslint/js": "^9.0.0",
    "@types/node": "^22.0.0",
    "eslint": "^9.0.0",
    "prettier": "^3.0.0",
    "typescript": "^5.0.0",
    "typescript-eslint": "^8.0.0",
    "typescript-language-server": "^4.0.0"
  }
}
'

  write_file "$TARGET_DIR/pnpm-workspace.yaml" 'packages:
  - "apps/*"
  - "libs/*"
'

  write_file "$TARGET_DIR/tsconfig.base.json" '{
  "compilerOptions": {
    "target": "ES2022",
    "lib": ["ES2022", "DOM"],
    "module": "NodeNext",
    "moduleResolution": "NodeNext",
    "strict": true,
    "esModuleInterop": true,
    "skipLibCheck": true,
    "forceConsistentCasingInFileNames": true,
    "declaration": true,
    "sourceMap": true,
    "baseUrl": ".",
    "paths": {
      "@repo/types": ["libs/types/src/index.ts"],
      "@repo/utils": ["libs/utils/src/index.ts"]
    }
  }
}
'

  write_file "$TARGET_DIR/eslint.config.mjs" 'import js from "@eslint/js";
import tseslint from "typescript-eslint";

export default [
  {
    ignores: [
      "**/dist/**",
      "**/build/**",
      "**/coverage/**",
      "**/node_modules/**",
      "**/*.tsbuildinfo",
      "graphify-out/**"
    ]
  },
  js.configs.recommended,
  ...tseslint.configs.recommended,
  {
    files: ["**/*.ts", "**/*.tsx"],
    languageOptions: {
      parserOptions: {
        sourceType: "module"
      }
    }
  }
];
'

  for app in backend frontend; do
    local lint_ext=".ts"
    local jsx_line=""
    local include_line='"include": ["src/**/*.ts"]'
    if [ "$app" = "frontend" ]; then
      lint_ext=".ts,.tsx"
      jsx_line=$',
    "jsx": "react-jsx"'
      include_line='"include": ["src/**/*.ts", "src/**/*.tsx"]'
    fi

    write_file "$TARGET_DIR/apps/$app/package.json" "{
  \"name\": \"@repo/$app\",
  \"version\": \"0.1.0\",
  \"private\": true,
  \"type\": \"module\",
  \"scripts\": {
    \"lint\": \"eslint src --ext $lint_ext\",
    \"typecheck\": \"tsc --noEmit\",
    \"test\": \"echo 'No tests configured for $app'\",
    \"build\": \"tsc -p tsconfig.json\"
  },
  \"dependencies\": {
    \"@repo/types\": \"workspace:*\",
    \"@repo/utils\": \"workspace:*\"
  }
}
"

    write_file "$TARGET_DIR/apps/$app/tsconfig.json" "{
  \"extends\": \"../../tsconfig.base.json\",
  \"compilerOptions\": {
    \"outDir\": \"dist\"$jsx_line
  },
  $include_line
}
"

    write_file "$TARGET_DIR/apps/$app/src/index.ts" "import type { HealthCheckResponse } from \"@repo/types\";
import { formatMessage } from \"@repo/utils\";

const response: HealthCheckResponse = {
  status: \"ok\"
};

console.log(formatMessage(\`$app:\${response.status}\`));
"
  done

  write_file "$TARGET_DIR/libs/types/package.json" '{
  "name": "@repo/types",
  "version": "0.1.0",
  "private": true,
  "type": "module",
  "scripts": {
    "lint": "eslint src --ext .ts",
    "typecheck": "tsc --noEmit",
    "test": "echo '\''No tests configured for types'\''",
    "build": "tsc -p tsconfig.json"
  }
}
'

  write_file "$TARGET_DIR/libs/types/tsconfig.json" '{
  "extends": "../../tsconfig.base.json",
  "compilerOptions": {
    "outDir": "dist",
    "rootDir": "src"
  },
  "include": ["src/**/*.ts"]
}
'

  write_file "$TARGET_DIR/libs/types/src/index.ts" 'export type HealthCheckStatus = "ok" | "degraded";

export type HealthCheckResponse = {
  status: HealthCheckStatus;
};
'

  write_file "$TARGET_DIR/libs/utils/package.json" '{
  "name": "@repo/utils",
  "version": "0.1.0",
  "private": true,
  "type": "module",
  "scripts": {
    "lint": "eslint src --ext .ts",
    "typecheck": "tsc --noEmit",
    "test": "echo '\''No tests configured for utils'\''",
    "build": "tsc -p tsconfig.json"
  }
}
'

  write_file "$TARGET_DIR/libs/utils/tsconfig.json" '{
  "extends": "../../tsconfig.base.json",
  "compilerOptions": {
    "outDir": "dist",
    "rootDir": "src"
  },
  "include": ["src/**/*.ts"]
}
'

  write_file "$TARGET_DIR/libs/utils/src/index.ts" 'export function formatMessage(message: string): string {
  return `[ai-harness] ${message}`;
}
'

  write_file "$TARGET_DIR/.gitignore" 'node_modules/
dist/
coverage/
*.tsbuildinfo
.env
.DS_Store
graphify-out/cache/
.codex-runs/*
!.codex-runs/.gitkeep
'
}

init_python_poetry() {
  echo "Initializing Python Poetry monorepo-style scaffold"

  mkdir -p "$TARGET_DIR"/{apps/api/src/api,libs/common/src/common,tests}

  write_file "$TARGET_DIR/pyproject.toml" '[tool.poetry]
name = "ai-harness-python-poetry"
version = "0.1.0"
description = "Python Poetry monorepo-style scaffold for AI harness testing"
authors = ["Your Name <you@example.com>"]
package-mode = false

[tool.poetry.dependencies]
python = "^3.12"

[tool.poetry.group.dev.dependencies]
pytest = "^8.0.0"
ruff = "^0.8.0"
mypy = "^1.0.0"
pyright = "^1.1.0"

[tool.ruff]
line-length = 100
target-version = "py312"

[tool.pytest.ini_options]
testpaths = ["tests"]
pythonpath = ["apps/api/src", "libs/common/src"]

[tool.mypy]
mypy_path = "apps/api/src:libs/common/src"

[build-system]
requires = ["poetry-core"]
build-backend = "poetry.core.masonry.api"
'

  write_file "$TARGET_DIR/apps/api/src/api/__init__.py" ''
  write_file "$TARGET_DIR/apps/api/src/api/main.py" 'from common.formatting import format_message


def health_check() -> dict[str, str]:
    return {"status": format_message("ok")}
'

  write_file "$TARGET_DIR/libs/common/src/common/__init__.py" ''
  write_file "$TARGET_DIR/libs/common/src/common/formatting.py" 'def format_message(message: str) -> str:
    return f"[ai-harness] {message}"
'

  write_file "$TARGET_DIR/tests/test_health.py" 'from api.main import health_check


def test_health_check() -> None:
    assert health_check()["status"] == "[ai-harness] ok"
'

  write_file "$TARGET_DIR/.gitignore" '.venv/
__pycache__/
.pytest_cache/
.mypy_cache/
.ruff_cache/
.env
.DS_Store
graphify-out/cache/
.codex-runs/*
!.codex-runs/.gitkeep
'
}

init_python_uv() {
  echo "Initializing Python uv monorepo-style scaffold"

  mkdir -p "$TARGET_DIR"/{apps/api/src/api,libs/common/src/common,tests}

  write_file "$TARGET_DIR/pyproject.toml" '[project]
name = "ai-harness-python-uv"
version = "0.1.0"
description = "Python uv monorepo-style scaffold for AI harness testing"
requires-python = ">=3.12"
dependencies = []

[dependency-groups]
dev = [
  "pytest>=8.0.0",
  "ruff>=0.8.0",
  "mypy>=1.0.0",
  "pyright>=1.1.0"
]

[tool.ruff]
line-length = 100
target-version = "py312"

[tool.pytest.ini_options]
testpaths = ["tests"]
pythonpath = ["apps/api/src", "libs/common/src"]

[tool.mypy]
mypy_path = "apps/api/src:libs/common/src"
'

  write_file "$TARGET_DIR/apps/api/src/api/__init__.py" ''
  write_file "$TARGET_DIR/apps/api/src/api/main.py" 'from common.formatting import format_message


def health_check() -> dict[str, str]:
    return {"status": format_message("ok")}
'

  write_file "$TARGET_DIR/libs/common/src/common/__init__.py" ''
  write_file "$TARGET_DIR/libs/common/src/common/formatting.py" 'def format_message(message: str) -> str:
    return f"[ai-harness] {message}"
'

  write_file "$TARGET_DIR/tests/test_health.py" 'from api.main import health_check


def test_health_check() -> None:
    assert health_check()["status"] == "[ai-harness] ok"
'

  write_file "$TARGET_DIR/.gitignore" '.venv/
__pycache__/
.pytest_cache/
.mypy_cache/
.ruff_cache/
.env
.DS_Store
graphify-out/cache/
.codex-runs/*
!.codex-runs/.gitkeep
'
}

init_jvm_gradle_kotlin() {
  echo "Initializing JVM Gradle Kotlin multi-module scaffold"

  mkdir -p "$TARGET_DIR"/{apps/api/src/main/kotlin/com/example/api,apps/api/src/test/kotlin/com/example/api,libs/common/src/main/kotlin/com/example/common}

  write_file "$TARGET_DIR/settings.gradle.kts" 'pluginManagement {
    repositories {
        gradlePluginPortal()
        mavenCentral()
    }
}

dependencyResolutionManagement {
    repositoriesMode.set(RepositoriesMode.FAIL_ON_PROJECT_REPOS)
    repositories {
        mavenCentral()
    }
}

rootProject.name = "ai-harness-jvm-gradle-kotlin"

include("apps:api")
include("libs:common")
'

  write_file "$TARGET_DIR/build.gradle.kts" 'plugins {
    kotlin("jvm") version "2.0.21" apply false
}

subprojects {
    group = "com.example"
    version = "0.1.0"

    plugins.withId("org.jetbrains.kotlin.jvm") {
        extensions.configure<org.jetbrains.kotlin.gradle.dsl.KotlinJvmProjectExtension> {
            jvmToolchain(21)
        }
    }
}
'

  write_file "$TARGET_DIR/apps/api/build.gradle.kts" 'plugins {
    kotlin("jvm")
}

dependencies {
    implementation(project(":libs:common"))
    testImplementation(kotlin("test"))
    testRuntimeOnly("org.junit.platform:junit-platform-launcher:1.11.0")
}

tasks.test {
    useJUnitPlatform()
}
'

  write_file "$TARGET_DIR/libs/common/build.gradle.kts" 'plugins {
    kotlin("jvm")
}
'

  write_file "$TARGET_DIR/libs/common/src/main/kotlin/com/example/common/Formatting.kt" 'package com.example.common

fun formatMessage(message: String): String = "[ai-harness] $message"
'

  write_file "$TARGET_DIR/apps/api/src/main/kotlin/com/example/api/App.kt" 'package com.example.api

import com.example.common.formatMessage

fun healthCheck(): String = formatMessage("ok")
'

  write_file "$TARGET_DIR/apps/api/src/test/kotlin/com/example/api/AppTest.kt" 'package com.example.api

import kotlin.test.Test
import kotlin.test.assertEquals

class AppTest {
    @Test
    fun healthCheckReturnsFormattedStatus() {
        assertEquals("[ai-harness] ok", healthCheck())
    }
}
'

  write_file "$TARGET_DIR/.gitignore" '.gradle/
build/
out/
.env
.DS_Store
graphify-out/cache/
.codex-runs/*
!.codex-runs/.gitkeep
'
}

init_jvm_gradle_java() {
  echo "Initializing JVM Gradle Java multi-module scaffold"

  mkdir -p "$TARGET_DIR"/{apps/api/src/main/java/com/example/api,apps/api/src/test/java/com/example/api,libs/common/src/main/java/com/example/common}

  write_file "$TARGET_DIR/settings.gradle.kts" 'pluginManagement {
    repositories {
        gradlePluginPortal()
        mavenCentral()
    }
}

dependencyResolutionManagement {
    repositoriesMode.set(RepositoriesMode.FAIL_ON_PROJECT_REPOS)
    repositories {
        mavenCentral()
    }
}

rootProject.name = "ai-harness-jvm-gradle-java"

include("apps:api")
include("libs:common")
'

  write_file "$TARGET_DIR/build.gradle.kts" 'plugins {
    java
}

subprojects {
    group = "com.example"
    version = "0.1.0"

    apply(plugin = "java")

    extensions.configure<JavaPluginExtension> {
        toolchain {
            languageVersion.set(JavaLanguageVersion.of(21))
        }
    }

    tasks.withType<Test> {
        useJUnitPlatform()
    }
}
'

  write_file "$TARGET_DIR/apps/api/build.gradle.kts" 'dependencies {
    implementation(project(":libs:common"))
    testImplementation("org.junit.jupiter:junit-jupiter:5.11.0")
    testRuntimeOnly("org.junit.platform:junit-platform-launcher:1.11.0")
}
'

  write_file "$TARGET_DIR/libs/common/build.gradle.kts" ''

  write_file "$TARGET_DIR/libs/common/src/main/java/com/example/common/Formatting.java" 'package com.example.common;

public final class Formatting {
    private Formatting() {
    }

    public static String formatMessage(String message) {
        return "[ai-harness] " + message;
    }
}
'

  write_file "$TARGET_DIR/apps/api/src/main/java/com/example/api/App.java" 'package com.example.api;

import com.example.common.Formatting;

public final class App {
    private App() {
    }

    public static String healthCheck() {
        return Formatting.formatMessage("ok");
    }
}
'

  write_file "$TARGET_DIR/apps/api/src/test/java/com/example/api/AppTest.java" 'package com.example.api;

import static org.junit.jupiter.api.Assertions.assertEquals;

import org.junit.jupiter.api.Test;

class AppTest {
    @Test
    void healthCheckReturnsFormattedStatus() {
        assertEquals("[ai-harness] ok", App.healthCheck());
    }
}
'

  write_file "$TARGET_DIR/.gitignore" '.gradle/
build/
out/
.env
.DS_Store
graphify-out/cache/
.codex-runs/*
!.codex-runs/.gitkeep
'
}

init_jvm_maven_java() {
  echo "Initializing JVM Maven Java multi-module scaffold"

  mkdir -p "$TARGET_DIR"/{apps/api/src/main/java/com/example/api,apps/api/src/test/java/com/example/api,libs/common/src/main/java/com/example/common}

  write_file "$TARGET_DIR/pom.xml" '<project xmlns="http://maven.apache.org/POM/4.0.0"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 https://maven.apache.org/xsd/maven-4.0.0.xsd">
  <modelVersion>4.0.0</modelVersion>

  <groupId>com.example</groupId>
  <artifactId>ai-harness-jvm-maven-java</artifactId>
  <version>0.1.0</version>
  <packaging>pom</packaging>

  <modules>
    <module>libs/common</module>
    <module>apps/api</module>
  </modules>

  <properties>
    <maven.compiler.release>21</maven.compiler.release>
    <project.build.sourceEncoding>UTF-8</project.build.sourceEncoding>
    <junit.jupiter.version>5.11.0</junit.jupiter.version>
  </properties>

  <dependencyManagement>
    <dependencies>
      <dependency>
        <groupId>org.junit.jupiter</groupId>
        <artifactId>junit-jupiter</artifactId>
        <version>${junit.jupiter.version}</version>
        <scope>test</scope>
      </dependency>
    </dependencies>
  </dependencyManagement>
</project>
'

  write_file "$TARGET_DIR/libs/common/pom.xml" '<project xmlns="http://maven.apache.org/POM/4.0.0"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 https://maven.apache.org/xsd/maven-4.0.0.xsd">
  <modelVersion>4.0.0</modelVersion>

  <parent>
    <groupId>com.example</groupId>
    <artifactId>ai-harness-jvm-maven-java</artifactId>
    <version>0.1.0</version>
    <relativePath>../../pom.xml</relativePath>
  </parent>

  <artifactId>common</artifactId>
</project>
'

  write_file "$TARGET_DIR/apps/api/pom.xml" '<project xmlns="http://maven.apache.org/POM/4.0.0"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 https://maven.apache.org/xsd/maven-4.0.0.xsd">
  <modelVersion>4.0.0</modelVersion>

  <parent>
    <groupId>com.example</groupId>
    <artifactId>ai-harness-jvm-maven-java</artifactId>
    <version>0.1.0</version>
    <relativePath>../../pom.xml</relativePath>
  </parent>

  <artifactId>api</artifactId>

  <dependencies>
    <dependency>
      <groupId>com.example</groupId>
      <artifactId>common</artifactId>
      <version>${project.version}</version>
    </dependency>
    <dependency>
      <groupId>org.junit.jupiter</groupId>
      <artifactId>junit-jupiter</artifactId>
      <scope>test</scope>
    </dependency>
  </dependencies>

  <build>
    <plugins>
      <plugin>
        <groupId>org.apache.maven.plugins</groupId>
        <artifactId>maven-surefire-plugin</artifactId>
        <version>3.5.0</version>
      </plugin>
    </plugins>
  </build>
</project>
'

  write_file "$TARGET_DIR/libs/common/src/main/java/com/example/common/Formatting.java" 'package com.example.common;

public final class Formatting {
    private Formatting() {
    }

    public static String formatMessage(String message) {
        return "[ai-harness] " + message;
    }
}
'

  write_file "$TARGET_DIR/apps/api/src/main/java/com/example/api/App.java" 'package com.example.api;

import com.example.common.Formatting;

public final class App {
    private App() {
    }

    public static String healthCheck() {
        return Formatting.formatMessage("ok");
    }
}
'

  write_file "$TARGET_DIR/apps/api/src/test/java/com/example/api/AppTest.java" 'package com.example.api;

import static org.junit.jupiter.api.Assertions.assertEquals;

import org.junit.jupiter.api.Test;

class AppTest {
    @Test
    void healthCheckReturnsFormattedStatus() {
        assertEquals("[ai-harness] ok", App.healthCheck());
    }
}
'

  write_file "$TARGET_DIR/.gitignore" 'target/
.env
.DS_Store
graphify-out/cache/
.codex-runs/*
!.codex-runs/.gitkeep
'
}

init_jvm_maven_kotlin() {
  echo "Initializing JVM Maven Kotlin multi-module scaffold"

  mkdir -p "$TARGET_DIR"/{apps/api/src/main/kotlin/com/example/api,apps/api/src/test/kotlin/com/example/api,libs/common/src/main/kotlin/com/example/common}

  write_file "$TARGET_DIR/pom.xml" '<project xmlns="http://maven.apache.org/POM/4.0.0"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 https://maven.apache.org/xsd/maven-4.0.0.xsd">
  <modelVersion>4.0.0</modelVersion>

  <groupId>com.example</groupId>
  <artifactId>ai-harness-jvm-maven-kotlin</artifactId>
  <version>0.1.0</version>
  <packaging>pom</packaging>

  <modules>
    <module>libs/common</module>
    <module>apps/api</module>
  </modules>

  <properties>
    <kotlin.version>2.0.21</kotlin.version>
    <junit.jupiter.version>5.11.0</junit.jupiter.version>
    <project.build.sourceEncoding>UTF-8</project.build.sourceEncoding>
  </properties>

  <dependencyManagement>
    <dependencies>
      <dependency>
        <groupId>org.jetbrains.kotlin</groupId>
        <artifactId>kotlin-bom</artifactId>
        <version>${kotlin.version}</version>
        <type>pom</type>
        <scope>import</scope>
      </dependency>
      <dependency>
        <groupId>org.junit.jupiter</groupId>
        <artifactId>junit-jupiter</artifactId>
        <version>${junit.jupiter.version}</version>
        <scope>test</scope>
      </dependency>
    </dependencies>
  </dependencyManagement>

  <build>
    <pluginManagement>
      <plugins>
        <plugin>
          <groupId>org.jetbrains.kotlin</groupId>
          <artifactId>kotlin-maven-plugin</artifactId>
          <version>${kotlin.version}</version>
        </plugin>
      </plugins>
    </pluginManagement>
  </build>
</project>
'

  write_file "$TARGET_DIR/libs/common/pom.xml" '<project xmlns="http://maven.apache.org/POM/4.0.0"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 https://maven.apache.org/xsd/maven-4.0.0.xsd">
  <modelVersion>4.0.0</modelVersion>

  <parent>
    <groupId>com.example</groupId>
    <artifactId>ai-harness-jvm-maven-kotlin</artifactId>
    <version>0.1.0</version>
    <relativePath>../../pom.xml</relativePath>
  </parent>

  <artifactId>common</artifactId>

  <dependencies>
    <dependency>
      <groupId>org.jetbrains.kotlin</groupId>
      <artifactId>kotlin-stdlib</artifactId>
    </dependency>
  </dependencies>

  <build>
    <sourceDirectory>src/main/kotlin</sourceDirectory>
    <testSourceDirectory>src/test/kotlin</testSourceDirectory>
    <plugins>
      <plugin>
        <groupId>org.jetbrains.kotlin</groupId>
        <artifactId>kotlin-maven-plugin</artifactId>
        <executions>
          <execution>
            <id>compile</id>
            <phase>compile</phase>
            <goals>
              <goal>compile</goal>
            </goals>
          </execution>
          <execution>
            <id>test-compile</id>
            <phase>test-compile</phase>
            <goals>
              <goal>test-compile</goal>
            </goals>
          </execution>
        </executions>
      </plugin>
    </plugins>
  </build>
</project>
'

  write_file "$TARGET_DIR/apps/api/pom.xml" '<project xmlns="http://maven.apache.org/POM/4.0.0"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 https://maven.apache.org/xsd/maven-4.0.0.xsd">
  <modelVersion>4.0.0</modelVersion>

  <parent>
    <groupId>com.example</groupId>
    <artifactId>ai-harness-jvm-maven-kotlin</artifactId>
    <version>0.1.0</version>
    <relativePath>../../pom.xml</relativePath>
  </parent>

  <artifactId>api</artifactId>

  <dependencies>
    <dependency>
      <groupId>com.example</groupId>
      <artifactId>common</artifactId>
      <version>${project.version}</version>
    </dependency>
    <dependency>
      <groupId>org.jetbrains.kotlin</groupId>
      <artifactId>kotlin-stdlib</artifactId>
    </dependency>
    <dependency>
      <groupId>org.jetbrains.kotlin</groupId>
      <artifactId>kotlin-test-junit5</artifactId>
      <scope>test</scope>
    </dependency>
  </dependencies>

  <build>
    <sourceDirectory>src/main/kotlin</sourceDirectory>
    <testSourceDirectory>src/test/kotlin</testSourceDirectory>
    <plugins>
      <plugin>
        <groupId>org.jetbrains.kotlin</groupId>
        <artifactId>kotlin-maven-plugin</artifactId>
        <executions>
          <execution>
            <id>compile</id>
            <phase>compile</phase>
            <goals>
              <goal>compile</goal>
            </goals>
          </execution>
          <execution>
            <id>test-compile</id>
            <phase>test-compile</phase>
            <goals>
              <goal>test-compile</goal>
            </goals>
          </execution>
        </executions>
      </plugin>
      <plugin>
        <groupId>org.apache.maven.plugins</groupId>
        <artifactId>maven-surefire-plugin</artifactId>
        <version>3.5.0</version>
      </plugin>
    </plugins>
  </build>
</project>
'

  write_file "$TARGET_DIR/libs/common/src/main/kotlin/com/example/common/Formatting.kt" 'package com.example.common

fun formatMessage(message: String): String = "[ai-harness] $message"
'

  write_file "$TARGET_DIR/apps/api/src/main/kotlin/com/example/api/App.kt" 'package com.example.api

import com.example.common.formatMessage

fun healthCheck(): String = formatMessage("ok")
'

  write_file "$TARGET_DIR/apps/api/src/test/kotlin/com/example/api/AppTest.kt" 'package com.example.api

import kotlin.test.Test
import kotlin.test.assertEquals

class AppTest {
    @Test
    fun healthCheckReturnsFormattedStatus() {
        assertEquals("[ai-harness] ok", healthCheck())
    }
}
'

  write_file "$TARGET_DIR/.gitignore" 'target/
.env
.DS_Store
graphify-out/cache/
.codex-runs/*
!.codex-runs/.gitkeep
'
}

if [ "$#" -lt 1 ]; then
  print_usage
  exit 1
fi

TARGET_DIR="$1"
shift

while [ "$#" -gt 0 ]; do
  case "$1" in
    --profile)
      PROFILE="${2:-}"
      shift 2
      ;;
    --install-harness)
      INSTALL_HARNESS=true
      shift
      ;;
    --force)
      FORCE=true
      shift
      ;;
    -h|--help)
      print_usage
      exit 0
      ;;
    *)
      echo "Unknown argument: $1" >&2
      print_usage
      exit 1
      ;;
  esac
done

if [ -z "$PROFILE" ]; then
  echo "Missing --profile" >&2
  print_usage
  exit 1
fi

mkdir -p "$TARGET_DIR"

case "$PROFILE" in
  typescript)
    init_typescript
    ;;
  python-poetry)
    init_python_poetry
    ;;
  python-uv)
    init_python_uv
    ;;
  jvm-gradle-java)
    init_jvm_gradle_java
    ;;
  jvm-gradle-kotlin)
    init_jvm_gradle_kotlin
    ;;
  jvm-maven-java)
    init_jvm_maven_java
    ;;
  jvm-maven-kotlin)
    init_jvm_maven_kotlin
    ;;
  *)
    echo "Profile '$PROFILE' does not support project scaffold initialization." >&2
    echo "Supported init profiles: typescript, python-poetry, python-uv, jvm-gradle-java, jvm-gradle-kotlin, jvm-maven-java, jvm-maven-kotlin" >&2
    exit 1
    ;;
esac

if [ "$INSTALL_HARNESS" = true ]; then
  "$HARNESS_ROOT/scripts/harness/install-to-project.sh" "$TARGET_DIR" --profile "$PROFILE"
fi

echo
echo "Project scaffold initialized."
echo
echo "Next steps:"
echo "  cd \"$TARGET_DIR\""

case "$PROFILE" in
  typescript)
    echo "  pnpm install"
    ;;
  python-poetry)
    echo "  poetry install"
    ;;
  python-uv)
    echo "  uv sync"
    ;;
  jvm-gradle-java|jvm-gradle-kotlin)
    echo "  ./gradlew test  # if wrapper exists, otherwise gradle test"
    ;;
  jvm-maven-java|jvm-maven-kotlin)
    echo "  ./mvnw test     # if wrapper exists, otherwise mvn test"
    ;;
esac

if [ "$INSTALL_HARNESS" = true ]; then
  echo "  ./scripts/codex/bootstrap.sh --check"
  echo "  ./scripts/codex/verify.sh"
fi
