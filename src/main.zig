//! Main program entry point

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

    const doc = litehtml.Document.init(
        \\<!DOCTYPE html>
        \\<body>
        \\  <h1>Hello</h1>
        \\</body>
    , &container.dc, ctx);
    defer doc.deinit();

    _ = doc.render(1024);
    doc.draw(undefined, 0, 0, .{
        .x = 0,
        .y = 0,
        .width = 1024,
        .height = 1024,
    });
}
