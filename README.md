# TrustSeal Backend

TrustSeal Backend is a comprehensive blockchain project verification platform that provides automated risk assessment, trust scoring, and monitoring for cryptocurrency projects.

## 🚀 Features

- **Automated Verification Engine**: Multi-tier scoring system with weighted criteria
- **Blockchain Integration**: Contract verification and liquidity lock monitoring
- **Real-time Monitoring**: Automated checks and risk reassessment
- **RESTful API**: Complete API for project management and verification
- **Role-based Access Control**: Secure admin and reviewer roles
- **Audit Logging**: Complete audit trail for compliance

## 📋 Prerequisites

- Node.js 18+ 
- PostgreSQL 15+
- Redis 7+
- npm or yarn

## 🛠️ Installation

1. **Clone the repository**
```bash
git clone <repository-url>
cd trustseal-backend
```

2. **Install dependencies**
```bash
npm install
```

3. **Set up environment variables**
```bash
cp .env.example .env
# Edit .env with your configuration
```

4. **Start PostgreSQL and Redis**
```bash
# Using Docker Compose
docker-compose up -d db redis

# Or start manually
```

5. **Run database migrations**
```bash
npm run migrate
```

6. **Start the server**
```bash
# Development mode
npm run dev

# Production mode
npm start
```

## 🔧 Configuration

Key environment variables:

- `DB_HOST`, `DB_PORT`, `DB_NAME`, `DB_USER`, `DB_PASSWORD` - Database configuration
- `REDIS_HOST`, `REDIS_PORT` - Redis configuration
- `JWT_SECRET` - JWT signing secret
- `ETHEREUM_RPC_URL` - Ethereum RPC endpoint
- `ETHERSCAN_API_KEY` - Etherscan API key

See `.env.example` for all available options.

## 📊 Database Schema

### Core Tables
- `projects` - Project information and verification status
- `verification_criteria` - Scoring breakdown by category
- `verification_checks` - Individual verification checks
- `audit_logs` - Audit trail
- `admin_users` - Admin users and roles

## 🎯 API Endpoints

### Projects
- `GET /api/v1/projects` - List all projects
- `GET /api/v1/projects/:id` - Get project details
- `POST /api/v1/projects` - Create new project
- `PUT /api/v1/projects/:id` - Update project

### Verification
- `POST /api/v1/projects/:id/verify` - Initiate verification
- `GET /api/v1/projects/:id/verification-status` - Get verification status
- `POST /api/v1/projects/:id/verification-checks` - Add verification check

### Admin
- `GET /api/v1/admin/verification-queue` - Get verification queue
- `POST /api/v1/admin/approve/:projectId` - Approve project
- `POST /api/v1/admin/reject/:projectId` - Reject project

## 🔐 Scoring System

The verification engine uses a weighted scoring system:

- **Team Verification** (25%): Team doxxing, LinkedIn, background checks
- **Technical Verification** (30%): Smart contract audits, code quality, security
- **Financial Verification** (25%): Financial audits, liquidity locks
- **Community Verification** (20%): Social media, engagement, community size

Risk adjustments are applied based on red/yellow flags.

## 📝 License

MIT
