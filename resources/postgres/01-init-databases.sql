-- //
-- // Configure the main development database
-- //
-- Create schema
CREATE SCHEMA IF NOT EXISTS demo;

-- Grant privileges on schema to the application user
GRANT ALL ON SCHEMA demo TO db_user;

-- Set search_path at the DB level
ALTER DATABASE fh_dev SET search_path TO demo, public;

-- Set search_path for current session too
SET search_path TO demo, public;

-- Create CDC publication for Debezium
CREATE PUBLICATION cdc_pub FOR TABLES IN SCHEMA demo;

-- Create pg_stat_statements extension for fh_dev
CREATE EXTENSION IF NOT EXISTS pg_stat_statements;
-- SHOW shared_preload_libraries;
-- SELECT COUNT(*) FROM pg_stat_statements;

-- //
-- // Create the 'metastore' database for the Hive metastore
-- //
CREATE DATABASE metastore;

\connect metastore;

GRANT ALL PRIVILEGES ON DATABASE metastore TO db_user;

-- Create pg_stat_statements extension for metastore
CREATE EXTENSION IF NOT EXISTS pg_stat_statements;

-- Grant read access to stats for db_user
GRANT pg_read_all_stats TO db_user;
