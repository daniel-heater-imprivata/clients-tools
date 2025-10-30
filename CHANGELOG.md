# Changelog

All notable changes to clients-tools standards and scripts will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).

## [Unreleased]

### Added
- **Logging Guidelines** (`standards/global/logging-guidelines.md`)
  - Help-focused error messages (inspired by Elm and Rust)
  - Performance considerations for logging
  - Structured logging format conventions
  - Log level usage guidelines
  - Examples for common scenarios
  
- **Comments Guidelines** (`standards/global/comments-guidelines.md`)
  - Comments reflect current state (not history)
  - Prefer log messages over comments for documentation
  - Explain WHY, not WHAT
  - When to use (and not use) comments
  - Special comment markers (TODO, FIXME, HACK, NOTE)

## [2025-10-30] - Repository Restructure

### Changed
- **Repository renamed**: `clients-docs` → `clients-tools`
  - Better reflects that it contains both documentation and scripts
  
### Added
- **Scripts directory** (`scripts/`)
  - Retained scripts for common tasks
  - Output format convention (JSON + exit codes)
  - Execution policy (trusted automation)
  - Example scripts: `check-cpp20.sh`, `find-todos.sh`
  
- **Ephemeral scripts support**
  - Generate on-demand for multi-step tasks
  - Faster than multiple tool calls
  - Cleaner (no context window bloat)
  - Documented in AGENTS.md

## [2025-10-30] - Initial Release

### Added
- **Product plans** (`product/`)
  - `mission.md` - Secure, auditable remote access without VPN
  - `roadmap.md` - Phase-based development plan
  - `tech-stack.md` - C++17/Zig, deprecated Java
  - `architecture.md` - Two-plane architecture overview
  
- **Standards** (`standards/`)
  - `backend/cpp-guidelines.md` - C++17 coding standards
  - `backend/zig-guidelines.md` - Zig 0.15.1 coding standards
  - `global/just-patterns.md` - Just command runner best practices
  
- **AI Instructions** (`AGENTS.md`)
  - Critical Carl persona
  - Subtract First philosophy
  - Required reading list
  - User interaction protocols (Intern Protocol)
  
- **Governance**
  - `CONTRIBUTING.md` - How to propose changes
  - `.github/CODEOWNERS` - Auto-assign reviewers
  - `.github/pull_request_template.md` - PR template

### Convention
- **Sibling directory structure**: `clients-tools` always as sibling to project repos
- **No symlinks, no setup commands** - Just convention
