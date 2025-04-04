const std = @import("std");
const windows = std.os.windows;

const Handle = windows.HANDLE;

pub const Layer = enum(c_int) {
    network = 0,
    network_forward = 1,
    flow = 2,
    socket = 3,
    reflect = 4,
    _,
};

pub const Flags = enum(u64) {
    all = 0x0000,
    sniff = 0x0001,
    drop = 0x0002,
    recv_only = 0x0004,
    send_only = 0x0008,
    no_install = 0x0010,
    fragments = 0x0020,
    _,
};

pub const NetworkLayerData = extern struct {
    interface_index: u32,
    sub_interface_index: u32,
};

pub const FlowLayerData = extern struct {
    endpoint_id: u64,
    parent_endpoint_id: u64,
    process_id: u32,
    local_addr: [4]u32,
    remote_addr: [4]u32,
    local_port: u16,
    remote_port: u16,
    protocol: u8,
};

pub const SocketLayerData = extern struct {
    endpoint_id: u64,
    parent_endpoint_id: u64,
    process_id: u32,
    local_addr: [4]u32,
    remote_addr: [4]u32,
    local_port: u16,
    remote_port: u16,
    protocol: u8,
};

pub const ReflectLayerData = extern struct {
    timestamp: i64,
    process_id: u32,
    layer: Layer,
    flags: Flags,
    priority: i16,
};

pub const LayerData = extern union {
    network: NetworkLayerData,
    flow: FlowLayerData,
    socket: SocketLayerData,
    reflect: ReflectLayerData,
    reserved: [64]u8,
};

pub const Address = extern struct {
    timestamp: i64,
    layer: u8,
    event: u8,

    is_sniffed: bool,
    is_outbound: bool,
    is_loopback: bool,
    is_impostor: bool,
    is_ipv6: bool,

    has_ip_checksum: bool,
    has_tcp_checksum: bool,
    has_udp_checksum: bool,

    reserved: u8,
    reserved2: u32,

    data: LayerData,
};

extern fn WinDivertOpen(filter: [*c]const u8, layer: Layer, priority: i16, flags: Flags) Handle;
extern fn WinDivertClose(handle: Handle) windows.BOOL;
extern fn WinDivertRecv(handle: Handle, pPacket: ?*anyopaque, packetLen: c_uint, pRecvLen: [*c]c_uint, pAddr: ?*Address) windows.BOOL;
extern fn WinDivertSend(handle: Handle, pPacket: ?*const anyopaque, packetLen: c_uint, pSendLen: [*c]c_uint, pAddr: ?*const Address) windows.BOOL;

pub fn open(filter: []const u8, layer: Layer, priority: i16, flags: Flags) !Handle {
    const handle = WinDivertOpen(filter.ptr, layer, priority, flags);
    if (handle == windows.INVALID_HANDLE_VALUE) return error.FailedToOpen;
    return handle;
}

pub fn close(handle: Handle) !void {
    if (WinDivertClose(handle) == 0) return error.FailedToClose;
}

pub fn recv(handle: Handle, address: *Address) !struct{[65535]u8, c_uint} {
    var packet: [65535]u8 = undefined;
    var len: c_uint = 0;

    if (WinDivertRecv(handle, packet[0..].ptr, @intCast(packet.len),
    &len, address) == 0) return error.FailedToReceive;

    return .{packet, len};
}

pub fn send(handle: Handle, packet: []u8, len: usize, address: *Address) !c_uint {
    var bytes_sent: c_uint = 0;

    if (WinDivertSend(handle, packet.ptr, @intCast(len), &bytes_sent, address) == 0) return error.FailedToSend;

    return bytes_sent;
}
