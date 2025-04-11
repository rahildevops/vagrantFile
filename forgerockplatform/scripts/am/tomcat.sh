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

  
  ##################### Tomcat Installation ########################
  #1. Extract the tomcat binaries 
  sudo sleep ${sleep_time_long}
  tar -xf ${software_folder_server}apache-tomcat-${tomcat_version}.tar.gz -C ${install_location}tomcat --strip-components=1
  
  #2. Creating a trust store for AM and importing the DS certificate to it
  sudo keytool -exportcert -keystore ${ldap_instance}config/keystore -storepass $(cat ${ldap_instance}config/keystore.pin) -alias ssl-key-pair -rfc -file ${secret_location}ds-cert.pem
  sudo keytool -import -file ${secret_location}ds-cert.pem -alias ds-cert -keystore ${secret_location}${am_trust_store} -keypass ${am_trust_store_password}  -storepass  ${am_trust_store_password} -noprompt

  #3. Creating systemctl file for tomcat
  cat > /etc/systemd/system/tomcat.service <<EOF
  [Unit]
  Description= Apache Tomcat Web Application Container
  After=network.target
  [Service]
  Type=forking
  User=rahil
  Group=rahil
  Environment="JAVA_HOME=/usr/lib/jvm/java-1.17.0-openjdk-amd64"
  Environment="CATALINA_HOME=${install_location}tomcat"
  Environment="CATALINA_PID=${install_location}tomcat/temp/tomcat.pid"
  Environment="CATALINA_OPTS=-Xms512M -Xmx1024M -server -XX:+UseParallelGC -Djavax.net.ssl.trustStore=${secret_location}${am_trust_store} -Djavax.net.ssl.trustStorePassword=${am_trust_store_password} -Djavax.net.ssl.trustStoreType=jks"
  ExecStart=${install_location}tomcat/bin/startup.sh
  ExecStop=${install_location}tomcat/bin/shutdown.sh
  [Install]
  WantedBy=multi-user.target 
EOF

  #4. Overidding the server.xml to change port to 8081
  sudo cp -f ${software_folder_server}/server.xml ${install_location}tomcat/conf/server.xml 

  #5. Start Tomcat 
  sudo chown -R rahil:rahil /app
  sudo systemctl daemon-reload
  sudo systemctl start tomcat
  sudo systemctl enable tomcat
  ################### End of Tomcat Installation####################
