# 🔑 API Keys Setup Guide

This guide will help you obtain all the necessary API keys for the TrustSeal backend.

## 🚨 Required Keys (Get These First)

### 1. **Etherscan API Key** ⭐ CRITICAL
**What it does**: Verifies smart contracts on Ethereum

**How to get it**:
1. Go to https://etherscan.io/register (or login if you have an account)
2. Once logged in, visit https://etherscan.io/myapikey
3. Click "Add" to create a new API Key
4. Name it "TrustSeal Backend" or similar
5. Copy the generated API key (looks like: `ABC123XYZ789...`)

**Free tier limits**: 
- 5 calls per second
- 100,000 calls per day

**Add to .env**:
```bash
ETHERSCAN_API_KEY=your-etherscan-key-here
```

---

### 2. **Ethereum RPC Endpoint** ⭐ CRITICAL
**What it does**: Reads blockchain data (contracts, tokens, transactions)

**Option A: Infura** (Recommended)
1. Go to https://infura.io/
2. Sign up or login
3. Create a new project (name it "TrustSeal")
4. Select "Ethereum" network
5. Copy the HTTPS endpoint URL

**Add to .env**:
```bash
ETHEREUM_RPC_URL=https://mainnet.infura.io/v3/YOUR_PROJECT_ID
```

**Option B: Alchemy** (Alternative)
1. Go to https://alchemy.com/
2. Sign up or login
3. Create a new app (name it "TrustSeal")
4. Select "Ethereum" network
5. Copy the HTTPS endpoint URL

**Add to .env**:
```bash
ETHEREUM_RPC_URL=https://eth-mainnet.g.alchemy.com/v2/YOUR_API_KEY
```

**Option C: Public RPC** (Free, but rate-limited)
```bash
ETHEREUM_RPC_URL=https://eth.llamarpc.com
```

---

## 📦 Optional Keys (For Future Features)

### 3. **AWS S3** (For file uploads)
**What it does**: Stores verification documents, images, audit reports

**How to get it**:
1. Go to https://aws.amazon.com/
2. Sign up or login
3. Go to IAM → Users → Create user
4. Select "Programmatic access"
5. Attach policy: `AmazonS3FullAccess`
6. Create access key and secret key
7. Create an S3 bucket named `trustseal-uploads`

**Add to .env**:
```bash
AWS_ACCESS_KEY_ID=AKIAIOSFODNN7EXAMPLE
AWS_SECRET_ACCESS_KEY=wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY
AWS_S3_BUCKET=trustseal-uploads
AWS_REGION=us-east-1
```

---

### 4. **Email Service** (For notifications)
**Option A: Gmail** (Easy, for development)
1. Use your Gmail account
2. Enable 2-factor authentication
3. Generate an app password: https://myaccount.google.com/apppasswords
4. Copy the 16-character password

**Add to .env**:
```bash
SMTP_HOST=smtp.gmail.com
SMTP_PORT=587
SMTP_USER=your-email@gmail.com
SMTP_PASS=your-16-char-app-password
```

**Option B: SendGrid** (Recommended for production)
1. Go to https://sendgrid.com/
2. Sign up for free tier (100 emails/day)
3. Get API key from settings

**Add to .env**:
```bash
SMTP_HOST=smtp.sendgrid.net
SMTP_PORT=587
SMTP_USER=apikey
SMTP_PASS=your-sendgrid-api-key
```

---

## 🛠️ Quick Setup Steps

### Step 1: Get Required Keys
1. ✅ Get Etherscan API key
2. ✅ Get Infura/Alchemy RPC endpoint

### Step 2: Update .env File
```bash
cd /Users/marvel/trustseal-backend
cp .env.example .env
nano .env  # or use your preferred editor
```

### Step 3: Add Your Keys
Edit the `.env` file and replace the placeholder values:
```bash
# Blockchain Configuration - REPLACE THESE
ETHEREUM_RPC_URL=https://mainnet.infura.io/v3/YOUR_ACTUAL_KEY
ETHERSCAN_API_KEY=YOUR_ACTUAL_KEY

# Optional - Can leave as default for now
AWS_ACCESS_KEY_ID=your-aws-access-key
AWS_SECRET_ACCESS_KEY=your-aws-secret-key
```

### Step 4: Restart Server
```bash
# Stop the current server (Ctrl+C)
# Then restart
npm run dev
```

---

## ✅ Verification Checklist

After adding your keys, test them:

```bash
# Test health endpoint
curl http://localhost:3000/health

# Create a test project with a real contract address
curl -X POST http://localhost:3000/api/v1/projects \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Test Project",
    "description": "Testing with real API keys",
    "contract_address": "0xdAC17F958D2ee523a2206206994597C13D831ec7"
  }'
```

If the project is created successfully and `contract_info` is not null, your keys are working! ✅

---

## 📝 Security Best Practices

1. **Never commit .env file** to git (already in .gitignore)
2. **Use different keys** for development and production
3. **Rotate keys periodically** for security
4. **Monitor API usage** to avoid hitting rate limits
5. **Keep keys secret** - never share them publicly

---

## 🆘 Troubleshooting

### "Invalid Etherscan API key"
- Check you copied the entire key
- Make sure there are no extra spaces
- Try creating a new API key

### "Ethereum RPC error"
- Check the URL format
- Verify your Infura/Alchemy project is active
- Try using a public RPC endpoint as backup

### "Rate limit exceeded"
- Free tier has limits (5 calls/sec for Etherscan)
- Wait a few seconds and try again
- Consider upgrading to a paid plan for production

---

## 💰 Cost Estimates

**Free tier covers**:
- ✅ Etherscan API: 5 calls/sec, 100K/day (FREE)
- ✅ Infura: 100K requests/day (FREE)
- ✅ AWS S3: 5GB storage, 20K requests/month (FREE)
- ✅ SendGrid: 100 emails/day (FREE)

**Production costs** (if you exceed free tier):
- Etherscan: ~$99/month for unlimited
- Infura: Pay as you go, ~$50-200/month
- AWS S3: ~$0.023/GB storage

---

## 📞 Need Help?

If you encounter any issues:
1. Check the server logs: `tail -f combined.log`
2. Verify keys are correctly formatted in `.env`
3. Test each service individually
4. Check service status pages (Infura, Etherscan, etc.)

Happy coding! 🚀
