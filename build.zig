const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const module = b.createModule(.{
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
        .link_libc = true,
    });

    module.linkSystemLibrary("user32", .{});
    module.linkSystemLibrary("gdi32", .{});
    module.linkSystemLibrary("kernel32", .{});

    const exe = b.addExecutable(.{
        .name = "proyecto_graficas",
        .root_module = module,
    });

    b.installArtifact(exe);

    const run_cmd = b.addRunArtifact(exe);
    run_cmd.step.dependOn(b.getInstallStep());

    const run_step = b.step("run", "Ejecuta el proyecto");
    run_step.dependOn(&run_cmd.step);
}
