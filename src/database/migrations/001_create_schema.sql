-- Create extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Projects table
CREATE TABLE IF NOT EXISTS projects (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(255) NOT NULL,
    description TEXT,
    website VARCHAR(500),
    contract_address VARCHAR(42),
    token_symbol VARCHAR(10),
    token_name VARCHAR(100),
    verification_status VARCHAR(20) DEFAULT 'unverified',
    trust_score DECIMAL(3,1) DEFAULT 0.0,
    verification_tier VARCHAR(20) DEFAULT 'pending',
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- Verification criteria table
CREATE TABLE IF NOT EXISTS verification_criteria (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    project_id UUID REFERENCES projects(id) ON DELETE CASCADE,
    team_verification_score DECIMAL(3,1) DEFAULT 0.0,
    technical_verification_score DECIMAL(3,1) DEFAULT 0.0,
    financial_verification_score DECIMAL(3,1) DEFAULT 0.0,
    community_verification_score DECIMAL(3,1) DEFAULT 0.0,
    overall_score DECIMAL(3,1) DEFAULT 0.0,
    risk_level VARCHAR(20) DEFAULT 'unknown',
    verification_tier VARCHAR(20) DEFAULT 'pending',
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- Verification checks table
CREATE TABLE IF NOT EXISTS verification_checks (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    project_id UUID REFERENCES projects(id) ON DELETE CASCADE,
    check_type VARCHAR(50) NOT NULL,
    check_name VARCHAR(100) NOT NULL,
    status VARCHAR(20) DEFAULT 'pending',
    score DECIMAL(3,1) DEFAULT 0.0,
    details JSONB,
    verified_by UUID,
    verified_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT NOW()
);

-- Audit logs table
CREATE TABLE IF NOT EXISTS audit_logs (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    project_id UUID REFERENCES projects(id) ON DELETE SET NULL,
    action VARCHAR(100) NOT NULL,
    admin_id UUID,
    details JSONB,
    ip_address INET,
    user_agent TEXT,
    created_at TIMESTAMP DEFAULT NOW()
);

-- Admin users table
CREATE TABLE IF NOT EXISTS admin_users (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    role VARCHAR(50) DEFAULT 'reviewer',
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT NOW(),
    last_login TIMESTAMP
);

-- Create indexes
CREATE INDEX IF NOT EXISTS idx_projects_status ON projects(verification_status);
CREATE INDEX IF NOT EXISTS idx_projects_address ON projects(contract_address);
CREATE INDEX IF NOT EXISTS idx_verification_project ON verification_criteria(project_id);
CREATE INDEX IF NOT EXISTS idx_checks_project ON verification_checks(project_id);
CREATE INDEX IF NOT EXISTS idx_audit_project ON audit_logs(project_id);
CREATE INDEX IF NOT EXISTS idx_audit_created ON audit_logs(created_at);

-- Create updated_at trigger function
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Create triggers
CREATE TRIGGER update_projects_updated_at BEFORE UPDATE ON projects
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_criteria_updated_at BEFORE UPDATE ON verification_criteria
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
