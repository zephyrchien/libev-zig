const c = @cImport(@cInclude("ev.h"));
const bitset = @import("bitset");

pub const Backend = bitset.make(.{
    .{ "Select",       c.EVBACKEND_SELECT,      },
    .{ "Poll",         c.EVBACKEND_POLL,        },
    .{ "Epoll",        c.EVBACKEND_EPOLL,       },
    .{ "Kqueue",       c.EVBACKEND_KQUEUE,      },
    .{ "DevPoll",      c.EVBACKEND_DEVPOLL,     },
    .{ "Port",         c.EVBACKEND_PORT,        },
    .{ "LinuxAio",     c.EVBACKEND_LINUXAIO,    },
    .{ "IoUring",      c.EVBACKEND_IOURING,     },
    .{ "All",          c.EVBACKEND_ALL,         },
    .{ "Mask",         c.EVBACKEND_MASK,        },
}, c_uint);

pub const Loop = bitset.make(.{
    .{ "Auto",         c.EVFLAG_AUTO,           },
    .{ "NoEnv",        c.EVFLAG_NOENV,          },
    .{ "ForkCheck",    c.EVFLAG_FORKCHECK,      },
    .{ "NoInotify",    c.EVFLAG_NOINOTIFY,      },
    .{ "SignalFd",     c.EVFLAG_SIGNALFD,       },
    .{ "NoSigMask",    c.EVFLAG_NOSIGMASK,      },
    .{ "NoTimerFd",    c.EVFLAG_NOTIMERFD,      },
}, c_uint);

pub const Event = bitset.make(.{
    .{ "Undef",        c.EV_UNDEF,              },
    .{ "None",         c.EV_NONE,               },
    .{ "Read",         c.EV_READ,               },
    .{ "Write",        c.EV_WRITE,              },
    .{ "_IoFdSet",     c.EV__IOFDSET,           },
    .{ "Io",           c.EV_IO,                 },  
    .{ "Timer",        c.EV_TIMER,              },
    .{ "Periodic",     c.EV_PERIODIC,           },
    .{ "Signal",       c.EV_SIGNAL,             },
    .{ "Child",        c.EV_CHILD,              },
    .{ "Stat",         c.EV_STAT,               },
    .{ "Idle",         c.EV_IDLE,               },
    .{ "Prepare",      c.EV_PREPARE,            },
    .{ "Check",        c.EV_CHECK,              },
    .{ "Embed",        c.EV_EMBED,              },
    .{ "Fork",         c.EV_FORK,               },
    .{ "Cleanup",      c.EV_CLEANUP,            },
    .{ "Async",        c.EV_ASYNC,              },
    .{ "Custom",       c.EV_CUSTOM,             },
    .{ "Error",        c.EV_ERROR,              },
}, c_int);

pub const Run = bitset.make(.{
    .{ "NoWait",       c.EVRUN_NOWAIT,          },
    .{ "Once",         c.EVRUN_ONCE,            },
}, c_int);

pub const Break = bitset.make(.{
    .{ "Cancel",       c.EVBREAK_CANCEL,        },
    .{ "One",          c.EVBREAK_ONE,           },
    .{ "All",          c.EVBREAK_ALL,           },
}, c_int);
