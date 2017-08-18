#!/usr/bin/env bash
docker run \
  -d \
  --name tm \
  -p 80:80 \
  timhaak/tech-maturity
