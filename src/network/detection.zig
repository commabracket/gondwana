const std = @import("std");

const Packet = @import("packet.zig").Packet;

pub const detections = struct {
    const join = &[_]u8{
        0xDE, 0x00, 0x01, 0x00, 0x0F, 0x00, 0x00, 0x00, 0x04, 0x00
    };
};

pub fn player_joined(packet: *Packet) bool {
    if (std.mem.indexOf(u8, packet.payload, detections.join) != null) return true;

    return false;
}

pub fn cheat_detected(packet: *Packet) bool {
    _ = packet; // todo
    return false; //
}
