# Jira CLI Tool

Command-line interface for Jira - more reliable than MCP for accessing tickets.

**GitHub:** https://github.com/ankitpokhrel/jira-cli

---

## Why Use Jira CLI?

**Advantages over web UI:**
- ✅ Faster - No browser overhead
- ✅ Scriptable - Can automate workflows
- ✅ Offline-friendly - Works with cached data
- ✅ Terminal-native - Fits developer workflow

**Advantages over MCP:**
- ✅ More reliable - Direct API access
- ✅ Better error messages - Clear what went wrong
- ✅ Faster - No AI intermediary
- ✅ Consistent - Same behavior every time

---

## Installation

### macOS (Homebrew)
```bash
brew install ankitpokhrel/jira-cli/jira-cli
```

### Linux (Snap)
```bash
snap install jira-cli
```

### Other Platforms
See: https://github.com/ankitpokhrel/jira-cli#installation

---

## Setup (One-Time)

### 1. Initialize Configuration

```bash
jira init
```

**You'll be prompted for:**
- **Jira URL**: `https://imprivata.atlassian.net` (or your instance)
- **Login method**: Choose "API Token" (recommended)
- **Email**: Your Imprivata email
- **API Token**: Generate at https://id.atlassian.com/manage-profile/security/api-tokens

### 2. Set Default Project

```bash
# Edit config file
vim ~/.config/.jira/.config.yml

# Add default project
project:
  key: CLIENTS  # Or your project key
```

### 3. Verify Setup

```bash
jira me
# Should show your user info

jira issue list
# Should show issues in your project
```

---

## Common Commands

### View Issues

```bash
# List issues in current sprint
jira sprint list --current

# List my assigned issues
jira issue list -a$(jira me)

# List issues by status
jira issue list -s"In Progress"

# Search with JQL
jira issue list --jql "project = CLIENTS AND assignee = currentUser()"
```

### View Issue Details

```bash
# View issue
jira issue view CLIENTS-520

# View issue in browser
jira open CLIENTS-520
```

### Create Issue

```bash
# Interactive creation
jira issue create

# Quick creation
jira issue create -tTask -s"Implement WebSocket support" -b"Add WebSocket support to librssconnect"

# With more details
jira issue create \
  -tTask \
  -s"Implement WebSocket support" \
  -b"Add WebSocket support to librssconnect following roadmap" \
  -lbackend \
  -lc++ \
  --priority High
```

### Update Issue

```bash
# Move to In Progress
jira issue move CLIENTS-520 "In Progress"

# Add comment
jira issue comment add CLIENTS-520 "Implemented control plane, working on data plane"

# Assign to yourself
jira issue assign CLIENTS-520 $(jira me)

# Link issues
jira issue link CLIENTS-520 CLIENTS-521 "blocks"
```

### Sprints

```bash
# List sprints
jira sprint list

# View current sprint
jira sprint list --current

# Add issue to sprint
jira sprint add <sprint-id> CLIENTS-520
```

### Boards

```bash
# List boards
jira board list

# View board
jira board view <board-id>
```

---

## Useful Workflows

### Daily Standup Prep

```bash
# What did I work on yesterday?
jira issue list -a$(jira me) --updated -1d

# What am I working on today?
jira issue list -a$(jira me) -s"In Progress"

# Any blockers?
jira issue list -a$(jira me) --jql "status = Blocked"
```

### Starting Work on Issue

```bash
# View issue details
jira issue view CLIENTS-520

# Move to In Progress
jira issue move CLIENTS-520 "In Progress"

# Assign to yourself
jira issue assign CLIENTS-520 $(jira me)

# Open in browser for more details
jira open CLIENTS-520
```

### Completing Work

```bash
# Add comment with summary
jira issue comment add CLIENTS-520 "Implemented WebSocket support. Tests passing. Ready for review."

# Move to Review
jira issue move CLIENTS-520 "In Review"

# Link to PR (if applicable)
jira issue comment add CLIENTS-520 "PR: https://github.com/imprivata-pas/librssconnect/pull/123"
```

### Sprint Planning

```bash
# View backlog
jira issue list --jql "project = CLIENTS AND status = Backlog ORDER BY priority DESC"

# View current sprint
jira sprint list --current

# Add issues to sprint
jira sprint add <sprint-id> CLIENTS-520 CLIENTS-521 CLIENTS-522
```

---

## Integration with AI Tools

### Use with Augment Code

```bash
# Get issue details for AI context
jira issue view CLIENTS-520 --plain

# Then in Augment Code:
"Implement CLIENTS-520: $(jira issue view CLIENTS-520 --plain)"
```

### Use in Scripts

```bash
#\!/usr/bin/env bash
# Get current sprint issues and generate report

SPRINT_ID=$(jira sprint list --current --plain | head -1 | awk '{print $1}')
ISSUES=$(jira issue list --sprint $SPRINT_ID --plain)

echo "Current Sprint Issues:"
echo "$ISSUES"

# Generate JSON for AI consumption
jira issue list --sprint $SPRINT_ID --json > /tmp/sprint-issues.json
```

---

## Configuration Tips

### Aliases (Add to ~/.bashrc or ~/.zshrc)

```bash
# Quick aliases
alias jl='jira issue list'
alias jv='jira issue view'
alias jo='jira open'
alias jm='jira issue move'
alias jc='jira issue comment add'

# My issues
alias jmine='jira issue list -a$(jira me)'

# Current sprint
alias jsprint='jira sprint list --current'
```

### Using JQL Directly

```bash
# Use JQL directly with --jql/-q flag
jira issue list --jql "project = CLIENTS AND assignee = currentUser() AND status != Done"

# Create shell aliases for common queries (add to ~/.bashrc or ~/.zshrc)
alias jmine='jira issue list --jql "assignee = currentUser() AND status != Done"'
alias jblocked='jira issue list --jql "status = Blocked"'
alias jreview='jira issue list --jql "assignee = currentUser() AND status = '"In Review"'"'
```
---

## Troubleshooting

### Config File Errors

**Error:** `unsupported protocol scheme ""`

This usually means your config file has YAML syntax errors.

**Common causes:**
- Duplicate keys in config file (e.g., multiple `queries:` keys)
- Malformed YAML syntax
- Server URL not being read correctly

**Solution:**
```bash
# Validate YAML syntax
python3 -c "import yaml; yaml.safe_load(open('~/.config/.jira/.config.yml'))" 2>&1

# If you see errors, check for duplicate keys
grep -n "^queries:" ~/.config/.jira/.config.yml
grep -n "^server:" ~/.config/.jira/.config.yml

# Remove duplicate keys manually or re-run jira init
vim ~/.config/.jira/.config.yml
```

**Verify fix:**
```bash
jira serverinfo  # Should show server info, not error
```


### JQL Query Errors

**Error:** `unsupported protocol scheme ""`

This usually means:
- JQL syntax error
- Missing quotes around JQL query
- Trying to use query alias (not supported)

**Solution:**
```bash
# Always use full JQL with quotes
jira issue list --jql "assignee = currentUser() AND status != Done"

# Create shell aliases for common queries instead
alias jmine='jira issue list --jql "assignee = currentUser()"'
```


### Authentication Issues

```bash
# Re-initialize config
jira init

# Verify credentials
jira me

# Check API token is valid
# Regenerate at: https://id.atlassian.com/manage-profile/security/api-tokens
```

### Connection Issues

```bash
# Test connection
jira serverinfo

# Check config
cat ~/.config/.jira/.config.yml

# Enable debug mode
jira --debug issue list
```

### Rate Limiting

Jira API has rate limits. If you hit them:
- Wait a few minutes
- Reduce frequency of requests
- Use `--plain` output to reduce data transfer

---

## Best Practices

### 1. Use Descriptive Issue Titles

```bash
# Bad
jira issue create -tTask -s"Fix bug"

# Good
jira issue create -tTask -s"Fix race condition in connection cleanup"
```

### 2. Add Context in Comments

```bash
# Bad
jira issue comment add CLIENTS-520 "Done"

# Good
jira issue comment add CLIENTS-520 "Implemented WebSocket support. Added tests. All sanitizers passing. Ready for review."
```

### 3. Link Related Issues

```bash
# Link blocking issues
jira issue link CLIENTS-520 CLIENTS-519 "blocks"

# Link related work
jira issue link CLIENTS-520 CLIENTS-521 "relates to"
```

### 4. Keep Status Updated

```bash
# Update status as you work
jira issue move CLIENTS-520 "In Progress"  # When starting
jira issue move CLIENTS-520 "In Review"    # When ready for review
jira issue move CLIENTS-520 "Done"         # When complete
```

---

## Team Coordination

### Viewing Team's Work

```bash
# View all team issues
jira issue list --jql "project = CLIENTS AND sprint in openSprints()"

# View specific team member's work
jira issue list -a"teammate@imprivata.com"

# View issues by component
jira issue list --jql "project = CLIENTS AND component = librssconnect"
```

### Sprint Reports

```bash
# View sprint progress
jira sprint list --current

# View completed issues
jira issue list --jql "project = CLIENTS AND sprint in openSprints() AND status = Done"

# View in-progress issues
jira issue list --jql "project = CLIENTS AND sprint in openSprints() AND status = 'In Progress'"
```

---

## Advanced Usage

### Custom Output Formats

```bash
# Plain text (for scripting)
jira issue list --plain

# JSON (for parsing)
jira issue list --json

# Table (default, human-readable)
jira issue list
```

### Filtering and Sorting

```bash
# Filter by type
jira issue list -tBug

# Filter by priority
jira issue list --priority High

# Sort by updated date
jira issue list --order-by updated

# Limit results
jira issue list --limit 10
```

### Bulk Operations

```bash
# Move multiple issues
for issue in CLIENTS-520 CLIENTS-521 CLIENTS-522; do
  jira issue move $issue "In Progress"
done

# Add multiple issues to sprint
jira sprint add <sprint-id> CLIENTS-520 CLIENTS-521 CLIENTS-522
```

---

## Security Notes

### API Token Management

**DO:**
- ✅ Generate API token at https://id.atlassian.com/manage-profile/security/api-tokens
- ✅ Store in `~/.config/.jira/.config.yml` (protected by file permissions)
- ✅ Rotate tokens periodically
- ✅ Revoke tokens when no longer needed

**DON'T:**
- ❌ Share API tokens
- ❌ Commit API tokens to git
- ❌ Use password authentication (deprecated)

### File Permissions

```bash
# Ensure config file is protected
chmod 600 ~/.config/.jira/.config.yml
```

---

## Resources

- **GitHub**: https://github.com/ankitpokhrel/jira-cli
- **Documentation**: https://github.com/ankitpokhrel/jira-cli/wiki
- **Jira API**: https://developer.atlassian.com/cloud/jira/platform/rest/v3/intro/

---

## Getting Help

```bash
# General help
jira --help

# Command-specific help
jira issue --help
jira issue create --help

# View man pages
jira man
```

---

## Summary

**Key Commands:**
- `jira issue list` - List issues
- `jira issue view <key>` - View issue details
- `jira issue create` - Create new issue
- `jira issue move <key> <status>` - Update status
- `jira open <key>` - Open in browser

**Key Workflows:**
- Daily standup: `jira issue list -a$(jira me)`
- Start work: `jira issue move <key> "In Progress"`
- Complete work: `jira issue move <key> "Done"`

**Remember:** CLI is faster and more reliable than web UI or MCP for Jira access.
