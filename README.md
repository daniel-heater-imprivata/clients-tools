# Clients Team Documentation

Standards, product context, and AI instructions for the PAS Clients team.

---

## Convention: Sibling Directory Structure

**Always clone `clients-docs` as a sibling to your project repos:**

### In Viewyard Viewsets

```bash
viewyard view create CLIENTS-XXX
# Select repos: clients-docs, librssconnect, universal-connection-manager

# Result:
~/src/viewyard-viewsets/CLIENTS-520-websocket/
├── clients-docs/          ← Always include this
├── librssconnect/
└── universal-connection-manager/
```

### Standalone Work

```bash
mkdir ~/src/clients-work
cd ~/src/clients-work
git clone git@github.com:daniel-heater-imprivata/clients-docs.git
git clone git@github.com:imprivata-pas/librssconnect.git
git clone git@github.com:imprivata-pas/universal-connection-manager.git

# Result:
~/src/clients-work/
├── clients-docs/          ← Clone here first
├── librssconnect/
└── universal-connection-manager/
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

---

## What's in This Repo

### Product Context

- **[mission.md](product/mission.md)** - What we're building and why
- **[roadmap.md](product/roadmap.md)** - Feature priorities and timeline
- **[tech-stack.md](product/tech-stack.md)** - Technology choices and rationale
- **[architecture.md](product/architecture.md)** - How the pieces fit together

### Coding Standards

- **[cpp-guidelines.md](standards/cpp-guidelines.md)**
- **[zig-guidelines.md](standards/zig-guidelines.md)**
- **[just-patterns.md](standards/just-patterns.md)**

