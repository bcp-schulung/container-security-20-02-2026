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
