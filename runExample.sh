#!/usr/bin/env bash
docker stop tm
docker rm -f tm
docker run \
  -d \
  --restart=always \
  --hostname tm.haak.co \
  --name tm \
  -v /docker/tm/logs:/site/logs \
  -v /docker/tm/db:/site/db \
  -p 80:80 \
  timhaak/tech-maturity
