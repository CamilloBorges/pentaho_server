-- =============================================================================
-- Pentaho Hibernate (Repository) Database Creation Script
-- Database: hibernate
-- Purpose: Repository and logging for Pentaho Server
-- =============================================================================

-- Create database
CREATE DATABASE hibernate
    WITH OWNER = postgres
    ENCODING = 'UTF8'
    TABLESPACE = pg_default
    LC_COLLATE = 'en_US.utf8'
    LC_CTYPE = 'en_US.utf8'
    CONNECTION LIMIT = -1;

-- Create user
CREATE USER hibuser WITH PASSWORD 'password';

-- Grant privileges
GRANT ALL PRIVILEGES ON DATABASE hibernate TO hibuser;

-- Connect to hibernate database
\c hibernate;

-- Grant schema privileges
GRANT ALL ON SCHEMA public TO hibuser;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO hibuser;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO hibuser;

-- Set default privileges for future objects
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON TABLES TO hibuser;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON SEQUENCES TO hibuser;

-- Display confirmation
SELECT 'Hibernate database created successfully' AS status;
