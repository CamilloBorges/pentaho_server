-- =============================================================================
-- Pentaho JackRabbit (JCR) Database Creation Script
-- Database: jackrabbit
-- Purpose: Content Repository for Pentaho Server
-- =============================================================================

-- Create database
CREATE DATABASE jackrabbit
    WITH OWNER = postgres
    ENCODING = 'UTF8'
    TABLESPACE = pg_default
    LC_COLLATE = 'en_US.utf8'
    LC_CTYPE = 'en_US.utf8'
    CONNECTION LIMIT = -1;

-- Create user
CREATE USER jcr_user WITH PASSWORD 'password';

-- Grant privileges
GRANT ALL PRIVILEGES ON DATABASE jackrabbit TO jcr_user;

-- Connect to jackrabbit database
\c jackrabbit;

-- Grant schema privileges
GRANT ALL ON SCHEMA public TO jcr_user;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO jcr_user;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO jcr_user;

-- Set default privileges for future objects
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON TABLES TO jcr_user;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON SEQUENCES TO jcr_user;

-- Display confirmation
SELECT 'JackRabbit database created successfully' AS status;
