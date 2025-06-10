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

pub fn parseArgs(allocator: std.mem.Allocator) !ParsedArgs
{
    const args = try std.process.argsAlloc(allocator);

    var options = std.StringHashMap(void).init(allocator);
    var positional_list = std.ArrayList([]const u8).init(allocator);

    var i: usize = 1;
    while (i < args.len) : (i += 1) {
        const arg = args[i];
        
        const normalized_arg = if (std.mem.eql(u8, arg, "-d")) "--debug"
        else if (std.mem.eql(u8, arg, "-v")) "--version"
            else if (std.mem.eql(u8, arg, "-h")) "--help"
                else if (std.mem.eql(u8, arg, "-t")) "--test"
                    else arg;

        if (std.mem.startsWith(u8, normalized_arg, "-"))
        {
            try options.put(normalized_arg, {});
        } else {
            try positional_list.append(arg);
        }
    }

    return ParsedArgs{
        .original = args,
        .positional = try positional_list.toOwnedSlice(),
        .options = options,
    };
}