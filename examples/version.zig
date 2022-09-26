const std = @import("std");
const ev = @import("ev");

pub fn main() !void {
    const major = ev.versionMajor();
    const minor = ev.versionMinor();
    const bk1 = ev.supportedBackends();
    const bk2 = ev.recommendedBackends();
    const bk3 = ev.embeddableBackends();
    std.debug.print("libev: {}.{}\n", .{major, minor});
    std.debug.print("supported: {}\n", .{bk1});
    std.debug.print("recommended: {}\n", .{bk2});
    std.debug.print("embeddable: {}\n", .{bk3});
}
