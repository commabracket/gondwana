const std = @import("std");
const parser = @import("parser.zig");

const ArenaAllocator = std.heap.ArenaAllocator;
const Allocator = std.mem.Allocator;

pub const Packet = struct {
    const Self = @This();

    packet: []u8,
    dst_ip: []u8,
    src_ip: []u8,
    payload: []u8,
    len: usize,
    arena: ArenaAllocator,

    pub fn init(packet: []u8, len: usize) !Packet {
        var arena = std.heap.ArenaAllocator.init(std.heap.c_allocator);
        const allocator = arena.allocator();

        const parsed_ips = try parser.parseIps(allocator, packet);
        const raw_packet = try allocator.dupe(u8, packet[0..len]);

        return Packet{
            .packet = raw_packet,
            .src_ip = parsed_ips.src_ip,
            .dst_ip = parsed_ips.dst_ip,
            .payload = raw_packet[20..],
            .len = len,
            .arena = arena,
        };
    }
    pub fn deinit(self: *Self) void {
        self.arena.deinit();
    }
    pub fn recalculateLength(self: *Packet) void {
        _ = self; // todo
    }
};
