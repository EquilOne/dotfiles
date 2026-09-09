# Ecosystem Templates Reference

Canonical .gitignore template URLs from github/gitignore. Use these exact patterns
when composing ecosystem-specific sections. If the raw URL is unreachable, use the
listed patterns as fallback (they mirror the canonical templates).

## Node.js

**Detection:** `package.json`, `yarn.lock`, `pnpm-lock.yaml`, `.nvmrc`
**Template:** https://raw.githubusercontent.com/github/gitignore/main/Node.gitignore
**Key patterns:**
```
node_modules/
npm-debug.log*
yarn-debug.log*
yarn-error.log*
.pnpm-debug.log*
lerna-debug.log*
.env
.env.local
.env.development.local
.env.test.local
.env.production.local
dist/
.next/
.cache/
```

## Python

**Detection:** `pyproject.toml`, `setup.py`, `setup.cfg`, `requirements.txt`, `Pipfile`, `poetry.lock`
**Template:** https://raw.githubusercontent.com/github/gitignore/main/Python.gitignore
**Key patterns:**
```
__pycache__/
*.py[cod]
*$py.class
*.so
.Python
env/
venv/
.venv/
pip-log.txt
pip-delete-this-directory.txt
.tox/
.coverage
.coverage.*
.cache
nosetests.xml
coverage.xml
*.cover
.hypothesis/
.pytest_cache/
```

## Rust

**Detection:** `Cargo.toml`, `Cargo.lock`
**Template:** https://raw.githubusercontent.com/github/gitignore/main/Rust.gitignore
**Key patterns:**
```
/target/
**/*.rs.bk
Cargo.lock   # only for libraries; commit for applications
```

## Go

**Detection:** `go.mod`, `go.sum`
**Template:** https://raw.githubusercontent.com/github/gitignore/main/Go.gitignore
**Key patterns:**
```
/bin/
*.exe
*.test
*.out
vendor/    # only if using vendor directory pattern
```

## Java (Maven)

**Detection:** `pom.xml`
**Template:** https://raw.githubusercontent.com/github/gitignore/main/Java.gitignore
**Key patterns:**
```
/target/
*.class
*.jar
*.war
*.ear
.settings/
.project
.classpath
```

## Java (Gradle)

**Detection:** `build.gradle`, `build.gradle.kts`
**Template:** https://raw.githubusercontent.com/github/gitignore/main/Gradle.gitignore
**Key patterns:**
```
.gradle/
/build/
!gradle/wrapper/gradle-wrapper.jar
!**/src/main/**/build/
!**/src/test/**/build/
```

## .NET / C#

**Detection:** `*.csproj`, `*.sln`
**Template:** https://raw.githubusercontent.com/github/gitignore/main/VisualStudio.gitignore
**Key patterns:**
```
[Bb]in/
[Oo]bj/
[Ll]og/
[Ll]ogs/
.vs/
*.user
*.suo
*.sln.docstates
*.nupkg
```

## PHP

**Detection:** `composer.json`
**Template:** https://raw.githubusercontent.com/github/gitignore/main/PHP.gitignore
**Key patterns:**
```
/vendor/
composer.lock   # only for libraries; commit for applications
```

## Ruby

**Detection:** `Gemfile`, `Rakefile`
**Template:** https://raw.githubusercontent.com/github/gitignore/main/Ruby.gitignore
**Key patterns:**
```
*.gem
.bundle/
vendor/bundle
vendor/ruby
```

## Dart / Flutter

**Detection:** `pubspec.yaml`
**Template:** https://raw.githubusercontent.com/github/gitignore/main/Dart.gitignore
**Key patterns:**
```
.dart_tool/
.packages
.pub/
build/
*.freezed.dart
*.g.dart
*.gen.dart
```

## Swift / Xcode

**Detection:** `Package.swift`, `*.xcodeproj`, `*.xcworkspace`
**Template:** https://raw.githubusercontent.com/github/gitignore/main/Swift.gitignore
**Key patterns:**
```
*.xcworkspace
xcuserdata/
DerivedData/
*.ipa
*.dSYM.zip
*.dSYM
```

## C / C++

**Detection:** `CMakeLists.txt`
**Template:** https://raw.githubusercontent.com/github/gitignore/main/C++.gitignore
**Key patterns:**
```
*.o
*.obj
*.exe
*.out
*.a
*.so
*.dll
*.dylib
build/
cmake-build-*/
```

## Elixir

**Detection:** `mix.exs`
**Template:** https://raw.githubusercontent.com/github/gitignore/main/Elixir.gitignore
**Key patterns:**
```
/_build/
/deps/
*.ez
*.beam
```

## Haskell

**Detection:** `stack.yaml`, `*.cabal`
**Template:** https://raw.githubusercontent.com/github/gitignore/main/Haskell.gitignore
**Key patterns:**
```
dist/
dist-newstyle/
.stack-work/
*.hi
*.o
```

## Terraform

**Detection:** `*.tf`
**Template:** https://raw.githubusercontent.com/github/gitignore/main/Terraform.gitignore
**Key patterns:**
```
*.tfstate
*.tfstate.*
crash.log
crash.*.log
.terraform/
*.tfvars
override.tf
override.tf.json
```

## Android (Kotlin)

**Detection:** `build.gradle.kts`, `settings.gradle.kts` on Android project structure
**Template:** https://raw.githubusercontent.com/github/gitignore/main/Android.gitignore
**Key patterns:**
```
local.properties
*.iml
.gradle/
build/
*/build/
captures/
.externalNativeBuild/
.cxx/
*.apk
*.aab
```

## Community Templates (Node.js Frameworks)

These apply on top of the Node.js template when the framework is detected:

**Next.js:** https://raw.githubusercontent.com/github/gitignore/main/Community/Next.js.gitignore
```
.next/
.cache/
out/
```

**Vue.js:** https://raw.githubusercontent.com/github/gitignore/main/Community/Vue.js.gitignore
```
dist/
dist-ssr/
*.local
```

**Angular:** https://raw.githubusercontent.com/github/gitignore/main/Community/Angular.gitignore
```
dist/
tmp/
```

**SvelteKit:** https://raw.githubusercontent.com/github/gitignore/main/Community/SvelteKit.gitignore
```
.svelte-kit/
build/
```

## Pattern Writing Guide

When you cannot reach the canonical template URLs, use these rules to compose
ecosystem patterns yourself:

- **Dependency directories:** `node_modules/`, `vendor/`, `.bundle/`, `deps/`, `.pub/`
- **Build output:** `dist/`, `build/`, `target/`, `_build/`, `.next/`, `.svelte-kit/`
- **Cache directories:** `.cache/`, `.parcel-cache/`, `.eslintcache/`, `.pytest_cache/`
- **Environment files:** `.env`, `.env.*` (but NOT `.env.example` — that should be committed)
- **Compiled artifacts:** `*.o`, `*.class`, `*.pyc`, `*.hi`, `*.beam`, `*.dll`, `*.so`, `*.dylib`
- **Package manager lockfiles:** Commit for apps (reproducible builds), ignore for libraries
- **IDE config directores:** `.vscode/`, `.idea/`, `.vs/` — prefer in global excludesFile
