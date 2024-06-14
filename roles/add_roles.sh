#!/bin/bash
POSTGRES_PASSWORD=postgres 
psql -U postgres -d postgres -c "CREATE ROLE reader;
CREATE ROLE writer;

GRANT CONNECT ON DATABASE postgres TO reader;
GRANT USAGE ON SCHEMA public TO reader;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO reader;

GRANT CONNECT ON DATABASE postgres TO writer;
GRANT USAGE ON SCHEMA public TO writer;
GRANT SELECT, INSERT, UPDATE ON ALL TABLES IN SCHEMA public TO writer;

CREATE USER analytic WITH PASSWORD 'analytic';
GRANT SELECT ON photo TO analytic;

CREATE ROLE group_no_access;
REVOKE CONNECT ON DATABASE postgres FROM group_no_access;"