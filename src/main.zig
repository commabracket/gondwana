const std = @import("std");
const network = @import("network/network.zig");
const detection = @import("network/detection.zig");
const log = std.log;

pub fn main() !void {
    var net = try network.GondwaNetwork.init(
        "udp and udp.PayloadLength > 0 and !loopback", 
        .network,
        0,
        .all
    );
    defer net.deinit();

    while (true) {
        var packet = try net.recv();
        if(detection.player_joined(&packet)) {
            const player = try net.getPlayer(&packet); 
            log.info("user: {s}, ip: {s}, timestamp: {d}", .{
                player.username,
                player.ip,
                player.timestamp
            });
            log.info("packet len: {d}", .{packet.len});
        }
        _ = try net.send(&packet);
    }
}
