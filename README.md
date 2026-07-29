# 🛒 ShopZone - Production E-Commerce Infrastructure

> **Cloud Computing & DevOps - Task 5** | Production-Grade Multi-Container Deployment

## 🏗️ Architecture

```
Internet
   │
   ▼
Nginx (Port 80)          ← Reverse Proxy + Load Balancer
   ├── /          →  Frontend (React/HTML)
   └── /api/      →  Backend (Node.js API)
                         ├── PostgreSQL (Database)
                         └── Redis (Cache)

Monitoring Stack:
   ├── Prometheus (Port 9090)
   ├── Grafana    (Port 3000)
   ├── Node Exporter
   └── cAdvisor
```

## 🚀 Quick Start (EC2 Setup)

### 1. Launch EC2 Instance
- **AMI:** Ubuntu 22.04 LTS
- **Instance Type:** t2.medium (2 vCPU, 4GB RAM)
- **Security Group Ports:** 22, 80, 3000, 9090

### 2. Install Docker on EC2
```bash
sudo apt update && sudo apt upgrade -y
sudo apt install -y docker.io docker-compose-v2 git curl
sudo usermod -aG docker ubuntu
newgrp docker
```

### 3. Clone & Deploy
```bash
git clone https://github.com/YOUR_USERNAME/production-devops-project.git
cd production-devops-project
cp .env.example .env
nano .env          # Edit passwords!
bash deploy.sh
```

### 4. Access Your App
| Service     | URL                          |
|-------------|------------------------------|
| 🌐 App      | http://YOUR_EC2_IP           |
| 📊 Grafana  | http://YOUR_EC2_IP:3000      |
| 📈 Prometheus | http://YOUR_EC2_IP:9090    |

---

## 📁 Project Structure

```
production-devops-project/
├── frontend/          # HTML/CSS/JS frontend
│   ├── index.html
│   └── Dockerfile
├── backend/           # Node.js REST API
│   ├── server.js
│   ├── package.json
│   └── Dockerfile
├── nginx/             # Reverse proxy config
│   └── nginx.conf
├── monitoring/        # Prometheus config
│   └── prometheus.yml
├── database/          # DB init scripts
│   └── init.sql
├── .github/workflows/ # CI/CD pipeline
│   └── deploy.yml
├── docker-compose.yml # All 9 services
├── .env.example       # Environment template
├── deploy.sh          # One-command deploy
├── backup.sh          # Auto backup
└── healthcheck.sh     # Health monitoring
```

---

## 🔧 Commands Reference

```bash
# Start all services
docker compose up -d

# Stop all services
docker compose down

# View logs
docker compose logs -f backend
docker compose logs -f nginx

# Rebuild specific service
docker compose up -d --build backend

# Health check
bash healthcheck.sh

# Manual backup
bash backup.sh

# Scale backend (load balancing)
docker compose up -d --scale backend=2
```

---

## ⚙️ GitHub Actions CI/CD Setup

Add these **Secrets** in GitHub → Settings → Secrets:

| Secret        | Value                        |
|---------------|------------------------------|
| `EC2_HOST`    | Your EC2 Public IP           |
| `EC2_USER`    | `ubuntu`                     |
| `EC2_SSH_KEY` | Your `.pem` private key content |

**Workflow:** Push to `main` → Auto build → Test → SSH Deploy → Health Check ✅

---

## 📊 Grafana Setup

1. Open http://YOUR_EC2_IP:3000
2. Login: `admin` / `Admin@Grafana123`
3. Add Prometheus source: `http://prometheus:9090`
4. Import Dashboard ID: **1860** (Node Exporter Full)
5. Import Dashboard ID: **893** (Docker cAdvisor)

---

## 🔒 Security Features

- ✅ Non-root containers
- ✅ Environment variables (no hardcoded secrets)
- ✅ Internal Docker networks (DB not exposed)
- ✅ Security headers in Nginx
- ✅ Resource limits (CPU + Memory)
- ✅ `.env` in `.gitignore`

---

## 📦 Services Summary

| Container     | Image              | Port  | Purpose          |
|---------------|--------------------|-------|------------------|
| nginx         | nginx:alpine       | 80    | Reverse Proxy    |
| frontend      | custom             | -     | Web UI           |
| backend       | custom (Node.js)   | 8080  | REST API         |
| postgres      | postgres:16-alpine | -     | Database         |
| redis         | redis:7-alpine     | -     | Cache            |
| prometheus    | prom/prometheus    | 9090  | Metrics          |
| grafana       | grafana/grafana    | 3000  | Dashboard        |
| node-exporter | prom/node-exporter | 9100  | System Metrics   |
| cadvisor      | cadvisor           | -     | Container Metrics|

---

## 🗓️ Automated Backup (Cron)

```bash
# Add to crontab for daily 2AM backup
crontab -e
# Add this line:
0 2 * * * cd /home/ubuntu/production-devops-project && bash backup.sh >> backups/backup.log 2>&1
```

---

**Skills Demonstrated:** Docker Compose · Multi-Container · Nginx · PostgreSQL · Redis · Prometheus · Grafana · GitHub Actions CI/CD · Zero-Downtime Deploy · Backup Automation · Security Hardening
