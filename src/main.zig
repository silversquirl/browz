//! Main program entry point

const std = @import("std");
const c = @import("c.zig");
const litehtml = @import("litehtml.zig");
const Container = @import("Container.zig");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();

    if (c.SDL_Init(c.SDL_INIT_VIDEO) != 0) {
        @panic(std.mem.span(c.SDL_GetError()));
    }
    defer c.SDL_Quit();

    if (c.TTF_Init() != 0) {
        @panic(std.mem.span(c.TTF_GetError()));
    }
    defer c.TTF_Quit();

    const win = c.SDL_CreateWindow(
        "browz",
        c.SDL_WINDOWPOS_UNDEFINED,
        c.SDL_WINDOWPOS_UNDEFINED,
        1024,
        768,
        c.SDL_WINDOW_RESIZABLE,
    ) orelse {
        @panic(std.mem.span(c.SDL_GetError()));
    };
    defer c.SDL_DestroyWindow(win);

    const ctx = litehtml.Context.init();
    defer ctx.deinit();
    ctx.loadMasterStylesheet(@embedFile("master.css"));

    var container = Container.init(gpa.allocator(), win);
    defer container.deinit();

    const doc = litehtml.Document.init(
        \\<!DOCTYPE html>
        \\<body>
        \\  <div>
        \\      <h1>Hello</h1>
        \\      <h2>This is a page</h2>
        \\      Lorem ipsum dolor sit amet etc
        \\  </div>
        \\</body>
    , &container.dc, ctx);
    defer doc.deinit();

    mainloop: while (true) {
        var w: c_int = undefined;
        var h: c_int = undefined;
        c.SDL_GetWindowSize(win, &w, &h);

        _ = doc.mediaChanged();
        _ = doc.render(w);

        doc.draw(undefined, 0, 0, .{
            .x = 0,
            .y = 0,
            .width = w,
            .height = h,
        });
        c.SDL_RenderPresent(container.ren);

        if (c.SDL_WaitEvent(null) == 0) {
            @panic(std.mem.span(c.SDL_GetError()));
        }

        var ev: c.SDL_Event = undefined;
        while (c.SDL_PollEvent(&ev) != 0) {
            switch (ev.type) {
                c.SDL_QUIT => break :mainloop,
                c.SDL_WINDOWEVENT => switch (ev.window.event) {
                    c.SDL_WINDOWEVENT_CLOSE => break :mainloop,
                    else => {},
                },
                else => {},
            }
        }
    }
}
