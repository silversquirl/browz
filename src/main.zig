const std = @import("std");
const litehtml = @import("litehtml.zig");
const Container = @import("Container.zig");

pub fn main() !void {
    const ctx = litehtml.Context.init();
    ctx.loadMasterStylesheet(@embedFile("master.css"));
    var container = Container{};
    const doc = litehtml.Document.init("<h1>Hello</h1>", &container.dc, ctx);
    defer doc.deinit();
}
