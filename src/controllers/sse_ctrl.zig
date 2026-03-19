const zzz = @import("zzz");
const home = @import("home.zig");

// ── Routes ─────────────────────────────────────────────────────────────

pub const ctrl = zzz.Controller.define(.{}, &.{
    zzz.Router.get("/sse-demo", sseDemo),
    zzz.Router.scope("/events", &.{zzz.sseMiddleware(.{})}, &.{
        zzz.Router.get("", sseEndpoint),
    }),
});

// ── Handlers ───────────────────────────────────────────────────────────

fn sseDemo(ctx: *zzz.Context) !void {
    ctx.html(.ok,
        \\<!DOCTYPE html>
        \\<html>
        \\<head><title>SSE Demo</title></head>
        \\<body>
        \\<h1>Server-Sent Events Demo</h1>
        \\<div id="events"></div>
        \\<script>
        \\const es = new EventSource('/events');
        \\es.addEventListener('message', e => {
        \\  document.getElementById('events').innerHTML += '<p>' + e.data + '</p>';
        \\});
        \\es.addEventListener('ping', e => {
        \\  document.getElementById('events').innerHTML += '<p style="color:gray">[ping] ' + e.data + '</p>';
        \\});
        \\</script>
        \\</body>
        \\</html>
    );
}

fn sseEndpoint(ctx: *zzz.Context) !void {
    // The SSE middleware has already set Content-Type: text/event-stream
    // For this demo, we just send a single event and let the connection close.
    // In a real app, you'd enter a loop or use a channel-based approach.
    ctx.respond(.ok, "text/event-stream",
        "event: message\ndata: Hello from SSE!\n\nevent: ping\ndata: connected\n\n"
    );
}
