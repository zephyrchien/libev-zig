const builtin = @import("builtin");
const backend = builtin.zig_backend;

const flag_stage1 = @import("flag.stage1.zig");
const flag_stage2 = @import("flag.stage2.zig");

pub usingnamespace if(backend == .stage1) flag_stage1 else flag_stage2;
