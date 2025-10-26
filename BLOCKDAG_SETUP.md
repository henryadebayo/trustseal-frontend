# 🔷 BlockDAG Network Setup Guide

TrustSeal backend now supports BlockDAG as the primary network! This guide will help you configure BlockDAG RPC and explorer APIs.

## 🎯 Quick Start

### 1. **BlockDAG RPC Endpoint** ⭐ CRITICAL
**What it does**: Connects to BlockDAG network to read blockchain data

**Available Endpoints**:
```bash
# Testnet (Recommended for development)
BLOCKDAG_TESTNET_RPC_URL=https://testnet.blockdag.network

# Mainnet
BLOCKDAG_RPC_URL=https://mainnet.blockdag.network
```

**Add to .env**:
```bash
BLOCKDAG_RPC_URL=https://testnet.blockdag.network
BLOCKDAG_TESTNET_RPC_URL=https://testnet.blockdag.network
```

### 2. **BlockDAG Explorer API Key** ⭐ CRITICAL
**What it does**: Verifies smart contracts and fetches contract data

**How to get it**:
1. Visit BlockDAG Explorer
2. Create an account
3. Generate API key from dashboard
4. Copy the API key

**Add to .env**:
```bash
BLOCKDAG_EXPLORER_API_KEY=your-blockdag-explorer-api-key
```

---

## 🔧 Configuration

### Update `.env` File

```bash
# BlockDAG Configuration (Primary Network)
BLOCKDAG_RPC_URL=https://testnet.blockdag.network
BLOCKDAG_TESTNET_RPC_URL=https://testnet.blockdag.network
BLOCKDAG_EXPLORER_API_KEY=your-api-key-here

# Optional: Cross-chain support
ETHEREUM_RPC_URL=https://mainnet.infura.io/v3/YOUR_KEY
ETHERSCAN_API_KEY=your-etherscan-key
```

---

## 🧪 Testing BlockDAG Integration

### 1. Test RPC Connection
```bash
curl -X POST https://testnet.blockdag.network \
  -H "Content-Type: application/json" \
  -d '{
    "jsonrpc": "2.0",
    "method": "eth_blockNumber",
    "params": [],
    "id": 1
  }'
```

### 2. Create a BlockDAG Project
```bash
curl -X POST http://localhost:3000/api/v1/projects \
  -H "Content-Type: application/json" \
  -d '{
    "name": "BlockDAG Test Project",
    "description": "Testing BlockDAG network integration",
    "website": "https://blockdag.network",
    "contract_address": "0xYourBlockDAGContractAddress",
    "token_symbol": "BDAG",
    "token_name": "BlockDAG Token"
  }'
```

### 3. Verify Contract
The backend will automatically use BlockDAG Explorer to verify contracts on BlockDAG network!

---

## 🌐 Supported Networks

TrustSeal backend supports multiple networks:

1. **BlockDAG** (Primary) 🔷
   - Mainnet
   - Testnet

2. **Ethereum** (Cross-chain) ⚪
   - For interoperability with Ethereum projects

3. **BSC** (Cross-chain) 🟡
   - Binance Smart Chain support

---

## 📊 BlockDAG Features

### Contract Verification
- Automatically verifies contracts on BlockDAG network
- Uses BlockDAG Explorer API
- Validates contract source code

### Token Metrics
- Fetches token supply, decimals, symbol, name
- Works with BlockDAG-native tokens
- Supports custom tokens deployed on BlockDAG

### Network Switching
- Switch between BlockDAG testnet/mainnet
- Cross-chain project support
- Network-specific verification

---

## 🔍 BlockDAG-Specific Endpoints

### Get Block Info
```javascript
// In your code
const blockchainService = require('./services/blockchain-service');

// Get BlockDAG block information
const blockInfo = await blockchainService.getBlockDAGBlockInfo(12345);
console.log(blockInfo);
```

### Get Transaction Info
```javascript
// Get BlockDAG transaction details
const txInfo = await blockchainService.getBlockDAGTransactionInfo('0x...');
console.log(txInfo);
```

### Switch Network
```javascript
// Switch to BlockDAG network
blockchainService.setNetwork('blockdag');

// Switch to BlockDAG testnet
blockchainService.setNetwork('blockdag-testnet');

// Switch to Ethereum (for cross-chain)
blockchainService.setNetwork('ethereum');
```

---

## 🎯 Use Cases

### 1. Verify BlockDAG Projects
```bash
# Verify a token contract on BlockDAG
curl -X POST http://localhost:3000/api/v1/projects/{id}/verify
```

### 2. Check BlockDAG Transactions
```bash
# Get transaction details
GET /api/v1/blockdag/transactions/{txHash}
```

### 3. Monitor BlockDAG Blocks
```bash
# Get block information
GET /api/v1/blockdag/blocks/{blockNumber}
```

---

## 💡 Best Practices

1. **Use Testnet First**: Start with BlockDAG testnet for development
2. **Verify Contracts**: Always verify smart contracts on BlockDAG Explorer
3. **Monitor Network**: Keep track of BlockDAG network status
4. **Handle Errors**: Implement proper error handling for RPC calls
5. **Rate Limiting**: Respect BlockDAG RPC rate limits

---

## 🆘 Troubleshooting

### "BlockDAG RPC connection failed"
- Check if RPC URL is correct
- Verify network connectivity
- Try switching between mainnet/testnet

### "BlockDAG Explorer API error"
- Verify API key is correct
- Check API key permissions
- Ensure explorer service is operational

### "Contract verification failed"
- Verify contract is deployed on BlockDAG
- Check if contract address is valid
- Ensure contract source code is verified on explorer

---

## 📈 BlockDAG Advantages

✨ **Faster Transactions**: DAG structure provides higher throughput  
🔷 **Lower Fees**: More efficient than traditional blockchains  
⚡ **Scalability**: Handles more TPS than linear blockchains  
🌐 **Interoperability**: Can work with other chains via bridges  

---

## 🔗 Resources

- **BlockDAG Official**: https://blockdag.network
- **BlockDAG Explorer**: https://explorer.blockdag.network
- **Documentation**: https://docs.blockdag.network
- **Developer Portal**: https://developer.blockdag.network

---

## 🚀 Next Steps

1. ✅ Get BlockDAG RPC URL (free)
2. ✅ Get BlockDAG Explorer API key
3. ✅ Update `.env` file
4. ✅ Test RPC connection
5. ✅ Create your first BlockDAG project
6. ✅ Verify contracts on BlockDAG network

Welcome to BlockDAG verification! 🔷🚀
