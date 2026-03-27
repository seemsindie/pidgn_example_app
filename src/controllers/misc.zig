const pidgn = @import("pidgn");

// ── Routes ─────────────────────────────────────────────────────────────

pub const ctrl = pidgn.Controller.define(.{}, &.{
    pidgn.Router.get("/download/:filename", downloadFile),
    pidgn.Router.get("/error-demo", errorDemo),
});

// Rate-limited handler is exported directly — wired via Router.scope() in main.zig
pub fn rateLimitedHandler(ctx: *pidgn.Context) !void {
    ctx.json(.ok,
        \\{"message": "You are within the rate limit"}
    );
}

// ── Handlers ───────────────────────────────────────────────────────────

fn downloadFile(ctx: *pidgn.Context) !void {
    const filename = ctx.param("filename") orelse {
        ctx.text(.bad_request, "missing filename");
        return;
    };
    ctx.sendFile(filename, null);
}

fn errorDemo(_: *pidgn.Context) !void {
    return error.IntentionalDemoError;
}
