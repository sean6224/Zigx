const std = @import("std");
const SemVer = @import("../../sync/semVer.zig").SemVer;
const UpdateService = @import("../../services/UpdateService.zig");

pub fn versioncheck(allocator: std.mem.Allocator) !void
{
    const current = try SemVer.Parser.parse(@import("build_options").zxc_version);
    const result = try UpdateService.checkForUpdate(allocator, current);

    const stdout = std.io.getStdOut().writer();
    try stdout.print("Current version: {}\n", .{result.current});
    try stdout.print("Latest version:  {}\n", .{result.latest});

    switch (result.status) 
    {
        .UpToDate => try stdout.writeAll("You are using the latest version.\n"),
        .UpdateAvailable => try stdout.writeAll("Update available! Run 'zxc upgrade'\n"),
        .Unknown => try stdout.writeAll("Could not determine update status.\n"),
    }
}