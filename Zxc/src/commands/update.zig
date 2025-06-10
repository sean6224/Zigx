const std = @import("std");
const core = @import("../core/mod.zig");

pub const UpdateError = error
{
    CurlFailed,
    RenameFailed,
};

// checking the version from the server,
// only updated if it is newer,
// verify the .sig signature,
// backup the current binary file.

pub const command = core.Command
{
    .name = "update",
    .description = "Update zxc to the latest version",
    .execute = &execute,
};

fn execute(
    allocator: std.mem.Allocator,
    args: []const []const u8,
    options: *const std.StringHashMap(void)) !void
{
    _ = args;
    _ = options;

    const stdout = std.io.getStdOut().writer();
    const stderr = std.io.getStdErr().writer();

    const update_url = "https://example.com/zxc-latest";

    const exe_path = try std.fs.selfExePathAlloc(allocator);
    defer allocator.free(exe_path);

    const tmp_path = try std.fmt.allocPrint(allocator, "{s}.tmp", .{exe_path});
    defer allocator.free(tmp_path);

    var child = std.process.Child.init(&[_][]const u8{
        "curl", "-sSL", update_url, "-o", tmp_path,
    }, allocator);

    child.stdin_behavior = .Ignore;
    child.stdout_behavior = .Inherit;
    child.stderr_behavior = .Inherit;

    try child.spawn();
    const term = try child.wait();

    if (term != .Exited or term.Exited != 0)
    {
        try stderr.print("❌ Error: curl failed (exit code {d})\n", .{term.Exited});
        return UpdateError.CurlFailed;
    }

    var cwd = std.fs.cwd();
    try cwd.rename(tmp_path, exe_path);

    try stdout.print("✅ zxc has been updated successfully.\n", .{});
}
