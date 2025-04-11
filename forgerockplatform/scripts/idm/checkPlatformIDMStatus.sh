#!/bin/bash

# Configuration
AM_HOST="am.example.com"
AM_PORT="8081"
OPENIDM_HOST="openidm.example.com"
OPENIDM_PORT="8080"
USERNAME="amAdmin"
PASSWORD="SecAuth0"
CLIENT_ID="idm-provisioning"
CLIENT_SECRET="openidm"
SCOPE="fr:idm:*"

# Retry Settings
MAX_ATTEMPTS=100
DELAY_SECONDS=5

# Endpoints
TOKEN_URL="http://$AM_HOST:$AM_PORT/am/oauth2/realms/root/access_token"
STATUS_URL="http://$OPENIDM_HOST:$OPENIDM_PORT/openidm/info/login"

# Function to get bearer token
get_bearer_token() {
  local response http_status response_body
  echo "Obtaining bearer token..."
  
  response=$(curl -s -w "\nHTTP_STATUS:%{http_code}" \
    --header "X-OpenAM-Username: $USERNAME" \
    --header "X-OpenAM-Password: $PASSWORD" \
    --header "Accept-API-Version: resource=2.0, protocol=1.0" \
    --request POST \
    --data "grant_type=client_credentials" \
    --data "client_id=$CLIENT_ID" \
    --data "client_secret=$CLIENT_SECRET" \
    --data "scope=$SCOPE" \
    "$TOKEN_URL")

  http_status=$(echo "$response" | grep "HTTP_STATUS:" | cut -d':' -f2)
  response_body=$(echo "$response" | sed '/HTTP_STATUS:/d')

  if [ "$http_status" -ne 200 ]; then
    echo "Failed to obtain bearer token. HTTP Status: $http_status"
    echo "Response: $response_body"
    return 1
  fi

  access_token=$(echo "$response_body" | jq -r '.access_token')
  if [ -z "$access_token" ] || [ "$access_token" == "null" ]; then
    echo "No access token found in response"
    return 1
  fi

  echo "Successfully obtained bearer token"
  echo "Token expires in: $(echo "$response_body" | jq -r '.expires_in') seconds"
  echo
}

# Function to check login status with retry logic
check_login_status() {
  local attempt=1
  local success=0
  
  while [ $attempt -le $MAX_ATTEMPTS ]; do
    echo "Attempt $attempt of $MAX_ATTEMPTS: Checking login status..."
    
    response=$(curl -s -w "\nHTTP_STATUS:%{http_code}" \
      --request GET \
      --header "Content-Type: application/json" \
      --header "Authorization: Bearer $access_token" \
      "$STATUS_URL")

    http_status=$(echo "$response" | grep "HTTP_STATUS:" | cut -d':' -f2)
    response_body=$(echo "$response" | sed '/HTTP_STATUS:/d')

    if [ "$http_status" -eq 200 ]; then
      echo "Login status check successful:"
      echo "$response_body" | jq
      echo
      echo "Authentication ID: $(echo "$response_body" | jq -r '.authenticationId')"
      echo "Roles: $(echo "$response_body" | jq -r '.authorization.roles | join(", ")')"
      success=1
      break
    else
      echo "Attempt $attempt failed. HTTP Status: $http_status"
      echo "Response: $response_body"
      
      if [ $attempt -lt $MAX_ATTEMPTS ]; then
        echo "Waiting $DELAY_SECONDS seconds before retry..."
        sleep $DELAY_SECONDS
      fi
      
      attempt=$((attempt + 1))
    fi
  done

  if [ $success -eq 0 ]; then
    echo "Maximum attempts reached. Failed to get successful login status."
    return 1
  fi
  return 0
}

# Main execution
if ! get_bearer_token; then
  exit 1
fi

if ! check_login_status; then
  exit 1
fi

exit 0