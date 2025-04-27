-- create a new schema named 'dev' in the current database ('factorhouse')
CREATE SCHEMA dev;

-- grant all privileges on the 'dev' schema to the 'dev_user' role
GRANT ALL ON SCHEMA dev TO db_user;

-- change search_path to dev on a connection-level
SET search_path TO dev;

-- change search_path to dev on a database-level
ALTER database "factorhouse" SET search_path TO dev;

-- create a publication for all tables in the dev schema
CREATE PUBLICATION cdc_pub FOR TABLES IN SCHEMA dev;
