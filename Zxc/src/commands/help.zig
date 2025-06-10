const std = @import("std");
const core = @import("../core/mod.zig");
const registry_mod = @import("../core/registry.zig");

pub const command = core.Command
{
    .name = "help",
    .description = "Show help information",
    .execute = &execute,
};

fn execute(
    allocator: std.mem.Allocator,
    args: []const []const u8,
    options: *const std.StringHashMap(void)) !void
{
    _ = allocator;
    _ = options;

    const stdout = std.io.getStdOut().writer();
    const stderr = std.io.getStdErr().writer();
    const registry = registry_mod.getGlobalRegistry();

    if (args.len > 0)
    {
        const cmd_name = args[0];
        var cmd_it = registry.listCommands();
        var found = false;

        while (cmd_it.next()) |entry|
        {
            if (std.mem.eql(u8, entry.key_ptr.*, cmd_name))
            {
                const cmd = entry.value_ptr;
                found = true;
                if (cmd.help) |help_text|
                {
                    try stdout.print("{s}\n", .{help_text});
                } else {
                    try stdout.print("{s}: {s}\n", .{cmd.name, cmd.description});
                    try stdout.print("No additional help available for this command.\n", .{});
                }
                break;
            }
        }

        if (!found) {
            try stderr.print("Unknown command: {s}\n", .{cmd_name});
            return error.UnknownCommand;
        }
        return;
    }

    try stdout.print("Usage: zxc [OPTIONS] COMMAND\n\n", .{});

    try stdout.print("Available commands:\n", .{});
    var cmd_it = registry.listCommands();
    while (cmd_it.next()) |entry| {
        try stdout.print("  {s: <10} - {s}\n", .
        {
            entry.key_ptr.*,
            entry.value_ptr.description
        });
    }

    try stdout.print("\nGlobal Options:\n", .{});
    var opt_it = registry_mod.listOptions();
    var seen_options = std.StringHashMap(void).init(std.heap.page_allocator);
    defer seen_options.deinit();

    while (opt_it.next()) |entry|
    {
        const option = entry.value_ptr;

        if (seen_options.contains(option.name)) continue;
        try seen_options.put(option.name, {});

        if (option.alias) |alias|
        {
            try stdout.print("  {s}, {s: <12} - {s}\n", .{
                alias,
                option.name,
                option.description
            });
        } else {
            try stdout.print("  {s: <15} - {s}\n", .
            {
                option.name,
                option.description
            });
        }
    }
}