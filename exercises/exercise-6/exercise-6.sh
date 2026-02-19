docker build -t envlab-bad --build-arg DB_PASSWORD="super-secret-123" -f app/Dockerfile app

docker run --rm -e APP_ENV=dev envlab-bad

docker inspect envlab-bad | grep -n "DB_PASSWORD" -n || true
