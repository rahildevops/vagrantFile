#!/bin/bash

# Configuration
AM_HOST="am.example.com"
AM_PORT="8081"
REALM="alpha"
ADMIN_USER="admin"  # Replace with actual admin username
ADMIN_PASS="password"  # Replace with actual admin password

# API Endpoint
URL="http://$AM_HOST:$AM_PORT/am/json/realms/root/realms/$REALM/realm-config/services/validation"

# Request Headers
HEADERS=(
    -H "Accept: application/json, text/javascript, */*; q=0.01"
    -H "Accept-API-Version: protocol=1.0,resource=1.0"
    -H "Content-Type: application/json"
    -H "Cache-Control: no-cache"
    -H "X-Requested-With: XMLHttpRequest"
    -H "iPlanetDirectoryPro: $ADMIN_TOKEN" 
)

# Request Body
DATA='{
  "validGotoDestinations": [
    "http://admin.example.com:8082/*",
    "http://admin.example.com:8082/*?*",
    "http://login.example.com:8083/*",
    "http://login.example.com:8083/*?*",
    "http://enduser.example.com:8888/*",
    "http://enduser.example.com:8888/*?*",
    "https://platform.example.com:9443/*",
    "https://platform.example.com:9443/*?"
  ],
  "_id": "",
  "_type": {
    "_id": "validation",
    "name": "Validation Service",
    "collection": false
  }
}'

# Make the request
response=$(curl -s -w "\nHTTP_STATUS:%{http_code}" -X PUT "${HEADERS[@]}" -u "$ADMIN_USER:$ADMIN_PASS" -d "$DATA" "$URL")

# Extract body and status
http_body=$(echo "$response" | sed '/HTTP_STATUS/d')
http_status=$(echo "$response" | tr -d '\n' | sed -e 's/.*HTTP_STATUS://')

# Output results
echo "Response Status: $http_status"
echo "Response Body:"
echo "$http_body" | jq .  # Pretty print JSON response

# Check for success
if [ "$http_status" -eq 200 ]; then
    echo "Validation configuration updated successfully"
    exit 0
else
    echo "Failed to update validation configuration"
    exit 1
fi