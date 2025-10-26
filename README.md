# 🔐 TrustSeal - Blockchain Verification Platform

<div align="center">

![TrustSeal Logo](assets/icons/shield-check.svg)

**Secure, Transparent, Trustworthy**

A Web3 blockchain verification platform built on Flutter for BlockDAG network, featuring secure vault encryption, role-based access control, and decentralized file storage.

[![Flutter](https://img.shields.io/badge/Flutter-3.0+-blue.svg)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.0+-blue.svg)](https://dart.dev)
[![BlockDAG](https://img.shields.io/badge/BlockDAG-Native-green.svg)](https://blockdag.network)
[![License](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

</div>

---

## 📖 Table of Contents

- [Overview](#overview)
- [Features](#features)
- [Tech Stack](#tech-stack)
- [Architecture](#architecture)
- [Getting Started](#getting-started)
- [User Guides](#user-guides)
- [API Documentation](#api-documentation)
- [Security](#security)
- [Contributing](#contributing)
- [License](#license)

---

## 🎯 Overview

**TrustSeal** is a cutting-edge blockchain verification platform that brings transparency and security to the crypto ecosystem. Built specifically for the BlockDAG network, TrustSeal provides a comprehensive solution for project verification, secure file management, and trusted business relationships.

### What Makes TrustSeal Special?

- ✅ **BlockDAG-Native**: Built specifically for BlockDAG network integration
- ✅ **Hybrid Encryption**: Military-grade AES-256-CBC + RSA-2048 encryption
- ✅ **Decentralized Storage**: IPFS integration for secure file storage
- ✅ **Role-Based Security**: Three distinct user types with granular permissions
- ✅ **Web3 Integration**: Native wallet connection (MetaMask, WalletConnect, Coinbase)
- ✅ **Transparent Verification**: Public verification badges and trust scores
- ✅ **Audit Trail**: Complete blockchain transaction logging

---

## ✨ Features

### 🔐 Authentication & Security

#### Multi-Auth Support
- **Email/Password**: Traditional authentication with JWT tokens
- **Google Sign-In**: OAuth2 integration for seamless login
- **Web3 Wallets**: MetaMask, WalletConnect, Coinbase Wallet
- **BlockDAG Wallets**: Native BlockDAG network integration
- **Biometric**: Touch ID / Face ID support (iOS/Android)

#### Role-Based Access Control
- **Admin Users**: Full system access, verification approval, vault management
- **Business Owners**: Project submission, application tracking, secure vault upload
- **Regular Users**: Browse verified projects, view trust scores

---

### 👥 Admin Module

#### Dashboard Features
- 📊 Real-time verification queue
- 📈 Analytics and statistics
- 🔔 Notification center
- 📋 Audit logs viewer

#### Verification Management
- ⏳ View pending applications
- ✅ Approve projects with verification
- ❌ Reject with detailed feedback
- 📝 Add custom verification checks
- 🔍 Search and filter applications

#### Secure Vault
- 🔒 Access encrypted files from business users
- 📥 Download and decrypt sensitive documents
- 📊 View transaction history
- 🔐 Manage RSA key pairs
- 📈 Vault analytics

---

### 🏢 Business Owners Module

#### Dashboard Features
- 📊 Project overview and statistics
- 📈 Application tracking
- 🎯 Trust score monitoring
- 📋 Recent activity feed

#### Project Application System
A comprehensive **6-step application process**:

**Step 1: Basic Information**
- Project name and description
- Website URL validation
- Contract address (BlockDAG network)
- Token details (symbol, name)

**Step 2: Team Information**
- Founder details
- Team size and experience
- LinkedIn and GitHub profiles

**Step 3: Community Information**
- Social media followers (Telegram, Twitter, Discord)
- Social media links
- Community engagement metrics

**Step 4: Financial Information**
- Total supply
- Market cap
- Liquidity information
- Lock details

**Step 5: Technical Information**
- Smart contract verification
- Audit completion status
- Audit report links
- GitHub repository

**Step 6: Review & Submit**
- Summary of all information
- Confirmation before submission
- Application tracking

#### Secure Vault Upload
- 🔒 Upload sensitive documents with encryption
- 📄 File preview (images, documents)
- 👥 Select admin receiver
- 📝 Add optional descriptions
- ✅ Track upload status
- 🔐 Military-grade encryption (AES-256-CBC)
- 🌐 IPFS storage with blockchain logging

#### Application Tracking
Track your applications in real-time:
- 📝 **Draft**: Save progress and continue later
- 📤 **Submitted**: Awaiting admin review
- 🔄 **Under Review**: Admin is reviewing
- ✅ **Approved**: Your project is verified!
- ❌ **Rejected**: Review feedback provided

---

### 👤 Users Module

#### Browse Verified Projects
- 🔍 Search by name or contract address
- 📊 Filter by verification tier (Gold, Silver, Bronze, Basic)
- 🏆 View trust scores and badges
- 📈 See verification statistics
- 🔗 Access project websites

#### Project Details
- 📋 Complete project information
- ✅ Verification criteria breakdown
- 📊 Trust score components
- 🎯 Risk level assessment
- 📝 Audit reports and documentation
- 🔗 Social media links

#### Verification Badge System
- 🥇 **Gold**: Trust score 8.0+ (Highest reliability)
- 🥈 **Silver**: Trust score 6.0-7.9 (High reliability)
- 🥉 **Bronze**: Trust score 4.0-5.9 (Medium reliability)
- 🏅 **Basic**: Trust score 2.0-3.9 (Entry level)

---

### 🗄️ Secure Vault System

TrustSeal's vault system uses **hybrid encryption** for maximum security:

#### How It Works

1. **Business User Uploads**
   - Select file to upload
   - Choose admin recipient
   - Add optional description
   - Click "Upload to Secure Vault"

2. **Backend Encryption**
   - Generates unique AES-256-CBC key
   - Encrypts file with AES
   - Gets admin's RSA-2048 public key
   - Encrypts AES key with RSA
   - Uploads to IPFS (with local fallback)

3. **Blockchain Recording**
   - Creates BlockDAG transaction
   - Logs encrypted key reference
   - Records sender/receiver info
   - Returns transaction hash

4. **Admin Access**
   - Views encrypted files in vault
   - Uses private key to decrypt
   - Downloads and views securely

#### Security Features
- 🔐 **Hybrid Encryption**: AES-256-CBC + RSA-2048
- 🌐 **IPFS Storage**: Decentralized file storage
- 📜 **Blockchain Logging**: Immutable audit trail
- 🔑 **Key Management**: Secure RSA key pairs
- 🛡️ **End-to-End Encryption**: Only receiver can decrypt

---

## 🛠️ Tech Stack

### Frontend
- **Flutter 3.0+**: Cross-platform framework
- **Dart 3.0+**: Programming language
- **Material Design 3**: Modern UI/UX
- **Google Fonts**: Typography
- **flutter_svg**: Vector graphics
- **file_picker**: File selection
- **google_sign_in**: OAuth authentication
- **http**: API communication
- **shared_preferences**: Local storage

### Backend Integration
- **REST API**: JSON-based communication
- **JWT Authentication**: Token-based security
- **BlockDAG Integration**: Blockchain connectivity
- **IPFS Storage**: Decentralized file system
- **PostgreSQL**: Database
- **Redis**: Caching layer

### Design System
- **Web3 Themes**: Modern gradient designs
- **Glass Morphism**: Glass-like UI effects
- **Animations**: Smooth transitions and interactions
- **Responsive Design**: All screen sizes
- **Dark/Light Mode Ready**: Theme switching support

---

## 🏗️ Architecture

### Clean Architecture

TrustSeal follows **Clean Architecture** principles with feature-based modules:

```
lib/
├── core/                     # Shared core functionality
│   ├── constants/           # App-wide constants
│   ├── navigation/          # Route handlers
│   ├── services/            # API services
│   └── widgets/             # Reusable widgets
│
├── features/                # Feature modules
│   ├── auth/               # Authentication
│   ├── admin/              # Admin module
│   ├── business_owners/    # Business module
│   └── users/              # Users module
│
└── main.dart                # App entry point
```

### Module Structure

Each feature module follows this structure:

```
feature_name/
├── data/                   # Data layer
│   ├── models/            # Data models
│   ├── repositories/      # Repository implementations
│   └── data_sources/     # Local/Remote data sources
├── domain/                # Business logic layer
│   ├── entities/         # Domain entities
│   ├── repositories/     # Repository interfaces
│   └── use_cases/       # Business logic
└── presentation/         # UI layer
    ├── views/           # Screens
    └── widgets/         # UI components
```

---

## 🚀 Getting Started

### Prerequisites

- Flutter 3.0+ installed ([Install Flutter](https://flutter.dev/docs/get-started/install))
- Dart 3.0+
- VS Code or Android Studio with Flutter plugins
- Git

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/trustseal_app.git
   cd trustseal_app
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the app**
   ```bash
   flutter run -d web-server --web-port 3002
   ```

4. **Access the app**
   Open your browser to: `http://localhost:3002`

### Development Setup

1. **Start the backend** (if not already running)
   ```bash
   # Navigate to backend directory
   cd /path/to/trustseal-backend
   npm start
   ```

2. **Verify backend is running**
   ```bash
   curl http://localhost:3000/health
   ```

3. **Run Flutter app**
   ```bash
   flutter run -d web-server --web-port 3002
   ```

---

## 📱 User Guides

### For Admin Users

#### Accessing Admin Dashboard
1. Go to landing page: `http://localhost:3002`
2. Click "Admin Login"
3. Enter admin credentials or use Google Sign-In
4. You'll be redirected to the Admin Dashboard

#### Reviewing Applications
1. Navigate to "Applications" tab
2. View pending applications in the queue
3. Click on an application to review details
4. Review all 6 steps of the application
5. Click "Approve" or "Reject"
6. If rejecting, provide feedback

#### Managing Vault
1. Navigate to "Vault" tab
2. View all encrypted files from business users
3. Click on a file to download
4. File will be automatically decrypted
5. View transaction history in the list

#### Viewing Analytics
1. Dashboard shows real-time statistics
2. View verification queue count
3. See approval/rejection rates
4. Track vault usage

### For Business Owners

#### Creating an Account
1. Go to landing page
2. Click "Business Sign Up"
3. Fill in:
   - First Name
   - Last Name
   - Email
   - Password
   - Wallet Address (BlockDAG)
4. Connect wallet (optional)
5. Click "Create Account"

#### Submitting a Project
1. Login to Business Dashboard
2. Click "New Application" button
3. Fill out the 6-step form:
   - **Step 1**: Basic project details
   - **Step 2**: Team information
   - **Step 3**: Community info
   - **Step 4**: Financial data
   - **Step 5**: Technical verification
   - **Step 6**: Review and submit
4. Click "Submit Application"
5. Track status in dashboard

#### Uploading to Secure Vault
1. Navigate to "Secure Vault" tab
2. Click "Select File" button
3. Choose file from your device
4. Select an admin recipient
5. Add description (optional)
6. Click "Upload to Secure Vault"
7. Wait for encryption and upload
8. View transaction ID

#### Tracking Applications
1. Dashboard shows all applications
2. Filter by status:
   - **Draft**: Still working on it
   - **Submitted**: Waiting for review
   - **Under Review**: Admin is reviewing
   - **Approved**: Verified! 🎉
   - **Rejected**: Need to make changes
3. Click on application to view details
4. View admin feedback if available

### For Regular Users

#### Browsing Verified Projects
1. Go to Users Home page
2. See all verified projects
3. Use search bar to find specific projects
4. Filter by verification tier
5. Click on a project card to view details

#### Viewing Project Details
1. Click on any project card
2. View:
   - Trust score and tier
   - Verification criteria
   - Team information
   - Social media links
   - Audit reports
   - Risk assessment
3. Visit project website

#### Understanding Trust Scores
- **0.0-1.9**: Pending verification
- **2.0-3.9**: Basic verification
- **4.0-5.9**: Bronze tier
- **6.0-7.9**: Silver tier
- **8.0+**: Gold tier

---

## 📡 API Documentation

### Base URL
```
https://hackerton-8it2.onrender.com/api/v1
```

### Authentication
All authenticated endpoints require:
```http
Authorization: Bearer <JWT_TOKEN>
```

### Main Endpoints

#### Authentication
```http
POST /auth/register       # Register new user
POST /auth/login          # Login user
POST /auth/google/signin  # Google OAuth
POST /auth/logout         # Logout
GET  /auth/profile        # Get user profile
```

#### Business Owner
```http
GET  /business/owner/projects                    # Get my projects
POST /business/owner/projects                    # Create project
GET  /business/owner/applications                 # Get applications
POST /business/owner/applications                # Create application
PUT  /business/owner/applications/:id/submit      # Submit application
GET  /business/owner/applications/:id             # Get application details
GET  /business/owner/analytics                    # Get analytics
```

#### Admin
```http
GET  /admin/verification-queue                     # Get verification queue
POST /admin/approve/:projectId                    # Approve project
POST /admin/reject/:projectId                     # Reject project
GET  /admin/audit-logs                            # Get audit logs
POST /admin/verification-checks/:projectId        # Add verification check
```

#### Vault
```http
POST /vault/upload                                 # Upload encrypted file
POST /vault/download/:transactionId                # Download and decrypt
GET  /vault/status                                 # Get vault status
GET  /vault/receiver/:receiverId/public-key       # Get public key
POST /vault/receiver/setup                        # Setup receiver
GET  /vault/receiver/:receiverId/transactions     # Get transactions
GET  /vault/files/sender                          # Get my files
GET  /vault/files/receiver                        # Get received files
```

#### BlockDAG Integration
```http
GET  /blockdag/network/health                      # Network health
GET  /blockdag/contracts/:address/verify           # Verify contract
GET  /blockdag/contracts/:address/features          # Get contract features
GET  /blockdag/transactions/:address/history       # Transaction history
```

---

## 🔐 Security

### Authentication Security
- ✅ JWT tokens with refresh token rotation
- ✅ Secure password hashing (bcrypt)
- ✅ Role-based access control (RBAC)
- ✅ Protected routes and navigation
- ✅ Token expiration and validation
- ✅ Google OAuth with PKCE
- ✅ Wallet signature verification

### Vault Security
- ✅ **AES-256-CBC**: Industry-standard symmetric encryption
- ✅ **RSA-2048**: Public-key encryption for keys
- ✅ **Hybrid Encryption**: Combines best of both
- ✅ **Key Escrow Prevention**: Only receiver can decrypt
- ✅ **One-Time Keys**: Each file gets unique key
- ✅ **IPFS Storage**: Decentralized and resilient
- ✅ **Blockchain Audit**: Immutable transaction log

### Data Security
- ✅ SQL injection prevention
- ✅ XSS protection
- ✅ CSRF tokens
- ✅ Rate limiting
- ✅ Input validation and sanitization
- ✅ Secure headers (CORS, CSP)

---

## 🧪 Testing

### Running Tests
```bash
# Run all tests
flutter test

# Run specific test file
flutter test test/widget_test.dart

# Run with coverage
flutter test --coverage
```

### Manual Testing Checklist

#### Authentication
- [ ] Email/Password login works
- [ ] Google Sign-In works
- [ ] Wallet connection works
- [ ] Logout clears session
- [ ] Protected routes redirect

#### Business Owner
- [ ] Can submit project application
- [ ] Can upload to vault
- [ ] Can view application status
- [ ] Can edit drafts
- [ ] Can view analytics

#### Admin
- [ ] Can view verification queue
- [ ] Can approve projects
- [ ] Can reject with feedback
- [ ] Can access vault files
- [ ] Can view audit logs

#### Users
- [ ] Can browse verified projects
- [ ] Can view project details
- [ ] Can search projects
- [ ] Can filter by tier
- [ ] Can view trust scores

---

## 🐛 Troubleshooting

### App Won't Start
```bash
# Kill existing processes
pkill -f flutter

# Clear cache
flutter clean

# Reinstall dependencies
flutter pub get

# Run again
flutter run -d web-server --web-port 3002
```

### Backend Connection Issues
```bash
# Check if backend is running
curl http://localhost:3000/health

# Start backend if not running
cd /path/to/trustseal-backend
npm start
```

### Port Already in Use
```bash
# Kill process on port 3002
lsof -ti:3002 | xargs kill -9

# Or use a different port
flutter run -d web-server --web-port 3003
```

### File Upload Issues
- Ensure file is under 100MB
- Check backend vault status
- Verify admin receiver is initialized
- Check browser console for errors

---

## 📊 Project Structure

```
trustseal_app/
├── assets/
│   └── icons/              # SVG icons
├── lib/
│   ├── core/               # Core functionality
│   │   ├── constants/     # App constants
│   │   ├── navigation/    # Route handling
│   │   ├── services/      # API services
│   │   └── widgets/       # Shared widgets
│   ├── features/          # Feature modules
│   │   ├── admin/         # Admin module
│   │   ├── auth/          # Authentication
│   │   ├── business_owners/ # Business module
│   │   └── users/         # Users module
│   └── main.dart          # Entry point
├── test/                   # Tests
├── web/                    # Web assets
├── pubspec.yaml           # Dependencies
├── .gitignore             # Git ignore rules
└── README.md              # This file
```

---

## 🎨 UI/UX Design

### Design Philosophy
- **Modern & Clean**: Minimal, focused interfaces
- **Web3 Themed**: Gradient backgrounds, particle effects
- **Glass Morphism**: Transparent, frosted glass effects
- **Animations**: Smooth transitions and micro-interactions
- **Responsive**: Works on all screen sizes
- **Accessible**: WCAG 2.1 AA compliance

### Color Scheme
- **Primary**: Blue (#3B82F6)
- **Secondary**: Purple (#8B5CF6)
- **Success**: Green (#10B981)
- **Warning**: Orange (#F59E0B)
- **Error**: Red (#EF4444)

### Typography
- **Primary Font**: Inter (Google Fonts)
- **Sizes**: 12px - 48px
- **Weights**: Regular, Medium, SemiBold, Bold

---

## 🤝 Contributing

We welcome contributions! Please see [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

### Quick Start for Contributors
1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Write/update tests
5. Submit a pull request

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## 👥 Team

**Built with ❤️ by Team Velox**

---

## 📞 Contact & Support

- **Documentation**: [View Docs](./docs)
- **Issues**: [GitHub Issues](https://github.com/yourusername/trustseal_app/issues)
- **Discussions**: [GitHub Discussions](https://github.com/yourusername/trustseal_app/discussions)

---

## 🙏 Acknowledgments

- Flutter Team for the amazing framework
- BlockDAG Network for blockchain infrastructure
- IPFS for decentralized storage
- All contributors and users

---

<div align="center">

**TrustSeal** - Securing the future of blockchain verification

Made with ❤️ using Flutter

</div>
