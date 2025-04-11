get_property() {
  local key=$1
  local file=$2
  grep "^${key}=" "$file" | cut -d'=' -f2- | tr -d '\r'
}

PROPERTIES_FILE="/vagrant/config.properties"
sleep_time=$(get_property "sleep_time" "$PROPERTIES_FILE")
tools_location=$(get_property "tools_location" "$PROPERTIES_FILE")
install_location=$(get_property "install_location" "$PROPERTIES_FILE")
secret_location=$(get_property "secret_location" "$PROPERTIES_FILE")
tmp_location=$(get_property "tmp_location" "$PROPERTIES_FILE")
ldap_instance=$(get_property "ldap_instance" "$PROPERTIES_FILE")
am_instance=$(get_property "am_instance" "$PROPERTIES_FILE")

##################JAVA INSTALLATION ############################
  echo we will not be intalling java
  sudo apt update -y
  sudo apt-get install openjdk-17-jdk -y
  echo java installation completed!!!
  sleep $sleep_time
  ##################UNZIP INSTALLATION ############################
  sudo apt install unzip -y
  echo unzip installation completed!!!
  sleep $sleep_time


##########################Install jq ################################
sudo apt-get update
sudo apt-get install -y jq
  ###################Adding entries to host file###################
  # 1. taking backup of the existing host file
     sudo cp /etc/hosts /etc/hosts.bak
  # 2. Add custom entries to /etc/hosts
    sudo echo "127.0.0.1    admin.example.com" | sudo tee -a /etc/hosts
    sudo echo "127.0.0.1    am.example.com" | sudo tee -a /etc/hosts
    sudo echo "127.0.0.1    directory.example.com" | sudo tee -a /etc/hosts
    sudo echo "127.0.0.1    enduser.example.com" | sudo tee -a /etc/hosts
    sudo echo "127.0.0.1    login.example.com" | sudo tee -a /etc/hosts
    sudo echo "127.0.0.1    openidm.example.com" | sudo tee -a /etc/hosts
    sudo echo "127.0.0.1    platform.example.com" | sudo tee -a /etc/hosts  
  ##################Creating Directory Structure #################
   mkdir -p  ${tools_location} \
    ${install_location} \
    ${install_location}tomcat \
    ${secret_location} \
    ${tmp_location} \
    ${ldap_instance} \
    ${am_instance}
