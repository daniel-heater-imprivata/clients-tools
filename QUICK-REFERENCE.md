# Quick Reference

## For Team Members

### First Time Setup
```bash
# Install agent-os
curl -sSL https://raw.githubusercontent.com/buildermethods/agent-os/main/scripts/base-install.sh | bash

# Clone profiles
cd ~/agent-os/profiles
git clone git@github.com:daniel-heater-imprivata/agent-os-profiles.git
```

### Use in Project
```bash
cd /path/to/your/project
~/agent-os/scripts/project-install.sh --profile agent-os-profiles/pas-clients
```

### Update Standards
```bash
# Pull latest
cd ~/agent-os/profiles/agent-os-profiles
git pull

# Re-compile in project
cd /path/to/your/project
~/agent-os/scripts/project-update.sh
```

## For Maintainers

### Update Standards
```bash
cd /Users/dheater/src/agent-os-profiles
# Edit files in pas-clients/standards/
vim CHANGELOG.md
git add .
git commit -m "Update: description"
git push
```

### Add New Profile
```bash
cd /Users/dheater/src/agent-os-profiles
mkdir -p new-profile/standards/{backend,global}
# Create profile-config.yml and standards
git add new-profile
git commit -m "Add new-profile"
git push
```

## Standards Locations

- **C++17**: `pas-clients/standards/backend/cpp-guidelines.md`
- **Zig 0.15.1**: `pas-clients/standards/backend/zig-guidelines.md`
- **Just**: `pas-clients/standards/global/just-patterns.md`

## Common Commands

```bash
# View profile structure
tree ~/agent-os/profiles/agent-os-profiles/pas-clients

# Check what's installed in project
ls agent-os/standards/backend/

# Verify standards are current
cd ~/agent-os/profiles/agent-os-profiles && git status

# See what changed
cd ~/agent-os/profiles/agent-os-profiles && git log --oneline
```

## Troubleshooting

**Profile not found?**
→ Use full path: `--profile agent-os-profiles/pas-clients`

**Standards not updating?**
→ Run `git pull` in profile, then `project-update.sh` in project

**Permission denied?**
→ Set up SSH key for GitHub
