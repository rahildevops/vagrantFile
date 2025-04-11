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
idm_version=$(get_property "idm_version" "$PROPERTIES_FILE")
sleep_time=$(get_property "sleep_time" "$PROPERTIES_FILE")
sleep_time_very_long=$(get_property "sleep_time_very_long" "$PROPERTIES_FILE")
idm_hostname=$(get_property "idm_hostname" "$PROPERTIES_FILE")
ig_version=$(get_property "ig_version" "$PROPERTIES_FILE")
ig_cert_store_pass=$(get_property "ig_cert_store_pass" "$PROPERTIES_FILE")

#####################Installation of IG Begin########################################
sudo echo "*******Stopping IDM to start IG Installation due to conflict"
sudo systemctl stop openidm
/vagrant/scripts/ig/8080_service_stop_status.sh
sudo echo "!!!!!!!!!!!!!!!!!!!!!IG Installation Started!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
sudo unzip -q ${software_folder_server}PingGateway-${ig_version} -d ${install_location}
mv ${install_location}identity-gateway-${ig_version}/ ${install_location}ig 
sudo cp -r ${software_folder_server}ig-config/ig.service  /etc/systemd/system
sudo systemctl daemon-reload 
sudo systemctl start ig 
sudo systemctl enable ig 
/vagrant/scripts/ig/8080_service_start_status.sh
sudo systemctl stop ig  
/vagrant/scripts/ig/8080_service_stop_status.sh
sudo echo "*****Installation IG completed succesfully Configuring TLS for IG"
sudo mkdir -p ${secret_location}ig
sudo echo ${ig_cert_store_pass} > ${secret_location}ig/keystore.pass
echo "password is " $ig_cert_store_pass
${JAVA_HOME}/bin/keytool -genkey -alias ig-key -keyalg RSA -keystore ${secret_location}ig/ig.pkcs12 -storepass ${ig_cert_store_pass} -keypass ${ig_cert_store_pass} -dname "CN=platform.example.com,O=ForgeRock" 
sudo cp ${software_folder_server}ig-config/admin.json /app/forgerock/config/.openig/config 
sudo cp ${software_folder_server}ig-config/config.json /app/forgerock/config/.openig/config
sudo echo "*****Starting back IG"
sudo systemctl start ig 
sudo echo "*****Starting back idm"
sudo systemctl start openidm