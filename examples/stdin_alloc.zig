const std = @import("std");
const ev = @import("ev");
const Loop = ev.loop.Loop;
const Io = ev.watcher.Io;
const Event = ev.watcher.Event;
const alloc = ev.alloc;

fn cb(w: *Io, e: Event) void {
    w.stop();
    std.debug.assert(e.Read);
    std.debug.print("stdin is ready!\n", .{});
}

pub fn main() !void {
    var buf: [1024]u8 = undefined;
    var fba = std.heap.FixedBufferAllocator.init(&buf);
    alloc.setEvAlloc(fba.allocator());

    const loop = Loop.default(.{}, .{}).?;
    var io = Io.new(loop, 0, .{.Read = true});
    io.setCallback(cb);
    io.start();
    loop.run(.{});
}
