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
    const bin_stdin = b.addExecutable("stdin", "examples/stdin.zig");
    bin_stdin.setBuildMode(mode);
    bin_stdin.setTarget(target);
    bin_stdin.addPackage(pkg_libev);
    bin_stdin.linkLibC();
    bin_stdin.linkSystemLibrary("ev");
    bin_stdin.install();
}
