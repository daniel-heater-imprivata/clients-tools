# Clients Team Documentation

Standards, product context, and AI instructions for the PAS Clients team.

## What's Here

- **[AGENTS.md](AGENTS.md)** - AI agent instructions (Critical Carl persona)
- **[product/](product/)** - Product mission, roadmap, tech stack, architecture
- **[standards/](standards/)** - Coding standards (C++, Zig, Just)
- **[CONTRIBUTING.md](CONTRIBUTING.md)** - How to propose changes
- **[CHANGELOG.md](CHANGELOG.md)** - Track changes to standards and product docs

---

## Convention: Sibling Directory Structure

**Always clone `clients-docs` as a sibling to your project repos:**

### In Viewyard Viewsets

```bash
viewyard view create CLIENTS-520-websocket
# Select repos: clients-docs, librssconnect, gatekeeper

# Result:
~/src/viewyard-viewsets/CLIENTS-520-websocket/
├── clients-docs/          ← Always include this
├── librssconnect/
├── gatekeeper/
└── audit/
```

### Standalone Work

```bash
mkdir ~/src/clients-work
cd ~/src/clients-work
git clone git@github.com:daniel-heater-imprivata/clients-docs.git
git clone git@github.com:imprivata-pas/librssconnect.git
git clone git@github.com:imprivata-pas/gatekeeper.git

# Result:
~/src/clients-work/
├── clients-docs/          ← Clone here first
├── librssconnect/
└── gatekeeper/
```

### Ad-Hoc Directories

```bash
mkdir ~/src/feature-xyz
cd ~/src/feature-xyz
git clone git@github.com:daniel-heater-imprivata/clients-docs.git
git clone git@github.com:imprivata-pas/librssconnect.git

# Result:
~/src/feature-xyz/
├── clients-docs/          ← Clone here first
└── librssconnect/
```

---

## How It Works

### Each Project References clients-docs

Each project repository has an `AGENTS.md` file that references `../clients-docs/` using relative paths:

```markdown
# librssconnect - AI Agent Instructions

## Team Context

**See [../clients-docs/AGENTS.md](../clients-docs/AGENTS.md) for:**
- Team standards (C++, Zig, Just)
- Product mission and roadmap
- Architecture overview
- Critical Carl persona

## Project-Specific Context
...
```

### AI Tools Read Both

When you open Augment Code (or any AI tool) in a project:

1. AI reads `librssconnect/AGENTS.md`
2. Follows reference to `../clients-docs/AGENTS.md`
3. Reads all standards and product docs
4. Has full context for coding

**No setup commands. No symlinks. Just convention.**

---

## Usage

### Working in Viewyard Viewsets

```bash
# Create viewset
viewyard view create CLIENTS-520-websocket
# Select: clients-docs, librssconnect, gatekeeper

# Work in any project
cd CLIENTS-520-websocket/librssconnect
# Open Augment Code - it reads AGENTS.md → ../clients-docs/

# Make changes, commit, push
git add .
git commit -m "Implement WebSocket support"
git push
```

### Working Standalone

```bash
# Setup once
mkdir ~/src/clients-work
cd ~/src/clients-work
git clone git@github.com:daniel-heater-imprivata/clients-docs.git
git clone git@github.com:imprivata-pas/librssconnect.git

# Work
cd librssconnect
# Open Augment Code - it reads AGENTS.md → ../clients-docs/
```

### Updating Standards

```bash
# Make changes
cd ~/src/clients-docs
vim standards/cpp-guidelines.md
vim CHANGELOG.md

# Commit and push
git add .
git commit -m "Update C++ guidelines: Add WebSocket patterns"
git push

# Team members pull updates
cd ~/src/clients-docs  # or viewset/clients-docs
git pull
# Updated standards immediately available to all projects
```

---

## What's in This Repo

### Product Context

- **[mission.md](product/mission.md)** - What we're building and why
- **[roadmap.md](product/roadmap.md)** - Feature priorities and timeline
- **[tech-stack.md](product/tech-stack.md)** - Technology choices and rationale
- **[architecture.md](product/architecture.md)** - How the pieces fit together

### Coding Standards

- **[cpp-guidelines.md](standards/cpp-guidelines.md)** - C++17 coding standards
- **[zig-guidelines.md](standards/zig-guidelines.md)** - Zig 0.15.1 coding standards
- **[just-patterns.md](standards/just-patterns.md)** - Task automation best practices

### Governance

- **[CONTRIBUTING.md](CONTRIBUTING.md)** - How to propose changes
- **[CHANGELOG.md](CHANGELOG.md)** - Track changes
- **[.github/CODEOWNERS](.github/CODEOWNERS)** - Auto-assign reviewers
- **[.github/pull_request_template.md](.github/pull_request_template.md)** - PR template

---

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for:
- How to propose changes to standards
- PR review process
- Writing good standards
- Deprecation process

---

## Philosophy

### Subtract First

Always ask "what can we remove?" before adding.

### Critical Carl

Be direct and honest. Challenge complexity, advocate simplicity.

### One Mission

**Secure, auditable remote access without VPN.**

Every line of code should serve this mission.

---

## Questions?

- Check existing issues for similar discussions
- Ask in team chat
- Open an issue for discussion before major changes
- Tag relevant code owners

---

## Projects Using This

- **librssconnect** - C++ connectivity library
- **gatekeeper** - Data plane exit point
- **audit** - MiTM session recording
- **RDP/SSH/FTP clients** - User-facing applications

All clients team projects reference this repository for standards and product context.
