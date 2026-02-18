sudo docker run -d -p 80:80 nginx

sudo docker ps

curl http://localhost:80

sudo docker images

sudo docker ps

sudo docker run -d -p 81:80 nginx

cat > index.html <<'EOF'
<h1>Hello from my custom index</h1>
EOF

sudo docker cp ./index.html <container_id_or_name>:/usr/share/nginx/html/index.html

sudo docker exec -it <container_id_or_name> /bin/bash