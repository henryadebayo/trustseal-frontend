# TrustSeal Backend

> **A Comprehensive Blockchain Project Verification Platform with Hybrid Encryption Vault System**

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Node.js Version](https://img.shields.io/badge/node-%3E%3D18.0.0-brightgreen)](https://nodejs.org/)
[![PostgreSQL](https://img.shields.io/badge/PostgreSQL-15+-blue)](https://www.postgresql.org/)

## 📋 Table of Contents

- [Overview](#overview)
- [Features](#-features)
- [Architecture](#-architecture)
- [Installation](#-installation)
- [Configuration](#-configuration)
- [API Reference](#-api-reference)
- [Usage Examples](#-usage-examples)
- [Security](#-security)
- [Deployment](#-deployment)
- [License](#-license)

---

## 🎯 Overview

TrustSeal is a production-ready blockchain project verification platform that provides automated risk assessment, trust scoring, and monitoring for cryptocurrency projects. It features a revolutionary **Hybrid Encryption Vault System** that enables secure file upload and key exchange via BlockDAG blockchain.

### Key Highlights

- ✅ **Automated Verification Engine** with weighted multi-tier scoring
- ✅ **Hybrid Encryption Vault** (AES-256-CBC + RSA-2048) for secure document storage
- ✅ **BlockDAG Blockchain Integration** for on-chain key exchange and transactions
- ✅ **IPFS Integration** for decentralized file storage
- ✅ **Role-Based Access Control** (Admin, Business Owner, User)
- ✅ **Multi-Authentication** (JWT, Web3 Wallet, Google OAuth)
- ✅ **Real-time Monitoring** with automated risk reassessment
- ✅ **AWS S3 Support** with local fallback for file storage
- ✅ **PostgreSQL** with comprehensive audit logging

---

## ✨ Features

### 🔐 Authentication & Authorization
- **JWT-based authentication** with refresh tokens
- **Web3 wallet connection** (MetaMask, WalletConnect)
- **Google OAuth integration** for seamless sign-in
- **Role-based access control** (Admin, Business Owner, User)
- **Password hashing** with bcryptjs
- **Session management** with Redis caching

### 🏢 Business Owner Dashboard
- **Project management** - Create and manage verification projects
- **Application submission** - Multi-step application workflow
- **Status tracking** - Real-time verification status
- **Document upload** - Secure file management
- **Analytics dashboard** - Success rates, scores, timelines

### 🔷 BlockDAG Integration
- **Network health monitoring** - Block height, hashrate, throughput
- **Smart contract verification** - Source code verification, ABI availability
- **Contract feature detection** - Burn, pause, anti-whale, reflection
- **Transaction history** - Volume analysis, holder tracking
- **Real-time blockchain data** - RPC and explorer API integration

### 📁 File Upload & Document Management
- **Multi-format support** - Images, PDFs, documents, spreadsheets
- **AWS S3 integration** with local fallback
- **Image processing** with Sharp (resize, optimize)
- **File validation** - Type, size, content validation
- **Secure storage** with metadata tracking
- **Signed URLs** for secure file access

### 🔐 Hybrid Encryption Vault System
- **Military-grade encryption** - AES-256-CBC for files, RSA-2048 for keys
- **One-time symmetric keys** for each file upload
- **Secure key exchange** via BlockDAG blockchain transactions
- **IPFS integration** for decentralized storage
- **Local fallback** for offline/development use
- **End-to-end encryption** - Files encrypted before upload
- **Receiver (auditor) setup** - Permanent public/private key pairs
- **Key handshake transactions** recorded on-chain

### 📊 Verification Engine
- **Weighted scoring system**:
  - Team Verification (25%): Doxxing, LinkedIn, background checks
  - Technical Verification (30%): Smart contract audits, code quality
  - Financial Verification (25%): Audits, liquidity locks
  - Community Verification (20%): Social media, engagement
- **Risk assessment** with red/yellow flags
- **Verification tiers**: Gold (8.5+), Silver (7.0+), Bronze (5.0+), Basic (3.0+)
- **Automated monitoring** - Hourly liquidity checks, risk reassessment

### 🔍 Monitoring & Compliance
- **Automated risk monitoring** every 6 hours
- **Daily audit reports** at 9 AM
- **Liquidity lock verification** with expiry alerts
- **Complete audit trail** for compliance
- **Real-time notifications** for risk changes

---

## 🏗️ Architecture

### System Components

```
┌─────────────────────────────────────────────────────────────┐
│                       TrustSeal Backend                     │
└─────────────────────────────────────────────────────────────┘
                              │
        ┌─────────────────────┼─────────────────────┐
        ▼                     ▼                     ▼
┌───────────────┐    ┌──────────────┐    ┌───────────────┐
│  PostgreSQL   │    │    Redis     │    │   IPFS/IPFS   │
│   Database    │    │   Cache      │    │   Storage     │
└───────────────┘    └──────────────┘    └───────────────┘
                              │
        ┌─────────────────────┼─────────────────────┐
        ▼                     ▼                     ▼
┌──────────────┐    ┌───────────────┐    ┌──────────────┐
│  BlockDAG    │    │  AWS S3 /     │    │  Vault       │
│  Blockchain  │    │  Local FS     │    │  Encryption  │
└──────────────┘    └───────────────┘    └──────────────┘
```

### Request Flow

```
Client Request
     │
     ├─→ Authentication Middleware (JWT/Wallet)
     │
     ├─→ Authorization Middleware (Role Check)
     │
     ├─→ Request Validation (express-validator)
     │
     ├─→ Rate Limiting
     │
     ├─→ Business Logic (Routes)
     │       │
     │       ├─→ Services
     │       │   ├─→ Vault Service (Encryption)
     │       │   ├─→ Blockchain Service (RPC)
     │       │   ├─→ Verification Engine (Scoring)
     │       │   └─→ File Upload Service (S3/Fallback)
     │       │
     │       └─→ Database (PostgreSQL)
     │
     └─→ Response to Client
```

---

## 🚀 Installation

### Prerequisites

- **Node.js** >= 18.0.0
- **PostgreSQL** >= 15
- **Redis** >= 7
- **npm** or **yarn**
- **Docker** and **Docker Compose** (optional, for containerized deployment)

### Quick Start

#### 1. Clone the Repository

```bash
git clone <repository-url>
cd trustseal-backend
```

#### 2. Install Dependencies

```bash
npm install
```

#### 3. Environment Configuration

Copy the example environment file:

```bash
cp .env.example .env
```

Edit `.env` with your configuration:

```bash
# Database
DB_HOST=localhost
DB_PORT=5432
DB_NAME=trustseal
DB_USER=postgres
DB_PASSWORD=your_password

# Redis
REDIS_HOST=localhost
REDIS_PORT=6379

# JWT
JWT_SECRET=your-super-secret-jwt-key-change-in-production
JWT_EXPIRATION=15m

# Blockchain RPC
BLOCKDAG_RPC_URL=https://rpc.blockdag.network
ETHEREUM_RPC_URL=https://eth.llamarpc.com

# AWS S3 (Optional)
AWS_ACCESS_KEY_ID=your-access-key
AWS_SECRET_ACCESS_KEY=your-secret-key
AWS_REGION=us-east-1
AWS_S3_BUCKET=your-bucket-name

# IPFS (Optional)
IPFS_HOST=localhost
IPFS_PORT=5001
IPFS_PROTOCOL=http

# BlockDAG Vault Smart Contract
VAULT_CONTRACT_ADDRESS=0xd54d40692605feebbe296e1cd0b5cf910602ad90
PRIVATE_KEY=your-blockdag-private-key
```

#### 4. Start Services with Docker

```bash
# Start PostgreSQL, Redis, and IPFS
docker-compose up -d db redis ipfs

# Or start all services including backend
docker-compose up
```

#### 5. Run Database Migrations

```bash
npm run migrate
```

This will run all SQL migrations in `src/database/migrations/`:
- `001_create_schema.sql` - Projects, verification, audit tables
- `002_add_unique_constraints.sql` - Unique constraints
- `003_create_users_table.sql` - Users, business owners, refresh tokens
- `004_create_applications_table.sql` - Applications, documents, ownership
- `005_create_vault_tables.sql` - Vault encryption keys and transactions

#### 6. Start the Server

```bash
# Development mode (with hot reload)
npm run dev

# Production mode
npm start
```

The server will start on `http://localhost:3000`

---

## ⚙️ Configuration

### Environment Variables

| Variable | Description | Required | Default |
|----------|-------------|----------|---------|
| `NODE_ENV` | Environment (development/production) | No | development |
| `PORT` | Server port | No | 3000 |
| `DB_HOST` | PostgreSQL host | Yes | localhost |
| `DB_PORT` | PostgreSQL port | Yes | 5432 |
| `DB_NAME` | Database name | Yes | trustseal |
| `DB_USER` | Database user | Yes | postgres |
| `DB_PASSWORD` | Database password | Yes | - |
| `REDIS_HOST` | Redis host | Yes | localhost |
| `REDIS_PORT` | Redis port | Yes | 6379 |
| `JWT_SECRET` | JWT signing secret | Yes | - |
| `JWT_EXPIRATION` | JWT token expiration | No | 15m |
| `BLOCKDAG_RPC_URL` | BlockDAG RPC endpoint | Yes | - |
| `ETHEREUM_RPC_URL` | Ethereum RPC endpoint | No | - |
| `AWS_ACCESS_KEY_ID` | AWS access key | No | - |
| `AWS_SECRET_ACCESS_KEY` | AWS secret key | No | - |
| `AWS_REGION` | AWS region | No | us-east-1 |
| `AWS_S3_BUCKET` | S3 bucket name | No | - |
| `IPFS_HOST` | IPFS host | No | localhost |
| `IPFS_PORT` | IPFS port | No | 5001 |
| `IPFS_PROTOCOL` | IPFS protocol | No | http |
| `VAULT_CONTRACT_ADDRESS` | BlockDAG vault contract | Yes | - |
| `PRIVATE_KEY` | BlockDAG private key | Yes | - |

### Database Configuration

The application uses PostgreSQL with the following structure:

**Core Tables:**
- `users` - User authentication and profiles
- `business_owners` - Business owner details
- `projects` - Verification projects
- `applications` - Application submissions
- `vault_transactions` - Encrypted file transactions
- `receiver_keys` - RSA public/private key pairs

**See `src/database/migrations/` for complete schema.**

---

## 📡 API Reference

### Base URL

```
http://localhost:3000/api/v1
```

### Authentication

Most endpoints require JWT authentication. Include the token in the Authorization header:

```http
Authorization: Bearer <your-jwt-token>
```

### API Endpoints

#### 🏥 Health Check

```http
GET /health
```

**Response:**
```json
{
  "status": "healthy",
  "timestamp": "2024-01-01T00:00:00.000Z",
  "services": {
    "database": "connected",
    "redis": "connected"
  }
}
```

#### 🔐 Authentication (`/api/v1/auth`)

**User Registration**
```http
POST /api/v1/auth/register
Content-Type: application/json

{
  "email": "user@example.com",
  "password": "SecurePass123!",
  "firstName": "John",
  "lastName": "Doe",
  "userType": "user"
}
```

**User Login**
```http
POST /api/v1/auth/login
Content-Type: application/json

{
  "email": "user@example.com",
  "password": "SecurePass123!"
}
```

**Wallet Connection**
```http
POST /api/v1/auth/wallet/connect
Content-Type: application/json

{
  "walletAddress": "0x742d35Cc6634C0532925a3b844Bc9e7595f0bEb0",
  "signature": "signature_string",
  "message": "message_to_sign"
}
```

**Refresh Token**
```http
POST /api/v1/auth/refresh
Content-Type: application/json

{
  "refreshToken": "refresh_token_here"
}
```

**User Profile**
```http
GET /api/v1/auth/profile
Authorization: Bearer <token>
```

#### 🏢 Business Owner APIs (`/api/v1/business`)

**Get Owner's Projects**
```http
GET /api/v1/business/owner/projects
Authorization: Bearer <business-owner-token>

Query Parameters:
- status: filter by status (optional)
- limit: results per page (default: 50)
- offset: pagination offset (default: 0)
```

**Create Project**
```http
POST /api/v1/business/owner/projects
Authorization: Bearer <business-owner-token>
Content-Type: application/json

{
  "name": "My Blockchain Project",
  "description": "Revolutionary DeFi platform",
  "website": "https://example.com",
  "contractAddress": "0x742d35Cc6634C0532925a3b844Bc9e7595f0bEb0",
  "tokenSymbol": "MBP",
  "tokenName": "My Blockchain Project Token"
}
```

**Submit Application**
```http
POST /api/v1/business/owner/applications
Authorization: Bearer <business-owner-token>
Content-Type: application/json

{
  "projectId": "project-uuid",
  "applicationType": "verification",
  "documents": [
    {"category": "legal_documents", "fileId": "file-uuid"}
  ]
}
```

**Get Analytics**
```http
GET /api/v1/business/owner/analytics
Authorization: Bearer <business-owner-token>
```

#### 🔷 BlockDAG APIs (`/api/v1/blockdag`)

**Network Health**
```http
GET /api/v1/blockdag/network/health
```

**Verify Contract**
```http
GET /api/v1/blockdag/contracts/:address/verify
```

**Get Contract Features**
```http
GET /api/v1/blockdag/contracts/:address/features
```

**Get Transaction History**
```http
GET /api/v1/blockdag/transactions/:address/history
```

#### 📁 File Upload APIs (`/api/v1/files`)

**Upload File**
```http
POST /api/v1/files/upload
Authorization: Bearer <token>
Content-Type: multipart/form-data

file: [binary data]
category: team_photos
projectId: project-uuid (optional)
```

**Get File Details**
```http
GET /api/v1/files/:fileId
Authorization: Bearer <token>
```

**Get Project Files**
```http
GET /api/v1/files/project/:projectId
Authorization: Bearer <token>
```

**Delete File**
```http
DELETE /api/v1/files/:fileId
Authorization: Bearer <token>
```

**Get Categories**
```http
GET /api/v1/files/categories/list
```

#### 🔐 Vault APIs (`/api/v1/vault`)

**Vault Status**
```http
GET /api/v1/vault/status
```

**Initialize Receiver**
```http
POST /api/v1/vault/receiver/setup
Authorization: Bearer <admin-token>
Content-Type: application/json

{
  "receiverId": "admin-uuid"
}
```

**Get Receiver Public Key**
```http
GET /api/v1/vault/receiver/:receiverId/public-key
```

**Upload to Vault**
```http
POST /api/v1/vault/upload
Authorization: Bearer <business-owner-token>
Content-Type: multipart/form-data

file: [binary data]
receiverId: admin-uuid
fileName: sensitive-document.pdf
description: KYC documents (optional)
```

**Download from Vault**
```http
POST /api/v1/vault/download/:transactionId
Authorization: Bearer <admin-token>
```

**Get Receiver Transactions**
```http
GET /api/v1/vault/receiver/:receiverId/transactions
Authorization: Bearer <admin-token>
```

**Get Sender Files**
```http
GET /api/v1/vault/files/sender
Authorization: Bearer <business-owner-token>
```

**Get Receiver Files**
```http
GET /api/v1/vault/files/receiver
Authorization: Bearer <admin-token>
```

#### 👨‍💼 Admin APIs (`/api/v1/admin`)

**Get Verification Queue**
```http
GET /api/v1/admin/verification-queue
Authorization: Bearer <admin-token>
```

**Approve Project**
```http
POST /api/v1/admin/approve/:projectId
Authorization: Bearer <admin-token>
Content-Type: application/json

{
  "notes": "All checks passed"
}
```

**Reject Project**
```http
POST /api/v1/admin/reject/:projectId
Authorization: Bearer <admin-token>
Content-Type: application/json

{
  "reason": "Insufficient documentation"
}
```

**Get Audit Logs**
```http
GET /api/v1/admin/audit-logs
Authorization: Bearer <admin-token>
```

**Add Verification Check**
```http
POST /api/v1/admin/verification-checks/:projectId
Authorization: Bearer <admin-token>
Content-Type: application/json

{
  "checkType": "team_team",
  "checkName": "team_doxxed",
  "status": "passed",
  "details": {}
}
```

---

## 💡 Usage Examples

### 1. Complete Verification Flow

```bash
# 1. Register a business owner
curl -X POST http://localhost:3000/api/v1/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "email": "business@example.com",
    "password": "SecurePass123!",
    "firstName": "John",
    "lastName": "Doe",
    "userType": "business"
  }'

# 2. Login to get token
curl -X POST http://localhost:3000/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "business@example.com",
    "password": "SecurePass123!"
  }'

# 3. Create a project (use token from login)
curl -X POST http://localhost:3000/api/v1/business/owner/projects \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "My DeFi Project",
    "description": "A revolutionary DeFi platform",
    "website": "https://example.com",
    "contractAddress": "0x742d35Cc6634C0532925a3b844Bc9e7595f0bEb0",
    "tokenSymbol": "MDP",
    "tokenName": "My DeFi Project Token"
  }'

# 4. Upload documents
curl -X POST http://localhost:3000/api/v1/files/upload \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -F "file=@team-photo.jpg" \
  -F "category=team_photos" \
  -F "projectId=PROJECT_UUID"

# 5. Submit for verification (admin action)
curl -X POST http://localhost:3000/api/v1/admin/verification-checks/PROJECT_UUID \
  -H "Authorization: Bearer ADMIN_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "checkType": "technical_technical",
    "checkName": "smart_contract_audit",
    "status": "passed"
  }'
```

### 2. Vault Upload Flow

```bash
# 1. Initialize admin receiver (admin only)
curl -X POST http://localhost:3000/api/v1/vault/receiver/setup \
  -H "Authorization: Bearer ADMIN_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"receiverId": "admin-uuid"}'

# 2. Get admin public key
curl http://localhost:3000/api/v1/vault/receiver/admin-uuid/public-key

# 3. Upload encrypted file (business owner)
curl -X POST http://localhost:3000/api/v1/vault/upload \
  -H "Authorization: Bearer BUSINESS_TOKEN" \
  -F "file=@sensitive-doc.pdf" \
  -F "receiverId=admin-uuid" \
  -F "fileName=sensitive-doc.pdf"

# 4. Admin downloads and decrypts
curl -X POST http://localhost:3000/api/v1/vault/download/TRANSACTION_UUID \
  -H "Authorization: Bearer ADMIN_TOKEN"
```

### 3. BlockDAG Integration

```bash
# Check network health
curl http://localhost:3000/api/v1/blockdag/network/health

# Verify a contract
curl http://localhost:3000/api/v1/blockdag/contracts/0x742d35Cc6634C0532925a3b844Bc9e7595f0bEb0/verify

# Check contract features
curl http://localhost:3000/api/v1/blockdag/contracts/0x742d35Cc6634C0532925a3b844Bc9e7595f0bEb0/features
```

---

## 🔒 Security

### Authentication & Authorization

- **JWT-based authentication** with configurable expiration
- **bcryptjs password hashing** with salt rounds
- **Role-based access control** (RBAC) for all endpoints
- **Refresh token rotation** for enhanced security
- **Rate limiting** to prevent brute force attacks
- **Input validation** and sanitization on all inputs

### Encryption

- **AES-256-CBC** encryption for file data
- **RSA-2048** encryption for key exchange
- **One-time symmetric keys** for each file
- **Secure key storage** with private key encryption
- **End-to-end encryption** before file upload

### Data Protection

- **SQL injection prevention** with parameterized queries
- **XSS protection** with helmet.js
- **CORS configuration** for allowed origins
- **Environment variable protection** (.env in .gitignore)
- **Audit logging** for compliance

### File Security

- **File type validation** (whitelist approach)
- **File size limits** per type
- **Secure file storage** (AWS S3 or local)
- **Virus scanning** (recommended for production)
- **Signed URLs** for temporary access
- **Metadata tracking** for audit trails

---

## 🚢 Deployment

### Docker Compose

```bash
# Start all services
docker-compose up -d

# View logs
docker-compose logs -f

# Stop services
docker-compose down
```

### Production Checklist

- [ ] Set `NODE_ENV=production`
- [ ] Configure strong `JWT_SECRET`
- [ ] Set up AWS S3 credentials
- [ ] Configure IPFS (or use fallback)
- [ ] Set up database backups
- [ ] Configure Redis persistence
- [ ] Set up SSL/TLS certificates
- [ ] Configure firewall rules
- [ ] Set up monitoring and alerts
- [ ] Configure log aggregation

### Environment Variables for Production

```bash
NODE_ENV=production
JWT_SECRET=<strong-random-secret>
DB_PASSWORD=<strong-db-password>
AWS_ACCESS_KEY_ID=<your-aws-key>
AWS_SECRET_ACCESS_KEY=<your-aws-secret>
VAULT_CONTRACT_ADDRESS=<deployed-contract-address>
PRIVATE_KEY=<blockdag-private-key>
```

---

## 📊 Database Schema

### Key Tables

**Users & Authentication**
- `users` - User accounts and profiles
- `business_owners` - Business owner details
- `refresh_tokens` - JWT refresh tokens

**Projects & Verification**
- `projects` - Verification projects
- `verification_criteria` - Scoring criteria
- `verification_checks` - Individual checks
- `applications` - Application submissions

**Vault System**
- `receiver_keys` - RSA public/private keys
- `vault_transactions` - Encrypted file transactions

**Administration**
- `admin_users` - Admin roles
- `audit_logs` - Audit trail

See `src/database/migrations/` for complete schema.

---

## 🛠️ Development

### Running in Development

```bash
npm run dev
```

### Running Migrations

```bash
npm run migrate
```

### Viewing Logs

```bash
# Backend logs (if running in background)
tail -f /tmp/trustseal-backend.log

# Docker logs
docker-compose logs -f backend
```

### Testing

```bash
# Run tests
npm test

# Watch mode
npm run test:watch
```

---

## 📝 License

MIT License

Copyright (c) 2024 TrustSeal

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

---

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

---

## 📞 Support

For support, email support@trustseal.com or open an issue on GitHub.

---

**Built with ❤️ for the blockchain community**