# Just Patterns: Best Practices and Anti-Patterns

This document captures lessons learned about writing idiomatic justfiles for the Just command runner.

Reference the [Just Manual](https://just.systems/man/en/) for details

## Core Principle

**Just is NOT Make or Bash.** It has its own expression language. Use Just's native features instead of shelling out to bash for control flow.

## Good Patterns

### 1. Use Just's Conditional Expressions with Recipe Parameters

**✅ GOOD - Pure Just with recipe parameter:**
```just
# Run tests with sanitizers - detects memory errors (asan), undefined behavior (ubsan), threading issues (tsan)
test-sanitizer SAN:
    cmake -DCMAKE_C_FLAGS="{{ if SAN == "asan" { "-fsanitize=address" } else if SAN == "ubsan" { "-fsanitize=undefined" } else if SAN == "tsan" { "-fsanitize=thread" } else { error("Unknown sanitizer: " + SAN) } }}"
```

**❌ BAD - Bash case statement:**
```just
test-sanitizer SAN:
    #!/usr/bin/env bash
    case "{{SAN}}" in
        asan) FLAG="-fsanitize=address" ;;
        ubsan) FLAG="-fsanitize=undefined" ;;
        tsan) FLAG="-fsanitize=thread" ;;
    esac
    cmake -DCMAKE_C_FLAGS="$FLAG"
```

**Why:** Just has built-in conditionals. Using bash is an escape hatch for when Just can't do something, not for basic control flow.

**Note:** `SAN` is a [recipe parameter](https://just.systems/man/en/recipe-parameters.html). Call with `just test-sanitizer tsan`.

### 2. Use Just's Built-in Functions

**✅ GOOD - Just functions:**
```just
default_profile := if os() == "macos" {
    if arch() == "aarch64" { "armv8-macos" } else { "x86_64-macos" }
} else if os() == "linux" {
    "x86_64-alma8"
} else {
    "default"
}
```

**❌ BAD - Bash uname:**
```just
default_profile := `uname -s | grep -q Darwin && echo "macos" || echo "linux"`
```

**Why:** Just provides `os()`, `arch()`, `env_var()`, `env_var_or_default()`, etc. Use them.

### 3. Use POSIX Commands, Not Bash-isms

**✅ GOOD - POSIX test:**
```just
test-leaks:
    @test -x build/test-rssconnect || (echo "Build failed" && exit 1)
```

**❌ BAD - Bash [[ ]]:**
```just
test-leaks:
    @if [[ ! -x build/test-rssconnect ]]; then echo "Build failed" && exit 1; fi
```

**Why:** Just's default shell can be any POSIX shell. Bash-specific syntax (`[[`, `((`, etc.) breaks portability.

### 4. Use String Concatenation and Path Joining

**✅ GOOD - Just operators:**
```just
version := "1.0.0"
tardir := "release-" + version
tarball := tardir + ".tar.gz"
config_path := config_dir() / ".project-config"
```

**❌ BAD - Bash string manipulation:**
```just
tarball := `echo "release-${VERSION}.tar.gz"`
```

**Why:** Just has `+` for concatenation and `/` for path joining. Use them.

### 5. Use error() for Validation

**✅ GOOD - Explicit error with doc comment:**
```just
# Deploy to staging or production environment
deploy ENV:
    {{ if ENV != "staging" && ENV != "production" { error("ENV must be staging or production") } else { "" } }}
    ./deploy.sh {{ENV}}
```

**❌ BAD - Silent failure or bash exit:**
```just
deploy ENV:
    @[[ "{{ENV}}" == "staging" ]] || [[ "{{ENV}}" == "production" ]] || exit 1
    ./deploy.sh {{ENV}}
```

**Why:** `error()` provides clear, immediate feedback. Bash exit codes are opaque.

**Note:** [Documentation comments](https://just.systems/man/en/documentation-comments.html) (lines starting with `#` directly above a recipe) appear in `just --list`.

### 6. Use Recipe Dependencies

**✅ GOOD - Dependency chain with doc comments:**
```just
# Run all tests
test: build
    cargo test

# Build the project
build: lint
    cargo build

# Run linter
lint:
    cargo clippy
```

**❌ BAD - Manual sequencing:**
```just
test:
    just lint
    just build
    cargo test
```

**Why:** Dependencies are declarative and Just handles the execution order.

### 7. Use Private Recipes for Helpers

**✅ GOOD - Private helper:**
```just
# Run all tests
test: _setup
    cargo test

# Private helper - won't appear in just --list
[private]
_setup:
    mkdir -p tmp
```

**❌ BAD - Public helper:**
```just
test: setup
    cargo test

setup:
    mkdir -p tmp
```

**Why:** Private recipes (prefix `_` or `[private]` attribute) don't clutter `just --list`. Doc comments on private recipes are optional since they're not listed.

### 8. Use Variables for Repeated Values

**✅ GOOD - DRY with variables:**
```just
build_type := env_var_or_default('BUILD_TYPE', 'Release')
toolchain := "build/" + build_type + "/generators/conan_toolchain.cmake"

build:
    cmake -DCMAKE_TOOLCHAIN_FILE={{toolchain}}

test:
    cmake -DCMAKE_TOOLCHAIN_FILE={{toolchain}}
```

**❌ BAD - Repeated strings:**
```just
build:
    cmake -DCMAKE_TOOLCHAIN_FILE=build/Release/generators/conan_toolchain.cmake

test:
    cmake -DCMAKE_TOOLCHAIN_FILE=build/Release/generators/conan_toolchain.cmake
```

**Why:** Variables make changes easier and reduce errors.

## When to Use Bash

Bash is an **escape hatch** for when Just's expression language can't do something. Use it sparingly.

**✅ Acceptable bash usage:**
```just
# Complex multi-line script with pipes, loops, etc.
publish:
    VERSION=$(sed -En 's/version.*"([^"]+)"/\1/p' Cargo.toml | head -1)
    git tag -a $VERSION -m "Release $VERSION"
    git push origin $VERSION
    cargo publish
```

**❌ Unnecessary bash usage:**
```just
# Simple conditional - use Just instead!
test SAN:
    #!/usr/bin/env bash
    if [ "{{SAN}}" = "tsan" ]; then
        cmake --build build -j1
    else
        cmake --build build
    fi
```

**Rule of thumb:** If you can express it in Just's expression language, do so. Only use bash for:
- Complex pipelines
- Loops over command output
- Advanced string manipulation not available in Just
- Interacting with shell features (job control, etc.)

## Common Mistakes

### Mistake 1: Using Bash for Simple Conditionals

**❌ WRONG:**
```just
recipe PARAM:
    @if [ "{{PARAM}}" = "foo" ]; then echo "bar"; fi
```

**✅ RIGHT:**
```just
recipe PARAM:
    @echo {{ if PARAM == "foo" { "bar" } else { "" } }}
```

### Mistake 2: Forgetting @ for Silent Commands

**❌ WRONG (noisy):**
```just
test:
    echo "Running tests..."
    cargo test
```

**✅ RIGHT (clean output):**
```just
test:
    @echo "Running tests..."
    cargo test
```

**Why:** `@` suppresses echoing the command itself. Use it for informational messages.

### Mistake 3: Not Using env_var_or_default

**❌ WRONG:**
```just
build:
    cmake -DCMAKE_BUILD_TYPE=${BUILD_TYPE:-Release}
```

**✅ RIGHT:**
```just
build_type := env_var_or_default('BUILD_TYPE', 'Release')

build:
    cmake -DCMAKE_BUILD_TYPE={{build_type}}
```

**Why:** Just has a built-in function for this. Use it.

### Mistake 4: Inline Bash for Platform Detection

**❌ WRONG:**
```just
install:
    @if [ "$(uname)" = "Darwin" ]; then brew install foo; else apt install foo; fi
```

**✅ RIGHT:**
```just
install:
    {{ if os() == "macos" { "brew install foo" } else { "apt install foo" } }}
```

**Why:** Just's `os()` function is clearer and more portable.

## Just Expression Language Reference

### Operators
- `+` - String concatenation: `"foo" + "bar"` → `"foobar"`
- `/` - Path joining: `"a" / "b"` → `"a/b"`
- `==`, `!=` - Equality comparison
- `&&`, `||` - Logical operators (treat empty string as false)
- `=~` - Regular expression match

### Conditionals
```just
value := if condition { "true-value" } else { "false-value" }
value := if cond1 { "a" } else if cond2 { "b" } else { "c" }
```

### Functions
- `os()` - Returns "macos", "linux", "windows"
- `arch()` - Returns "x86_64", "aarch64", etc.
- `env_var(name)` - Get environment variable (fails if not set)
- `env_var_or_default(name, default)` - Get env var with fallback
- `error(message)` - Abort with error message
- `quote(string)` - Shell-quote a string
- `uppercase(string)`, `lowercase(string)` - Case conversion
- `trim(string)` - Remove whitespace
- `replace(string, from, to)` - String replacement

### Backticks (Use Sparingly)
```just
# Capture command output
git_hash := `git rev-parse HEAD`
```

**Note:** Backticks run at parse time, not recipe execution time. Use sparingly.

## Shell Configuration

**Set the shell** only at the top of the file and only when required
This sets bash as the default shell for the file. **You never need a shebang**

```just
# Set shell only when required
set shell := ["bash", "-euo", "pipefail", "-c"]
```

**Flags explained:**
- `-e` - Exit on error
- `-u` - Error on undefined variables
- `-o pipefail` - Fail if any command in a pipeline fails
- `-c` - Execute command string

This makes recipes fail fast and predictably.

## Summary

1. **Use Just's expression language** for conditionals, string manipulation, and platform detection
2. **Use POSIX commands** in recipe bodies, not bash-specific syntax
3. **Use Just's built-in functions** instead of shelling out
4. **Use variables** to avoid repetition
5. **Use `@`** to suppress command echoing for clean output
6. **Use `error()`** for validation and clear error messages
7. **Use private recipes** (`_prefix` or `[private]`) for helpers

**The goal:** A justfile should read like a declarative build specification, not a bash script.

