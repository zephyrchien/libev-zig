const std = @import("std");
const c = @cImport({
    @cInclude("string.h");
    @cInclude("ev.h"); 
});

const Loop = @import("loop.zig").Loop;

const flag = @import("flag.zig");
pub const Event = flag.Event.set_t;

pub const Io = makeWatcher(c.struct_ev_io);
pub const Timer = makeWatcher(c.struct_ev_timer);

fn makeWatcher(comptime T: type) type {
const NameSpace = struct {
const Helper = struct {
    const cb_t = *const fn(*Watcher, Event) void;
    const native_cb_t = ?*const fn (
        ?*c.struct_ev_loop, ?*T, c_int
    ) callconv(.C) void;

    fn makecb(comptime cb: cb_t) native_cb_t {
        const F =  struct {
            fn callback(
                _: ?*c.struct_ev_loop,
                watcher: ?*T,
                events: c_int
            ) callconv(.C) void {
                const w = @ptrCast(*Watcher, watcher);
                const e = flag.Event.from_int(events);
                cb(w, e);
            }
        };
        return F.callback;
    }

    fn init(handle: *T) void {
        @ptrCast(*c.ev_watcher, handle).active = 0;
        @ptrCast(*c.ev_watcher, handle).pending = 0;
        @ptrCast(*c.ev_watcher, handle).priority = 0;
    }

    fn spec() type {
        return switch (T) {
            c.struct_ev_io => Spec.IoSpec,
            c.struct_ev_timer => Spec.TimerSpec,
            else => @compileError("bad type: " ++ @typeName(T)),
        };
    }

    fn freezeOn(w: *Watcher) void {
        if (w.isActive()) w.stop();
    }

    fn freezeOff(w: *Watcher) void {
        if (w.isActive()) w.start();
    }
};

// spec
const Spec = struct {
const IoSpec = struct {
    pub fn new(loop: Loop, fd: c_int, comptime f: Event) Watcher {
        const hint = comptime flag.Event.into_int(f) | flag.Event.Table._IoFdSet;
        var handle: T = undefined;
        Helper.init(&handle);

        handle.fd = fd;
        handle.events = hint;
        return Watcher {
            .loop = loop.native(),
            .handle = handle,
        };
    }

    pub fn set(self: *Watcher, fd: c_int, f: Event) void {
        Helper.freezeOn(self);
        defer Helper.freezeOff(self);

        const hint = flag.Event.into_int(f) | flag.Event.Table._IoFdSet;
        self.fd = fd;
        self.events = hint;
    }

    pub fn modify(self: *Watcher, f: Event) void {
        Helper.freezeOn(self);
        defer Helper.freezeOff(self);

        const hint = self.events & flag.Event.Table._IoFdSet | flag.Event.into_int(f);
        self.events = hint; 
    }
};
const TimerSpec = struct {
    pub fn new(loop: Loop, after: c.ev_tstamp, repeat: c.ev_tstamp) Watcher {
        var handle: T = undefined;
        Helper.init(&handle);
    
        handle.at = after;
        handle.repeat = repeat;
        return Watcher {
            .loop = loop.native(),
            .handle = handle,
        };
    }

    pub fn set(self: *Watcher, after: c.ev_tstamp, repeat: c.ev_tstamp) void {
        Helper.freezeOn(self);
        defer Helper.freezeOff(self);

        self.at = after;
        self.repeat = repeat;
    }

    pub fn again(self: *Watcher) void {
        c.ev_timer_again(self.asSpecWatcher());
    }

    pub fn remaining(self: *Watcher) c.ev_tstamp {
        return c.ev_timer_remaining(self.loop, self.asSpecWatcher());
    }
};
};

// generic
const Watcher = extern struct {
    // field
    handle: T,
    loop: *c.struct_ev_loop,

    // typedef
    pub const Callback = Helper.cb_t;

    // spec
    pub usingnamespace Helper.spec();

    // method
    const Self = @This();
    pub fn asWatcher(self: *Self) *c.struct_ev_watcher {
        return @ptrCast(*c.struct_ev_watcher, self);
    }

    pub fn asConstWatcher(self: *const Self) *const c.struct_ev_watcher {
        return @ptrCast(*const c.struct_ev_watcher, self);
    }

    pub fn asSpecWatcher(self: *Self) *T {
        return @ptrCast(*T, self);
    }

    pub fn asConstSpecWatcher(self: *const Self) *const T {
        return @ptrCast(*const T, self);
    }

    pub fn userData(self: *const Self) ?*anyopaque {
        return self.handle.data;
    }

    pub fn setUserData(self: *Self, data: ?*anyopaque) void {
        self.handle.data = data;
    }

    pub fn setCallback(self: *Self, comptime cb: Callback) void {
        const native_cb = comptime Helper.makecb(cb);
        self.handle.cb = native_cb;
        // memmove is used here to avoid strict aliasing violations
        _ = c.memmove(
        &(self.asWatcher().cb),
        &self.handle.cb,
        @sizeOf(@TypeOf(self.handle.cb)));
    }

    pub fn start(self: *Self) void {
        const l = self.loop;
        const ptr = self.asSpecWatcher();
        switch (T) {
            c.struct_ev_io => c.ev_io_start(l, ptr),
            c.struct_ev_timer => c.ev_timer_start(l, ptr),
            c.struct_ev_periodic => c.ev_periodic_start(l, ptr),
            c.struct_ev_signal => c.ev_signal_start(l, ptr),
            c.struct_ev_child => c.ev_child_start(l, ptr),
            c.struct_ev_stat => c.ev_stat_start(l, ptr),
            c.struct_ev_idle => c.ev_idle_start(l, ptr),
            c.struct_ev_prepare => c.ev_prepare_start(l, ptr),
            c.struct_ev_check => c.ev_check_start(l, ptr),
            c.struct_ev_embed => c.ev_embed_start(l, ptr),
            c.struct_ev_fork => c.ev_fork_start(l, ptr),
            c.struct_ev_async => c.ev_async_start(l, ptr),
            else => @compileError("bad type: " ++ @typeName(T)),
        }
    }

    pub fn stop(self: *Self) void {
        const l = self.loop;
        const ptr = self.asSpecWatcher();
        switch (T) {
            c.struct_ev_io => c.ev_io_stop(l, ptr),
            c.struct_ev_timer => c.ev_timer_stop(l, ptr),
            c.struct_ev_periodic => c.ev_periodic_stop(l, ptr),
            c.struct_ev_signal => c.ev_signal_stop(l, ptr),
            c.struct_ev_child => c.ev_child_stop(l, ptr),
            c.struct_ev_stat => c.ev_stat_stop(l, ptr),
            c.struct_ev_idle => c.ev_idle_stop(l, ptr),
            c.struct_ev_prepare => c.ev_prepare_stop(l, ptr),
            c.struct_ev_check => c.ev_check_stop(l, ptr),
            c.struct_ev_embed => c.ev_embed_stop(l, ptr),
            c.struct_ev_fork => c.ev_fork_stop(l, ptr),
            c.struct_ev_async => c.ev_async_stop(l, ptr),
            else => @compileError("bad type: " ++ @typeName(T)),
        }
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
};
return NameSpace.Watcher;
}
