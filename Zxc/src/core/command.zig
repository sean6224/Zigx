const std = @import("std");

pub const Command = struct
{
    name: []const u8,
    description: []const u8,
    help: ?[]const u8 = null,
    execute: *const fn (
        allocator: std.mem.Allocator,
        args: []const []const u8,
        options: *const std.StringHashMap(void),
    ) anyerror!void,
};

pub const Option = struct
{
    name: []const u8,
    alias: ?[]const u8 = null,
    description: []const u8,
    handler: ?*const fn (allocator: std.mem.Allocator) anyerror!void = null
};

pub const CommandRegistry = struct
{
    allocator: std.mem.Allocator,
    commands: std.StringHashMap(Command),
    options: std.StringHashMap(Option),

    pub fn init(allocator: std.mem.Allocator) !CommandRegistry
    {
        return CommandRegistry
        {
            .allocator = allocator,
            .commands = std.StringHashMap(Command).init(allocator),
            .options = std.StringHashMap(Option).init(allocator),
        };
    }

    pub fn deinit(self: *CommandRegistry) void
    {
        self.commands.deinit();
        self.options.deinit();
    }

    pub fn register(self: *CommandRegistry, command: Command) !void
    {
        try self.commands.put(command.name, command);
    }

    pub fn registerOption(self: *CommandRegistry, option: Option) !void
    {
        try self.options.put(option.name, option);
        if (option.alias) |a| {
            try self.options.put(a, option);
        }
    }
    
    pub fn resolveOptionAlias(self: *CommandRegistry, name: []const u8) ?[]const u8
    {
        if (self.options.get(name)) |opt|
        {
            return opt.name;
        }
        return null;
    }
    
    pub fn get(self: *CommandRegistry, name: []const u8) ?Command
    {
        return self.commands.get(name);
    }

    pub fn getOption(self: *CommandRegistry, name: []const u8) ?Option
    {
        return self.options.get(name);
    }

    pub fn listCommands(self: *CommandRegistry) std.StringHashMap(Command).Iterator
    {
        return self.commands.iterator();
    }

    pub fn listOptions(self: *CommandRegistry) std.StringHashMap(Option).Iterator
    {
        return self.options.iterator();
    }
};
