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
- **Migration Timeline**:
  - Q1 2026: Gatekeeper migration begins
  - Q2 2026: Java Connect removed from Gatekeeper
  - Q3 2026: Java Connect fully deprecated
- **Rationale for Deprecation**:
  - Performance limitations
  - Memory overhead
  - Maintenance burden
  - Team expertise shifting to C++/Zig

**⚠️ DO NOT use Java for new code. All new development in C++17 or Zig.**

---

## Core Libraries

### Boost (1.80+)
- **Boost.Asio**: Async I/O foundation
- **Boost.Beast**: HTTP/WebSocket client
- **Boost.URL**: URL parsing
- **Rationale**: Industry-standard, well-tested, cross-platform

### libssh2
- **Purpose**: SSH tunnel management
- **Version**: Latest stable
- **Rationale**: Mature, widely-used SSH library

### OpenSSL
- **Purpose**: TLS/SSL for control plane
- **Version**: 1.1.1+ or 3.0+
- **Rationale**: Industry standard for cryptography

### spdlog
- **Purpose**: High-performance logging
- **Rationale**: Fast, flexible, header-only option

---

## Build System

### CMake (3.20+)
- **Purpose**: Cross-platform build configuration
- **Rationale**: Industry standard, good IDE support

### Conan (2.0+)
- **Purpose**: Dependency management
- **Rationale**: C++ package manager, reproducible builds

### Just
- **Purpose**: Task automation
- **Rationale**: Simple, expressive, better than Make for tasks

---

## Testing

### Catch2
- **Purpose**: Unit and integration testing
- **Rationale**: Modern, expressive, header-only option

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
- **External**: Public packages for SDK consumers (future)

### Linking Strategy
- **Client Applications**: Static linking (single binary)
- **Gatekeeper**: Shared library (flexibility)
- **SDKs**: Both static and shared options

---

## Architecture Decisions

### Why C++17 over C++20?
- **Pros**: Stable, broad compiler support, production-proven
- **Cons**: Missing some nice features (std::span, ranges, concepts)
- **Decision**: Stability and compatibility over latest features

### Why Zig over Rust?
- **Pros**: Simpler than Rust, excellent C interop, cross-compilation
- **Cons**: Younger ecosystem, less mature tooling
- **Decision**: Simplicity and C interop more important than Rust's guarantees

### Why Boost.Asio over libuv?
- **Pros**: C++ native, type-safe, well-documented
- **Cons**: Large dependency, learning curve
- **Decision**: C++ integration and type safety worth the cost

### Why Static Linking for Client Apps?
- **Pros**: Single binary, no DLL hell, easier deployment
- **Cons**: Larger binary size
- **Decision**: Deployment simplicity more important than binary size

### Why Conan over vcpkg?
- **Pros**: Better C++ support, more mature, reproducible builds
- **Cons**: Learning curve
- **Decision**: Industry momentum and maturity

### Why Deprecate Java?
- **Performance**: C++/Zig significantly faster
- **Memory**: Lower memory footprint
- **Maintenance**: Team expertise shifting to C++/Zig
- **Cross-compilation**: Zig makes cross-platform builds easier
- **Decision**: Long-term benefits outweigh migration cost

---

## Coding Standards

See [standards/](../standards/) for detailed guidelines:
- [C++ Guidelines](../standards/cpp-guidelines.md)
- [Zig Guidelines](../standards/zig-guidelines.md)
- [Just Patterns](../standards/just-patterns.md)

---

## Future Considerations

### Potential Changes
- **HTTP/3**: May require different library (not in Boost yet)
- **QUIC**: May need custom implementation or third-party library
- **C++20**: Consider migration in 2027+ when compilers mature
- **Zig 0.16.0**: Monitor release, evaluate migration

### Technology Watch
- **Rust Interop**: Consider Rust for performance-critical components
- **WebAssembly**: Potential for browser-based clients
- **Cloud Native**: Kubernetes-specific features
