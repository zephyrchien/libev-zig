const c = @cImport({
    @cInclude("ev.h"); 
});
const flag = @import("flag.zig");
const loop = @import("loop.zig");

const alloc_cb_t = ?*const fn (?*anyopaque, c_long) callconv(.C) ?*anyopaque;
const syserr_cb_t = ?*const fn ([*c]const u8) callconv(.C) void;

pub const Allocator = alloc_cb_t;
pub const ErrHandler = syserr_cb_t;

pub fn versionMajor() c_int {
    return c.ev_version_major();
}

pub fn versionMinor() c_int {
    return c.ev_version_minor();
}

pub fn now(l: loop.Loop) c.ev_tstamp {
    return c.ev_now(l.native());
}

pub fn delay(interval: c.ev_tstamp) void {
    c.ev_sleep(interval);
}

pub fn supportedBackends() loop.Backend {
    return flag.Backend.from_int(c.ev_supported_backends());
}

pub fn recommendedBackends() loop.Backend {
    return flag.Backend.from_int(c.ev_recommended_backends());
}

pub fn embeddableBackends() loop.Backend {
    return flag.Backend.from_int(c.ev_embeddable_backends());
}

pub fn setAllocator(cb: alloc_cb_t) void {
    c.ev_set_allocator(cb);
}

pub fn setSyserrHandler(cb: syserr_cb_t) void {
    c.ev_set_syserr_cb(cb);
}
