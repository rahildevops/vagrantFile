 #########Reading the properties file

get_property() {
  local key=$1
  local file=$2
  grep "^${key}=" "$file" | cut -d'=' -f2- | tr -d '\r'
}

PROPERTIES_FILE="/vagrant/config.properties"
software_folder_server=$(get_property "software_folder_server" "$PROPERTIES_FILE")
ds_version=$(get_property "ds_version" "$PROPERTIES_FILE")
install_location=$(get_property "install_location" "$PROPERTIES_FILE")
DS_Deployment_password=$(get_property "DS_Deployment_password" "$PROPERTIES_FILE")
secret_location=$(get_property "secret_location" "$PROPERTIES_FILE")
secret_file=$(get_property "secret_file" "$PROPERTIES_FILE")
DS_admin_password=$(get_property "DS_admin_password" "$PROPERTIES_FILE")
DS_hostname=$(get_property "DS_hostname" "$PROPERTIES_FILE")
Admin_port=$(get_property "Admin_port" "$PROPERTIES_FILE")
Ldap_port=$(get_property "Ldap_port" "$PROPERTIES_FILE")
Ldaps_port=$(get_property "Ldaps_port" "$PROPERTIES_FILE")
DS_client_password=$(get_property "DS_client_password" "$PROPERTIES_FILE")
ldap_instance=$(get_property "ldap_instance" "$PROPERTIES_FILE")
sleep_time_long=$(get_property "sleep_time_long" "$PROPERTIES_FILE")
am_trust_store=$(get_property "am_trust_store" "$PROPERTIES_FILE")
am_trust_store_password=$(get_property "am_trust_store_password" "$PROPERTIES_FILE")
tomcat_version=$(get_property "tomcat_version" "$PROPERTIES_FILE")

am_version=$(get_property "am_version" "$PROPERTIES_FILE")
tmp_location=$(get_property "tmp_location" "$PROPERTIES_FILE")
AM_CONFIGURATION_TOOL=$(get_property "AM_CONFIGURATION_TOOL" "$PROPERTIES_FILE")
tools_location=$(get_property "tools_location" "$PROPERTIES_FILE")
JAVA_HOME=$(get_property "JAVA_HOME" "$PROPERTIES_FILE")
AM_CONFIGURATION_TOOL_JAR=$(get_property "AM_CONFIGURATION_TOOL_JAR" "$PROPERTIES_FILE")

 ################### CTS Configuration ####################
  
  # Create a temporary file with the configuration
  cat > /tmp/cts_config.json <<EOF
{
  "amconfig.org.forgerock.services.cts.store.common.section": {
    "org.forgerock.services.cts.store.location": "external",
    "org.forgerock.services.cts.store.root.suffix": "ou=famrecords,ou=openam-session,ou=tokens",
    "org.forgerock.services.cts.store.max.connections": "100",
    "org.forgerock.services.cts.store.page.size": 0,
    "org.forgerock.services.cts.store.vlv.page.size": 1000
  },
  "amconfig.org.forgerock.services.cts.store.external.section": {
    "org.forgerock.services.cts.store.ssl.enabled": true,
    "org.forgerock.services.cts.store.mtls.enabled": false,
    "org.forgerock.services.cts.store.starttls.enabled": false,
    "org.forgerock.services.cts.store.directory.name": "${DS_hostname}:${Ldaps_port}",
    "org.forgerock.services.cts.store.loginid": "uid=openam_cts,ou=admins,ou=famrecords,ou=openam-session,ou=tokens",
    "org.forgerock.services.cts.store.password": "${DS_client_password}",
    "org.forgerock.services.cts.store.heartbeat": 0,
    "org.forgerock.services.cts.store.affinity.enabled": true
  }
}
EOF

# Apply the configuration with enhanced retry logic
MAX_RETRIES=3
INITIAL_DELAY=2  # initial delay in seconds
MAX_DELAY=30     # maximum delay between retries
attempt=1
delay=$INITIAL_DELAY
SUCCESS=false

echo "Using session cookie: $ADMIN_TOKEN"
  # Store the full response for debugging
  RESPONSE_FILE="/tmp/cts_response_$attempt.json"
  
  HTTP_STATUS=$(curl -s -o "$RESPONSE_FILE" -w "%{http_code}" -X PUT \
    -H "Content-Type: application/json" \
    -H "Cookie: iplanetDirectoryPro=$ADMIN_TOKEN" \
    -H "Accept-API-Version: resource=1.0" \
    -H "If-Match: *" \
    -d @/tmp/cts_config.json \
    http://localhost:8081/am/json/global-config/servers/server-default/properties/cts#1.0_update)

  if [ "$HTTP_STATUS" -eq 200 ]; then
    SUCCESS=true
    echo "CTS external store configuration successfully applied"
    rm -f /tmp/cts_config.json "$RESPONSE_FILE"
  else
    echo "WARNING: Failed to configure CTS (HTTP $HTTP_STATUS)"
    echo "Response details:"
    jq . "$RESPONSE_FILE" 2>/dev/null || cat "$RESPONSE_FILE"
    
    if [ $attempt -lt $MAX_RETRIES ]; then
      echo "Retrying in $delay seconds..."
      sleep $delay
      # Exponential backoff with max limit
      delay=$((delay * 2))
      [ $delay -gt $MAX_DELAY ] && delay=$MAX_DELAY
    fi
    attempt=$((attempt + 1))
  fi
done
