// bitset does not compile with stage1

const c = @cImport(@cInclude("ev.h"));

pub const Backend = struct {
    pub const set_t = packed struct {
        Select       :bool = false,
        Poll         :bool = false,
        Epoll        :bool = false,
        Kqueue       :bool = false,
        DevPoll      :bool = false,
        Port         :bool = false,
        LinuxAio     :bool = false,
        IoUring      :bool = false,
        All          :bool = false,
        Mask         :bool = false,
        _padd        :u22  = 0,
    };

    pub const Table = struct {
        pub const Select =       c.EVBACKEND_SELECT;  
        pub const Poll =         c.EVBACKEND_POLL;    
        pub const Epoll =        c.EVBACKEND_EPOLL;   
        pub const Kqueue =       c.EVBACKEND_KQUEUE;  
        pub const DevPoll =      c.EVBACKEND_DEVPOLL; 
        pub const Port =         c.EVBACKEND_PORT;    
        pub const LinuxAio =     c.EVBACKEND_LINUXAIO;
        pub const IoUring =      c.EVBACKEND_IOURING; 
        pub const All =          c.EVBACKEND_ALL;     
        pub const Mask =         c.EVBACKEND_MASK;    
    };

    pub fn from_int(num: c_uint) set_t {
        return set_t {
            .Select = num & Table.Select != 0,  
            .Poll = num & Table.Poll != 0,    
            .Epoll = num & Table.Epoll != 0,   
            .Kqueue = num & Table.Kqueue != 0,  
            .DevPoll = num & Table.DevPoll != 0, 
            .Port = num & Table.Port != 0,    
            .LinuxAio = num & Table.LinuxAio != 0,
            .IoUring = num & Table.IoUring != 0, 
            .All = num & Table.All != 0,     
            .Mask = num & Table.Mask != 0,
        };
    }

    pub fn into_int(set: set_t) c_uint {
        var num: c_uint = 0;
        if(set.Select) num |= Table.Select;       
        if(set.Poll) num |= Table.Poll;         
        if(set.Epoll) num |= Table.Epoll;        
        if(set.Kqueue) num |= Table.Kqueue;       
        if(set.DevPoll) num |= Table.DevPoll;      
        if(set.Port) num |= Table.Port;         
        if(set.LinuxAio) num |= Table.LinuxAio;     
        if(set.IoUring) num |= Table.IoUring;      
        if(set.All) num |= Table.All;          
        if(set.Mask) num |= Table.Mask;       
        return num;  
    }
};

pub const Loop = struct {
    pub const set_t = packed struct {
        Auto         :bool = false,
        NoEnv        :bool = false,
        ForkCheck    :bool = false,
        NoInotify    :bool = false,
        SignalFd     :bool = false,
        NoSigMask    :bool = false,
        NoTimerFd    :bool = false,
        _padd        :u25  = 0,
    };

    pub const Table = struct {
        pub const Auto =          c.EVFLAG_AUTO;
        pub const NoEnv =         c.EVFLAG_NOENV;
        pub const ForkCheck =     c.EVFLAG_FORKCHECK;
        pub const NoInotify =     c.EVFLAG_NOINOTIFY;
        pub const SignalFd =      c.EVFLAG_SIGNALFD;
        pub const NoSigMask =     c.EVFLAG_NOSIGMASK;
        pub const NoTimerFd =     c.EVFLAG_NOTIMERFD;
    };

    pub fn from_int(num: c_uint) set_t {
        return set_t {
            .Auto = num & Table.Auto != 0,
            .NoEnv = num & Table.NoEnv != 0,
            .ForkCheck = num & Table.ForkCheck != 0,
            .NoInotify = num & Table.NoInotify != 0,
            .SignalFd = num & Table.SignalFd != 0,
            .NoSigMask = num & Table.NoSigMask != 0,
            .NoTimerFd = num & Table.NoTimerFd != 0,
        };
    }

    pub fn into_int(set: set_t) c_uint {
        var num: c_uint = 0;
        if(set.Auto) num |= Table.Auto;
        if(set.NoEnv) num |= Table.NoEnv;
        if(set.ForkCheck) num |= Table.ForkCheck;
        if(set.NoInotify) num |= Table.NoInotify;
        if(set.SignalFd) num |= Table.SignalFd;
        if(set.NoSigMask) num |= Table.NoSigMask;
        if(set.NoTimerFd) num |= Table.NoTimerFd;
        return num;  
    }
};

pub const Event = struct {
    pub const set_t = packed struct {
        Undef        :bool = false,
        None         :bool = false,
        Read         :bool = false,
        Write        :bool = false,
        _IoFdSet     :bool = false,
        Io           :bool = false,
        Timer        :bool = false,
        Periodic     :bool = false,
        Signal       :bool = false,
        Child        :bool = false,
        Stat         :bool = false,
        Idle         :bool = false,
        Prepare      :bool = false,
        Check        :bool = false,
        Embed        :bool = false,
        Fork         :bool = false,
        Cleanup      :bool = false,
        Async        :bool = false,
        Custom       :bool = false,
        Error        :bool = false,
        _padd        :u12  = 0,
    };

    pub const Table = struct {
        pub const Undef =         c.EV_UNDEF;
        pub const None =          c.EV_NONE;
        pub const Read =          c.EV_READ;
        pub const Write =         c.EV_WRITE;
        pub const _IoFdSet =      c.EV__IOFDSET;
        pub const Io =            c.EV_IO;
        pub const Timer =         c.EV_TIMER;
        pub const Periodic =      c.EV_PERIODIC;
        pub const Signal =        c.EV_SIGNAL;
        pub const Child =         c.EV_CHILD;
        pub const Stat =          c.EV_STAT;
        pub const Idle =          c.EV_IDLE;
        pub const Prepare =       c.EV_PREPARE;
        pub const Check =         c.EV_CHECK;
        pub const Embed =         c.EV_EMBED;
        pub const Fork =          c.EV_FORK;
        pub const Cleanup =       c.EV_CLEANUP;
        pub const Async =         c.EV_ASYNC;
        pub const Custom =        c.EV_CUSTOM;
        pub const Error =         c.EV_ERROR;
    };

    pub fn from_int(num: c_int) set_t {
        return set_t {
            .Undef = num & Table.Undef != 0,
            .None = num & Table.None != 0,
            .Read = num & Table.Read != 0,
            .Write = num & Table.Write != 0,
            ._IoFdSet = num & Table._IoFdSet != 0,
            .Io = num & Table.Io != 0,
            .Timer = num & Table.Timer != 0,
            .Periodic = num & Table.Periodic != 0,
            .Signal = num & Table.Signal != 0,
            .Child = num & Table.Child != 0,
            .Stat = num & Table.Stat != 0,
            .Idle = num & Table.Idle != 0,
            .Prepare = num & Table.Prepare != 0,
            .Check = num & Table.Check != 0,
            .Embed = num & Table.Embed != 0,
            .Fork = num & Table.Fork != 0,
            .Cleanup = num & Table.Cleanup != 0,
            .Async = num & Table.Async != 0,
            .Custom = num & Table.Custom != 0,
            .Error = num & Table.Error != 0,
        };
    }

    pub fn into_int(set: set_t) c_int {
        var num: c_int = 0;
        if(set.Undef) num |= Table.Undef;
        if(set.None) num |= Table.None;
        if(set.Read) num |= Table.Read;
        if(set.Write) num |= Table.Write;
        if(set._IoFdSet) num |= Table._IoFdSet;
        if(set.Io) num |= Table.Io;
        if(set.Timer) num |= Table.Timer;
        if(set.Periodic) num |= Table.Periodic;
        if(set.Signal) num |= Table.Signal;
        if(set.Child) num |= Table.Child;
        if(set.Stat) num |= Table.Stat;
        if(set.Idle) num |= Table.Idle;
        if(set.Prepare) num |= Table.Prepare;
        if(set.Check) num |= Table.Check;
        if(set.Embed) num |= Table.Embed;
        if(set.Fork) num |= Table.Fork;
        if(set.Cleanup) num |= Table.Cleanup;
        if(set.Async) num |= Table.Async;
        if(set.Custom) num |= Table.Custom;
        if(set.Error) num |= Table.Error;
        return num;  
    }
};


pub const Run = struct {
    pub const set_t = packed struct {
        NoWait         :bool = false,
        Once           :bool = false,
        _padd          :u30  = 0,
    };

    pub const Table = struct {
        pub const NoWait =       c.EVRUN_NOWAIT;
        pub const Once =         c.EVRUN_ONCE;
    };

    pub fn from_int(num: c_int) set_t {
        return set_t {
            .NoWait = num & Table.NoWait != 0,
            .Once = num & Table.Once != 0,
        };
    }

    pub fn into_int(set: set_t) c_int {
        var num: c_int = 0;
        if(set.NoWait) num |= Table.NoWait;
        if(set.Once) num |= Table.Once;
        return num;  
    }
};

pub const Break = struct {
    pub const set_t = packed struct {
        Cancel       :bool = false,
        One          :bool = false,
        All          :bool = false,
        _padd        :u29  = 0,
    };

    pub const Table = struct {
        pub const Cancel =      c.EVBREAK_CANCEL;
        pub const One    =      c.EVBREAK_ONE;
        pub const All    =      c.EVBREAK_ALL;
    };

    pub fn from_int(num: c_int) set_t {
        return set_t {
            .Cancel = num & Table.Cancel != 0,
            .One = num & Table.One != 0,
            .All = num & Table.All != 0,
        };
    }

    pub fn into_int(set: set_t) c_int {
        var num: c_int = 0;
        if(set.Cancel) num |= Table.Cancel;
        if(set.One) num |= Table.One;
        if(set.All) num |= Table.All;
        return num;  
    }
};