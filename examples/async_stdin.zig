const std = @import("std");
const ev = @import("ev");
const Loop = ev.loop.Loop;
const Io = ev.watcher.Io;
const Event = ev.watcher.Event;

pub fn main() !void {
    const loop = Loop.default(.{}, .{}).?;
    var io = Io.new(loop, 0, .{.Read = true});
    var frame = async handle(&io);
    loop.blockOn(&frame);
}

fn handle(io: *Io) callconv(.Async) void {
    await async io.wait();
    std.debug.print("stdin is ready!\n", .{});
}
