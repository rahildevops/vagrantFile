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
openidm_client_secret=$(get_property "openidm_client_secret" "$PROPERTIES_FILE")

#################################################################

sudo systemctl stop openidm
/vagrant/scripts/ig/8080_service_stop_status.sh
 #2. Configure IDM to trust DS cert
 sudo keytool -import -file ${secret_location}ds-cert.pem -alias ds-cert -keystore ${install_location}openidm/security/truststore  -storepass:file ${install_location}openidm/security/storepass -noprompt

 #3. REPLACE THE REPO.DS FILE
 sudo cp ${software_folder_server}repo.ds.json ${install_location}openidm/conf/

 #5.  Remove password encryption using jq from managed.json
    sudo jq '(.objects[] | select(.name == "user").schema.properties.password) |= del(.encryption)' ${install_location}openidm/conf/managed.json > ${install_location}openidm/conf/managed-updated.json &&
    sudo cp  ${install_location}openidm/conf/managed-updated.json ${install_location}openidm/conf/managed.json
 # Update managed.json with jq

 #6. from managed.json Update the password property to ensure that users update their passwords through the self-service APIs, not directly: "userEditable" : false
sudo jq '(.objects[] | select(.name == "user").schema.properties.password.userEditable) = false' ${install_location}openidm/conf/managed.json > ${install_location}openidm/conf/managed-updated.json &&
sudo mv ${install_location}openidm/conf/managed-updated.json ${install_location}openidm/conf/managed.json
    
# 8. Add cn and aliasList properties to user object's properties and update order array
#  Define the path to managed.json (adjust path as needed)
MANAGED_JSON="${install_location}openidm/conf/managed.json"

#Add cn and aliasList properties to user object's properties and update order array
 
jq --arg js_code "object.cn || (object.givenName + ' ' + object.sn)" '
   .objects[0].schema.properties += {
     "cn": {
       "title": "Common Name",
       "description": "Common Name",
       "type": "string",
       "viewable": false,
       "searchable": false,
       "userEditable": false,
       "scope": "private",
       "isPersonal": true,
       "isVirtual": true,
       "onStore": {
         "type": "text/javascript",
         "source": $js_code
       }
     },
     "aliasList": {
       "title": "User Alias Names List",
       "description": "List of identity aliases used primarily to record social IdP subjects for this user",
       "type": "array",
       "items": {
         "type": "string",
         "title": "User Alias Names Items"
       },
       "viewable": false,
       "searchable": false,
       "userEditable": true,
       "returnByDefault": false,
       "isVirtual": false
     }
   } |
   .objects[0].schema.order |= (
     .[0:(index("sn") + 1)] + ["cn", "aliasList"] + .[(index("sn") + 1):]
   )
' "$MANAGED_JSON" > tmp.json && mv tmp.json "$MANAGED_JSON"
 #8. Authenticate updating the authentication.json

  # copy the dowloaded file
     sudo  cp ${software_folder_server}authentication.json ${install_location}openidm/conf/authentication.json
  # Define the path to authentication.json (adjust path as needed)
    AUTH_JSON=${install_location}openidm/conf/authentication.json

  # Replace clientSecret value
    jq --arg client_secret "${openidm_client_secret}" '
  .rsFilter.clientSecret = "&{rs.client.secret|" + $client_secret + "}"
    ' "$AUTH_JSON" > tmp.json && mv tmp.json "$AUTH_JSON"

    #9. updating the configuration file --> not working
    # Define the path to ui-configuration.json (adjust path as needed)
    UI_CONFIG_JSON=${install_location}openidm/conf/ui-configuration.json

    # Add platformSettings to configuration object
    jq '
      .configuration += {
        "platformSettings": {
          "adminOauthClient": "idm-admin-ui",
          "adminOauthClientScopes": "fr:idm:*",
          "amUrl": "http://am.example.com:8081/am",
          "loginUrl": ""
        }
      }
    ' "$UI_CONFIG_JSON" > tmp.json && mv tmp.json "$UI_CONFIG_JSON"

    #11. Replacing the ui-themerealm.json  --> working
    sudo  cp ${software_folder_server}ui-themerealm.json  ${install_location}openidm/conf/
    
    #12. updating access.json --> working
    #cp ${install_location}openidm/conf/access.json ${tmp_location}access.json.bak
    # # Update access.json with jq to add the new config  
    jq '.configs += [{
        "pattern": "config/ui/themerealm",
        "roles": "*",
        "methods": "read",
        "actions": "*"
    }]' ${install_location}openidm/conf/access.json > ${tmp_location}access-updated.json &&
    mv ${tmp_location}access-updated.json ${install_location}openidm/conf/access.json

    #12. replacing  a servletfilter-cors.json
    sudo  cp ${software_folder_server}servletfilter-cors.json  ${install_location}openidm/conf/
    #10. start openidm
    sudo chmod 777 -R /app/
    sudo echo "********starting idm after platform setup"
    sudo systemctl start openidm
    /vagrant/scripts/ig/8080_service_start_status.sh
    sudo echo "!!!!!!!!!!!!!!!!!!!! Completed AM && IDM configuration !!!!!!!!!!!!!!!!"