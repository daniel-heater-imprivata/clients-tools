# Changelog

All notable changes to agent-os-profiles will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).

## [Unreleased]

## [1.0.0] - 2025-10-28

### Added

#### pas-clients Profile
- **C++ Guidelines** (`standards/backend/cpp-guidelines.md`)
  - C++17 standards (no C++20 features)
  - RAII and memory management patterns
  - Const correctness guidelines
  - Threading and async patterns with Boost.Asio
  - Public C API vs internal C++ implementation rules
  - Package management with Conan

- **Zig Guidelines** (`standards/backend/zig-guidelines.md`)
  - Zig 0.15.1 specific patterns
  - ArrayList patterns (unmanaged, `.empty` syntax)
  - Memory management decision tree
  - Error handling with `errdefer` and `orelse`
  - Type casting patterns
  - C interop patterns
  - Testing guidelines (colocated tests)

- **Just Patterns** (`standards/global/just-patterns.md`)
  - Just expression language best practices
  - Anti-patterns to avoid
  - When to use bash vs Just native features
  - Recipe patterns and conventions

### Infrastructure
- Initial repository structure
- Profile configuration inheriting from default
- README with installation and usage instructions
- This CHANGELOG

## Future Plans

### Planned Additions
- Additional profiles for other teams/project types
- More language-specific standards as needed
- CI/CD patterns and standards
- Testing strategy guidelines

### Maintenance
- Regular updates to keep pace with language evolution
- Team feedback incorporation
- Examples and case studies from real projects

---

## How to Update This Changelog

When making changes to standards:

1. Add entry under `[Unreleased]` section
2. Use categories: `Added`, `Changed`, `Deprecated`, `Removed`, `Fixed`
3. Be specific about what changed and why
4. Include the standard file affected

Example:
```markdown
### Changed
- **C++ Guidelines**: Updated smart pointer guidance to prefer `std::unique_ptr` over `std::shared_ptr` for single ownership
```
