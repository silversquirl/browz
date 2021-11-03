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

pub const DocumentContainer = extern struct {
    createFont: fn (
        *DocumentContainer,
        face_name: [*:0]const u8,
        size: c_int,
        weight: c_int,
        italic: bool,
        decoration: FontDecoration,
        metrics: *FontMetrics,
    ) callconv(.C) usize,
    deleteFont: fn (*DocumentContainer, font_handle: usize) callconv(.C) void,
    textWidth: fn (
        *DocumentContainer,
        text: [*:0]const u8,
        font_handle: usize,
    ) callconv(.C) c_int,
    drawText: fn (
        *DocumentContainer,
        hdc: usize,
        text: [*:0]const u8,
        font_handle: usize,
        color: WebColor,
        pos: Position,
    ) callconv(.C) void,

    ptToPx: fn (*DocumentContainer, pt: c_int) callconv(.C) c_int,
    getDefaultFontSize: fn (*DocumentContainer) callconv(.C) c_int,
    getDefaultFontName: fn (*DocumentContainer) callconv(.C) [*:0]const u8,

    loadImage: fn (
        *DocumentContainer,
        src: [*:0]const u8,
        base_url: [*:0]const u8,
        redraw_on_ready: bool,
    ) callconv(.C) void,
    getImageSize: fn (
        *DocumentContainer,
        src: [*:0]const u8,
        base_url: [*:0]const u8,
    ) callconv(.C) Size,

    drawListMarker: fn (
        *DocumentContainer,
        hdc: usize,
        marker: *const ListMarker,
    ) callconv(.C) void,
    drawBackground: fn (
        *DocumentContainer,
        hdc: usize,
        bg: *const BackgroundPaint,
    ) callconv(.C) void,
    drawBorders: fn (
        *DocumentContainer,
        hdc: usize,
        borders: *const Borders,
        draw_pos: Position,
        root: bool,
    ) callconv(.C) void,
};

const Context = opaque {
    pub const init = createContext;
    extern fn createContext() *Context;
    pub const deinit = destroyContext;
    extern fn destroyContext(*Context) void;
    pub extern fn loadMasterStylesheet(*Context, [*:0]const u8) void;
};

const Document = opaque {
    // TODO: user styles
    pub const init = createDocument;
    extern fn createDocument([*:0]const u8, *DocumentContainer, *Context) *Document;
    pub const deinit = destroyDocument;
    extern fn destroyDocument(*Document) void;
};
