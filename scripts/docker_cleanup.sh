#!/bin/bash

# Clean up orphaned Docker containers
docker ps -aq --filter "status=exited" | xargs docker rm -v

# Prune Docker system
docker system prune -af

