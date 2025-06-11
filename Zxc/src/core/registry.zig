const std = @import("std");
const core = @import("command.zig");
const builtin_options = @import("../commands/options/builtin_options.zig");

var global_registry: ?*core.CommandRegistry = null;

pub const RegistryError = error
{
    NotInitialized,
};

pub fn initGlobalRegistry(allocator: std.mem.Allocator) !*core.CommandRegistry
{
    if (global_registry == null)
    {
        const reg_ptr = try allocator.create(core.CommandRegistry);
        reg_ptr.* = try core.CommandRegistry.init(allocator);
        global_registry = reg_ptr;

        try reg_ptr.registerOption(.
        {
            .name = "--debug",
            .alias = "-d",
            .description = "Enable debug mode",
        });
        try reg_ptr.registerOption(.
        {
            .name = "--help",
            .alias = "-h",
            .description = "Show help information",
        });
        
        try reg_ptr.registerOption(.
        {
            .name = "--version",
            .alias = "-v",
            .description = "Print version and exit",
            .handler = &builtin_options.versioncheck
        });
    }
    return global_registry.?;
}

pub fn deinitGlobalRegistry() void
{
    if (global_registry) |reg|
    {
        reg.deinit();
        reg.allocator.destroy(reg);
        global_registry = null;
    }
}

pub fn getGlobalRegistry() *core.CommandRegistry
{
    return global_registry orelse @panic("Registry not initialized");
}

pub fn listOptions() std.StringHashMap(core.Option).Iterator
{
    return getGlobalRegistry().options.iterator();
}