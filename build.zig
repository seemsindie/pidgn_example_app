const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const tls_enabled = b.option(bool, "tls", "Enable TLS/HTTPS support (requires OpenSSL)") orelse false;
    const postgres_enabled = b.option(bool, "postgres", "Enable PostgreSQL support (requires libpq)") orelse false;
    const env_name = b.option([]const u8, "env", "Environment: dev (default), prod, staging") orelse "dev";

    const pidgn_dep = b.dependency("pidgn", .{
        .target = target,
        .tls = tls_enabled,
    });

    const pidgn_db_dep = b.dependency("pidgn_db", .{
        .target = target,
        .postgres = postgres_enabled,
    });

    const pidgn_jobs_dep = b.dependency("pidgn_jobs", .{
        .target = target,
        .postgres = postgres_enabled,
    });

    const pidgn_mailer_dep = b.dependency("pidgn_mailer", .{
        .target = target,
    });

    const pidgn_template_dep = b.dependency("pidgn_template", .{
        .target = target,
    });
    const pidgn_template_mod = pidgn_template_dep.module("pidgn_template");

    const pidgn_db_mod = pidgn_db_dep.module("pidgn_db");
    const pidgn_jobs_mod = pidgn_jobs_dep.module("pidgn_jobs");
    const pidgn_mailer_mod = pidgn_mailer_dep.module("pidgn_mailer");

    // Ensure pidgn_jobs uses the same pidgn_db module to avoid duplicate module errors
    pidgn_jobs_mod.addImport("pidgn_db", pidgn_db_mod);

    // Ensure pidgn and pidgn_mailer use the same pidgn_template module
    pidgn_mailer_mod.addImport("pidgn_template", pidgn_template_mod);
    pidgn_dep.module("pidgn").addImport("pidgn_template", pidgn_template_mod);

    // Build config path from -Denv option: config/dev.zig, config/prod.zig, etc.
    var config_path_buf: [64]u8 = undefined;
    const config_path = std.fmt.bufPrint(&config_path_buf, "config/{s}.zig", .{env_name}) catch "config/dev.zig";

    // Shared config.zig module (imported by dev.zig / prod.zig)
    const config_mod = b.createModule(.{
        .root_source_file = b.path("config/config.zig"),
        .target = target,
    });

    // Environment-specific config module
    const app_config_mod = b.createModule(.{
        .root_source_file = b.path(config_path),
        .target = target,
    });
    app_config_mod.addImport("config", config_mod);

    const exe = b.addExecutable(.{
        .name = "example_app",
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/main.zig"),
            .target = target,
            .optimize = optimize,
            .imports = &.{
                .{ .name = "pidgn", .module = pidgn_dep.module("pidgn") },
                .{ .name = "pidgn_db", .module = pidgn_db_mod },
                .{ .name = "pidgn_jobs", .module = pidgn_jobs_mod },
                .{ .name = "pidgn_mailer", .module = pidgn_mailer_mod },
                .{ .name = "pidgn_template", .module = pidgn_template_mod },
                .{ .name = "app_config", .module = app_config_mod },
            },
        }),
    });

    exe.root_module.link_libc = true;

    b.installArtifact(exe);

    const run_step = b.step("run", "Run the example app");
    const run_cmd = b.addRunArtifact(exe);
    run_step.dependOn(&run_cmd.step);
    run_cmd.step.dependOn(b.getInstallStep());

    if (b.args) |args| {
        run_cmd.addArgs(args);
    }
}
