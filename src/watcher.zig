const std = @import("std");
const c = @cImport({
    @cInclude("string.h");
    @cInclude("ev.h"); 
});

const flag = @import("flag.zig");
const Loop = @import("loop.zig").Loop;

pub const Watcher = extern struct {
    // field
    handle: c.struct_ev_io,
    loop: *c.struct_ev_loop,

    // typedef
    pub const Event = flag.Event.set_t;
    pub const Callback = cb_t;

    // callback helper
    const cb_t = *const fn(*Watcher, Event) void;
    const native_cb_t = ?*const fn (
        ?*c.struct_ev_loop, ?*c.struct_ev_io, c_int
    ) callconv(.C) void;

    fn makecb(comptime cb: cb_t) native_cb_t {
        const F =  struct {
            fn callback(
                _: ?*c.struct_ev_loop,
                watcher: ?*c.struct_ev_io,
                events: c_int
            ) callconv(.C) void {
                const w = @ptrCast(*Watcher, watcher);
                const e = flag.Event.from_int(events);
                cb(w, e);
            }
        };
        return F.callback;
    }


    // method
    const Self = @This();
    pub fn new(loop: Loop, fd: c_int, comptime f: Event) Self {
        const hint = comptime flag.Event.into_int(f) | flag.Event.Table._IoFdSet;

        var handle: c.struct_ev_io = undefined;
        @ptrCast(*c.ev_watcher, &handle).active = 0;
        @ptrCast(*c.ev_watcher, &handle).pending = 0;
        @ptrCast(*c.ev_watcher, &handle).priority = 0;
        handle.fd = fd;
        handle.events = hint;

        return Self {
            .loop = loop.native(),
            .handle = handle,
        };
    }

    pub fn asWatcher(self: *Self) *c.struct_ev_watcher {
        return @ptrCast(*c.struct_ev_watcher, self);
    }

    pub fn asConstWatcher(self: *const Self) *const c.struct_ev_watcher {
        return @ptrCast(*const c.struct_ev_watcher, self);
    }

    pub fn userData(self: *const Self) ?*anyopaque {
        return self.handle.data;
    }

    pub fn setUserData(self: *Self, data: ?*anyopaque) void {
        self.handle.data = data;
    }

    pub fn setCallback(self: *Self, comptime cb: Callback) void {
        const native_cb = comptime makecb(cb);
        self.handle.cb = native_cb;
        // memmove is used here to avoid strict aliasing violations
        _ = c.memmove(
        &(self.asWatcher().cb),
        &self.handle.cb,
        @sizeOf(@TypeOf(self.handle.cb)));
    }

    pub fn start(self: *Self) void {
        c.ev_io_start(self.loop, @ptrCast(*c.struct_ev_io, self));
    }

    pub fn stop(self: *Self) void {
        c.ev_io_stop(self.loop, @ptrCast(*c.struct_ev_io, self));
    }

    pub fn isActive(self: *const Self) bool {
        return self.asConstWatcher().active;
    }

    pub fn isPending(self: *const Self) bool {
        return self.asConstWatcher().pending;
    }

    pub fn feedEvent(self: *Self, f: Event) void {
        const hint = flag.Event.into_int(f);
        c.ev_feed_event(self.loop, self.asWatcher(), hint);
    }
};
