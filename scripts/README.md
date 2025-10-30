# Clients Team Scripts

Retained scripts for common tasks across the clients team.

## Purpose

This directory contains **retained scripts** - tools that are useful enough to keep, version, and share with the team.

**Ephemeral scripts** (generated on-demand by AI) are not stored here - they're created in `/tmp/` and discarded after use.

---

## Script Categories

### Code Quality
- **check-cpp20.sh** - Verify no C++20 features are used (we require C++17)
- **check-const-correctness.sh** - Find missing const qualifiers
- **check-raw-pointers.sh** - Find raw new/delete (should use smart pointers)

### Standards Enforcement
- **verify-api-naming.sh** - Check public API follows naming conventions
- **verify-includes.sh** - Check include/ directory is C-only (no C++ types)

### Project Management
- **find-todos.sh** - Find all TODO/FIXME/HACK comments across repos
- **generate-coverage-report.sh** - Generate test coverage report for all repos

### Repository Operations
- **sync-repos.sh** - Pull latest from all repos in viewset
- **check-branch-status.sh** - Show git status for all repos

---

## Output Format Convention

All scripts follow this convention:

### JSON Output
```json
{
  "status": "success|warning|error",
  "summary": "One-line human-readable summary",
  "details": {
    "script_specific_data": "..."
  },
  "items": [
    {"file": "...", "line": 42, "issue": "..."}
  ]
}
```

### Exit Codes
- `0` - Success (no issues found)
- `1` - Error (issues found or script failed)
- `2` - Warning (non-critical issues)

### AI Processing
1. AI parses JSON for structured data
2. AI checks exit code for success/failure
3. AI generates human-readable summary from JSON
4. AI can chain scripts (pass JSON as input)

---

## Execution Policy

### Authority Level: Trusted Automation

**Allowed:**
- ✅ Read/write files in working directory and subdirectories
- ✅ Spawn subprocesses (git, grep, find, etc.)
- ✅ Call HTTP APIs (GitHub API, etc.)
- ✅ Create/delete temporary files
- ✅ Execute existing tools (make, just, cmake, etc.)

**Prohibited:**
- ❌ Install system packages (apt, brew, etc.)
- ❌ Modify system configuration (/etc/, ~/.bashrc, etc.)
- ❌ Sudo/elevated privileges
- ❌ Network configuration changes
- ❌ Irreversible effects outside working directory

### Scope Limits

**Working directory:** Parent of clients-tools and project repos
```
~/src/viewyard-viewsets/CLIENTS-520/
├── clients-tools/
├── librssconnect/
└── gatekeeper/
```

**Scripts may:**
- Read/write within this tree
- Create temp files in /tmp/
- Call external APIs (read-only preferred)

**Scripts may NOT:**
- Modify files outside this tree
- Delete git repos
- Force push to remote
- Modify system state

---

## Usage

### In Viewyard Viewsets

```bash
viewyard view create CLIENTS-520-feature
# Select: clients-tools, librssconnect, gatekeeper

cd CLIENTS-520-feature
./clients-tools/scripts/check-cpp20.sh
```

### Standalone

```bash
cd ~/src/clients-work
./clients-tools/scripts/check-cpp20.sh
```

### With AI

```
You: "Check if we're using any C++20 features"
AI: [runs clients-tools/scripts/check-cpp20.sh]
AI: [parses JSON output]
AI: "Found 3 violations: ..."
```

---

## Writing New Scripts

### Template

```bash
#\!/usr/bin/env bash
# script-name.sh - Brief description
#
# Usage: ./script-name.sh [options]
#
# Output: JSON to stdout, exit code indicates success/failure

set -euo pipefail

# Script logic here
# ...

# Output JSON
cat << EOJSON
{
  "status": "success",
  "summary": "Checked X files, found Y issues",
  "details": {
    "files_checked": $files_checked,
    "issues_found": $issues_found
  },
  "items": [
    {"file": "path/to/file", "line": 42, "issue": "description"}
  ]
}
EOJSON

# Exit code
exit $exit_code
```

### Guidelines

1. **Use bash for simple scripts** - File operations, grep, find
2. **Use Zig for complex scripts** - Parsing, validation, performance-critical
3. **Always output JSON** - Structured data for AI consumption
4. **Use exit codes** - 0 = success, 1 = error, 2 = warning
5. **Include usage comment** - How to run the script
6. **Make executable** - `chmod +x script-name.sh`

### Testing

Before committing a script:
```bash
# Test it works
./script-name.sh

# Test JSON is valid
./script-name.sh | jq .

# Test exit code
./script-name.sh && echo "Success" || echo "Failed"
```

---

## Contributing

See [../CONTRIBUTING.md](../CONTRIBUTING.md) for:
- How to propose new scripts
- PR review process
- Code review guidelines

---

## Examples

See existing scripts in this directory for examples of:
- JSON output format
- Error handling
- Multi-repo operations
- API calls
