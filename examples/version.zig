const std = @import("std");
const ev = @import("ev");

pub fn main() !void {
    const major = ev.versionMajor();
    const minor = ev.versionMinor();
    std.debug.print("libev: {}.{}\n", .{major, minor});
}
