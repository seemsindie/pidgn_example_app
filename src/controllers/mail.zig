const std = @import("std");
const pidgn = @import("pidgn");
const pidgn_mailer = @import("pidgn_mailer");
const home = @import("home.zig");

const AppLayout = home.AppLayout;
const DevAdapter = pidgn_mailer.DevAdapter;
const DevMailer = pidgn_mailer.DevMailer;
const DevMailbox = pidgn_mailer.DevMailbox;
const Email = pidgn_mailer.Email;

// ── State ──────────────────────────────────────────────────────────────

var dev_adapter: DevAdapter = DevAdapter.init(.{});
var dev_mailer: DevMailer = DevMailer.init(.{});
var mailbox: DevMailbox = undefined;
var initialized: bool = false;

fn ensureInit() void {
    if (!initialized) {
        dev_mailer.adapter = dev_adapter;
        mailbox = DevMailbox.init(&dev_mailer.adapter);
        initialized = true;
    }
}

// ── Routes ─────────────────────────────────────────────────────────────

pub const ctrl = pidgn.Controller.define(.{
    .prefix = "/mail",
    .tag = "Mailer",
}, &.{
    pidgn.Router.get("/send-test", sendTestEmail)
        .doc(.{ .summary = "Send a test email", .description = "Sends a test email via the DevAdapter (viewable at /__pidgn/mailbox)." }),
});

// ── Handlers ───────────────────────────────────────────────────────────

fn sendTestEmail(ctx: *pidgn.Context) !void {
    ensureInit();

    const email = Email{
        .from = .{ .email = "noreply@example.com", .name = "Example App" },
        .to = &.{.{ .email = "user@example.com", .name = "Test User" }},
        .cc = &.{.{ .email = "cc@example.com" }},
        .subject = "Welcome to pidgn_mailer!",
        .text_body = "Hello from pidgn_mailer!\n\nThis is a test email sent via the DevAdapter.\nView all sent emails at /__pidgn/mailbox.",
        .html_body =
        \\<!DOCTYPE html>
        \\<html>
        \\<body style="font-family: sans-serif; max-width: 600px; margin: 0 auto; padding: 20px;">
        \\  <h1 style="color: #667eea;">Welcome to pidgn_mailer!</h1>
        \\  <p>Hello from pidgn_mailer!</p>
        \\  <p>This is a test email sent via the <strong>DevAdapter</strong>.</p>
        \\  <p>View all sent emails at <a href="/__pidgn/mailbox">/__pidgn/mailbox</a>.</p>
        \\  <hr style="border: none; border-top: 1px solid #eee; margin: 20px 0;">
        \\  <p style="color: #999; font-size: 12px;">Sent by the pidgn web framework</p>
        \\</body>
        \\</html>
        ,
    };

    _ = dev_mailer.send(email, ctx.allocator);

    ctx.redirect("/__pidgn/mailbox", .see_other);
}

// ── Dev Mailbox Handlers ───────────────────────────────────────────────

pub fn mailboxInbox(ctx: *pidgn.Context) !void {
    ensureInit();
    var buf: [32768]u8 = undefined;
    if (mailbox.renderInbox(&buf)) |html| {
        ctx.html(.ok, html);
    } else {
        ctx.text(.internal_server_error, "Failed to render mailbox");
    }
}

pub fn mailboxDetail(ctx: *pidgn.Context) !void {
    ensureInit();
    const index_str = ctx.param("index") orelse {
        ctx.text(.bad_request, "Missing index");
        return;
    };
    const index = std.fmt.parseInt(usize, index_str, 10) catch {
        ctx.text(.bad_request, "Invalid index");
        return;
    };
    var buf: [32768]u8 = undefined;
    if (mailbox.renderDetail(index, &buf)) |html| {
        ctx.html(.ok, html);
    } else {
        ctx.text(.not_found, "Email not found");
    }
}

pub fn mailboxHtml(ctx: *pidgn.Context) !void {
    ensureInit();
    const index_str = ctx.param("index") orelse {
        ctx.text(.bad_request, "Missing index");
        return;
    };
    const index = std.fmt.parseInt(usize, index_str, 10) catch {
        ctx.text(.bad_request, "Invalid index");
        return;
    };
    if (mailbox.renderHtmlBody(index)) |html| {
        ctx.html(.ok, html);
    } else {
        ctx.text(.not_found, "No HTML body");
    }
}

pub fn mailboxClear(ctx: *pidgn.Context) !void {
    ensureInit();
    dev_mailer.adapter.clear();
    ctx.redirect("/__pidgn/mailbox", .see_other);
}
