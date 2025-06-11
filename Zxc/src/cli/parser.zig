const std = @import("std");
const core = @import("../core/mod.zig");

pub const ParsedArgs = struct
{
    original: [][:0]u8,
    positional: []const []const u8,
    options: std.StringHashMap(void),

    pub fn deinit(self: *ParsedArgs, allocator: std.mem.Allocator) void
    {
        allocator.free(self.positional);
        self.options.deinit();
        std.process.argsFree(allocator, self.original);
    }
};

pub fn parseArgs(allocator: std.mem.Allocator, registry: *core.CommandRegistry) !ParsedArgs
{
    const args = try std.process.argsAlloc(allocator);
    var options = std.StringHashMap(void).init(allocator);
    var positional = std.ArrayList([]const u8).init(allocator);

    var i: usize = 1;
    while (i < args.len) : (i += 1)
    {
        const arg = args[i];

        if (std.mem.startsWith(u8, arg, "-"))
        {
            const resolved = registry.resolveOptionAlias(arg) orelse arg;
            try options.put(resolved, {});
        } else {
            try positional.append(arg);
        }
    }

    return ParsedArgs{
        .original = args,
        .positional = try positional.toOwnedSlice(),
        .options = options,
    };
}