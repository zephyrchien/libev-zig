const std = @import("std");
const ev = @import("ev");
const Loop = ev.Loop;
const IoWatcher = ev.IoWatcher;

fn cb(w: *IoWatcher, e: IoWatcher.Event) void {
    w.stop();
    std.debug.assert(e.Read);
    std.debug.print("stdin is ready!\n", .{});
}

pub fn main() !void {
    const loop = Loop.default(.{}, .{}).?;
    var watcher = IoWatcher.new(loop, 0, .{.Read = true});
    watcher.setCallback(cb);
    watcher.start();
    _ = loop.run(.{});
}
