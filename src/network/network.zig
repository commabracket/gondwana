const std = @import("std");
const packet = @import("packet.zig");
const windivert = @import("../windivert/windivert.zig");
const bindings = @import("../windivert/bindings.zig");

const Packet = packet.Packet;
const Player = @import("player.zig").Player;
const WinDivert = windivert.WinDivert;

pub const GondwaNetwork = struct {
    const Self = @This();

    windivert: WinDivert,

    pub fn init(filter: []const u8, layer: bindings.Layer, priority: i16, flags: bindings.Flags) !Self {
        return .{
            .windivert = try WinDivert.open(filter, layer, priority, flags),
        };
    }
    pub fn deinit(self: *Self) void {
        self.windivert.close();
    }
    pub fn recv(self: *Self) !Packet {
        var raw_packet, const raw_packet_len = try self.windivert.recv();

        return try packet.Packet.init(raw_packet[0..], raw_packet_len);
    }
    pub fn send(self: *Self, pPacket: *Packet) !c_uint {
        defer pPacket.deinit(); // deinitialize the packet allocation once it
        // has been sent

        return try self.windivert.send(pPacket.packet, pPacket.len);
    }
    pub fn getPlayer(self: *Self, pPacket: *Packet) !Player {
        return try Player.init(pPacket, self.windivert.address.timestamp);
    }
};
