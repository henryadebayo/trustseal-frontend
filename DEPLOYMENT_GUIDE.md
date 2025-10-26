# 🚀 Free Backend Deployment Guide for TrustSeal

This guide will help you deploy the TrustSeal backend to free hosting platforms.

---

## 📋 Table of Contents

- [Platform Comparison](#platform-comparison)
- [Option 1: Render.com (Recommended)](#option-1-rendercom-recommended)
- [Option 2: Railway.app](#option-2-railwayapp)
- [Option 3: Fly.io](#option-3-flyio)
- [Configuration Guide](#configuration-guide)
- [Post-Deployment](#post-deployment)
- [Troubleshooting](#troubleshooting)

---

## 🎯 Platform Comparison

| Platform | Free Tier | PostgreSQL | Redis | Docker | Difficulty | Best For |
|----------|-----------|------------|-------|--------|------------|----------|
| **Render.com** | ✅ Good | ✅ Managed | ✅ Managed | ✅ Yes | ⭐ Easy | **Recommended** |
| **Railway.app** | ✅ Good | ✅ Managed | ✅ Managed | ✅ Yes | ⭐ Easy | Modern Apps |
| **Fly.io** | ✅ Good | ⚠️ Self-host | ⚠️ Self-host | ✅ Yes | ⭐⭐ Medium | Docker Apps |
| **Vercel** | ⚠️ Limited | ❌ No | ❌ No | ❌ No | ⭐ Easy | Frontend Only |
| **Heroku** | ❌ Ended | N/A | N/A | ⚠️ Yes | ⭐ Easy | Legacy |

**Winner: Render.com** - Best free tier, managed databases, easy setup

---

## ✅ Option 1: Render.com (Recommended)

### Why Render.com?

- ✅ Generous free tier (750 hours/month)
- ✅ Free managed PostgreSQL
- ✅ Free managed Redis  
- ✅ Auto-deploys from Git
- ✅ Built-in Docker support
- ✅ Automatic HTTPS
- ✅ No credit card required

### Step-by-Step Deployment

#### 1. Create Render Account

```bash
# Visit https://render.com
# Sign up with GitHub (recommended)
```

#### 2. Create PostgreSQL Database

1. Go to Dashboard → **New → PostgreSQL**
2. Name: `trustseal-db`
3. Region: Select closest to you
4. PostgreSQL Version: 15
5. Click **Create Database**
6. Copy the **Internal Database URL**

#### 3. Create Redis Instance

1. Go to Dashboard → **New → Redis**
2. Name: `trustseal-redis`
3. Region: Same as database
4. Click **Create Redis**
5. Copy the **Internal Redis URL**

#### 4. Deploy Backend

1. Go to Dashboard → **New → Web Service**
2. Connect your GitHub repository
3. Select the `trustseal-backend` repo
4. Configure:

```yaml
Name: trustseal-backend
Region: Same as database
Branch: main
Runtime: Docker
```

5. Add Environment Variables:

```bash
# Database
DB_HOST=<internal-db-host-from-step-2>
DB_PORT=5432
DB_NAME=trustseal
DB_USER=<database-user-from-step-2>
DB_PASSWORD=<database-password-from-step-2>

# Redis
REDIS_HOST=<redis-host-from-step-3>
REDIS_PORT=6379
REDIS_PASSWORD=<redis-password-from-step-3>

# JWT
JWT_SECRET=<generate-a-random-secret-string>
JWT_EXPIRATION=15m

# Node Environment
NODE_ENV=production
PORT=3000

# Blockchain RPC
BLOCKDAG_RPC_URL=https://rpc.blockdag.network
ETHEREUM_RPC_URL=https://eth.llamarpc.com

# BlockDAG Contract (update with your deployed contract)
VAULT_CONTRACT_ADDRESS=0xd54d40692605feebbe296e1cd0b5cf910602ad90
PRIVATE_KEY=<your-blockdag-private-key>

# Optional: AWS S3
AWS_ACCESS_KEY_ID=<your-key>
AWS_SECRET_ACCESS_KEY=<your-secret>
AWS_REGION=us-east-1
AWS_S3_BUCKET=<your-bucket>

# Optional: IPFS (use local fallback if not available)
IPFS_HOST=localhost
IPFS_PORT=5001
IPFS_PROTOCOL=http
```

6. Click **Create Web Service**

#### 5. Wait for Deployment

Render will:
- Build your Docker image
- Install dependencies
- Run database migrations
- Start the server

**Time: ~5-10 minutes**

#### 6. Get Your Backend URL

```
Your backend: https://trustseal-backend.onrender.com
```

### Configure Dockerfile for Render

Update your `Dockerfile` to handle Render's requirements:

```dockerfile
FROM node:18-alpine

WORKDIR /app

# Copy package files
COPY package*.json ./

# Install dependencies
RUN npm ci --only=production

# Copy application code
COPY . .

# Run migrations on startup
RUN echo "#!/bin/sh\nnode src/database/migrate.js" > /start.sh

# Expose port
EXPOSE 3000

# Start server
CMD ["node", "src/server.js"]
```

### Deploy Using Render Dashboard

1. Go to https://dashboard.render.com
2. Click **New + → Web Service**
3. Connect your repository
4. Configure:
   - Name: `trustseal-backend`
   - Environment: `Docker`
   - Region: `Singapore` (closest to users)
   - Build Command: `docker build -t trustseal-backend .`
   - Start Command: `node src/server.js`
5. Add environment variables (from step 4 above)
6. Click **Create Web Service**

**Deployment time: ~10 minutes**

---

## 🚂 Option 2: Railway.app

### Why Railway.app?

- ✅ Free tier (500 hours/month)
- ✅ Managed PostgreSQL
- ✅ Managed Redis
- ✅ Auto-deploy from Git
- ✅ Great developer experience

### Deployment Steps

#### 1. Sign Up

```bash
# Visit https://railway.app
# Sign up with GitHub
```

#### 2. Create Project

1. Click **New Project**
2. Select **Deploy from GitHub repo**
3. Connect `trustseal-backend` repository

#### 3. Add Database

1. Click **New → Database → PostgreSQL**
2. Railway automatically creates database
3. Get connection string from **Variables** tab

#### 4. Add Redis

1. Click **New → Redis**
2. Railway automatically creates Redis
3. Get connection string from **Variables** tab

#### 5. Configure Environment Variables

Railway auto-generates database variables. Add these manually:

```bash
JWT_SECRET=<generate-random-secret>
JWT_EXPIRATION=15m
NODE_ENV=production
BLOCKDAG_RPC_URL=https://rpc.blockdag.network
VAULT_CONTRACT_ADDRESS=0xd54d40692605feebbe296e1cd0b5cf910602ad90
PRIVATE_KEY=<your-private-key>
```

#### 6. Deploy

Railway automatically:
- Builds and deploys
- Runs migrations
- Starts the server

**URL:** `https://trustseal-backend.up.railway.app`

---

## ✈️ Option 3: Fly.io

### Why Fly.io?

- ✅ Free tier (3 shared VMs)
- ✅ Global edge deployment
- ✅ Great for Docker apps
- ⚠️ Requires command-line setup

### Deployment Steps

#### 1. Install Fly CLI

```bash
# macOS
curl -L https://fly.io/install.sh | sh

# Or via Homebrew
brew install flyctl
```

#### 2. Login

```bash
fly auth login
```

#### 3. Create Fly App

```bash
cd trustseal-backend
fly launch
```

#### 4. Configure fly.toml

```toml
app = "trustseal-backend"
primary_region = "ord"  # Chicago

[build]
  dockerfile = "Dockerfile"

[[services]]
  internal_port = 3000
  protocol = "tcp"

  [[services.ports]]
    handlers = ["http"]
    port = 80
    force_https = true

  [[services.ports]]
    handlers = ["tls", "http"]
    port = 443

[env]
  NODE_ENV = "production"
  PORT = "3000"

[[vm]]
  memory_mb = 512
  cpu_kind = "shared"
  cpus = 1
```

#### 5. Deploy

```bash
fly deploy
```

#### 6. Configure Secrets

```bash
fly secrets set JWT_SECRET=<your-secret>
fly secrets set VAULT_CONTRACT_ADDRESS=0xd54d40692605feebbe296e1cd0b5cf910602ad90
fly secrets set PRIVATE_KEY=<your-key>
fly secrets set DB_HOST=<postgres-host>
fly secrets set REDIS_HOST=<redis-host>
```

#### 7. Get Your URL

```bash
fly info
```

**URL:** `https://trustseal-backend.fly.dev`

---

## ⚙️ Configuration Guide

### Generate Secure Secrets

```bash
# Generate JWT Secret (openssl)
openssl rand -base64 32

# Or use Node.js
node -e "console.log(require('crypto').randomBytes(32).toString('base64'))"
```

### Update .env.example

Before deploying, update `.env.example` with placeholder values:

```bash
NODE_ENV=production
PORT=3000

# Database (will be provided by hosting platform)
DB_HOST=your-db-host
DB_PORT=5432
DB_NAME=trustseal
DB_USER=your-db-user
DB_PASSWORD=your-db-password

# Redis (will be provided by hosting platform)
REDIS_HOST=your-redis-host
REDIS_PORT=6379

# JWT (generate your own)
JWT_SECRET=your-super-secret-jwt-key
JWT_EXPIRATION=15m

# Blockchain
BLOCKDAG_RPC_URL=https://rpc.blockdag.network
ETHEREUM_RPC_URL=https://eth.llamarpc.com
VAULT_CONTRACT_ADDRESS=0xd54d40692605feebbe296e1cd0b5cf910602ad90
PRIVATE_KEY=your-blockdag-private-key

# Optional Services
AWS_ACCESS_KEY_ID=
AWS_SECRET_ACCESS_KEY=
AWS_REGION=us-east-1
AWS_S3_BUCKET=
```

### Run Migrations

After deployment, run migrations:

**Option 1: Via SSH/Shell**
```bash
# On your hosting platform
npm run migrate
```

**Option 2: Add to start script**

Create `start.sh`:
```bash
#!/bin/sh
node src/database/migrate.js
node src/server.js
```

Update `Dockerfile`:
```dockerfile
CMD ["node", "src/server.js"]
```

Or use Docker Compose for local testing:
```yaml
# docker-compose.yml
services:
  web:
    build: .
    command: sh -c "npm run migrate && node src/server.js"
    environment:
      - NODE_ENV=production
```

---

## 🎯 Post-Deployment

### Test Your Deployment

```bash
# Health check
curl https://your-backend-url.railway.app/health

# Should return:
{
  "status": "healthy",
  "timestamp": "2024-01-01T00:00:00.000Z",
  "service": "trustseal-backend"
}
```

### Update Frontend

Point your frontend to the new backend URL:

```dart
// Flutter example
const String baseUrl = 'https://your-backend-url.railway.app';
```

### Monitor Logs

**Render.com:**
```bash
# View logs in dashboard
Dashboard → Your Service → Logs
```

**Railway:**
```bash
# View logs in dashboard
Deployments → View Logs
```

**Fly.io:**
```bash
# View logs via CLI
fly logs
```

---

## 🔧 Troubleshooting

### Common Issues

#### 1. Database Connection Failed

**Error:** `Cannot connect to database`

**Solution:**
- Check database credentials in environment variables
- Ensure database is running
- Check firewall rules allow connection

#### 2. Migration Failed

**Error:** `Migration failed`

**Solution:**
- Run migrations manually via terminal
- Check database user has permissions
- Verify `.sql` files have correct syntax

#### 3. Build Failed

**Error:** `Docker build failed`

**Solution:**
- Check `Dockerfile` syntax
- Ensure all dependencies are in `package.json`
- Check build logs for specific errors

#### 4. Redis Connection Failed

**Error:** `Cannot connect to Redis`

**Solution:**
- Check Redis credentials
- Use Redis URL if provided
- Add Redis instance to your project

#### 5. Out of Memory

**Error:** `JavaScript heap out of memory`

**Solution:**
- Increase memory in hosting settings
- Add to `package.json`:
```json
"scripts": {
  "start": "node --max-old-space-size=512 src/server.js"
}
```

---

## 📊 Free Tier Limits

### Render.com
- 750 hours/month (enough for 24/7 operation)
- 512MB RAM
- Free PostgreSQL (90 days inactive = pause)
- Free Redis (expires if inactive)
- Bandwidth: 100GB/month

### Railway.app
- 500 hours/month
- 512MB RAM
- Free PostgreSQL included
- Free Redis included
- Bandwidth: 100GB/month

### Fly.io
- 3 shared VMs (free)
- 256MB RAM per VM
- Bandwidth: 3GB/month
- PostgreSQL: Self-hosted or paid

---

## 🚀 Quick Deploy (Recommended: Render)

### One-Click Deploy Button

Add this to your README.md:

```markdown
[![Deploy to Render](https://render.com/images/deploy-to-render-button.svg)](https://render.com/deploy)
```

### Deploy Command (Render)

```bash
# 1. Push to GitHub
git push origin main

# 2. Connect to Render
# Visit https://render.com → Connect GitHub

# 3. Add database and Redis
# Follow steps above

# 4. Deploy
# Render auto-deploys from main branch
```

---

## 📝 Summary

**Best Option:** Render.com
- ✅ Easiest setup
- ✅ Managed databases
- ✅ Auto-deploy
- ✅ Free tier is generous

**Quick Start:**
1. Sign up for Render.com
2. Connect GitHub repo
3. Create PostgreSQL + Redis
4. Create Web Service
5. Add environment variables
6. Deploy!

**Your backend will be live in ~10 minutes! 🎉**

---

## 🔗 Resources

- [Render Documentation](https://render.com/docs)
- [Railway Documentation](https://docs.railway.app)
- [Fly.io Documentation](https://fly.io/docs)
- [TrustSeal Backend README](./README.md)

---

**Need help?** Open an issue or contact support!
