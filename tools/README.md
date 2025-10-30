# Team Tools

Documentation for tools used by the Clients team.

---

## Purpose

This directory documents **tools and workflows** used by the team. These are not coding standards (see `standards/`) but rather **how to use tools** effectively.

---

## Available Tools

### Development Tools

- **[jira-cli.md](jira-cli.md)** - Command-line interface for Jira
  - More reliable than MCP
  - Faster than web UI
  - Scriptable and terminal-native

### Workflow Tools

- **viewyard** - Multi-repo workflow tool (documentation TBD)
- **git** - Version control workflows (documentation TBD)

---

## Tool Selection Criteria

We document tools that:
1. **Improve productivity** - Faster than alternatives
2. **Are reliable** - Consistent behavior
3. **Fit developer workflow** - Terminal-native preferred
4. **Are team-standard** - Everyone should use them

---

## Installation and Setup

Each tool's documentation includes:
- Installation instructions
- One-time setup steps
- Common commands
- Best practices
- Troubleshooting

---

## Contributing

To add a new tool:
1. Create `tool-name.md` in this directory
2. Follow the template:
   - Why use this tool?
   - Installation
   - Setup
   - Common commands
   - Best practices
   - Troubleshooting
3. Update this README
4. Submit PR

See [../CONTRIBUTING.md](../CONTRIBUTING.md) for PR process.

---

## Tool Recommendations

### Jira Access

**Recommended:** `jira-cli` (see [jira-cli.md](jira-cli.md))
- Faster and more reliable than web UI or MCP
- Terminal-native
- Scriptable

**Alternative:** Web UI
- Use for complex workflows (sprint planning, board views)
- Use for attachments and rich formatting

**Not Recommended:** MCP
- Less reliable than CLI
- Slower
- Harder to debug

### Multi-Repo Workflows

**Recommended:** `viewyard` (documentation TBD)
- Manages multiple repos as a unit
- Ephemeral working directories
- Clean separation of features

**Alternative:** Manual cloning
- More control
- More setup overhead

---

## Getting Help

- Check tool-specific documentation in this directory
- Ask in team chat
- Open issue in clients-tools repo
