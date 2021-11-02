const std = @import("std");
const litehtml = @import("litehtml.zig");
comptime {
    _ = litehtml;
}

pub fn main() !void {
    std.log.info("All your codebase are belong to us.", .{});
}
