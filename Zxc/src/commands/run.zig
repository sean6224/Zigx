const std = @import("std");
const core = @import("../core/mod.zig");

pub const RunError = error
{
    MissingFilePath,
    UnsupportedExtension,
    ExecutionFailed,
};

pub const command = core.Command
{
    .name = "run",
    .description = "Run a .zigx file (preprocessor only)",
    .execute = &execute,
};

fn execute(
    allocator: std.mem.Allocator,
    args: []const []const u8,
    options: *const std.StringHashMap(void)) !void
{
    _ = allocator;
    const stdout = std.io.getStdOut().writer();

    if (options.contains("--debug")) {
        try stdout.print("⚙️ Debug mode is ON\n", .{});
    }

    if (args.len < 1)
    {
        try stdout.print("Error: Missing file path argument for run command\n", .{});
        return RunError.MissingFilePath;
    }

    const filename = args[0];
    const ext = std.fs.path.extension(filename);

    if (ext.len == 0)
    {
        try stdout.print("Error: file '{s}' has no extension\n", .{filename});
        return RunError.UnsupportedExtension;
    }

    if (!std.mem.eql(u8, ext, ".zigx"))
    {
        try stdout.print("Error: unrecognized file extension '{s}' for parameter '{s}'\n", .{ext, filename});
        return RunError.UnsupportedExtension;
    }

    try stdout.print("Running preprocessor on '{s}'\n", .{filename});
}