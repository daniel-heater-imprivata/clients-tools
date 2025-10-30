# Logging Guidelines

## Philosophy: Help, Don't Just Report

**Inspired by Elm and Rust:** When something goes wrong, **help the user** fix it.

### ❌ DON'T: Just report the error
```cpp
RSS_LOG_ERROR("Invalid configuration");
RSS_LOG_ERROR("Connection failed");
RSS_LOG_ERROR("Authentication error");
```

### ✅ DO: Help the user understand and fix it
```cpp
RSS_LOG_ERROR("Invalid configuration: 'server_url' is required. "
              "Add 'server_url=https://example.com' to config.ini");

RSS_LOG_ERROR("Connection failed to {}:{} - "
              "Check that the server is running and firewall allows port {}",
              host, port, port);

RSS_LOG_ERROR("Authentication failed: Invalid certificate. "
              "Expected certificate at ~/.rss/client.crt - "
              "Run 'rss-setup --generate-cert' to create one");
```

**Key elements of helpful messages:**
1. **What went wrong** - Clear description
2. **Why it matters** - Context
3. **How to fix it** - Actionable next steps
4. **Alternatives** - "Did you mean X?"

---

## Log Levels

Use appropriate levels to control verbosity and avoid overwhelming users.

### ERROR - Something Failed
**When:** Operation failed, user action required
**Audience:** End users, operators
**Examples:**
- Connection failed
- Authentication failed
- Configuration invalid
- File not found

```cpp
RSS_LOG_ERROR("Failed to connect to server at {}: {} - "
              "Verify server is running with 'systemctl status rss-server'",
              server_url, error_message);
```

### WARNING - Something Unexpected
**When:** Operation succeeded but something is wrong
**Audience:** End users, operators
**Examples:**
- Using deprecated feature
- Performance degradation
- Unusual but valid input
- Fallback behavior triggered

```cpp
RSS_LOG_WARNING("Using deprecated config option 'old_setting' - "
                "Please update to 'new_setting' in next release. "
                "See migration guide: https://docs.example.com/migrate");
```

### INFO - Important Events
**When:** Significant state changes, milestones
**Audience:** Operators, support engineers
**Examples:**
- Service started/stopped
- Connection established/closed
- Configuration loaded
- Major operation completed

```cpp
RSS_LOG_INFO("Connected to server {} (version {}) - Session ID: {}",
             server_url, server_version, session_id);
```

### DEBUG - Detailed Diagnostics
**When:** Troubleshooting, development
**Audience:** Developers, support engineers
**Examples:**
- Function entry/exit
- Variable values
- Decision points
- Internal state changes

```cpp
RSS_LOG_DEBUG("Processing LAUNCH command: service={}, port={}, protocol={}",
              service_name, port, protocol);
```

### TRACE - Very Detailed Diagnostics
**When:** Deep troubleshooting, performance analysis
**Audience:** Developers only
**Examples:**
- Loop iterations
- Byte-level data
- Every function call
- Performance measurements

```cpp
RSS_LOG_TRACE("Received {} bytes from socket: [{}]",
              bytes_received, hex_dump(buffer, bytes_received));
```

---

## Performance Considerations

**Logging has cost.** Be aware of performance impacts.

### ❌ DON'T: Log in hot paths without guards
```cpp
// This evaluates format string and arguments EVERY iteration
for (const auto& item : large_collection) {
    RSS_LOG_DEBUG("Processing item: {}", item.to_string());  // SLOW\!
}
```

### ✅ DO: Use level checks for expensive operations
```cpp
// Only evaluate if DEBUG is enabled
if (RSS_LOG_LEVEL_DEBUG) {
    for (const auto& item : large_collection) {
        RSS_LOG_DEBUG("Processing item: {}", item.to_string());
    }
}

// Or log summary instead
RSS_LOG_DEBUG("Processing {} items", large_collection.size());
```

### ❌ DON'T: Log every byte in production
```cpp
// This will kill performance
for (size_t i = 0; i < buffer_size; ++i) {
    RSS_LOG_TRACE("Byte {}: 0x{:02x}", i, buffer[i]);
}
```

### ✅ DO: Log summaries or use TRACE level
```cpp
// Summary for INFO/DEBUG
RSS_LOG_DEBUG("Sent {} bytes to {}", buffer_size, destination);

// Detailed dump only for TRACE (disabled in production)
if (RSS_LOG_LEVEL_TRACE) {
    RSS_LOG_TRACE("Data sent: {}", hex_dump(buffer, buffer_size));
}
```

### Performance Guidelines

1. **Avoid string construction in hot paths**
   - Use level checks before expensive operations
   - Defer string formatting until needed

2. **Batch log messages**
   - Log summaries instead of individual items
   - Use counters and periodic reporting

3. **Use appropriate levels**
   - TRACE for very detailed diagnostics (disabled in production)
   - DEBUG for development diagnostics (disabled in production)
   - INFO/WARNING/ERROR for production

4. **Measure impact**
   - Profile with logging enabled/disabled
   - Ensure logging doesn't dominate CPU time

---

## Structured Logging

Use structured formats that make logs easier to parse automatically.

### ✅ DO: Use consistent key-value format
```cpp
RSS_LOG_INFO("event=connection_established server={} port={} session_id={} "
             "protocol_version={} latency_ms={}",
             server_url, port, session_id, protocol_version, latency_ms);
```

**Benefits:**
- Easy to parse with tools (grep, awk, log aggregators)
- Consistent format across codebase
- Machine-readable for monitoring/alerting

### ✅ DO: Include context in structured format
```cpp
RSS_LOG_ERROR("event=authentication_failed reason='invalid_certificate' "
              "cert_path={} expected_issuer='{}' actual_issuer='{}' "
              "help='Run rss-setup --generate-cert to create valid certificate'",
              cert_path, expected_issuer, actual_issuer);
```

### ✅ DO: Use consistent field names
```
event=          # What happened
reason=         # Why it happened
component=      # Which component
session_id=     # Session identifier
user=           # User identifier
duration_ms=    # How long it took
error_code=     # Error code
help=           # How to fix it
```

---

## Context and Correlation

Include enough context to understand what happened.

### ✅ DO: Include identifiers for correlation
```cpp
RSS_LOG_INFO("event=tunnel_created session_id={} tunnel_id={} "
             "local_port={} remote_host={} remote_port={}",
             session_id, tunnel_id, local_port, remote_host, remote_port);

RSS_LOG_DEBUG("event=data_forwarded session_id={} tunnel_id={} "
              "bytes={} direction={}",
              session_id, tunnel_id, bytes_forwarded, direction);

RSS_LOG_INFO("event=tunnel_closed session_id={} tunnel_id={} "
             "duration_ms={} bytes_sent={} bytes_received={}",
             session_id, tunnel_id, duration_ms, bytes_sent, bytes_received);
```

**Benefits:**
- Can trace entire session lifecycle
- Can correlate events across components
- Can aggregate metrics per session/tunnel

---

## Error Messages: Help the User

### Pattern: What + Why + How

**What went wrong:**
```cpp
"Failed to load configuration file"
```

**Why it matters:**
```cpp
"Failed to load configuration file: File not found"
```

**How to fix it:**
```cpp
"Failed to load configuration file '{}': File not found - "
"Create config file with 'rss-setup --init' or specify path with --config"
```

### Pattern: Did You Mean?

```cpp
RSS_LOG_ERROR("Unknown config option 'server_addr' - "
              "Did you mean 'server_url'? "
              "See config.ini.example for valid options");

RSS_LOG_ERROR("Service 'rdp-server' not found - "
              "Available services: {} - "
              "Add service with 'rss-admin add-service rdp-server'",
              available_services);
```

### Pattern: Check Prerequisites

```cpp
RSS_LOG_ERROR("Failed to bind to port {}: Permission denied - "
              "Ports below 1024 require root privileges. "
              "Either run as root or use port >= 1024",
              port);

RSS_LOG_ERROR("SSH tunnel creation failed: ssh-keygen not found - "
              "Install OpenSSH client: 'apt install openssh-client'");
```

---

## Examples by Scenario

### Startup/Initialization

```cpp
RSS_LOG_INFO("event=service_starting version={} config={} pid={}",
             VERSION, config_path, getpid());

RSS_LOG_INFO("event=config_loaded server={} port={} log_level={}",
             config.server_url, config.port, config.log_level);

RSS_LOG_INFO("event=service_started listen_port={} worker_threads={}",
             listen_port, worker_threads);
```

### Connection Lifecycle

```cpp
RSS_LOG_INFO("event=connection_attempt server={} port={}",
             server_url, port);

RSS_LOG_DEBUG("event=tls_handshake_start server={} cipher_suite={}",
              server_url, cipher_suite);

RSS_LOG_INFO("event=connection_established session_id={} server={} "
             "latency_ms={}",
             session_id, server_url, latency_ms);

RSS_LOG_DEBUG("event=command_received session_id={} command={} params={}",
              session_id, command_type, params);

RSS_LOG_INFO("event=connection_closed session_id={} duration_ms={} "
             "bytes_sent={} bytes_received={} reason={}",
             session_id, duration_ms, bytes_sent, bytes_received, reason);
```

### Error Handling

```cpp
RSS_LOG_ERROR("event=connection_failed server={} port={} error='{}' - "
              "Check that server is running: 'systemctl status rss-server' - "
              "Check firewall allows port {}: 'sudo ufw status'",
              server_url, port, error_message, port);

RSS_LOG_ERROR("event=authentication_failed session_id={} reason='{}' - "
              "Verify certificate is valid: 'openssl x509 -in {} -noout -text' - "
              "Regenerate if needed: 'rss-setup --generate-cert'",
              session_id, reason, cert_path);

RSS_LOG_ERROR("event=tunnel_creation_failed session_id={} error='{}' - "
              "Check SSH service is running: 'systemctl status ssh' - "
              "Verify SSH key is configured: 'ssh-add -l'",
              session_id, error_message);
```

---

## Anti-Patterns

### ❌ DON'T: Log sensitive data
```cpp
// NEVER log passwords, keys, tokens
RSS_LOG_DEBUG("Password: {}", password);  // NO\!
RSS_LOG_DEBUG("API key: {}", api_key);    // NO\!
RSS_LOG_DEBUG("Session token: {}", token); // NO\!
```

### ✅ DO: Redact or hash sensitive data
```cpp
RSS_LOG_DEBUG("event=authentication_attempt user={} password_hash={}",
              username, hash(password));

RSS_LOG_DEBUG("event=api_call endpoint={} token_prefix={}...",
              endpoint, api_key.substr(0, 8));
```

### ❌ DON'T: Log without context
```cpp
RSS_LOG_ERROR("Connection failed");  // Which connection? Why?
RSS_LOG_ERROR("Invalid input");      // What input? What's invalid?
```

### ✅ DO: Provide context
```cpp
RSS_LOG_ERROR("event=connection_failed server={} port={} error='{}'",
              server_url, port, error_message);

RSS_LOG_ERROR("event=validation_failed field='server_url' value='{}' "
              "reason='Invalid URL format' expected='https://host:port'",
              invalid_url);
```

### ❌ DON'T: Use printf-style format strings
```cpp
RSS_LOG_INFO("Connected to %s:%d", host, port);  // Old style
```

### ✅ DO: Use modern format strings (spdlog, fmt)
```cpp
RSS_LOG_INFO("event=connection_established server={}:{}", host, port);
```

---

## Testing Logging

### Verify Log Messages Are Helpful

```cpp
// Test that error messages include help
TEST_CASE("Connection failure includes helpful message") {
    auto log_output = capture_logs([&]() {
        connect_to_server("invalid-host", 9999);
    });
    
    REQUIRE(log_output.contains("Check that server is running"));
    REQUIRE(log_output.contains("systemctl status"));
}
```

### Verify Performance Impact

```cpp
// Test that logging doesn't dominate performance
TEST_CASE("Logging overhead is acceptable") {
    auto start = std::chrono::steady_clock::now();
    
    for (int i = 0; i < 10000; ++i) {
        RSS_LOG_DEBUG("Processing item {}", i);
    }
    
    auto duration = std::chrono::steady_clock::now() - start;
    REQUIRE(duration < std::chrono::milliseconds(100));  // Adjust threshold
}
```

---

## Summary

**Key Principles:**
1. **Help, don't just report** - Include actionable next steps
2. **Be aware of performance** - Use level checks, avoid hot paths
3. **Use appropriate levels** - Don't overwhelm users
4. **Structure for parsing** - Consistent key-value format
5. **Include context** - Session IDs, identifiers for correlation
6. **Never log sensitive data** - Redact or hash

**Remember:** Logs are for **future you** and **future maintainers**. Make them helpful.
