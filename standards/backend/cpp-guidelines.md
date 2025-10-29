# C++ Coding Guidelines

## Foundation: C++ Core Guidelines

**Follow the [C++ Core Guidelines](https://isocpp.github.io/CppCoreGuidelines/CppCoreGuidelines) by Bjarne Stroustrup and Herb Sutter.**

The Core Guidelines are the authoritative source for modern C++ best practices. This document highlights project-specific requirements and exceptions, but when in doubt, consult the Core Guidelines.

### Project-Specific Exceptions

**Use `#pragma once` instead of header guards:**

```cpp
// ✅ DO - Use pragma once
#pragma once

class MyClass {
    // ...
};
```

```cpp
// ❌ DON'T - Use header guards
#ifndef MYCLASS_H_  // Hard to debug when names collide
#define MYCLASS_H_

class MyClass {
    // ...
};

#endif  // MYCLASS_H_
```

**Why:** All our compilers support `#pragma once`, and header guard name collisions are difficult to debug.

## Language Version

**C++17 only** - No C++20 features allowed.

### ✅ Allowed (C++17)
- Structured bindings: `auto [key, value] = map.insert(...)`
- `if` with initializer: `if (auto it = map.find(key); it != map.end())`
- `std::optional`, `std::variant`, `std::any`
- `std::string_view` (internal code only, not in public API)
- Fold expressions
- Class template argument deduction (CTAD)
- `inline` variables
- `std::filesystem`

### ❌ Forbidden (C++20+)
- `std::span` - Use pointers + size or containers
- Ranges library - Use traditional iterators
- Concepts - Use SFINAE or static_assert
- `std::format` - Use spdlog or string streams
- Coroutines (`co_await`, `co_return`)
- Modules
- Three-way comparison operator (`<=>`)
- `consteval`, `constinit`

**Why C++17?** Compatibility with older toolchains and build environments used by customers.

## Memory Management

### RAII Everywhere

**✅ DO:**
```cpp
// Smart pointers for ownership
auto session = std::make_shared<Session>();
auto buffer = std::make_unique<char[]>(size);

// RAII wrappers for resources
std::lock_guard<std::mutex> lock(mutex_);
std::ifstream file("config.txt");

// Containers manage their own memory
std::vector<Connection> connections;
std::string message;
```

**❌ DON'T:**
```cpp
// Raw new/delete
Session* session = new Session();  // NO!
delete session;                     // NO!

// Manual memory management
char* buffer = (char*)malloc(size); // NO!
free(buffer);                       // NO!

// Naked pointers for ownership
Connection* conn = new Connection(); // NO!
connections.push_back(conn);        // Who owns this?
```

### Smart Pointer Guidelines

**Ownership:**
- `std::unique_ptr` - Exclusive ownership
- `std::shared_ptr` - Shared ownership (use sparingly)
- Raw pointers/references - Non-owning observation only

**✅ DO:**
```cpp
// Async operations: capture shared_ptr to extend lifetime
void Session::asyncRead() {
    auto self = shared_from_this();
    asio::async_read(socket_, buffer_,
        [self](error_code ec, size_t bytes) {
            self->handleRead(ec, bytes);
        });
}

// Sync methods: pass by const reference (no ref counting overhead)
void processSession(const std::shared_ptr<Session>& session) {
    session->doWork();
}

// Or better: pass by reference when ownership not needed
void processSession(Session& session) {
    session.doWork();
}
```

**❌ DON'T:**
```cpp
// Don't pass shared_ptr by value unnecessarily
void processSession(std::shared_ptr<Session> session) {  // Unnecessary copy!
    session->doWork();
}

// Don't use shared_ptr when unique_ptr suffices
std::shared_ptr<Config> config = std::make_shared<Config>();  // Only one owner? Use unique_ptr!
```

## Const Correctness

**Think like the Rust borrow checker** - Make immutability the default.

**✅ DO:**
```cpp
class Session {
public:
    // Mark methods const if they don't modify state
    std::string getHost() const { return host_; }
    bool isConnected() const { return connected_; }
    
    // Const parameters when not modifying
    void setHost(const std::string& host) { host_ = host; }
    
    // Const member variables when possible
    const int timeout_;
    
private:
    std::string host_;
    bool connected_ = false;
};

// Const references for read-only access
void logMessage(const std::string& msg);
```

**❌ DON'T:**
```cpp
class Session {
public:
    // Missing const on getters
    std::string getHost() { return host_; }  // Should be const!
    
    // Unnecessary copies
    void setHost(std::string host) { host_ = host; }  // Pass by const ref!
};
```

## Threading

### Lifetime Management in Async Code

**✅ DO:**
```cpp
// Capture shared_ptr in async lambdas
void HttpTunnel::asyncConnect() {
    auto self = shared_from_this();
    resolver_.async_resolve(host_, port_,
        [self](error_code ec, tcp::resolver::results_type results) {
            if (!ec) {
                self->asyncHandshake(results);
            }
        });
}

// Use mutex for compound operations on shared state
void ConnectionPool::addConnection(std::shared_ptr<Connection> conn) {
    std::lock_guard<std::mutex> lock(mutex_);
    connections_.push_back(conn);
    available_++;
}
```

**❌ DON'T:**
```cpp
// Capturing 'this' without extending lifetime
void HttpTunnel::asyncConnect() {
    resolver_.async_resolve(host_, port_,
        [this](error_code ec, auto results) {  // DANGER! 'this' may be deleted
            if (!ec) {
                this->asyncHandshake(results);  // Use-after-free risk!
            }
        });
}

// Unprotected access to shared state
void ConnectionPool::addConnection(std::shared_ptr<Connection> conn) {
    connections_.push_back(conn);  // RACE CONDITION!
    available_++;                   // RACE CONDITION!
}
```

### Synchronization

**✅ DO:**
```cpp
// Protect shared state with mutex
class ThreadSafeQueue {
    std::mutex mutex_;
    std::queue<Item> queue_;
    
public:
    void push(Item item) {
        std::lock_guard<std::mutex> lock(mutex_);
        queue_.push(std::move(item));
    }
    
    std::optional<Item> pop() {
        std::lock_guard<std::mutex> lock(mutex_);
        if (queue_.empty()) return std::nullopt;
        Item item = std::move(queue_.front());
        queue_.pop();
        return item;
    }
};

// Use std::atomic for simple counters
std::atomic<int> connection_count_{0};
```

**❌ DON'T:**
```cpp
// Shared state without protection
class ThreadSafeQueue {
    std::queue<Item> queue_;  // NO MUTEX!
    
public:
    void push(Item item) {
        queue_.push(std::move(item));  // RACE CONDITION!
    }
};
```

### Detached Threads

**Document why** if you must use detached threads.

```cpp
// Acceptable: Background cleanup thread with clear justification
void startCleanupThread() {
    // Detached thread is acceptable here because:
    // 1. Cleanup is non-critical and can be interrupted
    // 2. Thread has no dependencies on parent object lifetime
    // 3. Uses only thread-safe global resources
    std::thread([]{
        while (true) {
            std::this_thread::sleep_for(std::chrono::minutes(5));
            cleanupExpiredSessions();
        }
    }).detach();
}
```

## Error Handling

**✅ DO:**
```cpp
// Use exceptions for exceptional conditions
void connect(const std::string& host) {
    if (host.empty()) {
        throw std::invalid_argument("Host cannot be empty");
    }
    // ... connect logic
}

// Use error codes for expected failures (especially in async code)
void asyncConnect(std::function<void(error_code)> callback) {
    // ... async operation that calls callback with error_code
}

// Use std::optional for "not found" cases
std::optional<Session> findSession(int id) {
    auto it = sessions_.find(id);
    if (it == sessions_.end()) return std::nullopt;
    return it->second;
}
```

**❌ DON'T:**
```cpp
// Don't use exceptions for control flow
std::optional<Session> findSession(int id) {
    try {
        return sessions_.at(id);  // Throws if not found - bad!
    } catch (std::out_of_range&) {
        return std::nullopt;
    }
}

// Don't ignore error codes
asio::error_code ec;
socket.connect(endpoint, ec);
// ... no check of ec!
```

## Code Organization

### Avoid Shared State

**✅ DO:**
```cpp
// Each session owns its state
class Session {
    std::string host_;
    tcp::socket socket_;
    std::vector<char> buffer_;
    // ... all state is instance-specific
};

// Pass dependencies explicitly
class HttpTunnel {
    asio::io_context& io_context_;  // Dependency injection
    
public:
    explicit HttpTunnel(asio::io_context& io) : io_context_(io) {}
};
```

**❌ DON'T:**
```cpp
// Global mutable state
static std::map<int, Session*> g_sessions;  // NO!

// Hidden shared state
class Session {
    static std::vector<Session*> all_sessions_;  // Avoid if possible
};
```

### Naming Conventions

```cpp
class MyClass {
public:
    void publicMethod();           // camelCase for methods
    int publicVariable;            // camelCase for public members
    
private:
    void privateMethod();          // camelCase for methods
    int private_member_;           // snake_case with trailing underscore for private members
    std::mutex mutex_;             // trailing underscore for all members
};

// Constants
const int kMaxConnections = 100;   // kPascalCase for constants
constexpr int kBufferSize = 4096;

// Free functions
void freeFunction();               // camelCase
```

## Public vs Internal API

### Public API (include/ directory)

**C-only. No C++ features whatsoever.**

See [docs/api.md](api.md) for complete guidelines.

**Key rules:**
- C types only: `int`, `char*`, `void*`, `size_t`
- `extern "C"` linkage for all functions
- Opaque pointers for objects: `typedef struct Session* SessionHandle;`
- Error codes, not exceptions
- No C++ in headers: no classes, templates, `std::` types, etc.

### Internal API (src/ directory)

**Modern C++17 encouraged.**

- Use all C++17 features freely
- RAII, smart pointers, containers, algorithms
- Exceptions for error handling
- Templates and generic programming
- Boost libraries (ASIO, Beast, URL)

## Dependencies

**Use Conan for all dependency management.**

**✅ DO:**
```bash
# Add dependency via Conan
conan install . --requires=new-package/1.0

# Update lockfile
make update-lockfile

# Clean rebuild
make clean build
```

**❌ DON'T:**
```python
# Don't manually edit conanfile.py for simple additions
# Use Conan commands instead
```

## See Also

- [architecture.md](architecture.md) - System architecture and deployment scenarios
- [api.md](api.md) - Public C API requirements
- [testing.md](testing.md) - Testing guidelines
- [CONTRIBUTING.md](../CONTRIBUTING.md) - Development workflow

