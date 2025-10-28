# Zig Coding Guidelines

## Foundation: Simplicity Over Cleverness

**Follow the Zig philosophy: explicit over implicit, simple over clever.**

Inspired by Andrew Kelly (Zig creator): Prefer straightforward code that's easy to understand over clever abstractions.

## Language Version

**Zig 0.15.1** - Zig evolves rapidly with breaking changes between versions.

### ⚠️ Important Version Notes

- **AI training is out of date** - Always check current documentation
- **ArrayList is unmanaged by default** in 0.15.1
- **Initialization uses `.empty` syntax**
- **All ArrayList methods require passing allocator explicitly**

## Memory Management

### ArrayList Patterns (Zig 0.15.1)

**✅ DO:**
```zig
// ArrayList field declaration
pub const VideoLayoutEngine = struct {
    allocator: std.mem.Allocator,
    video_rects: std.ArrayList(VideoRect),
    active_participants: std.ArrayList(u32),

    pub fn init(allocator: std.mem.Allocator, config: LayoutConfig) VideoLayoutEngine {
        return VideoLayoutEngine{
            .allocator = allocator,
            .video_rects = .empty,
            .active_participants = .empty,
        };
    }

    pub fn deinit(self: *VideoLayoutEngine) void {
        self.video_rects.deinit(self.allocator);
        self.active_participants.deinit(self.allocator);
    }
};

// Local ArrayList usage
var thumbnail_participants: std.ArrayList(u32) = .empty;
defer thumbnail_participants.deinit(allocator);
try thumbnail_participants.append(allocator, participant_id);
```

**❌ DON'T:**
```zig
// Don't use old managed ArrayList syntax
var list = std.ArrayList(u32).init(allocator);  // Wrong for 0.15.1

// Don't forget to pass allocator to methods
try list.append(item);  // Missing allocator parameter
```

### Pre-allocate When Size is Known

**✅ DO:**
```zig
// Single allocation with known size
var participant_ids = try std.ArrayList(u32).initCapacity(allocator, participants.items.len);
defer participant_ids.deinit(allocator);
for (participants.items) |p| {
    participant_ids.appendAssumeCapacity(p.id); // No allocation
}
```

**Benefits:** Single allocation, better cache locality, predictable performance.

### Match Allocation Strategy to Lifetime

#### Arena Allocators - For Temporary Data

**✅ DO:**
```zig
// Arena for temporary HTTP request data
pub fn makeApiRequest(self: *Client, url: []const u8) \![]const u8 {
    var arena = std.heap.ArenaAllocator.init(self.allocator);
    defer arena.deinit(); // Frees everything at once
    const temp_allocator = arena.allocator();

    const auth_header = try std.fmt.allocPrint(temp_allocator, "Bearer {s}", .{self.token});
    const request_body = try std.fmt.allocPrint(temp_allocator, "{{\"data\": \"{s}\"}}", .{data});
    const response = try self.httpRequest(url, auth_header, request_body, temp_allocator);

    // Only permanent result uses main allocator
    return try self.allocator.dupe(u8, response);
}
```

## Error Handling

### Resource Cleanup with errdefer

**✅ DO:**
```zig
// Automatic cleanup with errdefer
pub fn init(allocator: std.mem.Allocator) \!AppContext {
    try sdl.init(sdl.SDL_INIT_VIDEO);
    errdefer sdl.quit();

    const window = try sdl.createWindow("App", 1200, 800, 0);
    errdefer sdl.destroyWindow(window);

    const renderer = try sdl.createRenderer(window, null);
    errdefer sdl.destroyRenderer(renderer);

    var video_processor = video.VideoProcessor.init(allocator, renderer);
    errdefer video_processor.deinit();

    // If any subsequent operation fails, all errdefers execute in reverse order
    return AppContext{
        .window = window,
        .renderer = renderer,
        .video_processor = video_processor,
    };
}
```

**Why errdefer is better:**
- Cleanup happens automatically in reverse order (LIFO)
- Compiler-verified - can't forget or get order wrong
- Add new resource? Just add one errdefer line
- Zero runtime overhead

### Idiomatic Error Handling

**✅ DO:**
```zig
// Clean error handling with orelse
pub fn initializeClient(self: *Session, ca_path: [*:0]const u8) \!void {
    const sdk = rtms_c.rtms_alloc() orelse {
        rtms_c.rtms_uninit();
        return RTMSError.AllocFailed;
    };

    const result = rtms_c.rtms_config(sdk, null, SDK_ALL, 0);
    if (result \!= RTMS_SDK_OK) {
        return RTMSError.ConfigFailed;
    }
}
```

### Error Union Patterns

**✅ DO:**
```zig
// Specific error types
pub const RTMSError = error{
    InitFailed,
    AllocFailed,
    ConfigFailed,
    NotInitialized,
    InvalidArgs,
};

// Error handling with context
rtms_session.initializeRTMS(ca_path_z) catch |err| {
    log.err("Failed to initialize RTMS: {}", .{err});
    log.err("RTMS is required for kazui to function properly.", .{});
    return;
};
```

## Type System

### Type Casting Patterns

Prefer explicit type annotations over inline casts for better readability.

**✅ DO:**
```zig
// Type annotation on variable
const width: u32 = @intCast(surface.w);
const height: u32 = @intCast(surface.h);

// Extract to intermediate variable
const offset: u32 = @intCast(i);
const x = start_x + offset;

// Extract conversions first
const x_f: f32 = @floatFromInt(x);
const y_f: f32 = @floatFromInt(y);
const width_f: f32 = @floatFromInt(width);
const height_f: f32 = @floatFromInt(height);
const rect = sdl.FRect{ .x = x_f, .y = y_f, .w = width_f, .h = height_f };
```

**❌ DON'T:**
```zig
// Nested double-cast pattern
const width = @as(u32, @intCast(surface.w));

// Inline cast in arithmetic
const x = start_x + @as(u32, @intCast(i));
```

### Variable Naming

**✅ DO:**
```zig
// Semantic names that describe purpose
const stride: usize = @intCast(pitch);      // "stride" is standard graphics term
const offset: u32 = @intCast(i);            // describes what the value represents
const num_cols: u32 = @intCast(cols);       // clear semantic meaning
```

**❌ DON'T:**
```zig
// Type information in variable name (Hungarian notation)
const pitch_usize: usize = @intCast(pitch);
const i_u32: u32 = @intCast(i);
```

### Optional Types (?T)

**✅ DO:**
```zig
// Optional for resources that might not exist
pub const Session = struct {
    rtms_client: ?RTMSClient = null,
    connection_params: ?ConnectionParams = null,

    pub fn poll(self: *Session) void {
        if (self.rtms_client) |*client| {
            client.poll() catch |err| {
                log.debug("RTMS poll error: {}", .{err});
            };
        }
    }
};
```

### Sentinel-Terminated Pointers ([*:0]const u8)

**✅ DO:**
```zig
// For C interop - null-terminated strings
pub fn join(self: *RTMSClient, meeting_uuid: [*:0]const u8, ...) \!void {
    const result = rtms_c.rtms_join(self.sdk, meeting_uuid, ...);
    if (result \!= RTMS_SDK_OK) {
        return RTMSError.JoinFailed;
    }
}

// Converting Zig strings to C strings
const uuid_z = try allocator.dupeZ(u8, uuid_slice);
defer allocator.free(uuid_z);
```

## Code Organization

### Module Structure

**✅ DO:**
```zig
// Clear imports and exports
const std = @import("std");
const ui = @import("ui.zig");
const log = std.log.scoped(.rtms_session);

// Public API at top
pub const Session = struct { ... };
pub const RTMSError = error { ... };

// Private implementation at bottom
const RTMSClient = struct { ... };
```

## C Interop

### C Import Patterns

**✅ DO:**
```zig
// Organized C imports
const rtms_c = @cImport({
    @cInclude("rtms_csdk.h");
    @cInclude("rtms_common.h");
});

// Type aliases for clarity
const RTMS_SDK = rtms_c.rtms_csdk;
const SessionInfo = rtms_c.session_info;
const RTMS_SDK_OK = rtms_c.RTMS_SDK_OK;
```

### C Callback Patterns

**✅ DO:**
```zig
// Export functions for C callbacks
export fn c_on_join_confirm(sdk: [*c]RTMS_SDK, reason: c_int) callconv(.c) void {
    if (sdk \!= null) {
        if (findClientForSDK(sdk)) |client| {
            client.callbacks.on_join_confirm(sdk, @intCast(reason));
        }
    }
}
```

### Resource Management with C APIs

**✅ DO:**
```zig
// RAII pattern for C resources
pub fn init(allocator: std.mem.Allocator, ca_path: [*:0]const u8) RTMSError\!RTMSClient {
    const result = rtms_c.rtms_init(ca_path);
    if (result \!= RTMS_SDK_OK) {
        return RTMSError.InitFailed;
    }

    const sdk = rtms_c.rtms_alloc() orelse {
        rtms_c.rtms_uninit(); // Clean up on failure
        return RTMSError.AllocFailed;
    };

    return RTMSClient{
        .allocator = allocator,
        .sdk = sdk, // Always valid after init
    };
}

pub fn deinit(self: *RTMSClient) void {
    _ = rtms_c.rtms_release(self.sdk);
    rtms_c.rtms_uninit();
}
```

## Testing

### Test File Organization

**Colocate tests with code when:**
- Tests are for a single module
- Tests need access to private implementation details
- Making things public just for testing is wrong

**Keep tests separate when:**
- Tests are integration tests spanning multiple modules
- Tests require complex setup/teardown

**✅ DO:**
```zig
// Tests colocated in same file (audio.zig)
const JitterBuffer = struct {  // Private
    // ... implementation
};

// Tests at end of file
test "JitterBuffer - basic push and pop" {
    const allocator = testing.allocator;
    var buffer = try JitterBuffer.init(allocator, 123);
    defer buffer.deinit();
    // ...
}
```

### Import Tests in main.zig

**✅ DO:**
```zig
test {
    _ = @import("audio.zig");      // Runs tests colocated in audio.zig
    _ = @import("mixer_test.zig"); // Runs integration tests
}
```

## Anti-Patterns to Avoid

### Memory Management Anti-Patterns

**❌ DON'T:**
```zig
// Optional SDK that can be null after init
const RTMSClient = struct {
    sdk: ?*RTMS_SDK = null, // Creates invalid states
};
```

**✅ DO:**
```zig
// SDK always valid after init
const RTMSClient = struct {
    sdk: *RTMS_SDK, // Always valid
};
```

### Comment Anti-Patterns

**❌ DON'T:**
```zig
// Useless comments
// Idiomatic optional check
const sdk = self.sdk orelse return Error.InvalidArgs;
```

**✅ DO:**
```zig
// Helpful comments
// RTMS requires connection params before joining
if (self.connection_params == null) return Error.NotConfigured;
```

## Documentation Resources

- **[Zig Language Reference](https://ziglang.org/documentation/master/)** - Complete language specification
- **[Zig Standard Library](https://ziglang.org/documentation/master/std/)** - Standard library documentation
- **[Zig Learn](https://ziglearn.org/)** - Comprehensive tutorial
- **[Zig Guide](https://zig.guide/)** - Community-driven learning resource

## Quick Reference

### Memory Management Decision Tree
1. Multiple temporary allocations? → **Arena Allocator**
2. Single temporary allocation? → **Simple + defer**
3. Long-lived struct? → **Simple + deinit**
4. Performance critical? → **Consider optimization**

### Error Handling Checklist
- ✅ Use `errdefer` for automatic resource cleanup in init functions
- ✅ Use `orelse` for optional handling
- ✅ Use specific error types
- ✅ Provide context in error messages

### Code Quality Checklist
- ✅ Comments explain WHY, not WHAT
- ✅ Public API before private helpers
- ✅ Test with both success and error cases
- ✅ Make invalid states unrepresentable
- ✅ Explicit over implicit, simple over clever
