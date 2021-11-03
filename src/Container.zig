const std = @import("std");
const litehtml = @import("litehtml.zig");

dc: litehtml.DocumentContainer = doc_container,

default_font_size: c_int = 14,
default_font_name: [:0]const u8 = "sans-serif",

const Container = @This();

const doc_container = blk: {
    var dc: litehtml.DocumentContainer = undefined;
    for (std.meta.fieldNames(litehtml.DocumentContainer)) |name| {
        @field(dc, name) = @field(Container, name);
    }
    break :blk dc;
};

fn createFont(
    dc: *litehtml.DocumentContainer,
    face_name: [:0]const u8,
    size: c_int,
    weight: c_int,
    italic: bool,
    decoration: litehtml.FontDecoration,
    metrics: *litehtml.FontMetrics,
) usize {
    _ = &.{ dc, face_name, size, weight, italic, decoration, metrics };
    unreachable;
}

fn deleteFont(dc: *litehtml.DocumentContainer, font_handle: usize) void {
    _ = &.{ dc, font_handle };
    unreachable;
}

fn textWidth(
    dc: *litehtml.DocumentContainer,
    text: [:0]const u8,
    font_handle: usize,
) c_int {
    _ = &.{ dc, text, font_handle };
    unreachable;
}

fn drawText(
    dc: *litehtml.DocumentContainer,
    hdc: usize,
    text: [:0]const u8,
    font_handle: usize,
    color: litehtml.WebColor,
    pos: litehtml.Position,
) void {
    _ = &.{ dc, hdc, text, font_handle, color, pos };
    unreachable;
}

fn ptToPx(dc: *litehtml.DocumentContainer, pt: c_int) c_int {
    _ = &.{ dc, pt };
    unreachable;
}
fn getDefaultFontSize(dc: *litehtml.DocumentContainer) c_int {
    const self = @fieldParentPtr(Container, "dc", dc);
    return self.default_font_size;
}
fn getDefaultFontName(dc: *litehtml.DocumentContainer) [:0]const u8 {
    const self = @fieldParentPtr(Container, "dc", dc);
    return self.default_font_name;
}

fn loadImage(
    dc: *litehtml.DocumentContainer,
    src: [:0]const u8,
    base_url: [:0]const u8,
    redraw_on_ready: bool,
) void {
    _ = &.{ dc, src, base_url, redraw_on_ready };
    unreachable;
}

fn getImageSize(
    dc: *litehtml.DocumentContainer,
    src: [:0]const u8,
    base_url: [:0]const u8,
) litehtml.Size {
    _ = &.{ dc, src, base_url };
    unreachable;
}

fn drawListMarker(
    dc: *litehtml.DocumentContainer,
    hdc: usize,
    marker: *const litehtml.ListMarker,
) void {
    _ = &.{ dc, hdc, marker };
    unreachable;
}

fn drawBackground(
    dc: *litehtml.DocumentContainer,
    hdc: usize,
    bg: *const litehtml.BackgroundPaint,
) void {
    _ = &.{ dc, hdc, bg };
    unreachable;
}

fn drawBorders(
    dc: *litehtml.DocumentContainer,
    hdc: usize,
    borders: *const litehtml.Borders,
    draw_pos: litehtml.Position,
    root: bool,
) void {
    _ = &.{ dc, hdc, borders, draw_pos, root };
    unreachable;
}
