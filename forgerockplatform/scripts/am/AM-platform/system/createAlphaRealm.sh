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

sub_realm=$(get_property "sub_realm" "$PROPERTIES_FILE")
AM_hostname=$(get_property "AM_hostname" "$PROPERTIES_FILE")
###############Creating Alpha Realm#########################

  echo "Creating subrealm '${sub_realm}'..."
  
  # Create JSON payload for realm creation
  cat > /tmp/create_realm.json <<EOF
{
  "name": "${sub_realm}",
  "active": true,
  "parentPath": "/",
  "aliases": ["${sub_realm}.example.com"]
}
EOF

  REALM_CREATE_URL="http://${AM_hostname}:8081/am/json/global-config/realms"
  echo "Creating realm via POST to: $REALM_CREATE_URL"
  
  # Execute realm creation (removed _action parameter)
  HTTP_STATUS=$(curl -s -o /dev/null -w "%{http_code}" -X POST \
    -H "Content-Type: application/json" \
    -H "iPlanetDirectoryPro: $ADMIN_TOKEN" \
    -H "Accept-API-Version: resource=1.0" \
    -d @/tmp/create_realm.json \
    "$REALM_CREATE_URL")

  if [ "$HTTP_STATUS" -eq 201 ]; then
    echo "Subrealm '${sub_realm}' created successfully"
    rm -f /tmp/create_realm.json
  else
    echo "ERROR: Failed to create subrealm (HTTP $HTTP_STATUS)"
    echo "Response body:"
    curl -X POST \
      -H "Content-Type: application/json" \
      -H "iPlanetDirectoryPro: $ADMIN_TOKEN" \
      -H "Accept-API-Version: resource=1.0" \
      -d @/tmp/create_realm.json \
      "$REALM_CREATE_URL"
    exit 1
  fi
 ## End of Code till realm creation###