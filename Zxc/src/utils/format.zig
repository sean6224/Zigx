const std = @import("std");

pub const Color = enum
{
    reset,
    black,
    red,
    green,
    yellow,
    blue,
    magenta,
    cyan,
    white,
};

pub const TextStyle = enum
{
    normal,
    bold,
    dim,
    italic,
    underline,
};

pub const Style = struct
{
    prefix: []const u8 = "",
    color: Color,
    style: TextStyle = .normal,
};

pub const Theme = struct
{
    info: Style = .{ .prefix = "", .color = .cyan },
    success: Style = .{ .prefix = "", .color = .green, .style = .bold },
    warning: Style = .{ .prefix = "", .color = .yellow },
    errors: Style = .{ .prefix = "", .color = .red, .style = .bold },
    debug: Style = .{ .prefix = "", .color = .magenta },
    note: Style = .{ .prefix = "", .color = .blue },
};

pub const theme = Theme{};

pub fn ansi(allocator: std.mem.Allocator, color: Color, style: TextStyle) ![]u8
{
    const color_code = switch (color)
    {
        .reset => "0",
        .black => "30",
        .red => "31",
        .green => "32",
        .yellow => "33",
        .blue => "34",
        .magenta => "35",
        .cyan => "36",
        .white => "37",
    };

    const style_code = switch (style)
    {
        .normal => "",
        .bold => ";1",
        .dim => ";2",
        .italic => ";3",
        .underline => ";4",
    };

    return std.fmt.allocPrint(allocator, "\x1b[{s}{s}m", .{color_code, style_code});
}

pub fn printStyled(allocator: std.mem.Allocator, style: Style, text: []const u8) !void
{
    const stdout = std.io.getStdOut().writer();

    const start_ansi = try ansi(allocator, style.color, style.style);
    defer allocator.free(start_ansi);

    const reset_ansi = try ansi(allocator, .reset, .normal);
    defer allocator.free(reset_ansi);

    try stdout.print("{s}{s}{s}{s}{s}\n", .
    {
        start_ansi,
        style.prefix,
        text,
        reset_ansi,
        "",
    });
}

pub fn printStyledf(allocator: std.mem.Allocator, style: Style, comptime fmt: []const u8, args: anytype) !void
{
    const stdout = std.io.getStdOut().writer();

    const start_ansi = try ansi(allocator, style.color, style.style);
    defer allocator.free(start_ansi);

    const reset_ansi = try ansi(allocator, .reset, .normal);
    defer allocator.free(reset_ansi);
    
    try stdout.print("{s}{s}", .{start_ansi, style.prefix});
    try stdout.print(fmt, args);
    try stdout.print("{s}\n", .{reset_ansi});
}

pub fn printInfo(text: []const u8) !void {
    try printStyled(std.heap.page_allocator, theme.info, text);
}

pub fn printSuccess(text: []const u8) !void {
    try printStyled(std.heap.page_allocator, theme.success, text);
}

pub fn printWarn(text: []const u8) !void {
    try printStyled(std.heap.page_allocator, theme.warning, text);
}

pub fn printError(text: []const u8) !void {
    try printStyled(std.heap.page_allocator, theme.errors, text);
}

pub fn printDebug(text: []const u8) !void {
    try printStyled(std.heap.page_allocator, theme.debug, text);
}

pub fn printNote(text: []const u8) !void {
    try printStyled(std.heap.page_allocator, theme.note, text);
}

pub fn printInfof(comptime fmt: []const u8, args: anytype) !void {
    try printStyledf(std.heap.page_allocator, theme.info, fmt, args);
}

pub fn printSuccessf(comptime fmt: []const u8, args: anytype) !void {
    try printStyledf(std.heap.page_allocator, theme.success, fmt, args);
}

pub fn printWarnf(comptime fmt: []const u8, args: anytype) !void {
    try printStyledf(std.heap.page_allocator, theme.warning, fmt, args);
}

pub fn printErrorf(comptime fmt: []const u8, args: anytype) !void {
    try printStyledf(std.heap.page_allocator, theme.errors, fmt, args);
}

pub fn printDebugf(comptime fmt: []const u8, args: anytype) !void {
    try printStyledf(std.heap.page_allocator, theme.debug, fmt, args);
}

pub fn printNotef(comptime fmt: []const u8, args: anytype) !void {
    try printStyledf(std.heap.page_allocator, theme.note, fmt, args);
}
