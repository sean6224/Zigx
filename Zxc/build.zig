const std = @import("std");

pub fn build(b: *std.Build) void
{
    const version = "0.0.1";
    const exe = b.addExecutable(.{
        .name = "zxc",
        .root_source_file = b.path("src/main.zig"),
        .target = b.standardTargetOptions(.{}),
        .optimize = b.standardOptimizeOption(.{}),
    });

    exe.addIncludePath(b.path("src"));
    
    const build_options = b.addOptions();
    build_options.addOption([]const u8, "zxc_version", version);
    exe.root_module.addOptions("build_options", build_options);
    b.installArtifact(exe);
}