sudo docker stop <container_id_or_name>

sudo docker rm <container_id_or_name>

sudo docker ps -a

sudo docker images

sudo docker image rm <image_id_or_name>

sudo docker pull nginx

sudo docker tag nginx:latest registry.it-scholar.com/nginx:latest

sudo docker images

sudo docker image rm nginx:latest

sudo docker push registry.it-scholar.com/nginx:latest

sudo docker run -d -p 80:80 registry.it-scholar.com/nginx:latest

sudo docker ps