const std = @import("std");
const SemVer = @import("../semVer.zig").SemVer;

pub const VersionRange = struct {
    min: SemVer,
    max: SemVer,
    include_min: bool,
    include_max: bool,

    pub fn parse(constraint: []const u8) !VersionRange {
        if (constraint.len == 0) return error.EmptyConstraint;

        return switch (constraint[0]) {
            '^' => try parseCaretRange(constraint[1..]),
            '~' => try parseTildeRange(constraint[1..]),
            else => try parseExactVersion(constraint),
        };
    }

    fn parseCaretRange(version_str: []const u8) !VersionRange {
        const version = try SemVer.Parser.parse(version_str);
        var max = version;

        if (version.major > 0) {
            max.major += 1;
            max.minor = 0;
            max.patch = 0;
        } else if (version.minor > 0) {
            max.minor += 1;
            max.patch = 0;
        } else {
            max.patch += 1;
        }

        return VersionRange{
            .min = version,
            .max = max,
            .include_min = true,
            .include_max = false,
        };
    }

    fn parseTildeRange(version_str: []const u8) !VersionRange {
        const version = try SemVer.Parser.parse(version_str);
        var max = version;
        max.minor += 1;
        max.patch = 0;

        return VersionRange{
            .min = version,
            .max = max,
            .include_min = true,
            .include_max = false,
        };
    }

    fn parseExactVersion(version_str: []const u8) !VersionRange {
        const version = try SemVer.Parser.parse(version_str);
        return VersionRange{
            .min = version,
            .max = version,
            .include_min = true,
            .include_max = true,
        };
    }

    pub fn contains(self: VersionRange, version: *const SemVer) bool {
        const min_cmp = version.asComparable().cmp(self.min.asComparable());
        const max_cmp = version.asComparable().cmp(self.max.asComparable());

        return (self.include_min and min_cmp == .eq) or
            (self.include_max and max_cmp == .eq) or
            (min_cmp == .gt and max_cmp == .lt);
    }
};