#!/bin/bash

# Set strings used as environment variables
mysql_root_password="MYSQL_ROOT_PASSWORD=root"
mysql_user="MYSQL_USER=petclinic"
mysql_password="MYSQL_PASSWORD=petclinic"
mysql_database="MYSQL_DATABASE=petclinic"

spring_profile="SPRING_PROFILES_ACTIVE=mysql"
mysql_url="MYSQL_URL=jdbc:mysql://172.16.0.2/petclinic"

# Clean up containers and networks
docker rm -f $(docker ps -a -q)
docker network rm internal

# Create network and build images
docker network create --subnet=172.16.0.0/16 internal
docker build -f docker/Dockerfile.mysql -t database .
docker build -f docker/Dockerfile.petclinic --build-arg container_tag=stable -t stable .
docker build -f docker/Dockerfile.petclinic --build-arg container_tag=$1 -t latest .
docker build -f docker/Dockerfile.web -t haproxy .
docker build -f docker/Dockerfile.prom -t prometheus .

# Start containers
docker run --net internal --ip 172.16.0.2 -d --name database --env=$mysql_root_password --env=$mysql_user --env=$mysql_password --env=$mysql_database database
docker run --net internal --ip 172.16.0.3 -d --name stable --env=$spring_profile --env=$mysql_url stable
docker run --net internal --ip 172.16.0.4 -d --name latest --env=$spring_profile --env=$mysql_url latest
docker run --net internal --ip 172.16.0.5 -d -p 8080:8080 -p 8404:8404 --name haproxy haproxy
docker run --net internal --ip 172.16.0.6 -d -p 9090:9090 --name prometheus prometheus