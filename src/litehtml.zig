const std = @import("std");
const c = @cImport({
    @cInclude("litehtml_wrapper.h");
});

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
