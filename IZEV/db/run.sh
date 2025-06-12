#!/bin/bash

# Start SQL Server in the background
/opt/mssql/bin/sqlservr &

# Wait for SQL Server to start
echo "Waiting for SQL Server to start..."
sleep 20

# Run the SQL script
echo "Running scripts..."

echo "Creating DB IZEV_Arrival..."
/opt/mssql-tools/bin/sqlcmd -S localhost -U SA -P $SA_PASSWORD -i scripts/01_create_db_IZEV_Arrival.sql
sleep 10

echo "Creating tables for IZEV_Arrival..."
/opt/mssql-tools/bin/sqlcmd -S localhost -U SA -P $SA_PASSWORD -i scripts/02_create_tables_IZEV_Arrival.sql
sleep 10

echo "Creating DB IZEV_Reporting..."
/opt/mssql-tools/bin/sqlcmd -S localhost -U SA -P $SA_PASSWORD -i scripts/03_create_db_IZEV_Reporting.sql
sleep 10

echo "Creating tables for IZEV_Reporting..."
/opt/mssql-tools/bin/sqlcmd -S localhost -U SA -P $SA_PASSWORD -i scripts/04_create_tables_IZEV_Reporting.sql
sleep 10

echo "All scripts executed"

# Keep container running
wait
