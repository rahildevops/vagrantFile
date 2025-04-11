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

#########End of reading the properties file
##################Installing Directory Server #################
  #1. Unzip the ds binaries
  unzip -q ${software_folder_server}DS-${ds_version} -d ${install_location}
  #2. creating deployment descriptor
  deployment_Secret=$(${install_location}opendj/bin/dskeymgr create-deployment-id --deploymentIdPassword ${DS_Deployment_password})
  #3. String deployment secret in a file.
  echo deployment_secrert=${deployment_Secret}  >> ${secret_location}${secret_file}
  #4. Installing DS Server.
  echo starting to install DS Server !!!!!
 sudo ${install_location}opendj/setup \
 --deploymentId $deployment_Secret \
 --deploymentIdPassword ${DS_Deployment_password} \
 --rootUserDN uid=admin \
 --rootUserPassword ${DS_admin_password} \
 --monitorUserPassword ${DS_admin_password} \
 --hostname ${DS_hostname} \
 --adminConnectorPort ${Admin_port} \
 --ldapPort ${Ldap_port} \
 --enableStartTls \
 --ldapsPort ${Ldaps_port} \
 --profile am-config \
 --set am-config/amConfigAdminPassword:${DS_client_password} \
 --profile am-cts \
 --instancePath ${ldap_instance} \
 --set am-cts/amCtsAdminPassword:${DS_client_password} \
 --set am-cts/tokenExpirationPolicy:am-sessions-only \
 --profile am-identity-store \
 --set am-identity-store/amIdentityStoreAdminPassword:${DS_client_password} \
 --profile idm-repo \
 --set idm-repo/domain:forgerock.io \
 --acceptLicense  >> /app/forgerock/tmp/ldapInstall.log
  #5. Creating the opendj systemctl file 
  sudo adduser --gecos "" --disabled-password rahil
  sudo ${install_location}opendj/bin/create-rc-script --groupName rahil --userName rahil --systemdService /etc/systemd/system/opendj.service
  echo starting the ds ......
  sudo chown -R rahil:rahil /app 
  sudo systemctl daemon-reload
  sudo systemctl start opendj
  echo installation of DS completed succesfully!!!!
  sudo sleep ${sleep_time_long}

  #6. Creating file to run DS as a service.
  sudo ${install_location}opendj/bin/create-rc-script --groupName rahil --userName rahil --systemdService /etc/systemd/system/opendj.service
  echo starting the ds ......
  sudo chown -R rahil:rahil /app 
  sudo systemctl daemon-reload
  sudo systemctl stop opendj
  sudo sleep ${sleep_time_long}
  sudo systemctl start opendj
  sudo systemctl enable opendj

  #7. Creating tools.properties file 
  mkdir /home/rahil/.opendj
  cat > /home/rahil/.opendj/tools.properties <<EOF
  hostname=ubuntu-jammy
  adminConnectorPort=${Admin_port}
  ldapcompare.port=${Ldaps_port}
  ldapdelete.port=${Ldaps_port}
  ldapmodify.port=${Ldaps_port}
  ldappasswordmodify.port=${Ldaps_port}
  ldapsearch.port=${Ldaps_port}
  bindDN=uid=admin
  bindPassword=${DS_admin_password}
  useSsl=true
  trustAll=true 
EOF
  ##############End of Director Server Installation#################