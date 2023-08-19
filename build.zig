const std = @import("std");

// TODO: add cuda or opencl futhark apis
pub fn build(b: *std.Build) !void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const futhark: [4][]const u8 = .{ "futhark", "c", "--library", "src/wow.fut" };
    _ = try std.ChildProcess.exec(.{ .allocator = arena.allocator(), .argv = futhark[0..] });

    const exe = b.addExecutable(.{
        .name = "zig-futhark-example",
        .root_source_file = .{ .path = "src/main.zig" },
        .target = target,
        .optimize = optimize,
    });
    exe.linkLibC();
    exe.addCSourceFile(.{ .{ .path = "src/wow.c" }, &.{} });
    exe.addIncludePath(.{ .path = "src" });

    const run_cmd = b.addRunArtifact(exe);

    run_cmd.step.dependOn(b.getInstallStep());

    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);

    const unit_tests = b.addTest(.{
        .root_source_file = .{ .path = "src/main.zig" },
        .target = target,
        .optimize = optimize,
    });

    const run_unit_tests = b.addRunArtifact(unit_tests);

    const test_step = b.step("test", "Run unit tests");
    test_step.dependOn(&run_unit_tests.step);
}
