# TrustSeal Backend API Examples

## 🚀 Getting Started

The TrustSeal backend is running on `http://localhost:3000`

## 📋 API Endpoints

### 1. Health Check
```bash
curl http://localhost:3000/health
```

### 2. Create a Project
```bash
curl -X POST http://localhost:3000/api/v1/projects \
  -H "Content-Type: application/json" \
  -d '{
    "name": "My Crypto Project",
    "description": "A revolutionary DeFi project",
    "website": "https://example.com",
    "contract_address": "0x742d35Cc6634C0532925a3b844Bc9e7595f0bEb0",
    "token_symbol": "MCP",
    "token_name": "My Crypto Project Token"
  }'
```

### 3. Get All Projects
```bash
curl http://localhost:3000/api/v1/projects
```

### 4. Get Project by ID
```bash
curl http://localhost:3000/api/v1/projects/{project_id}
```

### 5. Add Verification Checks
```bash
# Team Doxxed
curl -X POST http://localhost:3000/api/v1/admin/verification-checks/{project_id} \
  -H "Content-Type: application/json" \
  -d '{
    "check_type": "team_team",
    "check_name": "team_doxxed",
    "status": "passed"
  }'

# Smart Contract Audit
curl -X POST http://localhost:3000/api/v1/admin/verification-checks/{project_id} \
  -H "Content-Type: application/json" \
  -d '{
    "check_type": "technical_technical",
    "check_name": "smart_contract_audit",
    "status": "passed",
    "details": {"isReputableAuditor": true}
  }'

# Liquidity Lock
curl -X POST http://localhost:3000/api/v1/admin/verification-checks/{project_id} \
  -H "Content-Type: application/json" \
  -d '{
    "check_type": "financial_financial",
    "check_name": "liquidity_lock",
    "status": "passed",
    "details": {"duration": 12}
  }'

# Social Media Presence
curl -X POST http://localhost:3000/api/v1/admin/verification-checks/{project_id} \
  -H "Content-Type: application/json" \
  -d '{
    "check_type": "community_community",
    "check_name": "social_media",
    "status": "passed",
    "details": {"platformsCount": 4, "totalFollowers": 15000}
  }'
```

### 6. Initiate Verification
```bash
curl -X POST http://localhost:3000/api/v1/projects/{project_id}/verify
```

### 7. Get Verification Status
```bash
curl http://localhost:3000/api/v1/projects/{project_id}/verification-status
```

### 8. Approve Project (Admin)
```bash
curl -X POST http://localhost:3000/api/v1/admin/approve/{project_id} \
  -H "Content-Type: application/json" \
  -d '{"adminId": "admin-123"}'
```

### 9. Reject Project (Admin)
```bash
curl -X POST http://localhost:3000/api/v1/admin/reject/{project_id} \
  -H "Content-Type: application/json" \
  -d '{
    "adminId": "admin-123",
    "reason": "Insufficient documentation"
  }'
```

### 10. Get Verification Queue (Admin)
```bash
curl http://localhost:3000/api/v1/admin/verification-queue
```

### 11. Get Audit Logs (Admin)
```bash
curl http://localhost:3000/api/v1/admin/audit-logs?projectId={project_id}
```

## 📊 Scoring System

The TrustSeal scoring system uses weighted criteria:

- **Team Verification** (25%): Team doxxing, LinkedIn, background checks
- **Technical Verification** (30%): Smart contract audits, code quality, security
- **Financial Verification** (25%): Financial audits, liquidity locks
- **Community Verification** (20%): Social media, engagement, community size

### Trust Score Calculation

```javascript
Overall Score = (Team × 0.25) + (Technical × 0.30) + (Financial × 0.25) + (Community × 0.20)
```

### Verification Tiers

- **Gold**: Score ≥ 8.5
- **Silver**: Score ≥ 7.0
- **Bronze**: Score ≥ 5.0
- **Basic**: Score ≥ 3.0
- **Pending**: Score < 3.0

### Risk Assessment

- **High Risk**: No doxxing, no audit, short liquidity lock
- **Medium Risk**: Small team, no social presence
- **Low Risk**: All checks passed

## 🧪 Example Test Flow

1. Create a project
2. Add verification checks for all categories
3. Initiate verification (calculates trust score)
4. Review the verification status
5. Approve or reject the project

## 📝 Notes

- All timestamps are in ISO 8601 format
- Project IDs are UUIDs
- The trust score is calculated automatically based on checks
- Monitoring service runs automated checks every hour
