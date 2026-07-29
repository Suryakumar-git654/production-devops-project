#!/bin/bash
set -e

echo "======================================"
echo "  ShopZone Production Deploy Script"
echo "======================================"

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

log() { echo -e "${GREEN}[$(date '+%H:%M:%S')] $1${NC}"; }
warn() { echo -e "${YELLOW}[WARN] $1${NC}"; }
error() { echo -e "${RED}[ERROR] $1${NC}"; exit 1; }

# Step 1: Pull latest code
log "Pulling latest code from GitHub..."
git pull origin main || warn "Git pull failed - deploying current code"

# Step 2: Check .env exists
if [ ! -f .env ]; then
  error ".env file not found! Copy .env.example to .env and fill values."
fi

# Step 3: Backup database before deploy
log "Taking database backup before deploy..."
bash backup.sh || warn "Backup failed - continuing deploy"

# Step 4: Build new images
log "Building Docker images..."
docker compose build --no-cache

# Step 5: Rolling restart (zero downtime)
log "Starting rolling deployment..."
docker compose up -d --remove-orphans

# Step 6: Wait for services to be healthy
log "Waiting for services to be healthy..."
sleep 15

# Step 7: Health check
log "Running health checks..."
MAX_RETRIES=10
COUNT=0
until curl -sf http://localhost/health > /dev/null 2>&1; do
  COUNT=$((COUNT+1))
  if [ $COUNT -ge $MAX_RETRIES ]; then
    error "Health check failed after $MAX_RETRIES attempts! Rolling back..."
    docker compose down
    git stash
    docker compose up -d
    exit 1
  fi
  warn "Health check attempt $COUNT/$MAX_RETRIES - retrying in 5s..."
  sleep 5
done

# Step 8: Show running containers
log "Deployment successful! Running containers:"
docker compose ps

echo ""
echo -e "${GREEN}======================================"
echo "  Deployment Complete!"
echo "  App:        http://$(curl -s ifconfig.me 2>/dev/null || echo 'YOUR_EC2_IP')"
echo "  Grafana:    http://$(curl -s ifconfig.me 2>/dev/null || echo 'YOUR_EC2_IP'):3000"
echo "  Prometheus: http://$(curl -s ifconfig.me 2>/dev/null || echo 'YOUR_EC2_IP'):9090"
echo -e "======================================${NC}"
