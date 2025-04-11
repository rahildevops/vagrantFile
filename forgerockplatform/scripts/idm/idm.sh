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
#################################################################
 #################Start of idm installation######################
# Create necessary directories
sudo mkdir -p ${install_location}/logs
#  #1. Install forgerock idm
#  sudo unzip ${software_folder_server}IDM-${idm_version}.zip -d ${install_location}
#  sudo sed -i 's/^openidm.host=.*/openidm.host=${idm_hostname}/' ${install_location}openidm/resolver/boot.properties
#  export OPENIDM_OPTS="-Xms4096m -Xmx4096m"
# sudo nohup /app/forgerock/install/openidm/startup.sh   > ${install_location}/logs/console.out 2>&1 &
# /vagrant/scripts/idm/checkIDMStatus.sh
# echo "OpenIDM is ready and running!"
#  sudo sleep ${sleep_time_very_long}
#  sudo /app/forgerock/install/openidm/shutdown.sh  
#  sudo cp ${software_folder_server}openidm.service /etc/systemd/system/
#  sudo systemctl enable openidm
#  sudo systemctl start openidm


#!/bin/bash




# Unzip the IDM package
echo "Unzipping IDM package..."
sudo unzip -qq ${software_folder_server}IDM-${idm_version}.zip -d ${install_location}

# Update hostname in boot.properties
echo "Configuring hostname..."
sudo sed -i "s/^openidm.host=.*/openidm.host=${idm_hostname}/" ${install_location}/openidm/resolver/boot.properties

# Set Java options (without sudo)
export OPENIDM_OPTS="-Xms4096m -Xmx4096m"

# # First run to create configuration
# echo "Initial startup of OpenIDM..."
# sudo nohup ${install_location}/openidm/startup.sh > ${install_location}/logs/console.out 2>&1 &

# # Wait for initial startup to complete
# echo "Waiting ${sleep_time_very_long} seconds for initial startup..."
# /vagrant/scripts/idm/checkIDMStatus.sh


# # Shutdown the initial instance
# echo "Stopping initial instance..."
# sudo ${install_location}/openidm/shutdown.sh
# /vagrant/scripts/ig/8080_service_stop_status.sh
# # Install systemd service
# echo "Setting up systemd service..."
sudo cp ${software_folder_server}openidm.service /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable openidm

# Start via systemd
echo "Starting OpenIDM service..."
sudo systemctl start openidm

# Verify service is running
echo "Checking service status..."
sleep 10 # Give it some time to start
systemctl status openidm --no-pager

/vagrant/scripts/idm/checkIDMStatus.sh
# Optional: Wait for OpenIDM to be fully ready
# echo "Waiting for OpenIDM to be ready..."
# attempt=1
# max_attempts=100
# delay=5

# while [ $attempt -le $max_attempts ]; do
#   if curl -s --header "X-OpenIDM-Username: openidm-admin" \
#           --header "X-OpenIDM-Password: openidm-admin" \
#           --header "Accept-API-Version: resource=1.0" \
#           "http://${idm_hostname}:8080/openidm/info/ping" | grep -q "ACTIVE_READY"; then
#     echo "OpenIDM is ready and running!"
#     exit 0
#   fi
#   echo "Attempt $attempt: OpenIDM not ready yet, waiting $delay seconds..."
#   sleep $delay
#   attempt=$((attempt + 1))
# done

# echo "ERROR: OpenIDM did not become ready after $max_attempts attempts"
# exit 1


