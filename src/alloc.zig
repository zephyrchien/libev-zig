const std = @import("std");
const c = @cImport(@cInclude("ev.h"));
const Allocator = std.mem.Allocator;


var EV_ALLOC: ?Allocator = null;

var CORO_ALLOC: Allocator = std.heap.c_allocator;

pub fn setEvAlloc(alloc: Allocator) void {
    EV_ALLOC = alloc;
    c.ev_set_allocator(Helper.alloc_cb);
}

pub fn getEvAlloc() Allocator {
    return EV_ALLOC.?;
}

pub fn setCoroAlloc(alloc: Allocator) void {
    CORO_ALLOC = alloc;
}

pub fn getCoroAlloc() Allocator {
    return CORO_ALLOC;
}

const Helper = struct {
    const alloc_cb_t = fn (?*anyopaque, c_long) callconv(.C) ?*anyopaque;
    fn alloc_cb(ptr: ?*anyopaque, size: c_long) callconv(.C) ?*anyopaque {
        const mem = getEvAlloc();
        const new_size = @intCast(usize, size) + @sizeOf(usize);
        // allocate [size + memory]
        if (ptr == null) {
            const new_slice = mem.alignedAlloc(u8, @sizeOf(usize), new_size) catch return null;
            @ptrCast(*usize, new_slice.ptr).* = new_size;
            return @intToPtr(*u8, @ptrToInt(new_slice.ptr) + @sizeOf(usize));
        }
        const head_ptr = @intToPtr([*]u8, @ptrToInt(ptr) - @sizeOf(usize));
        const size_ptr = @ptrCast(*usize, @alignCast(@sizeOf(usize), head_ptr));
        const old_size = size_ptr.*;
        // free
        if (size == 0) {
            mem.free(head_ptr[0..old_size]);
            return null;
        }
        // resize
        const new_slice = mem.reallocAdvanced(
            head_ptr[0..old_size],
            @sizeOf(usize), new_size, .exact) catch return null;
        @ptrCast(*usize, new_slice.ptr).* = new_size;
        return @intToPtr(*u8, @ptrToInt(new_slice.ptr) + @sizeOf(usize));
    }
};
