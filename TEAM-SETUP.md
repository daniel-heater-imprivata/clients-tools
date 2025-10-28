# Team Setup Guide

Quick setup instructions for team members to start using shared agent-os profiles.

## Prerequisites

- Git installed
- GitHub access to `daniel-heater-imprivata/agent-os-profiles`
- SSH key configured for GitHub

## One-Time Setup

### Step 1: Install Agent-OS

```bash
curl -sSL https://raw.githubusercontent.com/buildermethods/agent-os/main/scripts/base-install.sh | bash
```

This installs agent-os to `~/agent-os/`.

### Step 2: Clone Shared Profiles

```bash
cd ~/agent-os/profiles
git clone git@github.com:daniel-heater-imprivata/agent-os-profiles.git
```

Verify installation:
```bash
ls ~/agent-os/profiles/agent-os-profiles/pas-clients/standards/
# Should show: backend/ global/
```

## Using in Projects

### New Project Setup

```bash
cd /path/to/your/project
~/agent-os/scripts/project-install.sh --profile agent-os-profiles/pas-clients
```

This creates:
- `agent-os/` directory with compiled standards
- `.augment/` directory with custom slash commands (if using auggie)

### Verify Installation

```bash
ls agent-os/standards/backend/
# Should show: cpp-guidelines.md zig-guidelines.md (and others)

ls agent-os/standards/global/
# Should show: just-patterns.md (and others)
```

## Daily Workflow

### Getting Latest Standards

Periodically update your local copy of the profiles:

```bash
cd ~/agent-os/profiles/agent-os-profiles
git pull
```

Then update each project:

```bash
cd /path/to/your/project
~/agent-os/scripts/project-update.sh
```

### Using Standards

#### With Augment Code (auggie)

If you're using auggie CLI:

```bash
cd /path/to/your/project
auggie
> /implement-tasks "Add feature X"
> /review-cpp "src/myfile.cpp"
```

See `.augment/QUICK-START.md` in your project for all available commands.

#### With Other AI Tools

Reference standards directly:
```
"Implement the Session class following @agent-os/standards/backend/cpp-guidelines.md"
"Add a justfile recipe following @agent-os/standards/global/just-patterns.md"
```

## Multiple Projects

You can use the same profile across all your projects:

```bash
# Project 1
cd ~/src/librssconnect
~/agent-os/scripts/project-install.sh --profile agent-os-profiles/pas-clients

# Project 2
cd ~/src/kazui
~/agent-os/scripts/project-install.sh --profile agent-os-profiles/pas-clients

# Project 3
cd ~/src/other-project
~/agent-os/scripts/project-install.sh --profile agent-os-profiles/pas-clients
```

Each project gets its own `agent-os/` directory with the standards, but they all reference the same source profile.

## Troubleshooting

### "Profile not found" error

**Problem:**
```
Error: Profile 'pas-clients' not found
```

**Solution:** Use the full path:
```bash
~/agent-os/scripts/project-install.sh --profile agent-os-profiles/pas-clients
```

### Standards not updating

**Problem:** Changes to profile don't appear in project

**Solution:**
```bash
# 1. Update profile
cd ~/agent-os/profiles/agent-os-profiles
git pull

# 2. Re-compile in project
cd /path/to/your/project
~/agent-os/scripts/project-update.sh
```

### Permission denied when cloning

**Problem:**
```
Permission denied (publickey)
```

**Solution:** Set up your SSH key for GitHub:
```bash
# Generate SSH key if you don't have one
ssh-keygen -t ed25519 -C "your.email@example.com"

# Add to ssh-agent
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_ed25519

# Copy public key and add to GitHub
cat ~/.ssh/id_ed25519.pub
# Go to GitHub Settings > SSH Keys > New SSH Key
```

## Contributing Standards Updates

If you want to propose changes to the standards:

1. **Create a branch:**
   ```bash
   cd ~/agent-os/profiles/agent-os-profiles
   git checkout -b update-cpp-guidelines
   ```

2. **Make your changes:**
   ```bash
   # Edit files in pas-clients/standards/
   vim pas-clients/standards/backend/cpp-guidelines.md
   ```

3. **Update changelog:**
   ```bash
   vim CHANGELOG.md
   # Add entry under [Unreleased]
   ```

4. **Commit and push:**
   ```bash
   git add .
   git commit -m "Update C++ guidelines: Add guidance on X"
   git push origin update-cpp-guidelines
   ```

5. **Create pull request on GitHub**

6. **Get team review and merge**

## Questions?

- Check the main [README.md](README.md)
- Review the standards files in `pas-clients/standards/`
- Ask in team chat
- Open an issue in the repository
