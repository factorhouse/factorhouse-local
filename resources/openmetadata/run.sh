#!/bin/bash
# This script is the new main command for the container.
# It ensures environment variables are set before starting the main application.
set -e

echo "--- Custom Entrypoint: Running token generation script ---"

# Use 'source' (or '.') to run the script in the current shell's context.
# This is CRUCIAL for the exported environment variable to be available to the next command.
source /opt/airflow/generate_token_and_start.sh

echo "--- Custom Entrypoint: Token script finished. Starting main Airflow script. ---"

# Now, execute the original, long-running startup script.
# 'exec' replaces this script's process with the new one, which is a clean way to hand off control.
exec /opt/airflow/ingestion_dependency.sh
