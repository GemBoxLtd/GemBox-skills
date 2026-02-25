#!/usr/bin/env bash
docker run --platform linux/amd64 -it \
  -v "$(pwd)/local-mount":/gembox-skills/docker/local-mount \
  -w /gembox-skills/docker/local-mount \
  gembox/gembox-skill:latest
