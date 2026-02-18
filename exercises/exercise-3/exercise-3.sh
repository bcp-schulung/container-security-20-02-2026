mkdir exercise-3

cd exercise-3

cat > index.html <<'EOF'
<h1>Mein toller Webauftritt</h1>
EOF

cat > Dockerfile <<'EOF'
FROM nginx:latest

COPY index.html /usr/share/nginx/html/index.html

EXPOSE 80
EOF

sudo docker build -t exercise-3:latest .

sudo docker run -d -p 8080:80 --name exercise-3 exercise-3:latest

curl http://localhost:8080

sudo docker stop exercise-3

sudo docker rm exercise-3