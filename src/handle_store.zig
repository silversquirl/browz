//! This file contains a type for allocating and storing "handles" to objects.
//! Effectively an allocator for fixed-size objects that uses a customizable address size.

const std = @import("std");

pub fn HandleStore(comptime Handle: type, comptime Value: type) type {
    return struct {
        entries: std.ArrayListUnmanaged(Entry) = .{},
        free: ?Handle = null,

        const Entry = union {
            v: Value,
            free: ?Handle,
        };
        const Self = @This();

        pub fn deinit(self: *Self, allocator: std.mem.Allocator) void {
            self.entries.deinit(allocator);
        }

        pub inline fn get(self: Self, h: Handle) Value {
            return self.entries.items[h].v;
        }
        pub inline fn getPtr(self: Self, h: Handle) *Value {
            return &self.entries.items[h].v;
        }

        pub fn add(self: *Self, allocator: std.mem.Allocator, v: Value) !Handle {
            const h = if (self.free) |h| blk: {
                self.free = self.entries.items[h].free;
                break :blk h;
            } else blk: {
                _ = try self.entries.addOne(allocator);
                break :blk self.entries.items.len - 1;
            };

            self.entries.items[h] = .{ .v = v };
            return h;
        }

        pub fn del(self: *Self, h: Handle) Value {
            const v = self.get(h);
            self.entries.items[h] = .{ .free = self.free };
            self.free = h;
            return v;
        }
    };
}
