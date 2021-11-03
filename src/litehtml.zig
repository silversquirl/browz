const std = @import("std");
const c = @cImport({
    @cInclude("litehtml_wrapper.h");
});

pub const FontMetrics = extern struct {
    height: c_int,
    ascent: c_int,
    descent: c_int,
    x_height: c_int,
    draw_spaces: bool,
};

pub const FontDecoration = packed struct {
    underline: bool = false,
    linethrough: bool = false,
    overline: bool = false,
    _pad_0: u1 = 0,
    _pad_1: u4 = 0,

    comptime {
        std.debug.assert(@sizeOf(FontDecoration) == @sizeOf(u8));
        std.debug.assert(@bitCast(u8, FontDecoration{ .underline = true }) == 0x01);
        std.debug.assert(@bitCast(u8, FontDecoration{ .linethrough = true }) == 0x02);
        std.debug.assert(@bitCast(u8, FontDecoration{ .overline = true }) == 0x04);
    }
};

pub const WebColor = extern struct {
    blue: u8,
    green: u8,
    red: u8,
    alpha: u8,
};

pub const Position = extern struct {
    x: c_int,
    y: c_int,
    width: c_int,
    height: c_int,
};

pub const Size = extern struct {
    width: c_int,
    height: c_int,
};

pub const ListMarker = extern struct {
    image_len: usize,
    image: [*:0]const u8,
    baseurl: [*:0]const u8,
    marker_type: ListStyleType,
    color: WebColor,
    pos: Position,
    index: c_int,
    font: usize,
};
pub const ListStyleType = enum(c_int) {
    none,
    circle,
    disc,
    square,
    armenian,
    cjk_ideographic,
    decimal,
    decimal_leading_zero,
    georgian,
    hebrew,
    hiragana,
    hiragana_iroha,
    katakana,
    katakana_iroha,
    lower_alpha,
    lower_greek,
    lower_latin,
    lower_roman,
    upper_alpha,
    upper_latin,
    upper_roman,
};

pub const Borders = extern struct {
    left: Border,
    top: Border,
    right: Border,
    bottom: Border,
    radius: BorderRadiuses,
};
pub const Border = extern struct {
    width: c_int,
    style: BorderStyle,
    color: WebColor,
};
pub const BorderStyle = enum(c_int) {
    none,
    hidden,
    dotted,
    dashed,
    solid,
    double,
    groove,
    ridge,
    inset,
    outset,
};
pub const BorderRadiuses = extern struct {
    top_left_x: c_int,
    top_left_y: c_int,

    top_right_x: c_int,
    top_right_y: c_int,

    bottom_right_x: c_int,
    bottom_right_y: c_int,

    bottom_left_x: c_int,
    bottom_left_y: c_int,
};

pub const BackgroundPaint = extern struct {
    image_len: usize,
    image: [*:0]const u8,
    baseurl_len: usize,
    baseurl: [*:0]const u8,
    attachment: BackgroundAttachment,
    repeat: BackgroundRepeat,
    color: WebColor,
    clip_box: Position,
    origin_box: Position,
    border_box: Position,
    border_radius: BorderRadiuses,
    image_size: Size,
    position_x: c_int,
    position_y: c_int,
    is_root: bool,
};
pub const BackgroundAttachment = enum(c_int) {
    scroll,
    fixed,
};
pub const BackgroundRepeat = enum(c_int) {
    repeat,
    repeat_x,
    repeat_y,
    no_repeat,
};

pub const DocumentContainer = struct {
    createFont: fn (
        *DocumentContainer,
        face_name: [:0]const u8,
        size: c_int,
        weight: c_int,
        italic: bool,
        decoration: FontDecoration,
        metrics: *FontMetrics,
    ) usize,
    deleteFont: fn (*DocumentContainer, font_handle: usize) void,
    textWidth: fn (
        *DocumentContainer,
        text: [:0]const u8,
        font_handle: usize,
    ) c_int,
    drawText: fn (
        *DocumentContainer,
        hdc: usize,
        text: [:0]const u8,
        font_handle: usize,
        color: WebColor,
        pos: Position,
    ) void,

    ptToPx: fn (*DocumentContainer, pt: c_int) c_int,
    getDefaultFontSize: fn (*DocumentContainer) c_int,
    getDefaultFontName: fn (*DocumentContainer) [:0]const u8,

    loadImage: fn (
        *DocumentContainer,
        src: [:0]const u8,
        base_url: [:0]const u8,
        redraw_on_ready: bool,
    ) void,
    getImageSize: fn (
        *DocumentContainer,
        src: [:0]const u8,
        base_url: [:0]const u8,
    ) Size,

    drawListMarker: fn (
        *DocumentContainer,
        hdc: usize,
        marker: *const ListMarker,
    ) void,
    drawBackground: fn (
        *DocumentContainer,
        hdc: usize,
        bg: *const BackgroundPaint,
    ) void,
    drawBorders: fn (
        *DocumentContainer,
        hdc: usize,
        borders: *const Borders,
        draw_pos: Position,
        root: bool,
    ) void,

    export fn dcCreateFont(
        dc: *DocumentContainer,
        face_name: [*:0]const u8,
        size: c_int,
        weight: c_int,
        italic: bool,
        decoration: u8,
        metrics: *FontMetrics,
    ) usize {
        return dc.createFont(
            dc,
            std.mem.span(face_name),
            size,
            weight,
            italic,
            @bitCast(FontDecoration, decoration),
            metrics,
        );
    }
    export fn dcDeleteFont(dc: *DocumentContainer, font_handle: usize) void {
        dc.deleteFont(dc, font_handle);
    }
    export fn dcTextWidth(
        dc: *DocumentContainer,
        text: [*:0]const u8,
        font_handle: usize,
    ) c_int {
        return dc.textWidth(dc, std.mem.span(text), font_handle);
    }
    export fn dcDrawText(
        dc: *DocumentContainer,
        hdc: usize,
        text: [*:0]const u8,
        font_handle: usize,
        color: WebColor,
        pos: Position,
    ) void {
        dc.drawText(dc, hdc, std.mem.span(text), font_handle, color, pos);
    }

    export fn dcPtToPx(dc: *DocumentContainer, pt: c_int) c_int {
        return dc.ptToPx(dc, pt);
    }
    export fn dcGetDefaultFontSize(dc: *DocumentContainer) c_int {
        return dc.getDefaultFontSize(dc);
    }
    export fn dcGetDefaultFontName(dc: *DocumentContainer) [*:0]const u8 {
        return dc.getDefaultFontName(dc).ptr;
    }

    export fn dcLoadImage(
        dc: *DocumentContainer,
        src: [*:0]const u8,
        base_url: [*:0]const u8,
        redraw_on_ready: bool,
    ) void {
        dc.loadImage(dc, std.mem.span(src), std.mem.span(base_url), redraw_on_ready);
    }
    export fn dcGetImageSize(
        dc: *DocumentContainer,
        src: [*:0]const u8,
        base_url: [*:0]const u8,
    ) Size {
        return dc.getImageSize(dc, std.mem.span(src), std.mem.span(base_url));
    }

    export fn dcDrawListMarker(
        dc: *DocumentContainer,
        hdc: usize,
        marker: *const ListMarker,
    ) void {
        dc.drawListMarker(dc, hdc, marker);
    }
    export fn dcDrawBackground(
        dc: *DocumentContainer,
        hdc: usize,
        bg: *const BackgroundPaint,
    ) void {
        dc.drawBackground(dc, hdc, bg);
    }
    export fn dcDrawBorders(
        dc: *DocumentContainer,
        hdc: usize,
        borders: *const Borders,
        draw_pos: Position,
        root: bool,
    ) void {
        dc.drawBorders(dc, hdc, borders, draw_pos, root);
    }
};

pub const Context = opaque {
    pub const init = createContext;
    extern fn createContext() *Context;
    pub const deinit = destroyContext;
    extern fn destroyContext(*Context) void;
    pub extern fn loadMasterStylesheet(*Context, [*:0]const u8) void;
};

pub const Document = opaque {
    // TODO: user styles
    pub const init = createDocument;
    extern fn createDocument([*:0]const u8, *DocumentContainer, ?*Context) *Document;
    pub const deinit = destroyDocument;
    extern fn destroyDocument(*Document) void;
};
