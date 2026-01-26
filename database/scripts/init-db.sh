#!/bin/bash
# Wait for SQL Server to be ready
echo "Waiting for SQL Server to be ready..."
for i in {1..50}; do
  /opt/mssql-tools/bin/sqlcmd -S localhost -U sa -P YourStrong!Passw0rd -Q "SELECT 1" > /dev/null 2>&1
  if [ $? -eq 0 ]; then
    echo "SQL Server is ready!"
    break
  fi
  echo "Waiting... ($i/50)"
  sleep 2
done

# Create database
echo "Creating ServiceCatalogueDB database..."
/opt/mssql-tools/bin/sqlcmd -S localhost -U sa -P YourStrong!Passw0rd -Q "
IF NOT EXISTS (SELECT name FROM sys.databases WHERE name = 'ServiceCatalogueDB')
BEGIN
    CREATE DATABASE ServiceCatalogueDB;
END
GO
"

# Run schema script
echo "Running database schema script..."
/opt/mssql-tools/bin/sqlcmd -S localhost -U sa -P YourStrong!Passw0rd -d ServiceCatalogueDB -i /docker-entrypoint-initdb.d/db_structure.sql

echo "Database initialization complete!"
