#!/usr/bin/env bash
docker build --platform linux/amd64 -t gembox/gembox-skill:latest -f Dockerfile ..
