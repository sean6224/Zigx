const std = @import("std");
const SemVer = @import("../semVer.zig").SemVer;

pub const VersionDisplay = struct
{
    pub const VTable = struct {
        format: *const fn(ctx: *anyopaque, writer: std.fs.File.Writer) anyerror!void,
    };

    vtable: *const VTable,
    ctx: *anyopaque,

    pub fn create(version: *const SemVer) VersionDisplay
    {
        return .{
            .vtable = &.{
                .format = formatImpl,
            },
            .ctx = @constCast(version),
        };
    }

    pub fn format(self: VersionDisplay, writer: std.fs.File.Writer) !void {
        return self.vtable.format(self.ctx, writer);
    }
};

fn formatImpl(ctx: *anyopaque, writer: std.fs.File.Writer) !void
{
    const self = @as(*const SemVer, @ptrCast(@alignCast(ctx)));
    try writer.print("{d}.{d}.{d}", .{self.major, self.minor, self.patch});
    if (self.pre_release) |pre| {
        try writer.print("-{s}", .{pre});
    }
    if (self.build_metadata) |build| {
        try writer.print("+{s}", .{build});
    }
}