# Clients Team Tools

Standards, product context, scripts, and AI instructions for the PAS Clients team.

---

## Convention: Sibling Directory Structure

**Always clone `clients-tools` as a sibling to your project repos:**

### In Viewyard Viewsets

```bash
viewyard view create CLIENTS-XXX
# Select repos: clients-tools, librssconnect, universal-connection-manager

# Result:
~/src/viewyard-viewsets/CLIENTS-520-websocket/
├── clients-tools/          ← Always include this
├── librssconnect/
└── universal-connection-manager/
```

### Standalone Work

```bash
mkdir ~/src/clients-work
cd ~/src/clients-work
git clone git@github.com:daniel-heater-imprivata/clients-tools.git
git clone git@github.com:imprivata-pas/librssconnect.git
git clone git@github.com:imprivata-pas/universal-connection-manager.git

# Result:
~/src/clients-work/
├── clients-tools/          ← Clone here first
├── librssconnect/
└── universal-connection-manager/
```

### Ad-Hoc Directories

```bash
mkdir ~/src/feature-xyz
cd ~/src/feature-xyz
git clone git@github.com:daniel-heater-imprivata/clients-tools.git
git clone git@github.com:imprivata-pas/librssconnect.git

# Result:
~/src/feature-xyz/
├── clients-tools/          ← Clone here first
└── librssconnect/
```

---

## How It Works

### Each Project References clients-tools

Each project repository has an `AGENTS.md` file that references `../clients-tools/` using relative paths:

```markdown
# librssconnect - AI Agent Instructions

## Team Context

**See [../clients-tools/AGENTS.md](../clients-tools/AGENTS.md) for:**
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
- **[logging-guidelines.md](standards/global/logging-guidelines.md)** - Logging best practices
- **[comments-guidelines.md](standards/global/comments-guidelines.md)** - Comments best practices


---

## Scripts

The [scripts/](scripts/) directory contains retained scripts for common tasks:

- **check-cpp20.sh** - Verify no C++20 features are used (we require C++17)
- **find-todos.sh** - Find all TODO/FIXME/HACK comments across repos

See [scripts/README.md](scripts/README.md) for:
- Full list of available scripts
- Output format convention (JSON + exit codes)
- Execution policy
- How to write new scripts

### Usage

```bash
# In viewyard viewset
cd ~/src/viewyard-viewsets/CLIENTS-520/
./clients-tools/scripts/check-cpp20.sh

# Standalone
cd ~/src/clients-work/
./clients-tools/scripts/check-cpp20.sh
```

### Ephemeral Scripts

AI can generate **ephemeral scripts** on-demand for one-time tasks. These are:
- Created in `/tmp/`
- Executed once
- Discarded after use
- Not stored in this repository

**Retained scripts** (in `scripts/`) are for tasks useful enough to keep and share.

