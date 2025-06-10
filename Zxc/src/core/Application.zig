const std = @import("std");
const core = @import("../core/mod.zig");
const cli = @import("../cli/parser.zig");
const fmt = @import("../utils/format.zig");

const build_options = @import("build_options");
const version = build_options.zxc_version;

pub const Application = struct
{
    allocator: std.mem.Allocator,
    registry: *core.CommandRegistry,

    pub fn init(allocator: std.mem.Allocator) !Application
    {
        const registry = try core.registry.initGlobalRegistry(allocator);
        return Application{
            .allocator = allocator,
            .registry = registry,
        };
    }

    pub fn run(self: *Application) !void
    {
        var args = try cli.parseArgs(self.allocator);
        defer args.deinit(self.allocator);
        
        if (args.options.contains("--version"))
        {
            try fmt.printInfof("zxc v{s} — the flexible CLI for Zig", .{version});
            try fmt.printNote("Dynamic command registry, fluent options, and smart help.");
            try fmt.printNote("Built with ❤️ using Zig.");
            try fmt.printNote("License: MIT");
            return;
        }
        
        try self.validateOptions(&args.options);

        if (args.options.contains("--help") or args.positional.len == 0)
        {
            self.showHelp();
            return;
        }

        try self.executeCommand(args.positional, &args.options);
    }

    fn validateOptions(self: *Application, options: *std.StringHashMap(void)) !void
    {
        var it = options.iterator();
        while (it.next()) |entry|
        {
            if (self.registry.getOption(entry.key_ptr.*) == null)
            {
                try fmt.printErrorf("Unknown option: {s}\n", .{entry.key_ptr.*});
                self.showHelp();
                std.process.exit(1);
            }
        }
    }

    fn showHelp(self: *Application) void
    {
        if (self.registry.get("help")) |help_cmd|
        {
            const empty_args = [_][]const u8{};
            var opts = std.StringHashMap(void).init(self.allocator);
            _ = help_cmd.execute(self.allocator, &empty_args, &opts) catch {};
        } else {
            std.debug.print("No help available.\n", .{});
        }
    }

    fn executeCommand(
        self: *Application,
        positional: []const []const u8,
        options: *const std.StringHashMap(void),
    ) !void
    {
        const cmd_name = positional[0];
        const cmd = self.registry.get(cmd_name) orelse
        {
            try fmt.printErrorf("Unknown command: {s}\n", .{cmd_name});
            self.showHelp();
            std.process.exit(1);
        };
        try cmd.execute(self.allocator, positional[1..], options);
    }
};
