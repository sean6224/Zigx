const std = @import("std");
const SemVer = @import("../semVer.zig").SemVer;

pub const VersionComparable = struct
{
    pub const VTable = struct {
        cmp: *const fn(ctx: *anyopaque, other_ctx: *anyopaque) std.math.Order,
    };

    vtable: *const VTable,
    ctx: *anyopaque,

    pub fn create(version: *const SemVer) VersionComparable
    {
        return .{
            .vtable = &.{
                .cmp = cmpImpl,
            },
            .ctx = @constCast(version),
        };
    }

    pub fn cmp(self: VersionComparable, other: VersionComparable) std.math.Order
    {
        return self.vtable.cmp(self.ctx, other.ctx);
    }
};

fn cmpImpl(ctx: *anyopaque, other_ctx: *anyopaque) std.math.Order
{
    const self = @as(*const SemVer, @ptrCast(@alignCast(ctx)));
    const other = @as(*const SemVer, @ptrCast(@alignCast(other_ctx)));

    if (self.major != other.major) {
        return if (self.major < other.major) .lt else .gt;
    }
    if (self.minor != other.minor) {
        return if (self.minor < other.minor) .lt else .gt;
    }
    if (self.patch != other.patch) {
        return if (self.patch < other.patch) .lt else .gt;
    }

    if (self.pre_release == null and other.pre_release != null) return .gt;
    if (self.pre_release != null and other.pre_release == null) return .lt;
    if (self.pre_release != null and other.pre_release != null)
    {
        if (!std.mem.eql(u8, self.pre_release.?, other.pre_release.?))
        {
            return if (std.mem.lessThan(u8, self.pre_release.?, other.pre_release.?)) .lt else .gt;
        }
    }

    return .eq;
}