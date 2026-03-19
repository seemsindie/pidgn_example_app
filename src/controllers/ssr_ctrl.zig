const std = @import("std");
const zzz = @import("zzz");

// ── Routes ─────────────────────────────────────────────────────────────

pub const ctrl = zzz.Controller.define(.{}, &.{
    zzz.Router.get("/ssr-demo", ssrDemo),
});

// ── Handlers ───────────────────────────────────────────────────────────

fn ssrDemo(ctx: *zzz.Context) !void {
    ctx.html(.ok,
        \\<!DOCTYPE html>
        \\<html>
        \\<head><title>SSR Demo</title></head>
        \\<body>
        \\<h1>Server-Side Rendering Demo</h1>
        \\<p>The SSR bridge renders React components on the server via Bun subprocesses.</p>
        \\<h2>How it works</h2>
        \\<ol>
        \\  <li>Initialize an <code>SsrPool</code> with a path to your SSR worker script</li>
        \\  <li>Call <code>pool.render("ComponentName", propsJson)</code> to get HTML</li>
        \\  <li>Embed the rendered HTML in your response or template</li>
        \\</ol>
        \\<h2>Setup</h2>
        \\<pre><code>
        \\# Generate SSR scaffold:
        \\zzz assets setup --ssr
        \\
        \\# This creates:
        \\#   assets/ssr-worker.js        — Bun worker that renders components
        \\#   assets/components/App.jsx   — Example React component
        \\</code></pre>
        \\<h2>Usage in Zig</h2>
        \\<pre><code>
        \\const zzz = @import("zzz");
        \\
        \\var ssr_pool = zzz.SsrPool.init(allocator, .{
        \\    .worker_script = "assets/ssr-worker.js",
        \\    .pool_size = 4,
        \\});
        \\defer ssr_pool.deinit();
        \\
        \\// Render a component with props
        \\const html = try ssr_pool.render("App", "{\"title\":\"Hello\",\"message\":\"From SSR!\"}");
        \\defer allocator.free(html);
        \\</code></pre>
        \\<p><strong>Note:</strong> SSR requires <a href="https://bun.sh">Bun</a> to be installed on the server.</p>
        \\</body>
        \\</html>
    );
}
