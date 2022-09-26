const std = @import("std");
const Pkg = std.build.Pkg;

const pkg_bitset = Pkg {
    .name = "bitset",
    .source = .{.path = "bitset/bitset.zig"},
};

const pkg_libev = Pkg {
    .name = "ev",
    .source = .{.path = "src/lib.zig"},
    .dependencies = &.{pkg_bitset},
};

pub fn build(b: *std.build.Builder) !void {
    const mode = b.standardReleaseOptions();
    const target = b.standardTargetOptions(.{});

    // unit test
    const unit_test = b.addTest("main.zig");
    unit_test.setBuildMode(mode);
    unit_test.setTarget(target);

    // lib
    const lib = b.addStaticLibrary("ev", "src/lib.zig");
    lib.setBuildMode(mode);
    lib.addPackage(pkg_bitset);
    lib.linkLibC();
    lib.install();

    // examples
    const bin_version = b.addExecutable("version", "examples/version.zig");
    bin_version.setBuildMode(mode);
    bin_version.setTarget(target);
    bin_version.addPackage(pkg_libev);
    bin_version.linkLibC();
    bin_version.linkSystemLibrary("ev");
    bin_version.install();

    const bin_stdin = b.addExecutable("stdin", "examples/stdin.zig");
    bin_stdin.setBuildMode(mode);
    bin_stdin.setTarget(target);
    bin_stdin.addPackage(pkg_libev);
    bin_stdin.linkLibC();
    bin_stdin.linkSystemLibrary("ev");
    bin_stdin.install();

    const bin_timer = b.addExecutable("timer", "examples/timer.zig");
    bin_timer.setBuildMode(mode);
    bin_timer.setTarget(target);
    bin_timer.addPackage(pkg_libev);
    bin_timer.linkLibC();
    bin_timer.linkSystemLibrary("ev");
    bin_timer.install();

    // const bin_async_stdin = b.addExecutable("async_stdin", "examples/async_stdin.zig");
    // b.use_stage1 = true;
    // bin_async_stdin.setBuildMode(mode);
    // bin_async_stdin.setTarget(target);
    // bin_async_stdin.addPackage(pkg_libev);
    // bin_async_stdin.linkLibC();
    // bin_async_stdin.linkSystemLibrary("ev");
    // bin_async_stdin.install();
}
