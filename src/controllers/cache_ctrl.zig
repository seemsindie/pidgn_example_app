const std = @import("std");
const zzz = @import("zzz");

// ── Routes ─────────────────────────────────────────────────────────────

pub const ctrl = zzz.Controller.define(.{}, &.{
    zzz.Router.get("/cache-demo", cacheDemo),
    zzz.Router.scope("/api/cached", &.{zzz.cacheMiddleware(.{
        .cacheable_prefixes = &.{"/api/cached"},
        .default_ttl_s = 10,
    })}, &.{
        zzz.Router.get("/time", cachedTime),
    }),
});

// ── Handlers ───────────────────────────────────────────────────────────

fn cacheDemo(ctx: *zzz.Context) !void {
    ctx.html(.ok,
        \\<!DOCTYPE html>
        \\<html>
        \\<head><title>Cache Demo</title></head>
        \\<body>
        \\<h1>Response Cache Demo</h1>
        \\<p>The endpoint <code>/api/cached/time</code> returns the current timestamp but is cached for 10 seconds.</p>
        \\<p>First request: <code>X-Cache: MISS</code>. Subsequent: <code>X-Cache: HIT</code>.</p>
        \\<button onclick="fetch('/api/cached/time').then(r=>{document.getElementById('h').textContent=r.headers.get('X-Cache');return r.text()}).then(t=>document.getElementById('r').textContent=t)">Fetch</button>
        \\<p>Cache: <span id="h">-</span></p>
        \\<pre id="r"></pre>
        \\</body>
        \\</html>
    );
}

fn cachedTime(ctx: *zzz.Context) !void {
    // This will be cached — same response for 10s
    var buf: [64]u8 = undefined;
    const msg = std.fmt.bufPrint(&buf, "{{\"timestamp\": {d}}}", .{std.time.timestamp()}) catch "{}";
    ctx.json(.ok, msg);
}
