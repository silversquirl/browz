const std = @import("std");

pub fn build(b: *std.build.Builder) void {
    const target = b.standardTargetOptions(.{});
    const mode = b.standardReleaseOptions();

    const c_opt = switch (mode) {
        .Debug => "-O0",
        .ReleaseSafe, .ReleaseFast => "-O3",
        .ReleaseSmall => "-Oz",
    };

    // Build litehtml
    const litehtml = b.addStaticLibrary("litehtml", null);
    litehtml.linkLibC();
    litehtml.linkLibCpp();

    litehtml.addIncludeDir("deps/litehtml/include");
    litehtml.addIncludeDir("deps/litehtml/include/litehtml");
    litehtml.addIncludeDir("deps/litehtml/src/gumbo/include");
    litehtml.addIncludeDir("deps/litehtml/src/gumbo/include/gumbo");
    litehtml.addCSourceFiles(&litehtml_sources, &.{
        c_opt,
        "-Wall",
        "-Werror",
        "-Wno-unused-but-set-variable",
        "-Wno-tautological-constant-out-of-range-compare",
        "-Wno-switch",
    });
    litehtml.addCSourceFiles(&gumbo_sources, &.{
        c_opt,
        "-Wall",
        "-Werror",
        "-Wno-void-pointer-to-enum-cast",
    });

    litehtml.disable_sanitize_c = true; // litehtml does some slightly sketchy stuff
    litehtml.setTarget(target);
    litehtml.setBuildMode(mode);

    // Build browz
    const exe = b.addExecutable("main", "src/main.zig");

    exe.linkLibC();
    exe.linkLibCpp();
    exe.linkLibrary(litehtml);
    exe.addIncludeDir("deps/litehtml/include");
    exe.addCSourceFile("src/litehtml_wrapper.cxx", &.{ c_opt, "-Wall", "-Werror" });

    exe.setTarget(target);
    exe.setBuildMode(mode);
    exe.install();

    // Ensure we use UTF8 on windows
    if (target.getOsTag() == .windows) {
        litehtml.defineCMacroRaw("LITEHTML_UTF8");
        exe.defineCMacroRaw("LITEHTML_UTF8");
    }

    // Run browz
    const run_cmd = exe.run();
    run_cmd.step.dependOn(b.getInstallStep());
    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);
}

// List taken from deps/litehtml/CMakeLists.txt
const litehtml_sources = [_][]const u8{
    "deps/litehtml/src/background.cpp",
    "deps/litehtml/src/box.cpp",
    "deps/litehtml/src/codepoint.cpp",
    "deps/litehtml/src/context.cpp",
    "deps/litehtml/src/css_length.cpp",
    "deps/litehtml/src/css_selector.cpp",
    "deps/litehtml/src/document.cpp",
    "deps/litehtml/src/el_anchor.cpp",
    "deps/litehtml/src/el_base.cpp",
    "deps/litehtml/src/el_before_after.cpp",
    "deps/litehtml/src/el_body.cpp",
    "deps/litehtml/src/el_break.cpp",
    "deps/litehtml/src/el_cdata.cpp",
    "deps/litehtml/src/el_comment.cpp",
    "deps/litehtml/src/el_div.cpp",
    "deps/litehtml/src/element.cpp",
    "deps/litehtml/src/el_font.cpp",
    "deps/litehtml/src/el_image.cpp",
    "deps/litehtml/src/el_link.cpp",
    "deps/litehtml/src/el_li.cpp",
    "deps/litehtml/src/el_para.cpp",
    "deps/litehtml/src/el_script.cpp",
    "deps/litehtml/src/el_space.cpp",
    "deps/litehtml/src/el_style.cpp",
    "deps/litehtml/src/el_table.cpp",
    "deps/litehtml/src/el_td.cpp",
    "deps/litehtml/src/el_text.cpp",
    "deps/litehtml/src/el_title.cpp",
    "deps/litehtml/src/el_tr.cpp",
    "deps/litehtml/src/html.cpp",
    "deps/litehtml/src/html_tag.cpp",
    "deps/litehtml/src/iterators.cpp",
    "deps/litehtml/src/media_query.cpp",
    "deps/litehtml/src/style.cpp",
    "deps/litehtml/src/stylesheet.cpp",
    "deps/litehtml/src/table.cpp",
    "deps/litehtml/src/tstring_view.cpp",
    "deps/litehtml/src/url.cpp",
    "deps/litehtml/src/url_path.cpp",
    "deps/litehtml/src/utf8_strings.cpp",
    "deps/litehtml/src/web_color.cpp",
    "deps/litehtml/src/num_cvt.cpp",
};

// List taken from deps/litehtml/src/gumbo/CMakeLists.txt
const gumbo_sources = [_][]const u8{
    "deps/litehtml/src/gumbo/attribute.c",
    "deps/litehtml/src/gumbo/char_ref.c",
    "deps/litehtml/src/gumbo/error.c",
    "deps/litehtml/src/gumbo/parser.c",
    "deps/litehtml/src/gumbo/string_buffer.c",
    "deps/litehtml/src/gumbo/string_piece.c",
    "deps/litehtml/src/gumbo/tag.c",
    "deps/litehtml/src/gumbo/tokenizer.c",
    "deps/litehtml/src/gumbo/utf8.c",
    "deps/litehtml/src/gumbo/util.c",
    "deps/litehtml/src/gumbo/vector.c",
};
