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


###################Installation of AM ############################
  #1. stopping tomcat and cleanup of websapps folder 
  sudo systemctl stop tomcat
  sudo rm -rf  ${install_location}tomcat/webapps/*

  #2. unzip the am war file in the tmp directory and move to webapps folder
  sudo unzip -qq ${software_folder_server}/AM-${am_version}.zip -d ${tmp_location}
  sudo cp ${tmp_location}openam/AM-${am_version}.war ${install_location}tomcat/webapps/am.war
  sudo chown -R rahil:rahil /app
  sudo chown -R rahil:rahil /home/rahil
  sudo systemctl start tomcat
  sudo sleep 10
  sudo echo "*********Completed deploying AM war file, working to configure AM"
  #3. configuring AM
  sudo unzip -qq ${tmp_location}openam/${AM_CONFIGURATION_TOOL} -d ${tools_location}config
  sudo echo "JAVA_HOME=${JAVA_HOME}" >> /etc/environment
  sudo echo "export JAVA_HOME=${JAVA_HOME}" >> /home/vagrant/.bashrc
  sudo source /etc/environment
  sudo cp ${software_folder_server}config.properties ${tools_location}config
  sudo echo running jar for configuring AM... 
  sudo java -jar ${tools_location}config/${AM_CONFIGURATION_TOOL_JAR} -f ${tools_location}config/config.properties

  ###################Complete Installation of AM####################