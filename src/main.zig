const std = @import("std");
const litehtml = @import("litehtml.zig");
const Container = @import("Container.zig");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = &gpa.allocator;

    const ctx = litehtml.Context.init();
    defer ctx.deinit();
    ctx.loadMasterStylesheet(@embedFile("master.css"));

    var container = Container.init(allocator);
    defer container.deinit();

    const doc = litehtml.Document.init("<h1>Hello</h1>", &container.dc, ctx);
    defer doc.deinit();
}
