const std = @import("std");
const ev = @import("ev");
const Loop = ev.loop.Loop;
const Timer = ev.watcher.Timer;
const Event = ev.watcher.Event;

fn cb(w: *Timer, e: Event) void {
    w.stop();
    std.debug.assert(e.Timer);
    std.debug.print("1s timeout!\n", .{});
}

pub fn main() !void {
    const loop = Loop.default(.{}, .{}).?;
    var timer = Timer.new(loop, 1.0, 0.0);
    timer.setCallback(cb);
    timer.start();
    _ = loop.run(.{});
}
