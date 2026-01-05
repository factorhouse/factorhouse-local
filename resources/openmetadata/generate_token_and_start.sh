#!/bin/bash
set -e

## TODO: Currently it exports a token from an admin user. Create a bot and token from it!

# This script will wait for the OpenMetadata server to be ready,
# then create a bot and generate a JWT token for the Airflow lineage backend.

OM_ADMIN_USER=admin@factorhouse.io
OM_ADMIN_PASSWORD=admin
ENCODED_PASSWORD=$(echo -n "${OM_ADMIN_PASSWORD}" | base64)
OM_SERVER_URL="http://omt-server:8585/api"
OM_HEALTH_URL="http://omt-server:8586/healthcheck"
BOT_NAME="airflow_lineage_bot"
BOT_USER_JSON="{ \"name\": \"${BOT_NAME}\", \"displayName\": \"Airflow Lineage Bot\" }"

echo "Waiting for OpenMetadata server to be healthy at ${OM_HEALTH_URL}..."

# Wait for the server to be healthy
until $(curl --output /dev/null --silent --head --fail ${OM_HEALTH_URL}); do
  printf '.'
  sleep 5
done

echo -e "\nOpenMetadata server is healthy."

# echo "Waiting for 5 seconds for the main application to be ready..."
# sleep 5

# 1. Get the admin JWT token
echo "Attempting to get admin JWT token..."
ADMIN_TOKEN=$(curl -s -X POST \
  -H "Content-Type: application/json" \
  -d "{\"email\": \"${OM_ADMIN_USER}\", \"password\": \"${ENCODED_PASSWORD}\"}" \
  "${OM_SERVER_URL}/v1/users/login" | sed -n 's/.*"accessToken":"\([^"]*\)".*/\1/p')

if [ -z "$ADMIN_TOKEN" ] || [ "$ADMIN_TOKEN" == "null" ]; then
    echo "Failed to get admin token. Exiting."
    exit 1
fi
echo "Successfully obtained admin token."

# 2. Export the ADMIN token for the Airflow lineage backend to use
export AIRFLOW__LINEAGE__JWT_TOKEN="${ADMIN_TOKEN}"

echo "JWT Token has been set for the Airflow lineage backend using the ADMIN token."
echo "You can check the value of AIRFLOW__LINEAGE__JWT_TOKEN by executing the following command:"
echo "docker exec omt_ingestion cat /proc/1/environ | tr '\0' '\n' | grep AIRFLOW__LINEAGE__JWT_TOKEN"