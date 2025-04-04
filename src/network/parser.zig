const std = @import("std");
const detection = @import("detection.zig");

const ParseError = error{
    NoJoinDetectedToParseUser,
};

const Packet = @import("packet.zig").Packet;
const Allocator = std.mem.Allocator;

pub fn parseIps(allocator: Allocator, packet: []u8) !struct {src_ip: []u8, dst_ip: []u8} {
    var src_ip_len: usize = 3; // 3 for the three dots
    var dst_ip_len: usize = 3; // --------------------

    for (packet[12..16]) |p| {
        if (p < 10) src_ip_len += 1 else if (p < 100) src_ip_len += 2 else src_ip_len += 3;
    }
    for (packet[16..20]) |p| {
        if (p < 10) dst_ip_len += 1 else if (p < 100) dst_ip_len += 2 else dst_ip_len += 3;
    }
    const src_ip: []u8 = try allocator.alloc(u8, src_ip_len);
    const dst_ip: []u8 = try allocator.alloc(u8, dst_ip_len);

    _ = try std.fmt.bufPrint(src_ip, "{d}.{d}.{d}.{d}", .{packet[12], packet[13], packet[14], packet[15]});
    _ = try std.fmt.bufPrint(dst_ip, "{d}.{d}.{d}.{d}", .{packet[16], packet[17], packet[18], packet[19]});

    return .{
        .src_ip = src_ip,
        .dst_ip = dst_ip,
    };    
}

pub fn parseUsername(packet: *Packet) ParseError![]const u8 {
    if (!detection.player_joined(packet)) return ParseError.NoJoinDetectedToParseUser;
    const p1 = p1: {
        const d1 = &[_]u8{0x03, 0x00, 0x1B, 0x00, 0x01, 0x00, 0x0F, 0x00};
        const idx = std.mem.indexOf(u8, packet.payload, d1);
        break :p1 packet.payload[(idx.? + d1.len)..];
    };
    const p2 = p2: {
        const d2 = &[_]u8{0xDE, 0x00, 0x01, 0x00, 0x0F, 0x00, 0x00, 0x00, 0x04, 0x00};
        const idx = std.mem.indexOf(u8, p1, d2);
        break :p2 p1[0..idx.?];
    };

    return p2[2..]; //its 4 in hex, but 2 in bytes for start of index
}
