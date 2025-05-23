#!/bin/sh
set -e

# Verify required environment variables
required_vars="DB_USER DB_PASSWORD DB_NAME DB_SERVER JWT_SECRET SESSION_SECRET"

for var in $required_vars; do
    if [ -z "$(eval echo \$$var)" ]; then
        echo "Error: Required environment variable '$var' is not set"
        exit 1
    fi
done

# Wait for database to be ready
wait_for_db() {
    echo "Waiting for database connection..."
    for i in $(seq 1 30); do
        if nc -z $DB_SERVER 1433; then
            echo "Database is available"
            return 0
        fi
        sleep 1
    done
    echo "Error: Could not connect to database"
    exit 1
}


# Run checks
wait_for_db

# Execute main command
exec "$@"