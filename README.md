# Agent-OS Profiles

Shared [Agent-OS](https://github.com/buildermethods/agent-os) profiles for team development.

## Available Profiles

### `pas-clients`

**For:** C++ and Zig projects in the PAS Clients team

**Standards:**
- **C++17** - Modern C++ with RAII, const correctness, threading patterns
- **Zig 0.15.1** - Explicit over implicit, memory management, error handling
- **Just** - Command runner patterns and best practices

**Use for:** librssconnect, kazui, and other PAS client projects

## Quick Start

### 1. Install Agent-OS (if not already installed)

```bash
curl -sSL https://raw.githubusercontent.com/buildermethods/agent-os/main/scripts/base-install.sh | bash
```

### 2. Clone This Repository

```bash
cd ~/agent-os/profiles
git clone git@github.com:daniel-heater-imprivata/agent-os-profiles.git
```

### 3. Use in Your Project

```bash
cd /path/to/your/project
~/agent-os/scripts/project-install.sh --profile agent-os-profiles/pas-clients
```

**Note:** The profile path is `agent-os-profiles/pas-clients` because the profile is nested inside the cloned repo.

## Team Installation

Share these instructions with your team:

```bash
# One-time setup
cd ~/agent-os/profiles
git clone git@github.com:daniel-heater-imprivata/agent-os-profiles.git

# In each project
cd /path/to/project
~/agent-os/scripts/project-install.sh --profile agent-os-profiles/pas-clients
```

## Updating Standards

### For Profile Maintainers

When you update standards:

```bash
cd ~/agent-os/profiles/agent-os-profiles
# Edit files in pas-clients/standards/
git add .
git commit -m "Update C++ guidelines for X"
git push
```

### For Team Members

To get the latest standards:

```bash
# Update the profile
cd ~/agent-os/profiles/agent-os-profiles
git pull

# Re-compile standards in your project
cd /path/to/your/project
~/agent-os/scripts/project-update.sh
```

## Profile Structure

```
agent-os-profiles/
├── README.md                           # This file
├── CHANGELOG.md                        # Track standard changes
└── pas-clients/                        # Profile for PAS Clients team
    ├── profile-config.yml              # Inherits from default
    ├── standards/
    │   ├── backend/
    │   │   ├── cpp-guidelines.md       # C++17 coding standards
    │   │   └── zig-guidelines.md       # Zig 0.15.1 coding standards
    │   └── global/
    │       └── just-patterns.md        # Just command runner patterns
    └── workflows/                      # Custom workflows (optional)
```

## Standards Overview

### C++ Guidelines

- **C++17 only** - No C++20 features
- **RAII everywhere** - Smart pointers, no raw new/delete
- **Const correctness** - Think like Rust's borrow checker
- **Threading safety** - Proper use of shared_from_this, mutex protection
- **Public C API** - C-only types in include/ directory

### Zig Guidelines

- **Zig 0.15.1** - Version-specific patterns
- **Explicit over implicit** - Simplicity over cleverness
- **Memory management** - ArrayList patterns, arena allocators, errdefer
- **Error handling** - Specific error types, orelse patterns
- **C interop** - Sentinel-terminated pointers, callback patterns

### Just Patterns

- **Use Just's expression language** - Not bash
- **Built-in functions** - os(), arch(), env_var_or_default()
- **Error handling** - Use error() for validation
- **Recipe patterns** - Documentation, parameters, dependencies

## Contributing

### Proposing Changes

1. Create a branch
2. Make your changes to standards files
3. Update `CHANGELOG.md`
4. Create a pull request
5. Get team review

### Standards Philosophy

- **Subtract First** - Remove before adding
- **Explicit over Implicit** - Clear is better than clever
- **Examples over Explanation** - Show, don't just tell
- **Why over What** - Explain rationale, not just rules

## Resources

- **Agent-OS Documentation**: https://buildermethods.com/agent-os
- **C++ Core Guidelines**: https://isocpp.github.io/CppCoreGuidelines/
- **Zig Documentation**: https://ziglang.org/documentation/
- **Just Manual**: https://just.systems/man/en/
