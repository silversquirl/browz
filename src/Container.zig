//! This file contains browz's implementation of the litehtml DocumentContainer interface

const std = @import("std");
const c = @import("c.zig");
const litehtml = @import("litehtml.zig");
const HandleStore = @import("handle_store.zig").HandleStore;

const log = std.log.scoped(.container);

dc: litehtml.DocumentContainer = blk: {
    var dc: litehtml.DocumentContainer = undefined;
    for (std.meta.fieldNames(litehtml.DocumentContainer)) |name| {
        @field(dc, name) = @field(Container, name);
    }
    break :blk dc;
},

allocator: std.mem.Allocator,
win: *c.SDL_Window,
ren: *c.SDL_Renderer,
font_store: HandleStore(usize, Font) = .{},
default_font_size: c_int = 14,
default_font_name: [:0]const u8 = "sans-serif",

const Font = *c.TTF_Font;

const Container = @This();

pub fn init(allocator: std.mem.Allocator, win: *c.SDL_Window) Container {
    return .{
        .allocator = allocator,
        .win = win,
        .ren = c.SDL_CreateRenderer(win, -1, 0) orelse {
            @panic(std.mem.span(c.SDL_GetError()));
        },
    };
}
pub fn deinit(self: *Container) void {
    self.font_store.deinit(self.allocator);
}

fn createFont(
    dc: *litehtml.DocumentContainer,
    face_name: [:0]const u8,
    size: c_int,
    weight: c_int,
    italic: bool,
    decoration: litehtml.FontDecoration,
    metrics: *litehtml.FontMetrics,
) usize {
    const self = @fieldParentPtr(Container, "dc", dc);

    const font = c.TTF_OpenFont("/usr/share/fonts/TTF/FreeSans.ttf", size) orelse {
        std.debug.panic("Failed to load font: {s}", .{std.mem.span(c.TTF_GetError())});
    };
    var style: c_int = 0;
    if (weight >= 700) {
        style |= c.TTF_STYLE_BOLD;
    }
    if (italic) {
        style |= c.TTF_STYLE_ITALIC;
    }
    if (decoration.underline) {
        style |= c.TTF_STYLE_UNDERLINE;
    }
    if (decoration.linethrough) {
        style |= c.TTF_STYLE_STRIKETHROUGH;
    }
    if (style != 0) {
        c.TTF_SetFontStyle(font, style);
    }

    metrics.* = .{
        .height = 0,
        .ascent = 0,
        .descent = 0,
        .x_height = 0,
        .draw_spaces = true,
    };
    metrics.ascent = c.TTF_FontAscent(font);
    metrics.descent = c.TTF_FontDescent(font);
    metrics.height = c.TTF_FontLineSkip(font);
    metrics.x_height = c.TTF_FontHeight(font);

    const handle = self.font_store.add(self.allocator, font) catch {
        @panic("Out of memory");
    };
    log.debug("Loaded font : name='{'}', size={}, weight={}, italic={}, decoration=[{}]", .{
        std.zig.fmtEscapes(face_name), size, weight, italic, decoration,
    });
    return handle;
}

fn deleteFont(dc: *litehtml.DocumentContainer, font_handle: usize) void {
    const self = @fieldParentPtr(Container, "dc", dc);
    const font = self.font_store.del(font_handle);
    c.TTF_CloseFont(font);
    log.debug("Deleted font {}", .{font_handle});
}

fn textWidth(
    dc: *litehtml.DocumentContainer,
    text: [:0]const u8,
    font_handle: usize,
) c_int {
    const self = @fieldParentPtr(Container, "dc", dc);
    const font = self.font_store.get(font_handle);

    var w: c_int = undefined;
    if (c.TTF_SizeUTF8(font, text.ptr, &w, null) != 0) {
        std.debug.panic("Could not render text: {s}", .{std.mem.span(c.TTF_GetError())});
    }
    return w;
}

fn drawText(
    dc: *litehtml.DocumentContainer,
    _: usize,
    text: [:0]const u8,
    font_handle: usize,
    color: litehtml.WebColor,
    pos: litehtml.Position,
) void {
    const self = @fieldParentPtr(Container, "dc", dc);
    const font = self.font_store.get(font_handle);

    const surf = c.TTF_RenderUTF8_Blended(font, text.ptr, .{
        .r = color.red,
        .g = color.green,
        .b = color.blue,
        .a = color.alpha,
    });
    const tex = c.SDL_CreateTextureFromSurface(self.ren, surf);

    _ = c.SDL_RenderCopy(self.ren, tex, null, &.{
        .x = pos.x,
        .y = pos.y,
        .w = pos.width,
        .h = pos.height,
    });
}

fn ptToPx(dc: *litehtml.DocumentContainer, pt: c_int) c_int {
    // TODO
    _ = dc;
    return @divTrunc(pt * 96, 72);
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
    _: usize,
    bg: *const litehtml.BackgroundPaint,
) void {
    const self = @fieldParentPtr(Container, "dc", dc);
    _ = c.SDL_SetRenderDrawColor(self.ren, bg.color.red, bg.color.green, bg.color.blue, bg.color.alpha);
    if (bg.is_root) {
        _ = c.SDL_RenderClear(self.ren);
    } else {
        _ = c.SDL_RenderFillRect(self.ren, &.{
            .x = bg.clip_box.x,
            .y = bg.clip_box.y,
            .w = bg.clip_box.width,
            .h = bg.clip_box.height,
        });
    }
}

fn drawBorders(
    dc: *litehtml.DocumentContainer,
    hdc: usize,
    borders: *const litehtml.Borders,
    draw_pos: litehtml.Position,
    root: bool,
) void {
    _ = &.{ dc, hdc, borders, draw_pos, root };
    // unreachable;
}

fn getMediaFeatures(dc: *litehtml.DocumentContainer) litehtml.MediaFeatures {
    const self = @fieldParentPtr(Container, "dc", dc);

    const idx = c.SDL_GetWindowDisplayIndex(self.win);
    var mode: c.SDL_DisplayMode = undefined;
    _ = c.SDL_GetDisplayMode(idx, 0, &mode);

    var media = litehtml.MediaFeatures{
        .type = .screen,
        .width = undefined,
        .height = undefined,
        .device_width = mode.w,
        .device_height = mode.h,
        .color = @intCast(c_int, c.SDL_BITSPERPIXEL(mode.format)),
    };

    c.SDL_GetWindowSize(self.win, &media.width, &media.height);

    return media;
}
