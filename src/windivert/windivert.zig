const std = @import("std");
const windows = std.os.windows;
const bindings = @import("bindings.zig");

const Handle = windows.HANDLE;
const Address = bindings.Address;

pub const WinDivert = struct {
    const Self = @This();

    handle: Handle,
    address: Address = undefined,

    pub fn open(filter: []const u8, layer: bindings.Layer,
    priority: i16, flags: bindings.Flags) !Self {
        return .{
            .handle = try bindings.open(filter, layer, priority, flags),
        };
    }
    pub fn close(self: *Self) void {
        bindings.close(self.handle) catch {};
    }

    // returns packet and packet length
    pub fn recv(self: *Self) !struct{[65535]u8, c_uint} {
        return try bindings.recv(self.handle, &self.address);
    }
    pub fn send(self: *Self, packet: []u8, len: usize) !c_uint {
        return try bindings.send(self.handle, packet, len, &self.address);
    }
};
