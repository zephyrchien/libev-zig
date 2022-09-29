const std = @import("std");
const Pkg = std.build.Pkg;
const Builder = std.build.Builder;
const Mode = std.builtin.Mode;
const CrossTarget = std.zig.CrossTarget;

const pkg_bitset = Pkg {
    .name = "bitset",
    .source = .{.path = "bitset/bitset.zig"},
};

const pkg_libev = Pkg {
    .name = "ev",
    .source = .{.path = "src/lib.zig"},
    .dependencies = if (USE_STAGE1) null else &.{pkg_bitset},
};

fn bin(b: *Builder, mode: *const Mode, target: *const CrossTarget,
    comptime source: []const[]const u8) void {
    inline for (source) |s| {
        const file = b.addExecutable(s, "examples/" ++ s ++ ".zig");
        file.setBuildMode(mode.*);
        file.setTarget(target.*);
        file.addPackage(pkg_libev);
        file.linkLibC();
        file.linkSystemLibrary("ev");
        file.install();
    }
}

const USE_STAGE1 = false;
pub fn build(b: *Builder) !void {
    const mode = b.standardReleaseOptions();
    const target = b.standardTargetOptions(.{});

    b.use_stage1 = USE_STAGE1;

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

    // bin, sync
    bin(b, &mode, &target, &.{"version", "stdin", "timer"});

    // bin, async(not availabe in self-hosting compiler)
    if (USE_STAGE1) bin(b, &mode, &target, &.{"async_stdin", "async_timer"});
}
