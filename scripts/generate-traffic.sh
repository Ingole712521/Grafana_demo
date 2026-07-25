#!/bin/sh
# Generates traffic so Grafana charts show live data
while true; do
  wget -q -O /dev/null http://demo-app:8080/ 2>/dev/null || true
  wget -q -O /dev/null http://demo-app:8080/api/data 2>/dev/null || true
  wget -q -O /dev/null http://demo-app:8080/health 2>/dev/null || true
  sleep 2
done
