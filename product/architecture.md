# Clients Team Architecture

## Overview

The Clients team builds the connectivity layer for PAS (Privileged Access Security) - enabling secure, auditable remote access without VPN. Our components implement a **two-plane architecture** that works across multiple deployment scenarios.

For comprehensive PAS system documentation, see: `~/src/plumbing/dh-background-docs/docs/`

---

## Core Architecture: Two-Plane Design

### Control Plane (RSS Protocol)
- **Purpose**: Command and coordination with PAS server
- **Protocol**: Custom RSS protocol over HTTPS
- **Responsibilities**:
  - Server authentication and connection establishment
  - Receiving LAUNCH commands and other server directives
  - Status reporting and health monitoring
  - Dynamic port allocation coordination

### Data Plane (SSH Port Forwards)
- **Purpose**: Bidirectional data relay between applications and services
- **Transport**: SSH tunnels with libssh2
- **Responsibilities**:
  - Creating and managing SSH port forwards (Local and Remote)
  - Relaying application data transparently
  - Handling connection lifecycle and cleanup
  - Supporting protocol-specific callbacks (FTP, HTTP, etc.)

---

## Network Topology

```
[User/Client] ←→ [Jumpbox/PAM] ←→ [Gatekeeper] ←→ [Internal Services]
   (anywhere)        (DMZ)         (inside FW)      (corporate net)
```

### Components We Build

**1. User-Facing Applications (RDP, SSH, FTP clients)**
- Integrates librssconnect (static linking)
- Handles user interface and application-specific logic
- Data plane entry point

**2. librssconnect (C++ Library)**
- Implements both control and data planes
- Provides C API for FFI compatibility
- Core connectivity engine

**3. Gatekeeper (Data Plane Exit Point)**
- Currently Java (migrating to C++/Zig)
- Sits inside corporate firewall
- Handles dozens to ~100 concurrent connections
- Data plane exit point back to native protocols

**4. Audit (MiTM Session Recording)**
- Sits in DMZ on PAM server
- Real-time protocol manipulation
- Session recording for compliance
- Handles 1000-2000 concurrent connections

---

## Data Flow Example: RDP Session

1. **User Action**: User selects RDP service via PAS web UI
2. **Control Plane**: PAS server sends LAUNCH command to client
3. **Client Launch**: Client application launches RDP client with librssconnect
4. **Data Plane Setup**: librssconnect establishes SSH tunnel to jumpbox
5. **Connection**: RDP client connects through tunnel
6. **Audit**: Jumpbox audit component records session
7. **Forward**: Jumpbox forwards to gatekeeper via SSH
8. **Exit**: Gatekeeper connects to internal RDP server
9. **Data Flow**: Bidirectional RDP traffic flows through tunnel chain

---

## Component Relationships

### librssconnect (Core Library)
- **Used by**: All client applications, future Gatekeeper
- **Provides**: Control plane + data plane implementation
- **API**: C API (public), C++ API (internal)
- **Scale**: 1-few connections (clients), dozens-100 (gatekeeper)

### Client Applications
- **Depends on**: librssconnect
- **Provides**: User interface, protocol-specific logic
- **Examples**: RDP client, SSH client, FTP client
- **Scale**: 1-few connections per instance

### Gatekeeper
- **Current**: Java Connect (production)
- **Future**: librssconnect (C++/Zig)
- **Role**: Data plane exit point
- **Scale**: Dozens to ~100 concurrent connections

### Audit
- **Current**: Java (stable, no migration planned)
- **Role**: MiTM session recording
- **Scale**: 1000-2000 concurrent connections
- **Note**: Not part of clients team scope (server team)

---

## Deployment Scenarios

### Client Applications (Current)
- **Scale**: 1-few connections per instance
- **Role**: Data plane entry point
- **Flow**: Local App → librssconnect → SSH tunnel → Server
- **Distribution**: Static linking, Conan packages

### Gatekeeper (Q1 2026 Migration)
- **Scale**: Dozens to ~100 connections per instance
- **Role**: Data plane exit point
- **Flow**: SSH tunnel → librssconnect → Internal Service
- **Migration**: Java Connect → C++/Zig librssconnect

---

## Key Design Principles

### Separation of Concerns
- **Control plane** handles commands and coordination
- **Data plane** handles data relay
- Clean separation allows independent scaling and optimization

### Protocol Agnostic
- Data plane is protocol-agnostic (just bytes)
- Protocol-specific logic in client applications
- Allows supporting any TCP-based protocol

### Async I/O
- Boost.Asio for high-performance async I/O
- Non-blocking operations
- Scales to hundreds of concurrent connections

### Security First
- Certificate-based authentication
- TLS/SSL for control plane
- SSH for data plane
- Zero-trust architecture

---

## Authentication Flow

1. **Client Start**: Client application starts with credentials from properties/magnet link
2. **Control Plane Auth**: librssconnect authenticates to PAS server via HTTPS + certificates
3. **Data Plane Auth**: librssconnect establishes SSH tunnel using provided credentials
4. **Session**: Authenticated session maintained for duration of connection

---

## For More Details

**Comprehensive documentation:**
- System Overview: `~/src/plumbing/dh-background-docs/docs/architecture/system-overview.md`
- Component Model: `~/src/plumbing/dh-background-docs/docs/architecture/component-model.md`
- Data Flow: `~/src/plumbing/dh-background-docs/docs/architecture/data-flow.md`

**Component-specific:**
- librssconnect: `~/src/plumbing/dh-background-docs/docs/architecture/librssconnect.md`
- Gatekeeper: `~/src/plumbing/dh-background-docs/docs/architecture/gatekeeper.md`
- Audit: `~/src/plumbing/dh-background-docs/docs/architecture/audit-system.md`

**Specifications:**
- RSS Protocol: `~/src/plumbing/dh-background-docs/docs/specifications/rss-protocol.md`
- Security Model: `~/src/plumbing/dh-background-docs/docs/specifications/security-model.md`
- Deployment Model: `~/src/plumbing/dh-background-docs/docs/specifications/deployment-model.md`
