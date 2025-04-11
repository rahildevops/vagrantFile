#!/bin/bash

# Configuration
API_URL="http://openidm.example.com:8080/openidm/info/ping"
USERNAME="openidm-admin"
PASSWORD="openidm-admin"
MAX_ATTEMPTS=100
DELAY_SECONDS=5

# Function to check service status
check_service() {
  response=$(curl -s -w "\n%{http_code}" \
    --header "X-OpenIDM-Username: $USERNAME" \
    --header "X-OpenIDM-Password: $PASSWORD" \
    --header "Accept-API-Version: resource=1.0" \
    --request GET "$API_URL")
  
  http_code=$(echo "$response" | tail -n1)
  content=$(echo "$response" | head -n -1)
  
  if [ "$http_code" -eq 200 ]; then
    state=$(echo "$content" | jq -r '.state')
    if [ "$state" == "ACTIVE_READY" ]; then
      echo "OpenIDM service is running and ready"
      return 0
    else
      echo "OpenIDM service responded but not ready. State: $state"
      return 1
    fi
  else
    echo "OpenIDM service not available (HTTP $http_code)"
    return 1
  fi
}

# Main loop
attempt=1
while [ $attempt -le $MAX_ATTEMPTS ]; do
  echo "Attempt $attempt of $MAX_ATTEMPTS: Checking service status..."
  if check_service; then
    exit 0
  fi
  
  if [ $attempt -lt $MAX_ATTEMPTS ]; then
    echo "Waiting $DELAY_SECONDS seconds before next attempt..."
    sleep $DELAY_SECONDS
  fi
  
  attempt=$((attempt + 1))
done

echo "Maximum attempts reached. OpenIDM service is not ready."
exit 1