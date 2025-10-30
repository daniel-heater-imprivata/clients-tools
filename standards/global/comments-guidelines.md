# Comments Guidelines

## Philosophy: Comments for Future Maintainers

Comments should be **useful for future development and maintenance**. They explain **why**, not **what**.

---

## Core Principles

### 1. Comments Reflect Current State

**❌ DON'T: Record development history in comments**
```cpp
// 2024-10-15: Changed from std::vector to std::deque
// 2024-10-20: Added error handling
// 2024-10-25: Fixed memory leak
std::deque<Connection> connections_;
```

**✅ DO: Use git for history**
```cpp
// Use deque for efficient insertion/removal at both ends
std::deque<Connection> connections_;
```

**Why:** Git is the source of truth for history. Comments should explain the **current** design, not how we got here.

### 2. Prefer Log Messages Over Comments

**❌ DON'T: Document behavior in comments**
```cpp
// This function connects to the server and authenticates
// Returns true if successful, false otherwise
bool connect() {
    // Try to connect
    if (\!socket_.connect(server_url_)) {
        return false;
    }
    // Try to authenticate
    if (\!authenticate()) {
        return false;
    }
    return true;
}
```

**✅ DO: Use log messages for runtime documentation**
```cpp
bool connect() {
    RSS_LOG_DEBUG("event=connection_attempt server={}", server_url_);
    
    if (\!socket_.connect(server_url_)) {
        RSS_LOG_ERROR("event=connection_failed server={} error='{}' - "
                      "Check server is running: 'systemctl status rss-server'",
                      server_url_, socket_.error());
        return false;
    }
    
    RSS_LOG_DEBUG("event=authentication_attempt session_id={}", session_id_);
    
    if (\!authenticate()) {
        RSS_LOG_ERROR("event=authentication_failed session_id={} - "
                      "Verify certificate: 'openssl x509 -in {} -noout -text'",
                      session_id_, cert_path_);
        return false;
    }
    
    RSS_LOG_INFO("event=connection_established session_id={} server={}",
                 session_id_, server_url_);
    return true;
}
```

**Why:**
- Log messages are visible at runtime (comments are not)
- Log messages help with debugging and monitoring
- Log messages can be structured and parsed
- Comments become stale; log messages stay relevant

---

## When to Use Comments

### ✅ DO: Explain WHY, not WHAT

**❌ DON'T: Explain what the code does (code is self-documenting)**
```cpp
// Increment counter
counter++;

// Loop through connections
for (const auto& conn : connections_) {
    // Close the connection
    conn.close();
}
```

**✅ DO: Explain why the code does it**
```cpp
// Increment before logging to ensure unique sequence numbers
counter++;

// Close all connections before shutdown to ensure graceful cleanup
// and avoid "connection reset" errors on the server side
for (const auto& conn : connections_) {
    conn.close();
}
```

### ✅ DO: Explain non-obvious decisions

```cpp
// Use shared_ptr here (not unique_ptr) because callbacks may outlive
// the connection object. The connection must stay alive until all
// callbacks complete.
std::shared_ptr<Connection> conn = std::make_shared<Connection>();

// Sleep for 100ms to avoid overwhelming the server with reconnect attempts.
// Server rate-limits to 10 connections/second per client.
std::this_thread::sleep_for(std::chrono::milliseconds(100));

// Don't use std::span here - we're C++17 only (no C++20 features)
std::vector<uint8_t> buffer;  // Use vector instead of span
```

### ✅ DO: Explain workarounds and limitations

```cpp
// WORKAROUND: libssh2 doesn't support non-blocking DNS resolution,
// so we resolve the hostname synchronously before connecting.
// This can block for several seconds if DNS is slow.
// TODO: Consider using c-ares for async DNS resolution
auto resolved_ip = resolve_hostname(hostname);

// LIMITATION: Maximum 100 concurrent connections due to file descriptor
// limits on some systems. Increase with 'ulimit -n' if needed.
constexpr size_t MAX_CONNECTIONS = 100;

// HACK: Boost.Asio doesn't provide a way to get the local port of a
// connected socket, so we parse it from the socket's string representation.
// This is fragile but works for now.
auto local_port = parse_port_from_socket_string(socket_.local_endpoint());
```

### ✅ DO: Explain complex algorithms

```cpp
// Exponential backoff with jitter to avoid thundering herd:
// - Start with 100ms delay
// - Double delay on each retry (up to 30 seconds)
// - Add random jitter (±25%) to spread out retries
// - Reset delay after successful connection
auto delay = std::min(base_delay_ * (1 << retry_count_), max_delay_);
auto jitter = std::uniform_real_distribution<>(0.75, 1.25)(rng_);
std::this_thread::sleep_for(delay * jitter);
```

### ✅ DO: Explain safety-critical code

```cpp
// CRITICAL: Must hold lock while modifying connections_ to prevent
// race condition where another thread reads connections_ while we're
// adding/removing. Without lock, we could crash or corrupt memory.
std::lock_guard<std::mutex> lock(connections_mutex_);
connections_.push_back(std::move(conn));

// CRITICAL: Must call shutdown() before close() to ensure graceful
// connection termination. Calling close() directly can cause data loss.
socket_.shutdown(boost::asio::socket_base::shutdown_both);
socket_.close();
```

---

## When NOT to Use Comments

### ❌ DON'T: State the obvious

```cpp
// Bad: Obvious from code
int count = 0;  // Initialize count to zero
count++;        // Increment count
return count;   // Return count

// Good: No comments needed (code is clear)
int count = 0;
count++;
return count;
```

### ❌ DON'T: Repeat function/variable names

```cpp
// Bad: Just repeating the name
class ConnectionManager {
    // Manages connections
    void manage_connections();
    
    // The connection pool
    std::vector<Connection> connection_pool_;
};

// Good: Explain purpose and design
class ConnectionManager {
    // Maintains pool of reusable connections to avoid reconnection overhead.
    // Connections are recycled after use to improve performance.
    void manage_connections();
    
    std::vector<Connection> connection_pool_;
};
```

### ❌ DON'T: Comment out code

```cpp
// Bad: Commented-out code
void process() {
    // Old implementation
    // for (auto& item : items) {
    //     item.process();
    // }
    
    // New implementation
    std::for_each(items.begin(), items.end(), [](auto& item) {
        item.process();
    });
}

// Good: Delete old code (it's in git history)
void process() {
    std::for_each(items.begin(), items.end(), [](auto& item) {
        item.process();
    });
}
```

**Why:** Git is the source of truth for history. Commented-out code creates confusion and clutter.

### ❌ DON'T: Use comments as TODO lists

```cpp
// Bad: TODO in comments
// TODO: Add error handling
// TODO: Optimize performance
// TODO: Add tests
// TODO: Refactor this function
void process() {
    // ...
}

// Good: Use issue tracker or structured TODOs
// TODO(CLIENTS-520): Add retry logic for transient failures
// TODO(performance): Profile and optimize hot path (see issue #123)
void process() {
    // ...
}
```

**Better:** Use issue tracker (JIRA, GitHub Issues) for tracking work.

---

## Comment Styles

### File-Level Comments

```cpp
// connection_manager.h
//
// Manages pool of reusable connections to RSS server.
//
// Thread-safe: All public methods can be called from multiple threads.
//
// Usage:
//   ConnectionManager mgr(server_url);
//   auto conn = mgr.acquire();  // Get connection from pool
//   conn->send(data);
//   mgr.release(std::move(conn));  // Return to pool
```

### Class-Level Comments

```cpp
// Manages lifecycle of SSH tunnels for data plane.
//
// Each tunnel represents a bidirectional data relay between a local port
// and a remote service. Tunnels are created on-demand via LAUNCH commands
// and automatically cleaned up when the connection closes.
//
// Thread-safety: All methods must be called from the same thread (the
// Boost.Asio event loop thread). Use post() to call from other threads.
class TunnelManager {
    // ...
};
```

### Function-Level Comments

```cpp
// Attempts to reconnect with exponential backoff.
//
// Retries up to max_retries times with exponentially increasing delays
// (100ms, 200ms, 400ms, ..., up to 30 seconds). Adds random jitter to
// avoid thundering herd.
//
// Returns true if reconnection succeeded, false if max retries exceeded.
//
// Thread-safety: Must be called from Boost.Asio event loop thread.
bool reconnect_with_backoff(size_t max_retries);
```

### Inline Comments

```cpp
// Use shared_ptr because callbacks may outlive the connection
auto conn = std::make_shared<Connection>();

// Exponential backoff: 100ms, 200ms, 400ms, ..., up to 30s
auto delay = std::min(100ms * (1 << retry_count), 30s);

// CRITICAL: Must hold lock to prevent race condition
std::lock_guard<std::mutex> lock(mutex_);
```

---

## Special Comment Markers

### TODO - Work to be done

```cpp
// TODO(CLIENTS-520): Add retry logic for transient failures
// TODO(performance): Profile this hot path - seems slow
// TODO(security): Validate input to prevent injection attacks
```

**Format:** `TODO(context): Description`
- Include ticket number or category
- Be specific about what needs to be done

### FIXME - Known bugs or issues

```cpp
// FIXME(CLIENTS-521): Race condition when closing connection during send
// FIXME: Memory leak when exception thrown in callback
```

**Format:** `FIXME(context): Description`
- Include ticket number if bug is tracked
- Describe the problem clearly

### HACK - Temporary workaround

```cpp
// HACK: Boost.Asio doesn't expose local port, so we parse it from string.
// This is fragile but works for now. Replace when Boost adds proper API.
auto port = parse_port_from_string(socket.local_endpoint().to_string());
```

**Format:** `HACK: Description and why it's temporary`
- Explain why the hack is needed
- Explain what the proper solution would be

### NOTE - Important information

```cpp
// NOTE: This function blocks for up to 5 seconds waiting for response.
// Don't call from event loop thread.
void send_and_wait_for_response();

// NOTE: Caller must ensure buffer remains valid until callback is invoked.
void async_send(const uint8_t* buffer, size_t size, Callback callback);
```

**Format:** `NOTE: Important information`
- Highlight non-obvious behavior
- Warn about potential pitfalls

---

## Examples: Good vs Bad

### Example 1: Connection Retry Logic

**❌ Bad:**
```cpp
// Retry connection
for (int i = 0; i < 5; i++) {
    // Try to connect
    if (connect()) {
        // Success
        return true;
    }
    // Wait before retry
    sleep(1000 * i);
}
// Failed
return false;
```

**✅ Good:**
```cpp
// Retry with exponential backoff to avoid overwhelming server.
// Server rate-limits to 10 connections/second, so we need delays.
for (int i = 0; i < 5; i++) {
    if (connect()) {
        RSS_LOG_INFO("event=connection_established retry_count={}", i);
        return true;
    }
    
    // Exponential backoff: 1s, 2s, 4s, 8s, 16s
    auto delay = std::chrono::seconds(1 << i);
    RSS_LOG_DEBUG("event=retry_scheduled delay_seconds={} attempt={}/5",
                  delay.count(), i + 1);
    std::this_thread::sleep_for(delay);
}

RSS_LOG_ERROR("event=connection_failed_all_retries max_retries=5 - "
              "Check server is running: 'systemctl status rss-server'");
return false;
```

### Example 2: Thread Safety

**❌ Bad:**
```cpp
// Thread-safe
void add_connection(Connection conn) {
    // Lock mutex
    std::lock_guard<std::mutex> lock(mutex_);
    // Add connection
    connections_.push_back(std::move(conn));
}
```

**✅ Good:**
```cpp
// CRITICAL: Must hold lock while modifying connections_ to prevent
// race condition. Without lock, another thread could read connections_
// while we're modifying it, causing crash or memory corruption.
void add_connection(Connection conn) {
    std::lock_guard<std::mutex> lock(mutex_);
    connections_.push_back(std::move(conn));
    
    RSS_LOG_DEBUG("event=connection_added total_connections={}",
                  connections_.size());
}
```

---

## Summary

**Key Principles:**
1. **Comments reflect current state** - Not development history (use git)
2. **Prefer log messages** - Runtime documentation is better than comments
3. **Explain WHY, not WHAT** - Code shows what, comments explain why
4. **Be useful for future maintainers** - Explain non-obvious decisions
5. **Don't state the obvious** - Trust the reader to understand code
6. **Delete commented-out code** - It's in git history

**Remember:** Comments are for **future you** and **future maintainers**. Make them count.
