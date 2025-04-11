#########Reading the properties file

get_property() {
  local key=$1
  local file=$2
  grep "^${key}=" "$file" | cut -d'=' -f2- | tr -d '\r'
}

PROPERTIES_FILE="/vagrant/config.properties"
software_folder_server=$(get_property "software_folder_server" "$PROPERTIES_FILE")

###Updating har files.
sudo cp ${software_folder_server}ig-config/login.json /app/forgerock/config/.openig/config/routes/login.json
sudo cp ${software_folder_server}ig-config/enduser-ui.json /app/forgerock/config/.openig/config/routes/enduser-ui.json
sudo cp ${software_folder_server}ig-config/platform-ui.json /app/forgerock/config/.openig/config/routes/platform-ui.json
sudo cp ${software_folder_server}ig-config/am.json /app/forgerock/config/.openig/config/routes/am.json
sudo cp ${software_folder_server}ig-config/idm.json /app/forgerock/config/.openig/config/routes/idm.json