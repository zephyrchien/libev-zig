const c = @cImport(@cInclude("ev.h"));
const std = @import("std");
const flag = @import("flag.zig");

pub const Flag = flag.Loop.set_t;
pub const Backend = flag.Backend.set_t;
pub const Run = flag.Run.set_t;
pub const Break = flag.Break.set_t;

pub const Loop = struct {
    // field
    loop: *c.struct_ev_loop,
    
    // method
    const Self = @This();
    pub fn native(self: Self) *c.struct_ev_loop {
        return self.loop;
    }

    pub fn default(comptime b: Backend, comptime f: Flag) ?Self {
        const hint = comptime blk:{
            const hint_b = flag.Backend.into_int(b);
            const hint_f = flag.Loop.into_int(f);
            break :blk hint_b | hint_f;
        };

        if (c.ev_default_loop(hint)) |loop| {
            return . { .loop = loop };
        } else {
            return null;
        }
    }

    pub fn new(comptime b: Backend, comptime f: Flag) ?Self {
        const hint = comptime blk:{
            const hint_b = flag.Backend.into_int(b);
            const hint_f = flag.Loop.into_int(f);
            break :blk hint_b | hint_f;
        };

        if (c.ev_loop_new(hint)) |loop| {
            return . { .loop = loop };
        } else {
            return null;
        }
    }

    pub fn run(self: Self, comptime f: Run) bool {
        const hint = comptime flag.Run.into_int(f);
        return c.ev_run(self.loop, hint) != 0;
    }

    pub fn stop(self: Self, comptime f: Break) void {
        const hint = comptime flag.Break.into_int(f);
        c.ev_break(self.loop, hint);
    }

    pub fn blockOn(self: Self, comptime f: anyframe->void) void {
        self.run(.{});
        nosuspend await f;
    }

    pub fn destroy(self: Self) void {
        c.ev_loop_destroy(self.loop);
    }

    pub fn fork(self: Self) void {
        c.ev_loop_fork(self.loop);
    }

    pub fn isDefault(self: Self) bool {
        return c.ev_is_default_loop(self.loop) != 0;
    }

    pub fn iteration(self: Self) usize {
        return c.ev_iteration(self.loop);
    }

    pub fn depth(self: Self) usize {
        return c.ev_depth(self.loop);
    }

    pub fn backend(self: Self) Backend {
        return flag.Backend.from_int(c.ev_backend(self.loop));
    }

    // TODO
    pub fn now(self: Self) c.ev_tstamp {
        return c.ev_now(self.loop);
    }

    pub fn nowUpdate(self: Self) void {
        c.ev_now_update(self.loop);
    }

    pub fn suspendLoop(self: Self) void {
        c.ev_suspend(self.loop);
    }

    pub fn resumeLoop(self: Self) void {
        c.ev_resume(self.loop);
    }

    pub fn ref(self: Self) void {
        c.ev_ref(self.loop);
    }

    pub fn unref(self: Self) void {
        c.ev_unref(self.loop);
    }

    // TODO
    pub fn setIoCollectInterval(self: Self, intv: c.ev_tstamp) void {
        c.ev_set_io_collect_interval(self.loop, intv);
    }

    // TODO
    pub fn setTimeoutCollectInterval(self: Self, intv: c.ev_tstamp) void {
        c.ev_set_timeout_collect_interval(self.loop, intv);
    }

    pub fn invokePending(self: Self) void {
        c.ev_invoke_pending(self.loop);
    }

    pub fn pendingCount(self: Self) usize {
        return c.ev_pending_count(self.loop);
    }

    // TODO
    // ev_set_invoke_pending_cb
    // ev_set_loop_release_cb

    pub fn setUserData(self: Self, data: *anyopaque) void {
        c.ev_set_userdata(self.loop, data);
    }

    pub fn userData(self: Self) ?*anyopaque {
        return c.ev_userdata(self.loop);
    }

    pub fn verify(self: Self) void {
        c.ev_verify(self.loop);
    }
};
