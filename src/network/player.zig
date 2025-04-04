const Packet = @import("packet.zig").Packet;
const parser = @import("parser.zig");

pub const Player = struct {
    username: []const u8,
    ip: []const u8,
    timestamp: i64,

    pub fn init(packet: *Packet, timestamp: i64) !Player {
        return .{
            .username = try parser.parseUsername(packet),

            // will be a local ip if joining a game instead of hosting
            .ip = packet.src_ip,
            .timestamp = timestamp,
        };
    }
};
