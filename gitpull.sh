#!/bin/bash
# This script only works when your containers are running with docker-compose up!
# Also remember to make this executable!
# sudo chmod +x gitpull.sh

# Get ID of docker container that has git installed
DOCKER_ID=$(docker ps -qf "name=php")

# Pull from git source using socks5 tor proxy
docker exec -it $DOCKER_ID git config --global http.proxy socks5h://tor:9050

# Check and pull source if updated
docker exec -it $DOCKER_ID git -C /usr/share/nginx/html pull

# Remove twig cache
rm -rf /usr/share/nginx/html/twig_cache
