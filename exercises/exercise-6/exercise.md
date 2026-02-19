# Docker Env Vars & Secrets Lab (with Docker Compose)

This mini lab teaches how to pass **environment variables** and **secrets** into containers, including **what NOT to do** and the **recommended approach** using **Docker Compose secrets**.

---

## Learning goals

By the end, students can:

- Explain the difference between **config** (env vars) and **secrets**
- Identify **common secret-leak mistakes**
- Use Docker Compose to:
  - pass **non-sensitive config** via `.env`
  - mount **secrets as files** via `secrets:`
- Verify whether a secret leaked using `docker inspect`

---

## Prerequisites

- Docker installed
- Docker Compose available (`docker compose version`)

---

## Project setup

### Step 0 — Create a clean folder

```bash
mkdir docker-env-secrets-lab
cd docker-env-secrets-lab
mkdir app
```

### Step 1 — Create a tiny app that prints config

The app prints `APP_ENV` (non-sensitive) and reads a DB password either from:

- `DB_PASSWORD` (bad pattern), **or**
- `DB_PASSWORD_FILE` (good pattern: secret file)

Create `app/server.sh`:

```bash
cat > app/server.sh <<'EOF'
#!/usr/bin/env sh
set -eu

echo "=== App starting ==="
echo "APP_ENV=${APP_ENV:-<not set>}"

# read password from either env or a mounted secret file
if [ -n "${DB_PASSWORD:-}" ]; then
  echo "DB_PASSWORD is set via env (NOT recommended). Length: $(printf "%s" "$DB_PASSWORD" | wc -c | tr -d ' ')"
elif [ -f "${DB_PASSWORD_FILE:-}" ]; then
  pw="$(cat "$DB_PASSWORD_FILE")"
  echo "DB_PASSWORD loaded from file secret. Length: $(printf "%s" "$pw" | wc -c | tr -d ' ')"
else
  echo "No DB password provided."
fi

# keep container alive for inspection
echo "Sleeping... (Ctrl+C to stop)"
sleep infinity
EOF

chmod +x app/server.sh
```

Create `app/Dockerfile`:

```bash
cat > app/Dockerfile <<'EOF'
FROM alpine:3.20
WORKDIR /app
COPY server.sh /app/server.sh
RUN chmod +x /app/server.sh
CMD ["/app/server.sh"]
EOF
```

---

## Part A — ❌ The WRONG ways (learn what NOT to do)

### Step 2A — Wrong #1: bake secrets into the image

Never put secrets into a Docker image. Images are shared, cached, uploaded to registries, and inspected.

Replace `app/Dockerfile` with this intentionally bad version:

```bash
cat > app/Dockerfile <<'EOF'
FROM alpine:3.20
ARG DB_PASSWORD
ENV DB_PASSWORD=$DB_PASSWORD
WORKDIR /app
COPY server.sh /app/server.sh
RUN chmod +x /app/server.sh
CMD ["/app/server.sh"]
EOF
```

Build and run:

```bash
docker build -t envlab-bad --build-arg DB_PASSWORD="super-secret-123" -f app/Dockerfile app
docker run --rm -e APP_ENV=dev envlab-bad
```

Quick proof: the secret can appear in image/container metadata:

```bash
docker inspect envlab-bad | grep -n "DB_PASSWORD" || true
```

**Why this is bad**

The secret becomes part of image config and may leak through:

- registries
- CI logs
- image scans / support bundles
- `docker inspect`

### Step 3A — Wrong #2: put secrets in `docker-compose.yml` `environment:`

Create a “bad compose” file:

```bash
cat > docker-compose.bad.yml <<'EOF'
services:
  app:
    build: ./app
    environment:
      APP_ENV: "dev"
      DB_PASSWORD: "super-secret-123"  # ❌ bad: easy to leak and often committed
EOF
```

Run it:

```bash
docker compose -f docker-compose.bad.yml up --build
```

In another terminal, inspect container metadata:

```bash
docker compose -f docker-compose.bad.yml ps
docker inspect $(docker compose -f docker-compose.bad.yml ps -q app) | grep -n "DB_PASSWORD" || true
```

**Why this is bad**

- People commit Compose files to git
- Container configuration can be dumped and shared
- Secrets show up via `inspect` and sometimes logs

---

## Part B — ✅ The RIGHT way (recommended)

We will:

- Use `.env` for non-sensitive config
- Use a `secrets/` file for sensitive data
- Use Docker Compose `secrets:` to mount secrets as files at runtime

### Step 2B — Restore a safe Dockerfile

Replace `app/Dockerfile` with the safe version:

```bash
cat > app/Dockerfile <<'EOF'
FROM alpine:3.20
WORKDIR /app
COPY server.sh /app/server.sh
RUN chmod +x /app/server.sh
CMD ["/app/server.sh"]
EOF
```

### Step 3B — Create `.env` for non-sensitive config

Create `.env`:

```bash
cat > .env <<'EOF'
APP_ENV=dev
EOF
```

> `.env` is okay for non-secret configuration. Do **not** store secrets in `.env`.

### Step 4B — Create a secret file (DO NOT COMMIT IT)

```bash
mkdir -p secrets
printf "super-secret-123\n" > secrets/db_password.txt
```

Add a `.gitignore`:

```bash
cat > .gitignore <<'EOF'
.env
secrets/
EOF
```

Optional: you can commit a template like `.env.example`, but not the real `.env`.

### Step 5B — Create `docker-compose.yml` using secrets

Create `docker-compose.yml`:

```bash
cat > docker-compose.yml <<'EOF'
services:
  app:
    build: ./app
    env_file:
      - .env
    environment:
      # ✅ non-secret config via env var
      APP_ENV: ${APP_ENV}

      # ✅ tell app where the secret file will be mounted
      DB_PASSWORD_FILE: /run/secrets/db_password

    secrets:
      - db_password

secrets:
  db_password:
    file: ./secrets/db_password.txt
EOF
```

Run:

```bash
docker compose up --build
```

You should see output like:

```text
APP_ENV=dev
DB_PASSWORD loaded from file secret...
```

### Step 6 — Verify the secret is mounted as a file

In another terminal:

```bash
docker compose exec app sh -lc 'ls -l /run/secrets && echo "----" && cat /run/secrets/db_password'
```

### Step 7 — Checks: confirm secrets did NOT leak into env vars

Start again in detached mode:

```bash
docker compose up -d --build
```

Inspect and search for the `DB_PASSWORD` strings in container config:

```bash
docker inspect $(docker compose ps -q app) | grep -n "DB_PASSWORD" || true
```
