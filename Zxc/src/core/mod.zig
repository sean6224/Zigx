const command = @import("command.zig");
pub const registry = @import("registry.zig");

pub const CommandError = error
{
    InvalidArgument,
    UnknownCommand,
};

pub const Command = command.Command;
pub const CommandRegistry = command.CommandRegistry;
