const std = @import("std");
const ev = @import("ev");
const Loop = ev.loop.Loop;
const Timer = ev.watcher.Timer;
const Event = ev.watcher.Event;

pub fn main() !void {
    const loop = Loop.default(.{}, .{}).?;
    var timer = Timer.new(loop, 1.0, 0.0);
    var frame = async handle(&timer);
    loop.blockOn(&frame);
}

fn handle(timer: *Timer) callconv(.Async) void {
    await async timer.wait() catch unreachable;
    std.debug.print("1s timeout!\n", .{});
}
