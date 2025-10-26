-- Migration: 005_create_vault_tables.sql
-- Description: Create tables for TrustSeal Vault hybrid encryption system

-- Receiver keys table (permanent key pairs)
CREATE TABLE IF NOT EXISTS receiver_keys (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    receiver_id UUID NOT NULL UNIQUE,
    public_key TEXT NOT NULL,
    private_key TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Vault transactions table (key handshake records)
CREATE TABLE IF NOT EXISTS vault_transactions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    sender_id UUID NOT NULL,
    receiver_id UUID NOT NULL,
    ipfs_hash VARCHAR(255) NOT NULL,
    encrypted_file_key TEXT NOT NULL,
    transaction_data JSONB,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Vault files table (metadata for uploaded files)
CREATE TABLE IF NOT EXISTS vault_files (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    transaction_id UUID REFERENCES vault_transactions(id) ON DELETE CASCADE,
    sender_id UUID NOT NULL,
    receiver_id UUID NOT NULL,
    original_filename VARCHAR(255) NOT NULL,
    encrypted_filename VARCHAR(255) NOT NULL,
    file_size BIGINT NOT NULL,
    mime_type VARCHAR(100),
    ipfs_hash VARCHAR(255) NOT NULL,
    status VARCHAR(20) DEFAULT 'uploaded' CHECK (status IN ('uploaded', 'downloaded', 'expired')),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create indexes for performance
CREATE INDEX IF NOT EXISTS idx_receiver_keys_receiver_id ON receiver_keys(receiver_id);
CREATE INDEX IF NOT EXISTS idx_vault_transactions_sender_id ON vault_transactions(sender_id);
CREATE INDEX IF NOT EXISTS idx_vault_transactions_receiver_id ON vault_transactions(receiver_id);
CREATE INDEX IF NOT EXISTS idx_vault_transactions_created_at ON vault_transactions(created_at);
CREATE INDEX IF NOT EXISTS idx_vault_files_sender_id ON vault_files(sender_id);
CREATE INDEX IF NOT EXISTS idx_vault_files_receiver_id ON vault_files(receiver_id);
CREATE INDEX IF NOT EXISTS idx_vault_files_status ON vault_files(status);
CREATE INDEX IF NOT EXISTS idx_vault_files_created_at ON vault_files(created_at);

-- Create trigger function if it doesn't exist
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Create triggers
CREATE TRIGGER update_receiver_keys_updated_at BEFORE UPDATE ON receiver_keys
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_vault_files_updated_at BEFORE UPDATE ON vault_files
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
