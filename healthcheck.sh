#!/bin/bash

GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

check() {
  local name=$1
  local url=$2
  if curl -sf "$url" > /dev/null 2>&1; then
    echo -e "${GREEN}✅ $name - HEALTHY${NC}"
  else
    echo -e "${RED}❌ $name - UNHEALTHY${NC}"
  fi
}

echo "========== Health Check Report =========="
echo "Time: $(date)"
echo ""
check "Nginx (Port 80)"       "http://localhost/"
check "Backend API"           "http://localhost/health"
check "Prometheus"            "http://localhost:9090/-/healthy"
check "Grafana"               "http://localhost:3000/api/health"
echo ""
echo "========== Container Status =========="
docker compose ps
echo ""
echo "========== Resource Usage =========="
docker stats --no-stream --format "table {{.Name}}\t{{.CPUPerc}}\t{{.MemUsage}}"
