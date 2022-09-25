const std = @import("std");
const ev = @import("ev");
const Loop = ev.Loop;
const Watcher = ev.Watcher;

fn cb(w: *Watcher, e: Watcher.Event) void {
    w.stop();
    std.debug.assert(e.Read);
    std.debug.print("stdin is ready!\n", .{});
}

pub fn main() !void {
    const loop = Loop.default(.{}, .{}).?;
    var watcher = Watcher.new(loop, 0, .{.Read = true});
    watcher.setCallback(cb);
    watcher.start();
    _ = loop.run(.{});
}
