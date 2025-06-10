const std = @import("std");
const SemVer = @import("../semVer.zig").SemVer;
const VersionRange = @import("VersionRange.zig").VersionRange;

pub const Compatibility = struct
{
    pub const VTable = struct
    {
        isCompatibleWith: *const fn(ctx: *anyopaque, other: *const SemVer) bool,
        satisfies: *const fn(ctx: *anyopaque, constraint: []const u8) bool,
    };

    vtable: *const VTable,
    ctx: *anyopaque,

    pub fn create(version: *const SemVer) Compatibility
    {
        return .{
            .vtable = &.{
                .isCompatibleWith = isCompatibleWithImpl,
                .satisfies = satisfiesImpl,
            },
            .ctx = @constCast(version),
        };
    }

    pub fn isCompatibleWith(self: Compatibility, other: *const SemVer) bool {
        return self.vtable.isCompatibleWith(self.ctx, other);
    }

    pub fn satisfies(self: Compatibility, constraint: []const u8) bool {
        return self.vtable.satisfies(self.ctx, constraint);
    }
};

fn isCompatibleWithImpl(ctx: *anyopaque, other: *const SemVer) bool
{
    const self = @as(*const SemVer, @ptrCast(@alignCast(ctx)));

    if (self.major != other.major) return false;

    if (self.pre_release != null or other.pre_release != null) {
        return std.mem.eql(u8, self.pre_release orelse "", other.pre_release orelse "");
    }

    return true;
}

fn satisfiesImpl(ctx: *anyopaque, constraint: []const u8) bool
{
    const self = @as(*const SemVer, @ptrCast(@alignCast(ctx)));
    const range = VersionRange.parse(constraint) catch return false;
    return range.contains(self);
}