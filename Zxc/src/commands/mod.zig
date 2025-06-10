const std = @import("std");
const core = @import("../core/mod.zig");

const help = @import("help.zig");
const update = @import("update.zig");
const run = @import("run.zig");

pub fn registerAll(registry: *core.CommandRegistry) !void
{
    try registry.register(help.command);
    try registry.register(update.command);
    try registry.register(run.command);
}
