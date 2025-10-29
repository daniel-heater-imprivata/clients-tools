# Clients Team Mission

## Pitch

The PAS Clients team delivers **secure, auditable remote access without VPN** for highly regulated industries. We build the connectivity layer and user-facing applications that enable enterprises to provide controlled access to critical systems while maintaining comprehensive audit trails and regulatory compliance.

## What We Build

### User-Facing Applications
- **RDP Client** - Remote desktop access
- **SSH Client** - Secure shell access
- **FTP Client** - File transfer access
- **Other Protocol Clients** - VNC, Telnet, HTTP/HTTPS

### Plumbing (Infrastructure Libraries)
- **librssconnect** - C++ connectivity library implementing RSS protocol
- **Gatekeeper** - Data plane exit point (migrating Java → C++/Zig)
- **Audit** - MiTM session recording and protocol manipulation

## The Problem

Enterprises in highly regulated industries (healthcare, financial services, law enforcement, gaming, government) need to:
- Provide remote access to critical systems
- Maintain comprehensive audit trails for compliance
- Operate in on-premises/private cloud environments
- Support multiple protocols (RDP, SSH, FTP, VNC, etc.)
- Ensure zero-trust security architecture

**Traditional VPNs don't solve this** - they lack:
- Protocol-level auditing
- Session recording
- Credential injection
- Fine-grained access control

## Our Solution

**Two-plane architecture:**
- **Control Plane (RSS Protocol)** - Command and coordination with server
- **Data Plane (SSH Tunnels)** - Bidirectional data relay between applications and services

**Key capabilities:**
- Secure remote access without VPN
- Complete session recording and audit trails
- Protocol-specific manipulation (credential injection, etc.)
- Multi-protocol support
- Zero-trust architecture

## Users

### Primary Users (Internal)
- **Clients Team Developers** - Building and maintaining client applications and plumbing
- **QA Engineers** - Testing across multiple protocols and scenarios
- **DevOps** - Packaging and deployment

### Secondary Users (External)
- **End Users** - IT administrators, vendors, contractors accessing remote systems
- **Enterprise Developers** - Integrating PAS connectivity into custom applications
- **SDK Consumers** - Using C++/Java/Python SDKs

## Success Metrics

### Technical
- **Connection Reliability**: >99.9% successful connections
- **Performance**: Sub-second connection establishment
- **Protocol Support**: RDP, SSH, FTP, VNC, Telnet, HTTP/HTTPS
- **Audit Coverage**: 100% of sessions recorded

### Quality
- **Test Coverage**: >80% line coverage
- **Sanitizer Clean**: ASAN, TSAN, LSAN all passing
- **Zero Critical Bugs**: In production

### Adoption
- **Client Applications**: All migrated to librssconnect (Q4 2025)
- **Gatekeeper Migration**: Java → C++/Zig complete (Q1 2026)
- **SDK Adoption**: 3+ customer integrations (2026)

## Regulatory Compliance

Our solutions support:
- **Healthcare**: HIPAA (US), GDPR (EU), NHS standards (UK)
- **Financial**: PCI DSS, SOX, Basel III, MiFID II
- **Law Enforcement**: CJIS, various national security standards
- **Gaming**: State gaming commission regulations
- **Data Protection**: No PII/PHI in system logs, comprehensive audit trails

## Differentiators

### Production-Proven
Years of production experience with RSS protocol. We know the edge cases, failure modes, and performance characteristics.

### Modern C++/Zig
- C++17 with RAII, smart pointers, const correctness
- Zig 0.15.1 for cross-compilation and memory safety
- Moving away from Java for better performance and maintainability

### Cross-Platform
- Linux (primary)
- macOS (development)
- Windows (client applications)

### Developer-Friendly
- Comprehensive documentation
- Example applications
- CMake/Conan integration
- Just for task automation
