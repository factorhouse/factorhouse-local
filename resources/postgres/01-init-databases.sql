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

-- //
-- // Create the 'metastore' database for the Hive metastore
-- //
CREATE DATABASE metastore;

\connect metastore;

GRANT ALL PRIVILEGES ON DATABASE metastore TO db_user;
