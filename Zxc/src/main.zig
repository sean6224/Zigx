const std = @import("std");
const core = @import("core/mod.zig");
const SemVer = @import("sync/semVer.zig").SemVer;
const VersionRange = @import("sync/version/VersionRange.zig").VersionRange;

const cli = @import("cli/parser.zig");
const Application = @import("core/Application.zig");
const registry_mod = @import("core/registry.zig");
const commands = @import("commands/mod.zig");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    var app = try Application.Application.init(allocator);
    defer registry_mod.deinitGlobalRegistry();

    try commands.registerAll(app.registry);
  
    const args = try std.process.argsAlloc(allocator);
    defer std.process.argsFree(allocator, args);

    try app.run();
}
