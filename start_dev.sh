#!/usr/bin/env bash

export DEVELOPPER=$(whoami)
sudo chown -R $(whoami):$(whoami) $(pwd)/database
chmod -R 777 $(pwd)/database

sudo chown -R $(whoami):$(whoami) $(pwd)/composer_cache
chmod -R 777 $(pwd)/composer_cache

sudo docker-compose down -v
sudo docker-compose up --build
