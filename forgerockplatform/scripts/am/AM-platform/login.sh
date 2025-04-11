
#########Reading the properties file

get_property() {
  local key=$1
  local file=$2
  grep "^${key}=" "$file" | cut -d'=' -f2- | tr -d '\r'
}

PROPERTIES_FILE="/vagrant/config.properties"
am_password=$(get_property "am_password" "$PROPERTIES_FILE")
AM_hostname=$(get_property "AM_hostname" "$PROPERTIES_FILE")


#authenticate against AM
MAX_RETRIES=5
RETRY_DELAY=5  # seconds between retries
attempt=1

while [ $attempt -le $MAX_RETRIES ]; do
  echo "Attempt $attempt of $MAX_RETRIES..."
  
  ADMIN_TOKEN=$(curl -s -X POST \
    -H "X-OpenAM-Username: amadmin" \
    -H "X-OpenAM-Password: ${am_password}" \
    -H "Accept-API-Version: resource=2.1" \
    -H "Content-Type: application/json" \
    http://${AM_hostname}:8081/am/json/realms/root/authenticate | jq -r '.tokenId')

  if [ -n "$ADMIN_TOKEN" ]; then
    echo "Authentication successful.... " $ADMIN_TOKEN 
    export ADMIN_TOKEN=$ADMIN_TOKEN
    break
  fi

  if [ $attempt -lt $MAX_RETRIES ]; then
    echo "Authentication failed, retrying in $RETRY_DELAY seconds..."
    sleep $RETRY_DELAY
  fi
  
  attempt=$((attempt + 1))
done

if [ -z "$ADMIN_TOKEN" ]; then
  echo "Failed to authenticate as administrator after $MAX_RETRIES attempts"
  exit 1
fi