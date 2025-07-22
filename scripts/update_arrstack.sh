#!/bin/bash

cd $DOCKERDIR

sudo docker compose down

sudo sh ./scripts/docker_cleanup.sh
sudo sh ./scripts/update_docker_images.sh

sudo docker compose up -d