const std = @import("std");
const pidgn = @import("pidgn");
const home = @import("home.zig");

const AppLayout = home.AppLayout;

// ── Templates ──────────────────────────────────────────────────────────

const WsDemoContent = pidgn.template(@embedFile("../templates/ws_demo.html.pidgn"));
const ChatDemoContent = pidgn.template(@embedFile("../templates/chat.html.pidgn"));

// ── Channel Definition ─────────────────────────────────────────────────

fn roomJoin(_: *pidgn.Socket, _: []const u8, _: []const u8) pidgn.JoinResult {
    return .ok;
}

fn roomLeave(_: *pidgn.Socket, _: []const u8) void {}

fn roomHandleNewMsg(socket: *pidgn.Socket, topic: []const u8, _: []const u8, payload: []const u8) void {
    socket.broadcast(topic, "new_msg", payload);
}

const roomChannelDef: pidgn.ChannelDef = .{
    .topic_pattern = "room:*",
    .join = &roomJoin,
    .leave = &roomLeave,
    .handlers = &.{
        .{ .event = "new_msg", .handler = &roomHandleNewMsg },
    },
};

// ── WebSocket Callbacks ────────────────────────────────────────────────

fn wsEchoOpen(ws: *pidgn.WebSocket) void {
    _ = ws;
    std.log.info("[WS] client connected", .{});
}

fn wsEchoMessage(ws: *pidgn.WebSocket, msg: pidgn.WsMessage) void {
    switch (msg) {
        .text => |text| {
            std.log.info("[WS] echo: {s}", .{text});
            ws.send(text);
        },
        .binary => |data| {
            ws.sendBinary(data);
        },
    }
}

fn wsEchoClose(_: *pidgn.WebSocket, code: u16, _: []const u8) void {
    std.log.info("[WS] client disconnected (code: {d})", .{code});
}

// ── Routes ─────────────────────────────────────────────────────────────

pub const ctrl = pidgn.Controller.define(.{}, &.{
    pidgn.Router.get("/ws-demo", wsDemo),
    pidgn.Router.ws("/ws/echo", .{
        .on_open = wsEchoOpen,
        .on_message = wsEchoMessage,
        .on_close = wsEchoClose,
    }),
    pidgn.Router.get("/chat", chatDemo),
    pidgn.Router.channel("/socket", .{
        .channels = &.{roomChannelDef},
        .rate_limit_msgs = 50,
        .rate_limit_per_s = 5,
        .rate_limit_action = .drop,
    }),
});

// ── Handlers ───────────────────────────────────────────────────────────

fn wsDemo(ctx: *pidgn.Context) !void {
    try ctx.renderWithLayout(AppLayout, WsDemoContent, .ok, .{
        .title = "WebSocket Demo",
    });
}

fn chatDemo(ctx: *pidgn.Context) !void {
    try ctx.renderWithLayout(AppLayout, ChatDemoContent, .ok, .{
        .title = "Channel Chat Demo",
    });
}
