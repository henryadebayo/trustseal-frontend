# 🔗 BlockDAG Smart Contract Integration Plan for Vault System

## Current Issue

The vault system currently:
- ❌ Does NOT use BlockDAG smart contracts for signing
- ❌ Does NOT integrate with blockchain for key exchange
- ❌ Does NOT provide users with encryption keys stored on-chain
- ❌ Only uses backend API for encryption/decryption

## Required Implementation

### 1. Smart Contract Architecture

#### **VaultManager.sol** (Solidity Smart Contract)

```solidity
// BlockDAG Network Smart Contract
pragma solidity ^0.8.0;

contract VaultManager {
    struct VaultTransaction {
        address sender;
        address receiver;
        string ipfsHash;
        bytes32 encryptedKey; // AES key encrypted with RSA
        uint256 timestamp;
        bool isDecrypted;
    }
    
    mapping(uint256 => VaultTransaction) public transactions;
    mapping(address => bool) public authorizedAuditors; // Admin addresses
    
    event FileUploaded(
        uint256 indexed transactionId,
        address indexed sender,
        address indexed receiver,
        string ipfsHash
    );
    
    event FileDecrypted(
        uint256 indexed transactionId,
        address indexed receiver
    );
    
    // Upload file record (frontend calls this)
    function uploadFile(
        address receiver,
        string memory ipfsHash,
        bytes32 encryptedKey
    ) external returns (uint256) {
        uint256 transactionId = block.number + transactions.length;
        
        transactions[transactionId] = VaultTransaction({
            sender: msg.sender,
            receiver: receiver,
            ipfsHash: ipfsHash,
            encryptedKey: encryptedKey,
            timestamp: block.timestamp,
            isDecrypted: false
        });
        
        emit FileUploaded(transactionId, msg.sender, receiver, ipfsHash);
        
        return transactionId;
    }
    
    // Confirm decryption (receiver calls this)
    function confirmDecryption(uint256 transactionId) external {
        require(
            transactions[transactionId].receiver == msg.sender,
            "Only receiver can confirm decryption"
        );
        
        transactions[transactionId].isDecrypted = true;
        
        emit FileDecrypted(transactionId, msg.sender);
    }
    
    // Get encrypted key for receiver
    function getEncryptedKey(uint256 transactionId) external view returns (bytes32) {
        require(
            transactions[transactionId].receiver == msg.sender,
            "Only receiver can access key"
        );
        return transactions[transactionId].encryptedKey;
    }
}
```

---

## Frontend Implementation Requirements

### 2. Add Required Dependencies

```yaml
dependencies:
  # Blockchain & Web3
  web3dart: ^2.0.0
  flutter_web3_provider: ^2.0.2
  eth_sig_util: ^0.3.0
  
  # Key Management
  crypto: ^3.0.3
  
  # BlockDAG Specific
  blockdag_rpc: ^1.0.0
```

### 3. Create Smart Contract Service

**File:** `lib/core/services/blockdag_contract_service.dart`

```dart
import 'package:web3dart/web3dart.dart';
import 'package:flutter_web3_provider/flutter_web3_provider.dart';

class BlockDAGContractService {
  final String contractAddress = '0x...'; // Deploy contract first
  final String rpcUrl = 'https://eth.llamarpc.com';
  
  late Web3Client client;
  late DeployedContract contract;
  
  Future<void> initialize() async {
    client = Web3Client(rpcUrl, Client());
    // Load contract ABI and deploy
  }
  
  // Upload file with blockchain signing
  Future<String> uploadFileWithSigning({
    required String receiverAddress,
    required String ipfsHash,
    required String encryptedKey,
    required Function signingCallback, // User signs with wallet
  }) async {
    // 1. Trigger wallet signing (MetaMask, BlockDAG Wallet, etc.)
    final signature = await signingCallback();
    
    // 2. Call smart contract method
    final tx = await client.sendTransaction(
      credentials,
      Transaction.callContract(
        contract: contract,
        function: contract.function('uploadFile'),
        parameters: [
          EthereumAddress.fromHex(receiverAddress),
          ipfsHash,
          encryptedKey,
        ],
      ),
    );
    
    return tx;
  }
  
  // Get encrypted key from blockchain
  Future<String> getEncryptedKeyForUser(String transactionId) async {
    final key = await client.call(
      contract: contract,
      function: contract.function('getEncryptedKey'),
      params: [transactionId],
    );
    
    return key.toString();
  }
}
```

### 4. Update Vault Upload Flow

**Updated Flow:**

```
1. User selects file
2. User selects auditor (receiver)
3. User accepts terms ✅ (current)
4. **NEW: User connects BlockDAG wallet**
5. **NEW: User signs message with wallet** 🔐
6. File encrypted with AES-256-CBC (backend)
7. AES key encrypted with receiver's RSA public key (backend)
8. **NEW: Upload IPFS hash to BlockDAG smart contract**
9. **NEW: AES key stored encrypted on-chain**
10. Backend saves transaction ID
11. **User receives blockchain transaction hash** ✅
```

### 5. Wallet Signing Integration

**File:** `lib/features/business_owners/presentation/views/vault_upload_screen.dart`

Add wallet signing step:

```dart
bool _hasWalletConnected = false;
bool _hasSignedAgreement = false;
String? _blockchainTxHash;

Widget _buildWalletSigningCard() {
  if (!_hasWalletConnected) {
    return ElevatedButton.icon(
      onPressed: _connectWallet,
      icon: Icon(Icons.account_balance_wallet),
      label: Text('Connect BlockDAG Wallet'),
    );
  }
  
  if (!_hasSignedAgreement) {
    return ElevatedButton.icon(
      onPressed: _signWithWallet,
      icon: Icon(Icons.edit_note),
      label: Text('Sign Security Agreement'),
    );
  }
  
  return Card(
    color: Colors.green.shade50,
    child: ListTile(
      leading: Icon(Icons.check_circle, color: Colors.green),
      title: Text('Agreement Signed'),
      subtitle: Text('TX: ${_blockchainTxHash!.substring(0, 10)}...'),
    ),
  );
}
```

### 6. Updated Upload Process

```dart
Future<void> _uploadFile() async {
  if (!_hasWalletConnected || !_hasSignedAgreement) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Please connect wallet and sign agreement')),
    );
    return;
  }
  
  setState(() => _isUploading = true);
  
  try {
    // 1. Upload to backend (encryption happens)
    final result = await _vaultService.uploadToVault(
      file: _selectedFile,
      receiverId: _selectedReceiverId!,
      description: _descriptionController.text,
    );
    
    // 2. Upload IPFS hash to blockchain
    final txHash = await _blockdagService.uploadFileWithSigning(
      receiverAddress: result['receiverAddress'],
      ipfsHash: result['ipfsHash'],
      encryptedKey: result['encryptedKey'],
      signingCallback: _signTransaction,
    );
    
    // 3. Show success with blockchain TX
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('✅ Uploaded! TX: $txHash'),
        duration: Duration(seconds: 5),
      ),
    );
    
    setState(() {
      _uploadStatus = 'successful';
      _isUploading = false;
    });
    
  } catch (e) {
    setState(() {
      _uploadStatus = 'failed';
      _isUploading = false;
    });
  }
}
```

---

## User Experience Flow

### Current Flow (❌ No blockchain integration)
1. Select file
2. Select receiver
3. Add description
4. Accept terms
5. Upload → File goes to backend only

### New Flow (✅ With blockchain integration)
1. Select file
2. Select receiver
3. Add description
4. Accept terms
5. **Connect BlockDAG Wallet** 🔐
6. **Sign security agreement on-chain** ✍️
7. Upload → File encrypted + IPFS + **BlockDAG TX recorded**
8. **User receives blockchain transaction hash** 📜

---

## Backend Integration

The backend should:

1. **Create blockchain transaction** when vault upload happens:
   ```javascript
   // In backend: vault/upload endpoint
   const tx = await vaultContract.uploadFile(
     receiverAddress,
     ipfsHash,
     encryptedKey
   );
   
   return {
     transactionId: tx.id,
     blockchainTx: tx.hash,
     ipfsHash,
     encryptedKey
   };
   ```

2. **Store transaction on chain** (not just in database)

3. **Return blockchain TX hash** to frontend

---

## Security Model

### Current (❌ Centralized)
- Encryption keys stored in backend database
- Backend controls all access
- Single point of failure

### Proposed (✅ Decentralized)
- Encryption keys stored on BlockDAG blockchain
- Smart contract enforces access control
- Immutable audit trail
- User has proof of transaction on-chain

---

## Implementation Checklist

### Phase 1: Smart Contract Deployment
- [ ] Deploy `VaultManager.sol` to BlockDAG network
- [ ] Get contract address
- [ ] Update frontend contract address

### Phase 2: Frontend Integration
- [ ] Add wallet connection UI
- [ ] Add signing UI
- [ ] Integrate `BlockDAGContractService`
- [ ] Update vault upload flow
- [ ] Display blockchain transaction hash

### Phase 3: Backend Integration
- [ ] Add blockchain interaction to upload endpoint
- [ ] Store TX hash in database
- [ ] Update API responses to include blockchain TX

### Phase 4: User Experience
- [ ] Add loading states for blockchain operations
- [ ] Show transaction status
- [ ] Add "View on BlockDAG Explorer" link
- [ ] Display key receipt confirmation

---

## Current State vs. Required State

| Feature | Current | Required |
|---------|---------|----------|
| File Encryption | ✅ AES-256-CBC | ✅ Same |
| Key Storage | ❌ Backend only | ✅ BlockDAG blockchain |
| User Keys | ❌ No user access | ✅ User can view on-chain |
| Signing | ❌ UI-only checkbox | ✅ Blockchain smart contract |
| Audit Trail | ❌ Database only | ✅ Immutable on-chain |
| Transaction Hash | ❌ None | ✅ BlockDAG TX hash |

---

## Summary

The current implementation:
- ❌ Does NOT use BlockDAG smart contracts
- ❌ Users do NOT sign on-chain
- ❌ Keys are NOT stored on blockchain
- ❌ No blockchain transaction hash

**To make it BlockDAG-compliant:**
1. Deploy smart contract for vault management
2. Add wallet connection (MetaMask, BlockDAG wallet)
3. Add blockchain signing step
4. Store encrypted key on-chain
5. Return blockchain TX hash to user

**This requires backend changes + smart contract deployment.**

