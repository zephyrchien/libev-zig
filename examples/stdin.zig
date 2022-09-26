const std = @import("std");
const ev = @import("ev");
const Loop = ev.loop.Loop;
const Io = ev.watcher.Io;
const Event = ev.watcher.Event;

fn cb(w: *Io, e: Event) void {
    w.stop();
    std.debug.assert(e.Read);
    std.debug.print("stdin is ready!\n", .{});
}

pub fn main() !void {
    const loop = Loop.default(.{}, .{}).?;
    var io = Io.new(loop, 0, .{.Read = true});
    io.setCallback(cb);
    io.start();
    _ = loop.run(.{});
}
