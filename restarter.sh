#!/bin/sh -x

while true; do
  sleep 3600;
  docker compose up $RESET_SERVICES -d --force-recreate
done