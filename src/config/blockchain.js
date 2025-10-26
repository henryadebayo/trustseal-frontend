module.exports = {
    // BlockDAG Network Configuration
    BLOCKDAG: {
        MAINNET: {
            RPC_URL: process.env.BLOCKDAG_RPC_URL || 'https://rpc.blockdag.network',
            EXPLORER: 'https://explorer.blockdag.network',
            CHAIN_ID: 77, // BlockDAG mainnet chain ID
            NAME: 'BlockDAG Mainnet'
        },
        TESTNET: {
            RPC_URL: process.env.BLOCKDAG_TESTNET_RPC_URL || 'https://testnet-rpc.blockdag.network',
            EXPLORER: 'https://testnet-explorer.blockdag.network',
            CHAIN_ID: 77, // BlockDAG testnet chain ID
            NAME: 'BlockDAG Testnet'
        }
    },

    // Ethereum (for cross-chain projects)
    ETHEREUM: {
        RPC_URL: process.env.ETHEREUM_RPC_URL || 'https://mainnet.infura.io/v3/YOUR_INFURA_KEY',
        EXPLORER: 'https://etherscan.io',
        CHAIN_ID: 1,
        NAME: 'Ethereum Mainnet'
    },

    // BSC (for cross-chain projects)
    BSC: {
        RPC_URL: process.env.BSC_RPC_URL || 'https://bsc-dataseed.binance.org/',
        EXPLORER: 'https://bscscan.com',
        CHAIN_ID: 56,
        NAME: 'Binance Smart Chain'
    }
};
