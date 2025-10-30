# Clients Team Tech Stack

## Primary Languages

### C++17 (Primary)
- **Why**: Balance of modern features and compiler support
- **Standard**: Strictly C++17, no C++20 features
- **Rationale**: Production stability over bleeding-edge features
- **Usage**: librssconnect, future Gatekeeper

### Zig 0.15.1 (Primary)
- **Why**: Memory safety, cross-compilation, C interop
- **Version**: 0.15.1 (stable)
- **Rationale**: Better than C for systems programming, easier than Rust
- **Usage**: Future Gatekeeper, cross-platform builds

### ~~Java~~ (Legacy, Being Replaced)
- **Status**: **DEPRECATED** - Being phased out
- **Current Usage**: Gatekeeper (production), Audit (stable)
- **Rationale for Deprecation**:
  - Customer request
  - Complexity of distributing Java runtime
  - Performance limitations
  - Memory overhead

---

## Core Libraries

### Boost (1.80+) **To be removed**
- **Boost.Asio**: Async I/O foundation (plan to replace with header-only ASIO)
- **Boost.Beast**: HTTP/WebSocket client (plan to replace with Curl)
- **Boost.URL**: URL parsing (plan to replace with simple internal implementation)
- **Longer term**: Replace with Zig standard library

### libssh2
- **Purpose**: SSH tunnel management
- **Version**: Latest stable
- **Rationale**: Mature, widely-used SSH library

### OpenSSL
- **Purpose**: TLS/SSL for control plane
- **Version**: 1.1.1+ or 3.0+
- **Rationale**: Industry standard for cryptography
- **Long term**: Replace with native OS TLS providers for better FIPS support (Inspired by Rust native-TLS)

### spdlog
- **Purpose**: High-performance logging
- **Rationale**: Fast, flexible, header-only option
- **Long term**: Replace with Zig standard library logging

---

## Build System

### CMake (3.20+)
- **Purpose**: Cross-platform build configuration
- **Rationale**: Industry standard, good IDE support
- **Plan to replace**: Replace with Zig build system soon to enable cross-compilation

### Conan (2.0+)
- **Purpose**: Dependency management
- **Rationale**: C++ package manager, reproducible builds
- **Plan to replace**: Replace with Zig or Devbox packages and header-only C++ equivalents

### Just
- **Purpose**: Task automation
- **Rationale**: Simple, expressive, better than Make for tasks

### Devbox
- **Purpose**: Isolated reproducible builds

**Fallback**: We need to maintain current build options with Make and tools installed on runners until CI migrates to the new plan

---

## Testing

### Catch2
- **Purpose**: Unit and integration testing
- **Rationale**: Modern, expressive, header-only option
- **Long term**: Replace with Zig standard testing

### Sanitizers
- **ASAN**: Address sanitizer (memory safety)
- **TSAN**: Thread sanitizer (race conditions)
- **LSAN**: Leak sanitizer (memory leaks)
- **Rationale**: Catch bugs early, ensure production quality

---

## Development Tools

### Compiler Support
- **GCC**: 9.0+ (C++17 support)
- **Clang**: 10.0+ (C++17 support)
- **MSVC**: 2019+ (Windows support)
- **Zig**: 0.15.1 (Zig compilation)

### Platforms
- **Primary**: Linux (Ubuntu 20.04+, RHEL 8+)
- **Secondary**: macOS (for development)
- **Tertiary**: Windows (for client applications)

### Version Control
- **Git**: All code in git
- **GitHub**: Primary hosting
- **Viewyard**: Multi-repo workflow tool

---

## Distribution

### Conan Packages
- **Internal**: Private Conan repository

### Linking Strategy
- **Default**: Static linking (single binary)
- **SDKs**: Both shared libraries

---

## Architecture Decisions

### Why Zig over Rust?
- **Pros**: Simpler than Rust, excellent C interop, cross-compilation
- **Cons**: Younger ecosystem, less mature tooling
- **Decision**: Simplicity and C interop more important than Rust's guarantees

### Why Static Linking for Client Apps?
- **Pros**: Single binary, no DLL hell, easier deployment
- **Cons**: Larger binary size
- **Decision**: Deployment simplicity more important than binary size

---

## Coding Standards

See [standards/](../standards/) for detailed guidelines:
- [C++ Guidelines](../standards/cpp-guidelines.md)
- [Zig Guidelines](../standards/zig-guidelines.md)
- [Just Patterns](../standards/just-patterns.md)

