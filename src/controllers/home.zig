const std = @import("std");
const pidgn = @import("pidgn");
const pidgn_db = @import("pidgn_db");

const pg_enabled = pidgn_db.postgres_enabled;

// ── Templates ──────────────────────────────────────────────────────────

pub const AppLayout = pidgn.templateWithPartials(
    @embedFile("../templates/layout.html.pidgn"),
    .{
        .nav = @embedFile("../templates/partials/nav.html.pidgn"),
    },
);

const IndexContent = pidgn.template(@embedFile("../templates/index.html.pidgn"));
const AboutContent = pidgn.template(@embedFile("../templates/about.html.pidgn"));

// ── Routes ─────────────────────────────────────────────────────────────

pub const ctrl = pidgn.Controller.define(.{}, &.{
    pidgn.Router.get("/", index).named("home"),
    pidgn.Router.get("/about", about).named("about"),
});

// ── Handlers ───────────────────────────────────────────────────────────

const RouteItem = struct { html: []const u8 };

const index_routes = [_]RouteItem{
    .{ .html = "<a href=\"/about\">About</a>" },
    .{ .html = "<a href=\"/api/status\">API Status</a>" },
    .{ .html = "<a href=\"/api/users/1\">User 1</a>" },
    .{ .html = "<a href=\"/api/users/42\">User 42</a>" },
    .{ .html = "<a href=\"/api/posts\">Posts</a>" },
    .{ .html = "<a href=\"/api/posts/hello-world\">Post: hello-world</a>" },
    .{ .html = "POST /api/echo &mdash; body parser echo (JSON, form, multipart, text)" },
    .{ .html = "POST /api/upload &mdash; file upload demo" },
    .{ .html = "<a href=\"/login\">Login</a> &mdash; session + CSRF token demo" },
    .{ .html = "<a href=\"/dashboard\">Dashboard</a> &mdash; session data demo" },
    .{ .html = "POST /api/protected &mdash; CSRF-protected endpoint" },
    .{ .html = "<a href=\"/old-page\">Old Page</a> &mdash; redirect demo (301)" },
    .{ .html = "<a href=\"/set-cookie\">Set Cookie</a> &mdash; cookie demo" },
    .{ .html = "<a href=\"/delete-cookie\">Delete Cookie</a> &mdash; cookie deletion demo" },
    .{ .html = "<a href=\"/api/limited\">Rate Limited</a> &mdash; rate limiting demo (10 req/min)" },
    .{ .html = "<a href=\"/download/build.zig\">Download build.zig</a> &mdash; sendFile demo" },
    .{ .html = "<a href=\"/error-demo\">Error Demo</a> &mdash; global error handler demo" },
    .{ .html = "GET /auth/bearer &mdash; Bearer token auth demo (requires Authorization header)" },
    .{ .html = "GET /auth/basic &mdash; Basic auth demo (curl -u user:pass)" },
    .{ .html = "GET /auth/jwt &mdash; JWT auth demo (requires valid HS256 token)" },
    .{ .html = "<a href=\"/htmx\">htmx Demo</a> &mdash; htmx counter + greeting demos" },
    .{ .html = "<a href=\"/todos\">Todo List</a> &mdash; htmx CRUD demo" },
    .{ .html = "<a href=\"/ws-demo\">WebSocket Demo</a> &mdash; WebSocket echo with pidgn.js" },
    .{ .html = "<a href=\"/chat\">Channel Chat</a> &mdash; Phoenix-style channel chat with pidgn.js" },
    .{ .html = "<a href=\"/db\">Database Demo</a> &mdash; SQLite CRUD with pidgn_db" },
    .{ .html = "<a href=\"/jobs\">Background Jobs</a> &mdash; pidgn_jobs demo" },
    .{ .html = "<a href=\"/api/docs\">API Docs</a> &mdash; Swagger UI (OpenAPI 3.1.0)" },
    .{ .html = "<a href=\"/sse-demo\">SSE Demo</a> &mdash; Server-Sent Events streaming" },
    .{ .html = "<a href=\"/cache-demo\">Cache Demo</a> &mdash; response caching with X-Cache headers" },
    .{ .html = "<a href=\"/ssr-demo\">SSR Demo</a> &mdash; server-side rendering with Bun" },
} ++ if (pg_enabled) [_]RouteItem{
    .{ .html = "<a href=\"/pg\">PostgreSQL Demo</a> &mdash; CRUD with PostgreSQL via pidgn_db" },
} else [_]RouteItem{};

fn index(ctx: *pidgn.Context) !void {
    try ctx.renderWithLayout(AppLayout, IndexContent, .ok, .{
        .title = "Pidgn Example App",
        .description = "A sample app built with the Pidgn web framework.",
        .show_routes = true,
        .routes = @as([]const RouteItem, &index_routes),
    });
}

fn about(ctx: *pidgn.Context) !void {
    try ctx.renderWithLayout(AppLayout, AboutContent, .ok, .{
        .title = "About",
    });
}
