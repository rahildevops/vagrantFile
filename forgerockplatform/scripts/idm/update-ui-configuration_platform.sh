get_property() {
  local key=$1
  local file=$2
  grep "^${key}=" "$file" | cut -d'=' -f2- | tr -d '\r'
}
PROPERTIES_FILE="/vagrant/config.properties"
install_location=$(get_property "install_location" "$PROPERTIES_FILE")
## updating the ui-configuration file to point to platform url
UI_CONFIG_JSON=${install_location}openidm/conf/ui-configuration.json
jq '.configuration.platformSettings.amUrl = "https://platform.example.com:9443/am"' "$UI_CONFIG_JSON" > tmp.json && mv tmp.json "$UI_CONFIG_JSON"
