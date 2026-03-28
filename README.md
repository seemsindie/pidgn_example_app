# pidgn_example_app

Comprehensive demo application for the pidgn web framework.

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Zig](https://img.shields.io/badge/Zig-0.16.0-orange.svg)](https://ziglang.org/)

A reference implementation showcasing pidgn's features end-to-end: routing, middleware, templates, REST APIs, authentication, sessions, WebSocket channels, database operations, background jobs, and htmx integration.

## Running

```bash
cd pidgn_example_app
zig build run
# Server running on http://127.0.0.1:9000
```

### With Asset Pipeline

```bash
pidgn assets setup     # Generate starter asset files
bun install          # Install JavaScript dependencies
pidgn assets build     # Bundle, minify, and fingerprint assets
zig build run        # Start the server
```

During development, run `pidgn assets watch` in a separate terminal to rebuild assets on change.

### With PostgreSQL

```bash
docker compose up -d          # Start PostgreSQL + Adminer
zig build run -Dpostgres=true
```

### With TLS

```bash
zig build run -Dtls=true
# HTTPS on https://127.0.0.1:9000 (dev certificates included)
```

## What's Demonstrated

### Core Web

| Route | Feature |
|-------|---------|
| `GET /` | Home page with template rendering |
| `GET /about` | Static page with layout system |
| `GET /api/status` | JSON health check |
| `GET /api/docs` | Swagger UI (auto-generated OpenAPI spec) |
| `GET /download/:filename` | File downloads via `sendFile` |
| `GET /error-demo` | Global error handler |

### REST API

| Route | Feature |
|-------|---------|
| `GET /api/users` | List users (JSON) |
| `GET /api/users/:id` | Get user by ID |
| `POST /api/users` | Create user |
| `POST /api/echo` | Echo body (JSON, form, multipart, text) |
| `POST /api/upload` | Multipart file upload |
| `CRUD /api/posts/:slug` | RESTful resource |

### Authentication

| Route | Feature |
|-------|---------|
| `GET /auth/bearer` | Bearer token auth |
| `GET /auth/basic` | Basic auth (username:password) |
| `GET /auth/jwt` | JWT/HS256 auth |
| `GET /api/limited` | Rate limiting (10 req/min) |

### Sessions and Cookies

| Route | Feature |
|-------|---------|
| `GET /login` | Login page with CSRF token |
| `GET /dashboard` | Session data display |
| `POST /api/protected` | CSRF-protected endpoint |
| `GET /set-cookie` | Set cookie |
| `GET /delete-cookie` | Delete cookie |
| `GET /old-page` | 301 redirect |

### htmx

| Route | Feature |
|-------|---------|
| `GET /htmx` | Interactive counter |
| `POST /htmx/increment` | HTMX partial update |
| `GET /todos` | Full CRUD todo list |

### WebSocket and Channels

| Route | Feature |
|-------|---------|
| `GET /ws-demo` | WebSocket echo demo |
| `WS /ws/echo` | WebSocket echo server |
| `GET /chat` | Channel-based chat |
| `CHANNEL /socket` | Phoenix-style channels (`room:*`) |

### Database

| Route | Feature |
|-------|---------|
| `GET /db` | SQLite CRUD demo |
| `POST /db/add` | Insert with pidgn_db ORM |
| `GET /pg` | PostgreSQL CRUD demo (optional) |

### Background Jobs

| Route | Feature |
|-------|---------|
| `GET /jobs` | Job queue dashboard |
| `POST /jobs/enqueue` | Enqueue background job |
| `GET /jobs/stats` | Queue statistics |

### Server-Sent Events

| Route | Feature |
|-------|---------|
| `GET /sse-demo` | SSE demo page |
| `GET /events` | SSE event stream endpoint |

### Caching

| Route | Feature |
|-------|---------|
| `GET /cache-demo` | Cache demo page |
| `GET /api/cached/time` | Cached JSON endpoint (10s TTL, `X-Cache` header) |

### Server-Side Rendering

| Route | Feature |
|-------|---------|
| `GET /ssr-demo` | SSR bridge documentation and usage guide |

## Middleware Stack

The app uses 11 middleware in its pipeline:

1. Error handler (with debug details)
2. Logging
3. GZIP compression
4. Request ID
5. CORS
6. htmx support
7. Body parser (JSON/form/multipart/text)
8. Session management
9. CSRF protection
10. Static file serving
11. Swagger UI
12. Response cache (`/api/cached/*`)

## Project Structure

```
pidgn_example_app/
  src/
    main.zig                  # Route aggregation & server setup
    controllers/
      home.zig                # Home, about pages
      api.zig                 # REST API & Swagger
      auth.zig                # Auth demos
      sessions.zig            # Sessions & cookies
      htmx.zig                # htmx demos
      db.zig                  # SQLite CRUD
      pg.zig                  # PostgreSQL CRUD
      jobs.zig                # Background jobs
      ws.zig                  # WebSocket & channels
      misc.zig                # File download, errors
      sse_ctrl.zig            # SSE demo
      cache_ctrl.zig          # Cache demo
      ssr_ctrl.zig            # SSR demo
    templates/
      layout.html.pidgn         # Main layout
      index.html.pidgn          # Home page
      partials/
        nav.html.pidgn          # Navigation
  public/
    css/style.css
    js/app.js
  certs/                       # Dev TLS certificates
  docker-compose.yml           # PostgreSQL + Adminer
```

## Documentation

Full documentation available at [docs.pidgn.indielab.link](https://docs.pidgn.indielab.link).

## Ecosystem

| Package | Description |
|---------|-------------|
| [pidgn.zig](https://github.com/seemsindie/pidgn) | Core web framework |
| [pidgn_db](https://github.com/seemsindie/pidgn_db) | Database ORM (SQLite + PostgreSQL) |
| [pidgn_jobs](https://github.com/seemsindie/pidgn_jobs) | Background job processing |
| [pidgn_mailer](https://github.com/seemsindie/pidgn_mailer) | Email sending |
| [pidgn_template](https://github.com/seemsindie/pidgn_template) | Template engine |
| [pidgn_cli](https://github.com/seemsindie/pidgn_cli) | CLI tooling |

## Requirements

- Zig 0.16.0-dev.2535+b5bd49460 or later
- All dependencies are vendored or fetched automatically -- no system libraries required
- PostgreSQL (optional, via Docker Compose)
- OpenSSL 3 (optional, for TLS)

## License

MIT License -- Copyright (c) 2026 Ivan Stamenkovic
