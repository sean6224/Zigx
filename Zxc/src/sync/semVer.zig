const std = @import("std");
const VersionComparable = @import("version/VersionComparable.zig").VersionComparable;
const VersionDisplay = @import("version/VersionDisplay.zig").VersionDisplay;
const Compatibility = @import("version/Compatibility.zig").Compatibility;
const VersionRange = @import("version/VersionRange.zig").VersionRange;

pub const SemVer = struct
{
    major: u32,
    minor: u32,
    patch: u32,
    pre_release: ?[]const u8 = null,
    build_metadata: ?[]const u8 = null,

    pub fn create(
        major: u32,
        minor: u32,
        patch: u32,
        pre_release: ?[]const u8,
        build_metadata: ?[]const u8,
    ) SemVer {
        return .{
            .major = major,
            .minor = minor,
            .patch = patch,
            .pre_release = pre_release,
            .build_metadata = build_metadata
        };
    }

    pub const Parser = struct
    {
        pub fn parse(version_str: []const u8) !SemVer
        {
            const dot1 = std.mem.indexOfScalar(u8, version_str, '.') orelse return error.InvalidVersionFormat;
            const dot2 = std.mem.indexOfScalar(u8, version_str[dot1 + 1 ..], '.') orelse return error.InvalidVersionFormat;

            const major_str = version_str[0..dot1];
            const minor_str = version_str[dot1 + 1 ..][0..dot2];
            const patch_and_rest = version_str[dot1 + 1 ..][dot2 + 1 ..];

            const patch_end = std.mem.indexOfAny(u8, patch_and_rest, "-+") orelse patch_and_rest.len;
            const patch_str = patch_and_rest[0..patch_end];

            const major = try std.fmt.parseInt(u32, major_str, 10);
            const minor = try std.fmt.parseInt(u32, minor_str, 10);
            const patch = try std.fmt.parseInt(u32, patch_str, 10);

            var pre_release: ?[]const u8 = null;
            var build_metadata: ?[]const u8 = null;

            if (patch_end < patch_and_rest.len)
            {
                const suffix = patch_and_rest[patch_end..];
                if (suffix[0] == '-')
                {
                    const end = std.mem.indexOfScalar(u8, suffix, '+') orelse suffix.len;
                    pre_release = suffix[1..end];
                    if (end < suffix.len) {
                        build_metadata = suffix[end + 1 ..];
                    }
                } else if (suffix[0] == '+') {
                    build_metadata = suffix[1..];
                }
            }

            return SemVer.create(major, minor, patch, pre_release, build_metadata);
        }
    };

    pub fn asComparable(self: *const SemVer) VersionComparable {
        return VersionComparable.create(self);
    }

    pub fn asDisplay(self: *const SemVer) VersionDisplay {
        return VersionDisplay.create(self);
    }

    pub fn asCompatibility(self: *const SemVer) Compatibility {
        return Compatibility.create(self);
    }

    pub fn incrementMajor(self: *SemVer) void {
        self.major += 1;
        self.minor = 0;
        self.patch = 0;
        self.pre_release = null;
        self.build_metadata = null;
    }

    pub fn incrementMinor(self: *SemVer) void
    {
        self.minor += 1;
        self.patch = 0;
        self.pre_release = null;
        self.build_metadata = null;
    }

    pub fn incrementPatch(self: *SemVer) void
    {
        self.patch += 1;
        self.pre_release = null;
        self.build_metadata = null;
    }

    pub fn format(
        self: SemVer,
        comptime fmt: []const u8,
        options: std.fmt.FormatOptions,
        writer: anytype) !void
    {
        _ = fmt;
        _ = options;
        try writer.print("{d}.{d}.{d}", .{self.major, self.minor, self.patch});
        if (self.pre_release) |pre| {
            try writer.print("-{s}", .{pre});
        }
        if (self.build_metadata) |build| {
            try writer.print("+{s}", .{build});
        }
    }

    pub fn isNewerThan(self: SemVer, other: *const SemVer) bool {
        return self.major > other.major
            or (self.major == other.major and self.minor > other.minor)
            or (self.major == other.major and self.minor == other.minor and self.patch > other.patch);
    }
};

pub const errors = error{
    InvalidVersionFormat,
    EmptyConstraint,
};