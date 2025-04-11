###################Configuring AM for Platform ####################
  sudo apt-get update
  sudo apt-get install -y jq
  # 1. Wait for AM to be fully initialized
  #echo "Waiting for AM to be ready..."
  #while ! curl -s -o /dev/null -w "%{http_code}" http://#{AM_hostname}:8081/am/json/healthcheck | grep -q "200"; do
  #  sleep 5
  #  echo "Waiting for AM to be ready..."
  #done

  # 2. Log In as an Administrator (from Postman collection)
#   echo "Authenticating as administrator..."
#   ADMIN_TOKEN=$(curl -s -X POST \
#     -H "X-OpenAM-Username: amadmin" \
#     -H "X-OpenAM-Password: #{am_password}" \
#     -H "Accept-API-Version: resource=2.1" \
#     -H "Content-Type: application/json" \
#     http://#{AM_hostname}:8081/am/json/realms/root/authenticate | jq -r '.tokenId')

#   if [ -z "$ADMIN_TOKEN" ]; then
#     echo "Failed to authenticate as administrator"
#     exit 1
#   fi


  echo "Admin token*****: $ADMIN_TOKEN"
  sudo sleep 10
  # 3. Add CTS External Store (from Postman collection)
  ################### CTS Configuration ####################
  echo "Configuring CTS external store..."
#   ################### CTS Configuration ####################
  
#   # Create a temporary file with the configuration
#   cat > /tmp/cts_config.json <<EOF
# {
#   "amconfig.org.forgerock.services.cts.store.common.section": {
#     "org.forgerock.services.cts.store.location": "external",
#     "org.forgerock.services.cts.store.root.suffix": "ou=famrecords,ou=openam-session,ou=tokens",
#     "org.forgerock.services.cts.store.max.connections": "100",
#     "org.forgerock.services.cts.store.page.size": 0,
#     "org.forgerock.services.cts.store.vlv.page.size": 1000
#   },
#   "amconfig.org.forgerock.services.cts.store.external.section": {
#     "org.forgerock.services.cts.store.ssl.enabled": true,
#     "org.forgerock.services.cts.store.mtls.enabled": false,
#     "org.forgerock.services.cts.store.starttls.enabled": false,
#     "org.forgerock.services.cts.store.directory.name": "#{DS_hostname}:#{Ldaps_port}",
#     "org.forgerock.services.cts.store.loginid": "uid=openam_cts,ou=admins,ou=famrecords,ou=openam-session,ou=tokens",
#     "org.forgerock.services.cts.store.password": "#{DS_client_password}",
#     "org.forgerock.services.cts.store.heartbeat": 0,
#     "org.forgerock.services.cts.store.affinity.enabled": true
#   }
# }
# EOF

#   # Apply the configuration
#   HTTP_STATUS=$(curl -s -o /dev/null -w "%{http_code}" -X PUT \
#     -H "Content-Type: application/json" \
#     -H "Cookie: iplanetDirectoryPro=$ADMIN_TOKEN" \
#     -H "Accept-API-Version: resource=1.0" \
#     -H "If-Match: *" \
#     -d @/tmp/cts_config.json \
#     http://localhost:8081/am/json/global-config/servers/server-default/properties/cts#1.0_update)

#   # Verify the response
#   if [ "$HTTP_STATUS" -eq 200 ]; then
#     echo "CTS external store configuration successfully applied"
#     rm -f /tmp/cts_config.json
#   else
#     echo "ERROR: Failed to configure CTS external store (HTTP $HTTP_STATUS)"
#     echo "Check AM logs for details: /app/forgerock/tomcat/logs/amAuthentication.log"
#     echo "Last configuration attempt saved at: /tmp/cts_config.json"
#     exit 1
#   fi

  # 2. Log In as an Administrator (from Postman collection)
  echo sleep 10
  echo "Authenticating as administrator..."
  ADMIN_TOKEN=$(curl -s -X POST \
    -H "X-OpenAM-Username: amadmin" \
    -H "X-OpenAM-Password: #{am_password}" \
    -H "Accept-API-Version: resource=2.1" \
    -H "Content-Type: application/json" \
    http://#{AM_hostname}:8081/am/json/realms/root/authenticate | jq -r '.tokenId')

  if [ -z "$ADMIN_TOKEN" ]; then
    echo "Failed to authenticate as administrator"
    exit 1
  fi

  echo "Admin token*****: $ADMIN_TOKEN"
  ################### Create SubRealm  ####################

 
  echo "Creating subrealm '#{sub_realm}'..."
  
  # Create JSON payload for realm creation
  cat > /tmp/create_realm.json <<EOF
{
  "name": "#{sub_realm}",
  "active": true,
  "parentPath": "/",
  "aliases": ["#{sub_realm}.example.com"]
}
EOF

  REALM_CREATE_URL="http://#{AM_hostname}:8081/am/json/global-config/realms"
  echo "Creating realm via POST to: $REALM_CREATE_URL"
  
  # Execute realm creation (removed _action parameter)
  HTTP_STATUS=$(curl -s -o /dev/null -w "%{http_code}" -X POST \
    -H "Content-Type: application/json" \
    -H "iPlanetDirectoryPro: $ADMIN_TOKEN" \
    -H "Accept-API-Version: resource=1.0" \
    -d @/tmp/create_realm.json \
    "$REALM_CREATE_URL")

  if [ "$HTTP_STATUS" -eq 201 ]; then
    echo "Subrealm '#{sub_realm}' created successfully"
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
 ## Begning of code to update the scope of ldap to SCOPE_ONE
  sudo echo "starting to update the scope of ldap to SCOPE_ONE"
 ##### Make the HTTP PUT request with proper line continuations
    curl -X PUT "http://am.example.com:8081/am/json/realms/root/realms/alpha/realm-config/services/id-repositories/LDAPv3ForOpenDS/OpenDJ" \
      -H "Accept: application/json, text/javascript, */*; q=0.01" \
      -H "Accept-API-Version: protocol=2.0,resource=1.0" \
      -H "Accept-Encoding: gzip, deflate" \
      -H "Accept-Language: en-US" \
      -H "Cache-Control: no-cache" \
      -H "Connection: keep-alive" \
      -H "iPlanetDirectoryPro: $ADMIN_TOKEN" \
      -H "Content-Type: application/json" \
      -H "Host: am.example.com:8081" \
      -H "Origin: http://am.example.com:8081" \
      -H "Referer: http://am.example.com:8081/am/ui-admin/" \
      -H "User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36 Edg/135.0.0.0" \
      -H "X-Requested-With: XMLHttpRequest" \
      -d '{"_id":"OpenDJ","ldapsettings":{"sun-idrepo-ldapv3-config-time-limit":10,"openam-idrepo-ldapv3-mtls-enabled":false,"openam-idrepo-ldapv3-behera-support-enabled":true,"openam-idrepo-ldapv3-affinity-level":"all","sun-idrepo-ldapv3-config-search-scope":"SCOPE_ONE","openam-idrepo-ldapv3-mtls-secret-label":"","sun-idrepo-ldapv3-config-organization_name":"ou=identities","sun-idrepo-ldapv3-config-connection-mode":"LDAPS","openam-idrepo-ldapv3-heartbeat-interval":10,"openam-idrepo-ldapv3-affinity-enabled":false,"sun-idrepo-ldapv3-config-authid":"uid=am-identity-bind-account,ou=admins,ou=identities","openam-idrepo-ldapv3-proxied-auth-enabled":false,"openam-idrepo-ldapv3-heartbeat-timeunit":"SECONDS","sun-idrepo-ldapv3-config-ldap-server":["directory.example.com:1636"],"openam-idrepo-ldapv3-keepalive-searchbase":"","openam-idrepo-ldapv3-keepalive-searchfilter":"(objectclass=*)","sun-idrepo-ldapv3-config-trust-all-server-certificates":false,"openam-idrepo-ldapv3-proxied-auth-denied-fallback":false,"sun-idrepo-ldapv3-config-connection_pool_max_size":10,"sun-idrepo-ldapv3-config-max-result":1000,"sun-idrepo-ldapv3-config-connection_pool_min_size":1,"openam-idrepo-ldapv3-contains-iot-identities-enriched-as-oauth2client":false},"userconfig":{"sun-idrepo-ldapv3-config-people-container-name":"ou","sun-idrepo-ldapv3-config-user-attributes":["iplanet-am-auth-configuration","iplanet-am-user-alias-list","iplanet-am-user-password-reset-question-answer","mail","assignedDashboard","authorityRevocationList","dn","iplanet-am-user-password-reset-options","employeeNumber","createTimestamp","kbaActiveIndex","caCertificate","iplanet-am-session-quota-limit","iplanet-am-user-auth-config","sun-fm-saml2-nameid-infokey","sunIdentityMSISDNNumber","iplanet-am-user-password-reset-force-reset","sunAMAuthInvalidAttemptsData","devicePrintProfiles","givenName","iplanet-am-session-get-valid-sessions","objectClass","adminRole","inetUserHttpURL","lastEmailSent","iplanet-am-user-account-life","postalAddress","userCertificate","preferredtimezone","iplanet-am-user-admin-start-dn","boundDevices","oath2faEnabled","preferredlanguage","sun-fm-saml2-nameid-info","userPassword","iplanet-am-session-service-status","telephoneNumber","iplanet-am-session-max-idle-time","distinguishedName","iplanet-am-session-destroy-sessions","kbaInfoAttempts","modifyTimestamp","uid","iplanet-am-user-success-url","iplanet-am-user-auth-modules","kbaInfo","memberOf","sn","preferredLocale","manager","iplanet-am-session-max-session-time","deviceProfiles","cn","oathDeviceProfiles","webauthnDeviceProfiles","iplanet-am-user-login-status","pushDeviceProfiles","push2faEnabled","inetUserStatus","retryLimitNodeCount","iplanet-am-user-failure-url","iplanet-am-session-max-caching-time"],"sun-idrepo-ldapv3-config-inactive":"Inactive","sun-idrepo-ldapv3-config-auth-kba-index-attr":"kbaActiveIndex","sun-idrepo-ldapv3-config-auth-kba-attempts-attr":["kbaInfoAttempts"],"sun-idrepo-ldapv3-config-user-objectclass":["iplanet-am-managed-person","inetuser","sunFMSAML2NameIdentifier","inetorgperson","devicePrintProfilesContainer","boundDevicesContainer","iplanet-am-user-service","iPlanetPreferences","pushDeviceProfilesContainer","forgerock-am-dashboard-service","organizationalperson","top","kbaInfoContainer","person","sunAMAuthAccountLockout","oathDeviceProfilesContainer","webauthnDeviceProfilesContainer","iplanet-am-auth-configuration-service","deviceProfilesContainer"],"sun-idrepo-ldapv3-config-auth-kba-attr":["kbaInfo"],"sun-idrepo-ldapv3-config-people-container-value":"people","sun-idrepo-ldapv3-config-users-search-attribute":"fr-idm-uuid","sun-idrepo-ldapv3-config-active":"Active","sun-idrepo-ldapv3-config-isactive":"inetuserstatus","sun-idrepo-ldapv3-config-users-search-filter":"(objectclass=inetorgperson)","sun-idrepo-ldapv3-config-createuser-attr-mapping":["cn","sn"]},"groupconfig":{"sun-idrepo-ldapv3-config-group-attributes":["dn","cn","uniqueMember","objectclass"],"sun-idrepo-ldapv3-config-groups-search-attribute":"cn","sun-idrepo-ldapv3-config-memberurl":"memberUrl","sun-idrepo-ldapv3-config-group-container-name":"ou","sun-idrepo-ldapv3-config-group-objectclass":["top","groupofuniquenames"],"sun-idrepo-ldapv3-config-uniquemember":"uniqueMember","sun-idrepo-ldapv3-config-groups-search-filter":"(objectclass=groupOfUniqueNames)","sun-idrepo-ldapv3-config-group-container-value":"groups"},"errorhandling":{"com.iplanet.am.ldap.connection.delay.between.retries":1000},"pluginconfig":{"sunIdRepoAttributeMapping":[],"sunIdRepoSupportedOperations":["realm=read,create,edit,delete,service","user=read,create,edit,delete,service","group=read,create,edit,delete"],"sunIdRepoClass":"org.forgerock.openam.idrepo.ldap.DJLDAPv3Repo"},"authentication":{"sun-idrepo-ldapv3-config-auth-naming-attr":"uid"},"persistentsearch":{"sun-idrepo-ldapv3-config-psearch-filter":"(!(objectclass=frCoreToken))","sun-idrepo-ldapv3-config-psearchbase":"ou=identities","sun-idrepo-ldapv3-config-psearch-scope":"SCOPE_SUB"},"cachecontrol":{"sun-idrepo-ldapv3-dncache-enabled":true,"sun-idrepo-ldapv3-dncache-size":1500},"_type":{"_id":"LDAPv3ForOpenDS","name":"OpenDJ","collection":true}}' \
      -o /vagrant/curl_response.json \
      -v 2>> /vagrant/curl_error.log

    # Check the curl exit status
    if [ $? -ne 0 ]; then
      echo "curl request failed. Check /vagrant/curl_error.log for details."
      exit 1
    fi

    # Log completion
    echo "Request completed at $(date)" >> /vagrant/curl_request.log
  ##### Making call to update the search attribute 
  sudo echo "starting to Making call to update the search attribute"
    # Make the HTTP PUT request
    curl -X PUT "http://am.example.com:8081/am/json/realms/root/realms/alpha/realm-config/services/id-repositories/LDAPv3ForOpenDS/OpenDJ" \
      -H "Accept: application/json, text/javascript, */*; q=0.01" \
      -H "Accept-API-Version: protocol=2.0,resource=1.0" \
      -H "Accept-Encoding: gzip, deflate" \
      -H "Accept-Language: en-US" \
      -H "Cache-Control: no-cache" \
      -H "iPlanetDirectoryPro: $ADMIN_TOKEN" \
      -H "Connection: keep-alive" \
      -H "Content-Type: application/json" \
      -H "Host: am.example.com:8081" \
      -H "Origin: http://am.example.com:8081" \
      -H "Referer: http://am.example.com:8081/am/ui-admin/" \
      -H "User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36 Edg/135.0.0.0" \
      -H "X-Requested-With: XMLHttpRequest" \
      -d '{"_id":"OpenDJ","ldapsettings":{"openam-idrepo-ldapv3-mtls-enabled":false,"openam-idrepo-ldapv3-heartbeat-timeunit":"SECONDS","sun-idrepo-ldapv3-config-connection_pool_min_size":1,"sun-idrepo-ldapv3-config-search-scope":"SCOPE_ONE","openam-idrepo-ldapv3-proxied-auth-enabled":false,"openam-idrepo-ldapv3-contains-iot-identities-enriched-as-oauth2client":false,"sun-idrepo-ldapv3-config-max-result":1000,"sun-idrepo-ldapv3-config-organization_name":"ou=identities","openam-idrepo-ldapv3-proxied-auth-denied-fallback":false,"openam-idrepo-ldapv3-affinity-enabled":false,"sun-idrepo-ldapv3-config-authid":"uid=am-identity-bind-account,ou=admins,ou=identities","openam-idrepo-ldapv3-heartbeat-interval":10,"sun-idrepo-ldapv3-config-trust-all-server-certificates":false,"sun-idrepo-ldapv3-config-connection-mode":"LDAPS","openam-idrepo-ldapv3-affinity-level":"all","openam-idrepo-ldapv3-keepalive-searchfilter":"(objectclass=*)","openam-idrepo-ldapv3-behera-support-enabled":true,"sun-idrepo-ldapv3-config-ldap-server":["directory.example.com:1636"],"sun-idrepo-ldapv3-config-time-limit":10,"sun-idrepo-ldapv3-config-connection_pool_max_size":10},"userconfig":{"sun-idrepo-ldapv3-config-users-search-filter":"(objectclass=inetorgperson)","sun-idrepo-ldapv3-config-active":"Active","sun-idrepo-ldapv3-config-people-container-name":"ou","sun-idrepo-ldapv3-config-user-objectclass":["iplanet-am-managed-person","inetuser","sunFMSAML2NameIdentifier","inetorgperson","devicePrintProfilesContainer","boundDevicesContainer","iplanet-am-user-service","iPlanetPreferences","pushDeviceProfilesContainer","forgerock-am-dashboard-service","organizationalperson","top","kbaInfoContainer","person","sunAMAuthAccountLockout","oathDeviceProfilesContainer","webauthnDeviceProfilesContainer","iplanet-am-auth-configuration-service","deviceProfilesContainer"],"sun-idrepo-ldapv3-config-users-search-attribute":"fr-idm-uuid","sun-idrepo-ldapv3-config-people-container-value":"people","sun-idrepo-ldapv3-config-auth-kba-attempts-attr":["kbaInfoAttempts"],"sun-idrepo-ldapv3-config-auth-kba-index-attr":"kbaActiveIndex","sun-idrepo-ldapv3-config-user-attributes":["iplanet-am-auth-configuration","iplanet-am-user-alias-list","iplanet-am-user-password-reset-question-answer","mail","assignedDashboard","authorityRevocationList","dn","iplanet-am-user-password-reset-options","employeeNumber","createTimestamp","kbaActiveIndex","caCertificate","iplanet-am-session-quota-limit","iplanet-am-user-auth-config","sun-fm-saml2-nameid-infokey","sunIdentityMSISDNNumber","iplanet-am-user-password-reset-force-reset","sunAMAuthInvalidAttemptsData","devicePrintProfiles","givenName","iplanet-am-session-get-valid-sessions","objectClass","adminRole","inetUserHttpURL","lastEmailSent","iplanet-am-user-account-life","postalAddress","userCertificate","preferredtimezone","iplanet-am-user-admin-start-dn","boundDevices","oath2faEnabled","preferredlanguage","sun-fm-saml2-nameid-info","userPassword","iplanet-am-session-service-status","telephoneNumber","iplanet-am-session-max-idle-time","distinguishedName","iplanet-am-session-destroy-sessions","kbaInfoAttempts","modifyTimestamp","uid","iplanet-am-user-success-url","iplanet-am-user-auth-modules","kbaInfo","memberOf","sn","preferredLocale","manager","iplanet-am-session-max-session-time","deviceProfiles","cn","oathDeviceProfiles","webauthnDeviceProfiles","iplanet-am-user-login-status","pushDeviceProfiles","push2faEnabled","inetUserStatus","retryLimitNodeCount","iplanet-am-user-failure-url","iplanet-am-session-max-caching-time"],"sun-idrepo-ldapv3-config-createuser-attr-mapping":["cn","sn"],"sun-idrepo-ldapv3-config-inactive":"Inactive","sun-idrepo-ldapv3-config-auth-kba-attr":["kbaInfo"],"sun-idrepo-ldapv3-config-isactive":"inetuserstatus"},"groupconfig":{"sun-idrepo-ldapv3-config-group-attributes":["dn","cn","uniqueMember","objectclass"],"sun-idrepo-ldapv3-config-groups-search-attribute":"cn","sun-idrepo-ldapv3-config-memberurl":"memberUrl","sun-idrepo-ldapv3-config-group-container-name":"ou","sun-idrepo-ldapv3-config-group-objectclass":["top","groupofuniquenames"],"sun-idrepo-ldapv3-config-uniquemember":"uniqueMember","sun-idrepo-ldapv3-config-groups-search-filter":"(objectclass=groupOfUniqueNames)","sun-idrepo-ldapv3-config-group-container-value":"groups"},"errorhandling":{"com.iplanet.am.ldap.connection.delay.between.retries":1000},"pluginconfig":{"sunIdRepoAttributeMapping":[],"sunIdRepoSupportedOperations":["realm=read,create,edit,delete,service","user=read,create,edit,delete,service","group=read,create,edit,delete"],"sunIdRepoClass":"org.forgerock.openam.idrepo.ldap.DJLDAPv3Repo"},"authentication":{"sun-idrepo-ldapv3-config-auth-naming-attr":"uid"},"persistentsearch":{"sun-idrepo-ldapv3-config-psearch-filter":"(!(objectclass=frCoreToken))","sun-idrepo-ldapv3-config-psearchbase":"ou=identities","sun-idrepo-ldapv3-config-psearch-scope":"SCOPE_SUB"},"cachecontrol":{"sun-idrepo-ldapv3-dncache-enabled":true,"sun-idrepo-ldapv3-dncache-size":1500},"_type":{"_id":"LDAPv3ForOpenDS","name":"OpenDJ","collection":true}}' \
      -o /vagrant/curl_response.json \
      -v 2>> /vagrant/curl_error.log

    # Check the curl exit status
    if [ $? -ne 0 ]; then
      echo "curl request failed. Check /vagrant/curl_error.log for details."
      exit 1
    fi

    # Log completion
    echo "Request completed at $(date)" >> /vagrant/curl_request.log
    ###Delete the ldap from root realm.
     sudo echo "starting to Delete the ldap from root realm"
    # Make the HTTP DELETE request
    curl -X DELETE "http://am.example.com:8081/am/json/realms/root/realm-config/services/id-repositories/LDAPv3ForOpenDS/OpenDJ" \
      -H "Accept: application/json, text/javascript, */*; q=0.01" \
      -H "Accept-API-Version: protocol=2.0,resource=1.0" \
      -H "Accept-Encoding: gzip, deflate" \
      -H "Accept-Language: en-US" \
      -H "Cache-Control: no-cache" \
      -H "iPlanetDirectoryPro: $ADMIN_TOKEN" \
      -H "Connection: keep-alive" \
      -H "Content-Type: application/json" \
      -H "Host: am.example.com:8081" \
      -H "Origin: http://am.example.com:8081" \
      -H "Referer: http://am.example.com:8081/am/ui-admin/" \
      -H "User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36 Edg/135.0.0.0" \
      -H "X-Requested-With: XMLHttpRequest" \
      -o /vagrant/curl_response.json \
      -v 2>> /vagrant/curl_error.log

    # Check the curl exit status
    if [ $? -ne 0 ]; then
      echo "curl request failed. Check /vagrant/curl_error.log for details."
      exit 1
    fi

    # Log completion
    echo "Request completed at $(date)" >> /vagrant/curl_request.log
 
#### creating clients needed for platform setup################
#### creating client idm-resource-server in root
sudo echo "starting to creating client idm-resource-server in root"
    # Make the HTTP PUT request to create idm-resource-server
    curl -X PUT "http://am.example.com:8081/am/json/realms/root/realm-config/agents/OAuth2Client/idm-resource-server" \
      -H "Accept: application/json, text/javascript, */*; q=0.01" \
      -H "Accept-API-Version: protocol=2.0,resource=1.0" \
      -H "Accept-Encoding: gzip, deflate" \
      -H "Accept-Language: en-US" \
      -H "Cache-Control: no-cache" \
      -H "Connection: keep-alive" \
      -H "iPlanetDirectoryPro: $ADMIN_TOKEN" \
      -H "Content-Type: application/json" \
      -H "Host: am.example.com:8081" \
      -H "If-None-Match: *" \
      -H "Origin: http://am.example.com:8081" \
      -H "Referer: http://am.example.com:8081/am/ui-admin/" \
      -H "User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36 Edg/135.0.0.0" \
      -H "X-Requested-With: XMLHttpRequest" \
      -d '{"coreOAuth2ClientConfig":{"defaultScopes":[],"redirectionUris":[],"scopes":["am-introspect-all-tokens","am-introspect-all-tokens-any-realm"],"userpassword":"password"}}' \
      -o /vagrant/curl_response.json \
      -v 2>> /vagrant/curl_error.log

    # Check the curl exit status
    if [ $? -ne 0 ]; then
      echo "curl request failed. Check /vagrant/curl_error.log for details."
      exit 1
    fi

    # Log completion
    echo "Request completed at $(date)" >> /vagrant/curl_request.log

   ##### creating client idm-provisioning in root
sudo echo "starting to creating client idm-provisioning in root"
    # Make the HTTP PUT request to create idm-resource-server
    curl -X PUT "http://am.example.com:8081/am/json/realms/root/realm-config/agents/OAuth2Client/idm-provisioning" \
      -H "Accept: application/json, text/javascript, */*; q=0.01" \
      -H "Accept-API-Version: protocol=2.0,resource=1.0" \
      -H "Accept-Encoding: gzip, deflate" \
      -H "Accept-Language: en-US" \
      -H "Cache-Control: no-cache" \
      -H "Connection: keep-alive" \
      -H "iPlanetDirectoryPro: $ADMIN_TOKEN" \
      -H "Content-Type: application/json" \
      -H "Host: am.example.com:8081" \
      -H "If-None-Match: *" \
      -H "Origin: http://am.example.com:8081" \
      -H "Referer: http://am.example.com:8081/am/ui-admin/" \
      -H "User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36 Edg/135.0.0.0" \
      -H "X-Requested-With: XMLHttpRequest" \
      -d '{"coreOAuth2ClientConfig":{"defaultScopes":[],"redirectionUris":[],"scopes":["fr:idm:*"],"userpassword":"openidm"}}' \
      -o /vagrant/curl_response.json \
      -v 2>> /vagrant/curl_error.log

    # Check the curl exit status
    if [ $? -ne 0 ]; then
      echo "curl request failed. Check /vagrant/curl_error.log for details."
      exit 1
    fi

    # Log completion
    echo "Request completed at $(date)" >> /vagrant/curl_request.log

##### updating client idm-provisioning in root
sudo echo "starting to updating client idm-provisioning in root"

    # Make the HTTP PUT request to create idm-resource-server
    curl -X PUT "http://am.example.com:8081/am/json/realms/root/realm-config/agents/OAuth2Client/idm-provisioning" \
      -H "Accept: application/json, text/javascript, */*; q=0.01" \
      -H "Accept-API-Version: protocol=2.0,resource=1.0" \
      -H "Accept-Encoding: gzip, deflate" \
      -H "Accept-Language: en-US" \
      -H "Cache-Control: no-cache" \
      -H "iPlanetDirectoryPro: $ADMIN_TOKEN" \
      -H "Connection: keep-alive" \
      -H "Content-Type: application/json" \
      -H "Host: am.example.com:8081" \
      -H "If-Match: *" \
      -H "Origin: http://am.example.com:8081" \
      -H "Referer: http://am.example.com:8081/am/ui-admin/" \
      -H "User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36 Edg/135.0.0.0" \
      -H "X-Requested-With: XMLHttpRequest" \
      -d '{"_id":"idm-resource-server","overrideOAuth2ClientConfig":{"issueRefreshToken":true,"validateScopePluginType":"PROVIDER","tokenEncryptionEnabled":false,"evaluateScopePluginType":"PROVIDER","oidcMayActScript":"[Empty]","oidcClaimsScript":"[Empty]","scopesPolicySet":"oauth2Scopes","accessTokenModificationPluginType":"PROVIDER","authorizeEndpointDataProviderClass":"org.forgerock.oauth2.core.plugins.registry.DefaultEndpointDataProvider","useForceAuthnForMaxAge":false,"oidcClaimsPluginType":"PROVIDER","providerOverridesEnabled":false,"authorizeEndpointDataProviderScript":"[Empty]","statelessTokensEnabled":false,"authorizeEndpointDataProviderPluginType":"PROVIDER","remoteConsentServiceId":null,"enableRemoteConsent":false,"validateScopeClass":"org.forgerock.oauth2.core.plugins.registry.DefaultScopeValidator","usePolicyEngineForScope":false,"evaluateScopeClass":"org.forgerock.oauth2.core.plugins.registry.DefaultScopeEvaluator","overrideableOIDCClaims":[],"accessTokenMayActScript":"[Empty]","evaluateScopeScript":"[Empty]","clientsCanSkipConsent":false,"accessTokenModificationScript":"[Empty]","issueRefreshTokenOnRefreshedToken":true,"validateScopeScript":"[Empty]"},"advancedOAuth2ClientConfig":{"name":{"value":[],"inherited":false},"softwareIdentity":{"value":"","inherited":false},"require_pushed_authorization_requests":{"value":false,"inherited":false},"subjectType":{"value":"public","inherited":false},"clientUri":{"value":[],"inherited":false},"responseTypes":{"value":["code","token","id_token","code token","token id_token","code id_token","code token id_token","device_code","device_code id_token"],"inherited":false},"logoUri":{"value":[],"inherited":false},"tokenExchangeAuthLevel":{"value":0,"inherited":false},"updateAccessToken":{"value":"","inherited":false},"isConsentImplied":{"value":false,"inherited":false},"contacts":{"value":[],"inherited":false},"descriptions":{"value":[],"inherited":false},"refreshTokenGracePeriod":{"value":0,"inherited":false},"customProperties":{"value":[],"inherited":false},"requestUris":{"value":[],"inherited":false},"softwareVersion":{"value":"","inherited":false},"javascriptOrigins":{"value":[],"inherited":false},"mixUpMitigation":{"value":false,"inherited":false},"tosURI":{"value":[],"inherited":false},"tokenEndpointAuthMethod":{"value":"client_secret_basic","inherited":false},"grantTypes":{"value":["client_credentials"],"inherited":false},"sectorIdentifierUri":{"value":"","inherited":false},"policyUri":{"value":[],"inherited":false}},"signEncOAuth2ClientConfig":{"tokenEndpointAuthSigningAlgorithm":{"inherited":false,"value":"RS256"},"idTokenEncryptionEnabled":{"inherited":false,"value":false},"tokenIntrospectionEncryptedResponseEncryptionAlgorithm":{"inherited":false,"value":"A128CBC-HS256"},"requestParameterSignedAlg":{"inherited":false},"authorizationResponseSigningAlgorithm":{"inherited":false,"value":"RS256"},"clientJwtPublicKey":{"inherited":false},"idTokenPublicEncryptionKey":{"inherited":false},"mTLSSubjectDN":{"inherited":false},"jwkStoreCacheMissCacheTime":{"inherited":false,"value":60000},"jwkSet":{"inherited":false},"idTokenEncryptionMethod":{"inherited":false,"value":"A128CBC-HS256"},"jwksUri":{"inherited":false},"tokenIntrospectionEncryptedResponseAlg":{"inherited":false,"value":"RSA-OAEP-256"},"authorizationResponseEncryptionMethod":{"inherited":false},"userinfoResponseFormat":{"inherited":false,"value":"JSON"},"mTLSCertificateBoundAccessTokens":{"inherited":false,"value":false},"publicKeyLocation":{"inherited":false,"value":"jwks_uri"},"tokenIntrospectionResponseFormat":{"inherited":false,"value":"JSON"},"requestParameterEncryptedEncryptionAlgorithm":{"inherited":false,"value":"A128CBC-HS256"},"userinfoSignedResponseAlg":{"inherited":false},"idTokenEncryptionAlgorithm":{"inherited":false,"value":"RSA-OAEP-256"},"requestParameterEncryptedAlg":{"inherited":false},"authorizationResponseEncryptionAlgorithm":{"inherited":false},"mTLSTrustedCert":{"inherited":false},"jwksCacheTimeout":{"inherited":false,"value":3600000},"userinfoEncryptedResponseAlg":{"inherited":false},"idTokenSignedResponseAlg":{"inherited":false,"value":"RS256"},"tokenIntrospectionSignedResponseAlg":{"inherited":false,"value":"RS256"},"userinfoEncryptedResponseEncryptionAlgorithm":{"inherited":false,"value":"A128CBC-HS256"}},"coreOAuth2ClientConfig":{"secretLabelIdentifier":{"inherited":false},"status":{"inherited":false,"value":"Active"},"clientName":{"inherited":false,"value":[]},"clientType":{"inherited":false,"value":"Confidential"},"loopbackInterfaceRedirection":{"inherited":false,"value":false},"defaultScopes":{"inherited":false,"value":[]},"refreshTokenLifetime":{"inherited":false,"value":0},"scopes":{"inherited":false,"value":["fr:idm:*"]},"accessTokenLifetime":{"inherited":false,"value":0},"redirectionUris":{"inherited":false,"value":[]},"authorizationCodeLifetime":{"inherited":false,"value":0}},"coreOpenIDClientConfig":{"claims":{"inherited":false,"value":[]},"backchannel_logout_uri":{"inherited":false},"defaultAcrValues":{"inherited":false,"value":[]},"jwtTokenLifetime":{"inherited":false,"value":0},"defaultMaxAgeEnabled":{"inherited":false,"value":false},"clientSessionUri":{"inherited":false},"defaultMaxAge":{"inherited":false,"value":600},"postLogoutRedirectUri":{"inherited":false,"value":[]},"backchannel_logout_session_required":{"inherited":false,"value":false}},"coreUmaClientConfig":{"claimsRedirectionUris":{"inherited":false,"value":[]}},"_type":{"_id":"OAuth2Client","name":"OAuth2 Clients","collection":true}}' \
      -o /vagrant/curl_response.json \
      -v 2>> /vagrant/curl_error.log

    # Check the curl exit status
    if [ $? -ne 0 ]; then
      echo "curl request failed. Check /vagrant/curl_error.log for details."
      exit 1
    fi

    # Log completion
    echo "Request completed at $(date)" >> /vagrant/curl_request.log
 
    ##### creating client idm-provisioning in alpha
  sudo echo "starting to creating client idm-provisioning in alpha"
    # Make the HTTP PUT request to create idm-resource-server
    curl -X PUT "http://am.example.com:8081/am/json/realms/root/realms/alpha/realm-config/agents/OAuth2Client/idm-provisioning" \
      -H "Accept: application/json, text/javascript, */*; q=0.01" \
      -H "Accept-API-Version: protocol=2.0,resource=1.0" \
      -H "Accept-Encoding: gzip, deflate" \
      -H "Accept-Language: en-US" \
      -H "Cache-Control: no-cache" \
      -H "Connection: keep-alive" \
      -H "iPlanetDirectoryPro: $ADMIN_TOKEN" \
      -H "Content-Type: application/json" \
      -H "Host: am.example.com:8081" \
      -H "If-None-Match: *" \
      -H "Origin: http://am.example.com:8081" \
      -H "Referer: http://am.example.com:8081/am/ui-admin/" \
      -H "User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36 Edg/135.0.0.0" \
      -H "X-Requested-With: XMLHttpRequest" \
      -d '{"coreOAuth2ClientConfig":{"defaultScopes":[],"redirectionUris":[],"scopes":["fr:idm:*"],"userpassword":"openidm"}}' \
      -o /vagrant/curl_response.json \
      -v 2>> /vagrant/curl_error.log

    # Check the curl exit status
    if [ $? -ne 0 ]; then
      echo "curl request failed. Check /vagrant/curl_error.log for details."
      exit 1
    fi

    # Log completion
    echo "Request completed at $(date)" >> /vagrant/curl_request.log

##### updating client idm-provisioning in alpha
sudo echo "starting to updating client idm-provisioning in alpha"

    # Make the HTTP PUT request to update idm-provision
    curl -X PUT "http://am.example.com:8081/am/json/realms/root/realms/alpha/realm-config/agents/OAuth2Client/idm-provisioning" \
      -H "Accept: application/json, text/javascript, */*; q=0.01" \
      -H "Accept-API-Version: protocol=2.0,resource=1.0" \
      -H "Accept-Encoding: gzip, deflate" \
      -H "Accept-Language: en-US" \
      -H "Cache-Control: no-cache" \
      -H "iPlanetDirectoryPro: $ADMIN_TOKEN" \
      -H "Connection: keep-alive" \
      -H "Content-Type: application/json" \
      -H "Host: am.example.com:8081" \
      -H "If-Match: *" \
      -H "Origin: http://am.example.com:8081" \
      -H "Referer: http://am.example.com:8081/am/ui-admin/" \
      -H "User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36 Edg/135.0.0.0" \
      -H "X-Requested-With: XMLHttpRequest" \
      -d '{"_id":"idm-resource-server","overrideOAuth2ClientConfig":{"issueRefreshToken":true,"validateScopePluginType":"PROVIDER","tokenEncryptionEnabled":false,"evaluateScopePluginType":"PROVIDER","oidcMayActScript":"[Empty]","oidcClaimsScript":"[Empty]","scopesPolicySet":"oauth2Scopes","accessTokenModificationPluginType":"PROVIDER","authorizeEndpointDataProviderClass":"org.forgerock.oauth2.core.plugins.registry.DefaultEndpointDataProvider","useForceAuthnForMaxAge":false,"oidcClaimsPluginType":"PROVIDER","providerOverridesEnabled":false,"authorizeEndpointDataProviderScript":"[Empty]","statelessTokensEnabled":false,"authorizeEndpointDataProviderPluginType":"PROVIDER","remoteConsentServiceId":null,"enableRemoteConsent":false,"validateScopeClass":"org.forgerock.oauth2.core.plugins.registry.DefaultScopeValidator","usePolicyEngineForScope":false,"evaluateScopeClass":"org.forgerock.oauth2.core.plugins.registry.DefaultScopeEvaluator","overrideableOIDCClaims":[],"accessTokenMayActScript":"[Empty]","evaluateScopeScript":"[Empty]","clientsCanSkipConsent":false,"accessTokenModificationScript":"[Empty]","issueRefreshTokenOnRefreshedToken":true,"validateScopeScript":"[Empty]"},"advancedOAuth2ClientConfig":{"name":{"value":[],"inherited":false},"softwareIdentity":{"value":"","inherited":false},"require_pushed_authorization_requests":{"value":false,"inherited":false},"subjectType":{"value":"public","inherited":false},"clientUri":{"value":[],"inherited":false},"responseTypes":{"value":["code","token","id_token","code token","token id_token","code id_token","code token id_token","device_code","device_code id_token"],"inherited":false},"logoUri":{"value":[],"inherited":false},"tokenExchangeAuthLevel":{"value":0,"inherited":false},"updateAccessToken":{"value":"","inherited":false},"isConsentImplied":{"value":false,"inherited":false},"contacts":{"value":[],"inherited":false},"descriptions":{"value":[],"inherited":false},"refreshTokenGracePeriod":{"value":0,"inherited":false},"customProperties":{"value":[],"inherited":false},"requestUris":{"value":[],"inherited":false},"softwareVersion":{"value":"","inherited":false},"javascriptOrigins":{"value":[],"inherited":false},"mixUpMitigation":{"value":false,"inherited":false},"tosURI":{"value":[],"inherited":false},"tokenEndpointAuthMethod":{"value":"client_secret_basic","inherited":false},"grantTypes":{"value":["client_credentials"],"inherited":false},"sectorIdentifierUri":{"value":"","inherited":false},"policyUri":{"value":[],"inherited":false}},"signEncOAuth2ClientConfig":{"tokenEndpointAuthSigningAlgorithm":{"inherited":false,"value":"RS256"},"idTokenEncryptionEnabled":{"inherited":false,"value":false},"tokenIntrospectionEncryptedResponseEncryptionAlgorithm":{"inherited":false,"value":"A128CBC-HS256"},"requestParameterSignedAlg":{"inherited":false},"authorizationResponseSigningAlgorithm":{"inherited":false,"value":"RS256"},"clientJwtPublicKey":{"inherited":false},"idTokenPublicEncryptionKey":{"inherited":false},"mTLSSubjectDN":{"inherited":false},"jwkStoreCacheMissCacheTime":{"inherited":false,"value":60000},"jwkSet":{"inherited":false},"idTokenEncryptionMethod":{"inherited":false,"value":"A128CBC-HS256"},"jwksUri":{"inherited":false},"tokenIntrospectionEncryptedResponseAlg":{"inherited":false,"value":"RSA-OAEP-256"},"authorizationResponseEncryptionMethod":{"inherited":false},"userinfoResponseFormat":{"inherited":false,"value":"JSON"},"mTLSCertificateBoundAccessTokens":{"inherited":false,"value":false},"publicKeyLocation":{"inherited":false,"value":"jwks_uri"},"tokenIntrospectionResponseFormat":{"inherited":false,"value":"JSON"},"requestParameterEncryptedEncryptionAlgorithm":{"inherited":false,"value":"A128CBC-HS256"},"userinfoSignedResponseAlg":{"inherited":false},"idTokenEncryptionAlgorithm":{"inherited":false,"value":"RSA-OAEP-256"},"requestParameterEncryptedAlg":{"inherited":false},"authorizationResponseEncryptionAlgorithm":{"inherited":false},"mTLSTrustedCert":{"inherited":false},"jwksCacheTimeout":{"inherited":false,"value":3600000},"userinfoEncryptedResponseAlg":{"inherited":false},"idTokenSignedResponseAlg":{"inherited":false,"value":"RS256"},"tokenIntrospectionSignedResponseAlg":{"inherited":false,"value":"RS256"},"userinfoEncryptedResponseEncryptionAlgorithm":{"inherited":false,"value":"A128CBC-HS256"}},"coreOAuth2ClientConfig":{"secretLabelIdentifier":{"inherited":false},"status":{"inherited":false,"value":"Active"},"clientName":{"inherited":false,"value":[]},"clientType":{"inherited":false,"value":"Confidential"},"loopbackInterfaceRedirection":{"inherited":false,"value":false},"defaultScopes":{"inherited":false,"value":[]},"refreshTokenLifetime":{"inherited":false,"value":0},"scopes":{"inherited":false,"value":["fr:idm:*"]},"accessTokenLifetime":{"inherited":false,"value":0},"redirectionUris":{"inherited":false,"value":[]},"authorizationCodeLifetime":{"inherited":false,"value":0}},"coreOpenIDClientConfig":{"claims":{"inherited":false,"value":[]},"backchannel_logout_uri":{"inherited":false},"defaultAcrValues":{"inherited":false,"value":[]},"jwtTokenLifetime":{"inherited":false,"value":0},"defaultMaxAgeEnabled":{"inherited":false,"value":false},"clientSessionUri":{"inherited":false},"defaultMaxAge":{"inherited":false,"value":600},"postLogoutRedirectUri":{"inherited":false,"value":[]},"backchannel_logout_session_required":{"inherited":false,"value":false}},"coreUmaClientConfig":{"claimsRedirectionUris":{"inherited":false,"value":[]}},"_type":{"_id":"OAuth2Client","name":"OAuth2 Clients","collection":true}}' \
      -o /vagrant/curl_response.json \
      -v 2>> /vagrant/curl_error.log

    # Check the curl exit status
    if [ $? -ne 0 ]; then
      echo "curl request failed. Check /vagrant/curl_error.log for details."
      exit 1
    fi

    # Log completion
    echo "Request completed at $(date)" >> /vagrant/curl_request.log


##### creating client idm-admin-ui in alpha
sudo echo "starting to creating client idm-admin-ui in alpha"
    # Make the HTTP PUT request to create idm-admin-ui
    curl -X PUT "http://am.example.com:8081/am/json/realms/root/realms/alpha/realm-config/agents/OAuth2Client/idm-admin-ui" \
      -H "Accept: application/json, text/javascript, */*; q=0.01" \
      -H "Accept-API-Version: protocol=2.0,resource=1.0" \
      -H "Accept-Encoding: gzip, deflate" \
      -H "Accept-Language: en-US" \
      -H "Cache-Control: no-cache" \
      -H "Connection: keep-alive" \
      -H "Content-Type: application/json" \
      -H "iPlanetDirectoryPro: $ADMIN_TOKEN" \
      -H "Host: am.example.com:8081" \
      -H "If-None-Match: *" \
      -H "Origin: http://am.example.com:8081" \
      -H "Referer: http://am.example.com:8081/am/ui-admin/" \
      -H "User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36 Edg/135.0.0.0" \
      -H "X-Requested-With: XMLHttpRequest" \
      -d '{"coreOAuth2ClientConfig":{"defaultScopes":[],"redirectionUris":["http://openidm.example.com:8080/platform/appAuthHelperRedirect.html","http://openidm.example.com:8080/platform/sessionCheck.html","http://openidm.example.com:8080/admin/appAuthHelperRedirect.html","http://openidm.example.com:8080/admin/sessionCheck.html","http://admin.example.com:8082/appAuthHelperRedirect.html","http://admin.example.com:8082/sessionCheck.html","http://admin.example.com:8080/appAuthHelperRedirect.html","http://admin.example.com:8080/sessionCheck.html"],"scopes":["openid","fr:idm:*"]}}' \
      -o /vagrant/curl_response.json \
      -v 2>> /vagrant/curl_error.log

    # Check the curl exit status
    if [ $? -ne 0 ]; then
      echo "curl request failed. Check /vagrant/curl_error.log for details."
      exit 1
    fi

    # Log completion
    echo "Request completed at $(date)" >> /vagrant/curl_request.log
  
##### creating client idm-admin-ui in root
sudo echo "starting to creating client idm-admin-ui in root"
    # Make the HTTP PUT request to create idm-admin-ui
    curl -X PUT "http://am.example.com:8081/am/json/realms/root/realm-config/agents/OAuth2Client/idm-admin-ui" \
      -H "Accept: application/json, text/javascript, */*; q=0.01" \
      -H "Accept-API-Version: protocol=2.0,resource=1.0" \
      -H "Accept-Encoding: gzip, deflate" \
      -H "Accept-Language: en-US" \
      -H "Cache-Control: no-cache" \
      -H "Connection: keep-alive" \
      -H "Content-Type: application/json" \
      -H "iPlanetDirectoryPro: $ADMIN_TOKEN" \
      -H "Host: am.example.com:8081" \
      -H "If-None-Match: *" \
      -H "Origin: http://am.example.com:8081" \
      -H "Referer: http://am.example.com:8081/am/ui-admin/" \
      -H "User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36 Edg/135.0.0.0" \
      -H "X-Requested-With: XMLHttpRequest" \
      -d '{"coreOAuth2ClientConfig":{"defaultScopes":[],"redirectionUris":["http://openidm.example.com:8080/platform/appAuthHelperRedirect.html","http://openidm.example.com:8080/platform/sessionCheck.html","http://openidm.example.com:8080/admin/appAuthHelperRedirect.html","http://openidm.example.com:8080/admin/sessionCheck.html","http://admin.example.com:8082/appAuthHelperRedirect.html","http://admin.example.com:8082/sessionCheck.html","http://admin.example.com:8080/appAuthHelperRedirect.html","http://admin.example.com:8080/sessionCheck.html"],"scopes":["openid","fr:idm:*"]}}' \
      -o /vagrant/curl_response.json \
      -v 2>> /vagrant/curl_error.log

    # Check the curl exit status
    if [ $? -ne 0 ]; then
      echo "curl request failed. Check /vagrant/curl_error.log for details."
      exit 1
    fi

    # Log completion
    echo "Request completed at $(date)" >> /vagrant/curl_request.log

##### updating client idm-admin-ui in alpha to public
sudo echo "starting to updating client idm-admin-ui in alpha to public"
    # Make the HTTP PUT request to update idm-admin-ui
    curl -X PUT "http://am.example.com:8081/am/json/realms/root/realms/alpha/realm-config/agents/OAuth2Client/idm-admin-ui" \
      -H "Accept: application/json, text/javascript, */*; q=0.01" \
      -H "Accept-API-Version: protocol=2.0,resource=1.0" \
      -H "Accept-Encoding: gzip, deflate" \
      -H "Accept-Language: en-US" \
      -H "Cache-Control: no-cache" \
      -H "Connection: keep-alive" \
      -H "iPlanetDirectoryPro: $ADMIN_TOKEN" \
      -H "Content-Type: application/json" \
      -H "Host: am.example.com:8081" \
      -H "If-Match: *" \
      -H "Origin: http://am.example.com:8081" \
      -H "Referer: http://am.example.com:8081/am/ui-admin/" \
      -H "User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36 Edg/135.0.0.0" \
      -H "X-Requested-With: XMLHttpRequest" \
      -d '{"_id":"idm-admin-ui","overrideOAuth2ClientConfig":{"issueRefreshToken":true,"validateScopePluginType":"PROVIDER","tokenEncryptionEnabled":false,"evaluateScopePluginType":"PROVIDER","oidcMayActScript":"[Empty]","oidcClaimsScript":"[Empty]","scopesPolicySet":"oauth2Scopes","accessTokenModificationPluginType":"PROVIDER","authorizeEndpointDataProviderClass":"org.forgerock.oauth2.core.plugins.registry.DefaultEndpointDataProvider","useForceAuthnForMaxAge":false,"oidcClaimsPluginType":"PROVIDER","providerOverridesEnabled":false,"authorizeEndpointDataProviderScript":"[Empty]","statelessTokensEnabled":false,"authorizeEndpointDataProviderPluginType":"PROVIDER","remoteConsentServiceId":null,"enableRemoteConsent":false,"validateScopeClass":"org.forgerock.oauth2.core.plugins.registry.DefaultScopeValidator","usePolicyEngineForScope":false,"evaluateScopeClass":"org.forgerock.oauth2.core.plugins.registry.DefaultScopeEvaluator","overrideableOIDCClaims":[],"accessTokenMayActScript":"[Empty]","evaluateScopeScript":"[Empty]","clientsCanSkipConsent":false,"accessTokenModificationScript":"[Empty]","issueRefreshTokenOnRefreshedToken":true,"validateScopeScript":"[Empty]"},"advancedOAuth2ClientConfig":{"logoUri":{"inherited":false,"value":[]},"subjectType":{"inherited":false,"value":"public"},"clientUri":{"inherited":false,"value":[]},"tokenExchangeAuthLevel":{"inherited":false,"value":0},"responseTypes":{"inherited":false,"value":["code","token","id_token","code token","token id_token","code id_token","code token id_token","device_code","device_code id_token"]},"mixUpMitigation":{"inherited":false,"value":false},"customProperties":{"inherited":false,"value":[]},"javascriptOrigins":{"inherited":false,"value":[]},"policyUri":{"inherited":false,"value":[]},"softwareVersion":{"inherited":false},"tosURI":{"inherited":false,"value":[]},"sectorIdentifierUri":{"inherited":false},"tokenEndpointAuthMethod":{"inherited":false,"value":"client_secret_basic"},"refreshTokenGracePeriod":{"inherited":false,"value":0},"isConsentImplied":{"inherited":false,"value":false},"softwareIdentity":{"inherited":false},"grantTypes":{"inherited":false,"value":["authorization_code"]},"require_pushed_authorization_requests":{"inherited":false,"value":false},"descriptions":{"inherited":false,"value":[]},"requestUris":{"inherited":false,"value":[]},"name":{"inherited":false,"value":[]},"contacts":{"inherited":false,"value":[]},"updateAccessToken":{"inherited":false}},"signEncOAuth2ClientConfig":{"tokenEndpointAuthSigningAlgorithm":{"inherited":false,"value":"RS256"},"idTokenEncryptionEnabled":{"inherited":false,"value":false},"tokenIntrospectionEncryptedResponseEncryptionAlgorithm":{"inherited":false,"value":"A128CBC-HS256"},"requestParameterSignedAlg":{"inherited":false},"authorizationResponseSigningAlgorithm":{"inherited":false,"value":"RS256"},"clientJwtPublicKey":{"inherited":false},"idTokenPublicEncryptionKey":{"inherited":false},"mTLSSubjectDN":{"inherited":false},"jwkStoreCacheMissCacheTime":{"inherited":false,"value":60000},"jwkSet":{"inherited":false},"idTokenEncryptionMethod":{"inherited":false,"value":"A128CBC-HS256"},"jwksUri":{"inherited":false},"tokenIntrospectionEncryptedResponseAlg":{"inherited":false,"value":"RSA-OAEP-256"},"authorizationResponseEncryptionMethod":{"inherited":false},"userinfoResponseFormat":{"inherited":false,"value":"JSON"},"mTLSCertificateBoundAccessTokens":{"inherited":false,"value":false},"publicKeyLocation":{"inherited":false,"value":"jwks_uri"},"tokenIntrospectionResponseFormat":{"inherited":false,"value":"JSON"},"requestParameterEncryptedEncryptionAlgorithm":{"inherited":false,"value":"A128CBC-HS256"},"userinfoSignedResponseAlg":{"inherited":false},"idTokenEncryptionAlgorithm":{"inherited":false,"value":"RSA-OAEP-256"},"requestParameterEncryptedAlg":{"inherited":false},"authorizationResponseEncryptionAlgorithm":{"inherited":false},"mTLSTrustedCert":{"inherited":false},"jwksCacheTimeout":{"inherited":false,"value":3600000},"userinfoEncryptedResponseAlg":{"inherited":false},"idTokenSignedResponseAlg":{"inherited":false,"value":"RS256"},"tokenIntrospectionSignedResponseAlg":{"inherited":false,"value":"RS256"},"userinfoEncryptedResponseEncryptionAlgorithm":{"inherited":false,"value":"A128CBC-HS256"}},"coreOAuth2ClientConfig":{"secretLabelIdentifier":{"value":"","inherited":false},"defaultScopes":{"value":[],"inherited":false},"scopes":{"value":["openid","fr:idm:*"],"inherited":false},"redirectionUris":{"value":["http://openidm.example.com:8080/platform/appAuthHelperRedirect.html","http://openidm.example.com:8080/platform/sessionCheck.html","http://openidm.example.com:8080/admin/appAuthHelperRedirect.html","http://openidm.example.com:8080/admin/sessionCheck.html","http://admin.example.com:8082/appAuthHelperRedirect.html","http://admin.example.com:8082/sessionCheck.html"],"inherited":false},"status":{"value":"Active","inherited":false},"authorizationCodeLifetime":{"value":0,"inherited":false},"refreshTokenLifetime":{"value":0,"inherited":false},"agentgroup":"","accessTokenLifetime":{"value":0,"inherited":false},"clientType":{"value":"Public","inherited":false},"loopbackInterfaceRedirection":{"value":false,"inherited":false},"clientName":{"value":[],"inherited":false}},"coreOpenIDClientConfig":{"claims":{"inherited":false,"value":[]},"backchannel_logout_uri":{"inherited":false},"defaultAcrValues":{"inherited":false,"value":[]},"jwtTokenLifetime":{"inherited":false,"value":0},"defaultMaxAgeEnabled":{"inherited":false,"value":false},"clientSessionUri":{"inherited":false},"defaultMaxAge":{"inherited":false,"value":600},"postLogoutRedirectUri":{"inherited":false,"value":[]},"backchannel_logout_session_required":{"inherited":false,"value":false}},"coreUmaClientConfig":{"claimsRedirectionUris":{"inherited":false,"value":[]}},"_type":{"_id":"OAuth2Client","name":"OAuth2 Clients","collection":true}}' \
      -o /vagrant/curl_response.json \
      -v 2>> /vagrant/curl_error.log

    # Check the curl exit status
    if [ $? -ne 0 ]; then
      echo "curl request failed. Check /vagrant/curl_error.log for details."
      exit 1
    fi

    # Log completion
    echo "Request completed at $(date)" >> /vagrant/curl_request.log

##### updating client idm-admin-ui in root to public
sudo echo "starting to updating client idm-admin-ui in root to public"
    # Make the HTTP PUT request to update idm-admin-ui
    curl -X PUT "http://am.example.com:8081/am/json/realms/root/realm-config/agents/OAuth2Client/idm-admin-ui" \
      -H "Accept: application/json, text/javascript, */*; q=0.01" \
      -H "Accept-API-Version: protocol=2.0,resource=1.0" \
      -H "Accept-Encoding: gzip, deflate" \
      -H "Accept-Language: en-US" \
      -H "Cache-Control: no-cache" \
      -H "Connection: keep-alive" \
      -H "iPlanetDirectoryPro: $ADMIN_TOKEN" \
      -H "Content-Type: application/json" \
      -H "Host: am.example.com:8081" \
      -H "If-Match: *" \
      -H "Origin: http://am.example.com:8081" \
      -H "Referer: http://am.example.com:8081/am/ui-admin/" \
      -H "User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36 Edg/135.0.0.0" \
      -H "X-Requested-With: XMLHttpRequest" \
      -d '{"_id":"idm-admin-ui","overrideOAuth2ClientConfig":{"issueRefreshToken":true,"validateScopePluginType":"PROVIDER","tokenEncryptionEnabled":false,"evaluateScopePluginType":"PROVIDER","oidcMayActScript":"[Empty]","oidcClaimsScript":"[Empty]","scopesPolicySet":"oauth2Scopes","accessTokenModificationPluginType":"PROVIDER","authorizeEndpointDataProviderClass":"org.forgerock.oauth2.core.plugins.registry.DefaultEndpointDataProvider","useForceAuthnForMaxAge":false,"oidcClaimsPluginType":"PROVIDER","providerOverridesEnabled":false,"authorizeEndpointDataProviderScript":"[Empty]","statelessTokensEnabled":false,"authorizeEndpointDataProviderPluginType":"PROVIDER","remoteConsentServiceId":null,"enableRemoteConsent":false,"validateScopeClass":"org.forgerock.oauth2.core.plugins.registry.DefaultScopeValidator","usePolicyEngineForScope":false,"evaluateScopeClass":"org.forgerock.oauth2.core.plugins.registry.DefaultScopeEvaluator","overrideableOIDCClaims":[],"accessTokenMayActScript":"[Empty]","evaluateScopeScript":"[Empty]","clientsCanSkipConsent":false,"accessTokenModificationScript":"[Empty]","issueRefreshTokenOnRefreshedToken":true,"validateScopeScript":"[Empty]"},"advancedOAuth2ClientConfig":{"logoUri":{"inherited":false,"value":[]},"subjectType":{"inherited":false,"value":"public"},"clientUri":{"inherited":false,"value":[]},"tokenExchangeAuthLevel":{"inherited":false,"value":0},"responseTypes":{"inherited":false,"value":["code","token","id_token","code token","token id_token","code id_token","code token id_token","device_code","device_code id_token"]},"mixUpMitigation":{"inherited":false,"value":false},"customProperties":{"inherited":false,"value":[]},"javascriptOrigins":{"inherited":false,"value":[]},"policyUri":{"inherited":false,"value":[]},"softwareVersion":{"inherited":false},"tosURI":{"inherited":false,"value":[]},"sectorIdentifierUri":{"inherited":false},"tokenEndpointAuthMethod":{"inherited":false,"value":"client_secret_basic"},"refreshTokenGracePeriod":{"inherited":false,"value":0},"isConsentImplied":{"inherited":false,"value":false},"softwareIdentity":{"inherited":false},"grantTypes":{"inherited":false,"value":["authorization_code"]},"require_pushed_authorization_requests":{"inherited":false,"value":false},"descriptions":{"inherited":false,"value":[]},"requestUris":{"inherited":false,"value":[]},"name":{"inherited":false,"value":[]},"contacts":{"inherited":false,"value":[]},"updateAccessToken":{"inherited":false}},"signEncOAuth2ClientConfig":{"tokenEndpointAuthSigningAlgorithm":{"inherited":false,"value":"RS256"},"idTokenEncryptionEnabled":{"inherited":false,"value":false},"tokenIntrospectionEncryptedResponseEncryptionAlgorithm":{"inherited":false,"value":"A128CBC-HS256"},"requestParameterSignedAlg":{"inherited":false},"authorizationResponseSigningAlgorithm":{"inherited":false,"value":"RS256"},"clientJwtPublicKey":{"inherited":false},"idTokenPublicEncryptionKey":{"inherited":false},"mTLSSubjectDN":{"inherited":false},"jwkStoreCacheMissCacheTime":{"inherited":false,"value":60000},"jwkSet":{"inherited":false},"idTokenEncryptionMethod":{"inherited":false,"value":"A128CBC-HS256"},"jwksUri":{"inherited":false},"tokenIntrospectionEncryptedResponseAlg":{"inherited":false,"value":"RSA-OAEP-256"},"authorizationResponseEncryptionMethod":{"inherited":false},"userinfoResponseFormat":{"inherited":false,"value":"JSON"},"mTLSCertificateBoundAccessTokens":{"inherited":false,"value":false},"publicKeyLocation":{"inherited":false,"value":"jwks_uri"},"tokenIntrospectionResponseFormat":{"inherited":false,"value":"JSON"},"requestParameterEncryptedEncryptionAlgorithm":{"inherited":false,"value":"A128CBC-HS256"},"userinfoSignedResponseAlg":{"inherited":false},"idTokenEncryptionAlgorithm":{"inherited":false,"value":"RSA-OAEP-256"},"requestParameterEncryptedAlg":{"inherited":false},"authorizationResponseEncryptionAlgorithm":{"inherited":false},"mTLSTrustedCert":{"inherited":false},"jwksCacheTimeout":{"inherited":false,"value":3600000},"userinfoEncryptedResponseAlg":{"inherited":false},"idTokenSignedResponseAlg":{"inherited":false,"value":"RS256"},"tokenIntrospectionSignedResponseAlg":{"inherited":false,"value":"RS256"},"userinfoEncryptedResponseEncryptionAlgorithm":{"inherited":false,"value":"A128CBC-HS256"}},"coreOAuth2ClientConfig":{"secretLabelIdentifier":{"value":"","inherited":false},"defaultScopes":{"value":[],"inherited":false},"scopes":{"value":["openid","fr:idm:*"],"inherited":false},"redirectionUris":{"value":["http://openidm.example.com:8080/platform/appAuthHelperRedirect.html","http://openidm.example.com:8080/platform/sessionCheck.html","http://openidm.example.com:8080/admin/appAuthHelperRedirect.html","http://openidm.example.com:8080/admin/sessionCheck.html","http://admin.example.com:8082/appAuthHelperRedirect.html","http://admin.example.com:8082/sessionCheck.html"],"inherited":false},"status":{"value":"Active","inherited":false},"authorizationCodeLifetime":{"value":0,"inherited":false},"refreshTokenLifetime":{"value":0,"inherited":false},"agentgroup":"","accessTokenLifetime":{"value":0,"inherited":false},"clientType":{"value":"Public","inherited":false},"loopbackInterfaceRedirection":{"value":false,"inherited":false},"clientName":{"value":[],"inherited":false}},"coreOpenIDClientConfig":{"claims":{"inherited":false,"value":[]},"backchannel_logout_uri":{"inherited":false},"defaultAcrValues":{"inherited":false,"value":[]},"jwtTokenLifetime":{"inherited":false,"value":0},"defaultMaxAgeEnabled":{"inherited":false,"value":false},"clientSessionUri":{"inherited":false},"defaultMaxAge":{"inherited":false,"value":600},"postLogoutRedirectUri":{"inherited":false,"value":[]},"backchannel_logout_session_required":{"inherited":false,"value":false}},"coreUmaClientConfig":{"claimsRedirectionUris":{"inherited":false,"value":[]}},"_type":{"_id":"OAuth2Client","name":"OAuth2 Clients","collection":true}}' \
      -o /vagrant/curl_response.json \
      -v 2>> /vagrant/curl_error.log

    # Check the curl exit status
    if [ $? -ne 0 ]; then
      echo "curl request failed. Check /vagrant/curl_error.log for details."
      exit 1
    fi

    # Log completion
    echo "Request completed at $(date)" >> /vagrant/curl_request.log

##### updating client advanced tab in idm-admin-ui for realm alpha
sudo echo "starting updating client advanced tab in idm-admin-ui for realm alpha"
    # Make the HTTP PUT request to update idm-admin-ui
    curl -X PUT "http://am.example.com:8081/am/json/realms/root/realms/alpha/realm-config/agents/OAuth2Client/idm-admin-ui" \
      -H "Accept: application/json, text/javascript, */*; q=0.01" \
      -H "Accept-API-Version: protocol=2.0,resource=1.0" \
      -H "Accept-Encoding: gzip, deflate" \
      -H "Accept-Language: en-US" \
      -H "Cache-Control: no-cache" \
      -H "Connection: keep-alive" \
      -H "iPlanetDirectoryPro: $ADMIN_TOKEN" \
      -H "Content-Type: application/json" \
      -H "Host: am.example.com:8081" \
      -H "If-Match: *" \
      -H "Origin: http://am.example.com:8081" \
      -H "Referer: http://am.example.com:8081/am/ui-admin/" \
      -H "User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36 Edg/135.0.0.0" \
      -H "X-Requested-With: XMLHttpRequest" \
      -d '{"_id":"idm-admin-ui","overrideOAuth2ClientConfig":{"issueRefreshToken":true,"validateScopePluginType":"PROVIDER","tokenEncryptionEnabled":false,"evaluateScopePluginType":"PROVIDER","oidcMayActScript":"[Empty]","oidcClaimsScript":"[Empty]","scopesPolicySet":"oauth2Scopes","accessTokenModificationPluginType":"PROVIDER","authorizeEndpointDataProviderClass":"org.forgerock.oauth2.core.plugins.registry.DefaultEndpointDataProvider","useForceAuthnForMaxAge":false,"oidcClaimsPluginType":"PROVIDER","providerOverridesEnabled":false,"authorizeEndpointDataProviderScript":"[Empty]","statelessTokensEnabled":false,"authorizeEndpointDataProviderPluginType":"PROVIDER","remoteConsentServiceId":null,"enableRemoteConsent":false,"validateScopeClass":"org.forgerock.oauth2.core.plugins.registry.DefaultScopeValidator","usePolicyEngineForScope":false,"evaluateScopeClass":"org.forgerock.oauth2.core.plugins.registry.DefaultScopeEvaluator","overrideableOIDCClaims":[],"accessTokenMayActScript":"[Empty]","evaluateScopeScript":"[Empty]","clientsCanSkipConsent":false,"accessTokenModificationScript":"[Empty]","issueRefreshTokenOnRefreshedToken":true,"validateScopeScript":"[Empty]"},"advancedOAuth2ClientConfig":{"mixUpMitigation":{"value":false,"inherited":false},"grantTypes":{"value":["authorization_code","implicit"],"inherited":false},"softwareVersion":{"value":"","inherited":false},"softwareIdentity":{"value":"","inherited":false},"tokenEndpointAuthMethod":{"value":"none","inherited":false},"tokenExchangeAuthLevel":{"value":0,"inherited":false},"contacts":{"value":[],"inherited":false},"policyUri":{"value":[],"inherited":false},"sectorIdentifierUri":{"value":"","inherited":false},"javascriptOrigins":{"value":[],"inherited":false},"updateAccessToken":{"value":"","inherited":false},"name":{"value":[],"inherited":false},"descriptions":{"value":[],"inherited":false},"require_pushed_authorization_requests":{"value":false,"inherited":false},"tosURI":{"value":[],"inherited":false},"requestUris":{"value":[],"inherited":false},"clientUri":{"value":[],"inherited":false},"refreshTokenGracePeriod":{"value":0,"inherited":false},"subjectType":{"value":"public","inherited":false},"logoUri":{"value":[],"inherited":false},"responseTypes":{"value":["code","token","id_token","code token","token id_token","code id_token","code token id_token","device_code","device_code id_token"],"inherited":false},"isConsentImplied":{"value":true,"inherited":false},"customProperties":{"value":[],"inherited":false}},"signEncOAuth2ClientConfig":{"tokenEndpointAuthSigningAlgorithm":{"inherited":false,"value":"RS256"},"idTokenEncryptionEnabled":{"inherited":false,"value":false},"tokenIntrospectionEncryptedResponseEncryptionAlgorithm":{"inherited":false,"value":"A128CBC-HS256"},"requestParameterSignedAlg":{"inherited":false},"authorizationResponseSigningAlgorithm":{"inherited":false,"value":"RS256"},"clientJwtPublicKey":{"inherited":false},"idTokenPublicEncryptionKey":{"inherited":false},"mTLSSubjectDN":{"inherited":false},"jwkStoreCacheMissCacheTime":{"inherited":false,"value":60000},"jwkSet":{"inherited":false},"idTokenEncryptionMethod":{"inherited":false,"value":"A128CBC-HS256"},"jwksUri":{"inherited":false},"tokenIntrospectionEncryptedResponseAlg":{"inherited":false,"value":"RSA-OAEP-256"},"authorizationResponseEncryptionMethod":{"inherited":false},"userinfoResponseFormat":{"inherited":false,"value":"JSON"},"mTLSCertificateBoundAccessTokens":{"inherited":false,"value":false},"publicKeyLocation":{"inherited":false,"value":"jwks_uri"},"tokenIntrospectionResponseFormat":{"inherited":false,"value":"JSON"},"requestParameterEncryptedEncryptionAlgorithm":{"inherited":false,"value":"A128CBC-HS256"},"userinfoSignedResponseAlg":{"inherited":false},"idTokenEncryptionAlgorithm":{"inherited":false,"value":"RSA-OAEP-256"},"requestParameterEncryptedAlg":{"inherited":false},"authorizationResponseEncryptionAlgorithm":{"inherited":false},"mTLSTrustedCert":{"inherited":false},"jwksCacheTimeout":{"inherited":false,"value":3600000},"userinfoEncryptedResponseAlg":{"inherited":false},"idTokenSignedResponseAlg":{"inherited":false,"value":"RS256"},"tokenIntrospectionSignedResponseAlg":{"inherited":false,"value":"RS256"},"userinfoEncryptedResponseEncryptionAlgorithm":{"inherited":false,"value":"A128CBC-HS256"}},"coreOAuth2ClientConfig":{"secretLabelIdentifier":{"inherited":false},"status":{"inherited":false,"value":"Active"},"clientName":{"inherited":false,"value":[]},"clientType":{"inherited":false,"value":"Public"},"loopbackInterfaceRedirection":{"inherited":false,"value":false},"defaultScopes":{"inherited":false,"value":[]},"refreshTokenLifetime":{"inherited":false,"value":0},"scopes":{"inherited":false,"value":["openid","fr:idm:*"]},"accessTokenLifetime":{"inherited":false,"value":0},"redirectionUris":{"inherited":false,"value":["http://openidm.example.com:8080/platform/appAuthHelperRedirect.html","http://openidm.example.com:8080/platform/sessionCheck.html","http://openidm.example.com:8080/admin/appAuthHelperRedirect.html","http://openidm.example.com:8080/admin/sessionCheck.html","http://admin.example.com:8082/appAuthHelperRedirect.html","http://admin.example.com:8082/sessionCheck.html"]},"authorizationCodeLifetime":{"inherited":false,"value":0}},"coreOpenIDClientConfig":{"claims":{"inherited":false,"value":[]},"backchannel_logout_uri":{"inherited":false},"defaultAcrValues":{"inherited":false,"value":[]},"jwtTokenLifetime":{"inherited":false,"value":0},"defaultMaxAgeEnabled":{"inherited":false,"value":false},"clientSessionUri":{"inherited":false},"defaultMaxAge":{"inherited":false,"value":600},"postLogoutRedirectUri":{"inherited":false,"value":[]},"backchannel_logout_session_required":{"inherited":false,"value":false}},"coreUmaClientConfig":{"claimsRedirectionUris":{"inherited":false,"value":[]}},"_type":{"_id":"OAuth2Client","name":"OAuth2 Clients","collection":true}}' \
      -o /vagrant/curl_response.json \
      -v 2>> /vagrant/curl_error.log

    # Check the curl exit status
    if [ $? -ne 0 ]; then
      echo "curl request failed. Check /vagrant/curl_error.log for details."
      exit 1
    fi

    # Log completion
    echo "Request completed at $(date)" >> /vagrant/curl_request.log

##### updating client advanced tab in idm-admin-ui for realm root
sudo echo "starting updating client advanced tab in idm-admin-ui for realm root "
    # Make the HTTP PUT request to update idm-admin-ui
    curl -X PUT "http://am.example.com:8081/am/json/realms/root/realm-config/agents/OAuth2Client/idm-admin-ui" \
      -H "Accept: application/json, text/javascript, */*; q=0.01" \
      -H "Accept-API-Version: protocol=2.0,resource=1.0" \
      -H "Accept-Encoding: gzip, deflate" \
      -H "Accept-Language: en-US" \
      -H "Cache-Control: no-cache" \
      -H "Connection: keep-alive" \
      -H "iPlanetDirectoryPro: $ADMIN_TOKEN" \
      -H "Content-Type: application/json" \
      -H "Host: am.example.com:8081" \
      -H "If-Match: *" \
      -H "Origin: http://am.example.com:8081" \
      -H "Referer: http://am.example.com:8081/am/ui-admin/" \
      -H "User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36 Edg/135.0.0.0" \
      -H "X-Requested-With: XMLHttpRequest" \
      -d '{"_id":"idm-admin-ui","overrideOAuth2ClientConfig":{"issueRefreshToken":true,"validateScopePluginType":"PROVIDER","tokenEncryptionEnabled":false,"evaluateScopePluginType":"PROVIDER","oidcMayActScript":"[Empty]","oidcClaimsScript":"[Empty]","scopesPolicySet":"oauth2Scopes","accessTokenModificationPluginType":"PROVIDER","authorizeEndpointDataProviderClass":"org.forgerock.oauth2.core.plugins.registry.DefaultEndpointDataProvider","useForceAuthnForMaxAge":false,"oidcClaimsPluginType":"PROVIDER","providerOverridesEnabled":false,"authorizeEndpointDataProviderScript":"[Empty]","statelessTokensEnabled":false,"authorizeEndpointDataProviderPluginType":"PROVIDER","remoteConsentServiceId":null,"enableRemoteConsent":false,"validateScopeClass":"org.forgerock.oauth2.core.plugins.registry.DefaultScopeValidator","usePolicyEngineForScope":false,"evaluateScopeClass":"org.forgerock.oauth2.core.plugins.registry.DefaultScopeEvaluator","overrideableOIDCClaims":[],"accessTokenMayActScript":"[Empty]","evaluateScopeScript":"[Empty]","clientsCanSkipConsent":false,"accessTokenModificationScript":"[Empty]","issueRefreshTokenOnRefreshedToken":true,"validateScopeScript":"[Empty]"},"advancedOAuth2ClientConfig":{"mixUpMitigation":{"value":false,"inherited":false},"grantTypes":{"value":["authorization_code","implicit"],"inherited":false},"softwareVersion":{"value":"","inherited":false},"softwareIdentity":{"value":"","inherited":false},"tokenEndpointAuthMethod":{"value":"none","inherited":false},"tokenExchangeAuthLevel":{"value":0,"inherited":false},"contacts":{"value":[],"inherited":false},"policyUri":{"value":[],"inherited":false},"sectorIdentifierUri":{"value":"","inherited":false},"javascriptOrigins":{"value":[],"inherited":false},"updateAccessToken":{"value":"","inherited":false},"name":{"value":[],"inherited":false},"descriptions":{"value":[],"inherited":false},"require_pushed_authorization_requests":{"value":false,"inherited":false},"tosURI":{"value":[],"inherited":false},"requestUris":{"value":[],"inherited":false},"clientUri":{"value":[],"inherited":false},"refreshTokenGracePeriod":{"value":0,"inherited":false},"subjectType":{"value":"public","inherited":false},"logoUri":{"value":[],"inherited":false},"responseTypes":{"value":["code","token","id_token","code token","token id_token","code id_token","code token id_token","device_code","device_code id_token"],"inherited":false},"isConsentImplied":{"value":true,"inherited":false},"customProperties":{"value":[],"inherited":false}},"signEncOAuth2ClientConfig":{"tokenEndpointAuthSigningAlgorithm":{"inherited":false,"value":"RS256"},"idTokenEncryptionEnabled":{"inherited":false,"value":false},"tokenIntrospectionEncryptedResponseEncryptionAlgorithm":{"inherited":false,"value":"A128CBC-HS256"},"requestParameterSignedAlg":{"inherited":false},"authorizationResponseSigningAlgorithm":{"inherited":false,"value":"RS256"},"clientJwtPublicKey":{"inherited":false},"idTokenPublicEncryptionKey":{"inherited":false},"mTLSSubjectDN":{"inherited":false},"jwkStoreCacheMissCacheTime":{"inherited":false,"value":60000},"jwkSet":{"inherited":false},"idTokenEncryptionMethod":{"inherited":false,"value":"A128CBC-HS256"},"jwksUri":{"inherited":false},"tokenIntrospectionEncryptedResponseAlg":{"inherited":false,"value":"RSA-OAEP-256"},"authorizationResponseEncryptionMethod":{"inherited":false},"userinfoResponseFormat":{"inherited":false,"value":"JSON"},"mTLSCertificateBoundAccessTokens":{"inherited":false,"value":false},"publicKeyLocation":{"inherited":false,"value":"jwks_uri"},"tokenIntrospectionResponseFormat":{"inherited":false,"value":"JSON"},"requestParameterEncryptedEncryptionAlgorithm":{"inherited":false,"value":"A128CBC-HS256"},"userinfoSignedResponseAlg":{"inherited":false},"idTokenEncryptionAlgorithm":{"inherited":false,"value":"RSA-OAEP-256"},"requestParameterEncryptedAlg":{"inherited":false},"authorizationResponseEncryptionAlgorithm":{"inherited":false},"mTLSTrustedCert":{"inherited":false},"jwksCacheTimeout":{"inherited":false,"value":3600000},"userinfoEncryptedResponseAlg":{"inherited":false},"idTokenSignedResponseAlg":{"inherited":false,"value":"RS256"},"tokenIntrospectionSignedResponseAlg":{"inherited":false,"value":"RS256"},"userinfoEncryptedResponseEncryptionAlgorithm":{"inherited":false,"value":"A128CBC-HS256"}},"coreOAuth2ClientConfig":{"secretLabelIdentifier":{"inherited":false},"status":{"inherited":false,"value":"Active"},"clientName":{"inherited":false,"value":[]},"clientType":{"inherited":false,"value":"Public"},"loopbackInterfaceRedirection":{"inherited":false,"value":false},"defaultScopes":{"inherited":false,"value":[]},"refreshTokenLifetime":{"inherited":false,"value":0},"scopes":{"inherited":false,"value":["openid","fr:idm:*"]},"accessTokenLifetime":{"inherited":false,"value":0},"redirectionUris":{"inherited":false,"value":["http://openidm.example.com:8080/platform/appAuthHelperRedirect.html","http://openidm.example.com:8080/platform/sessionCheck.html","http://openidm.example.com:8080/admin/appAuthHelperRedirect.html","http://openidm.example.com:8080/admin/sessionCheck.html","http://admin.example.com:8082/appAuthHelperRedirect.html","http://admin.example.com:8082/sessionCheck.html"]},"authorizationCodeLifetime":{"inherited":false,"value":0}},"coreOpenIDClientConfig":{"claims":{"inherited":false,"value":[]},"backchannel_logout_uri":{"inherited":false},"defaultAcrValues":{"inherited":false,"value":[]},"jwtTokenLifetime":{"inherited":false,"value":0},"defaultMaxAgeEnabled":{"inherited":false,"value":false},"clientSessionUri":{"inherited":false},"defaultMaxAge":{"inherited":false,"value":600},"postLogoutRedirectUri":{"inherited":false,"value":[]},"backchannel_logout_session_required":{"inherited":false,"value":false}},"coreUmaClientConfig":{"claimsRedirectionUris":{"inherited":false,"value":[]}},"_type":{"_id":"OAuth2Client","name":"OAuth2 Clients","collection":true}}' \
      -o /vagrant/curl_response.json \
      -v 2>> /vagrant/curl_error.log

    # Check the curl exit status
    if [ $? -ne 0 ]; then
      echo "curl request failed. Check /vagrant/curl_error.log for details."
      exit 1
    fi

    # Log completion
    echo "Request completed at $(date)" >> /vagrant/curl_request.log

##### creating client end-user-ui in alpha
sudo echo "starting creating client end-user-ui in alpha"
    # Make the HTTP PUT request to create OAuth2Client configuration
    curl -X PUT "http://am.example.com:8081/am/json/realms/root/realms/alpha/realm-config/agents/OAuth2Client/end-user-ui" \
      -H "Accept: application/json, text/javascript, */*; q=0.01" \
      -H "Accept-API-Version: protocol=2.0,resource=1.0" \
      -H "Accept-Encoding: gzip, deflate" \
      -H "Accept-Language: en-US" \
      -H "Cache-Control: no-cache" \
      -H "iPlanetDirectoryPro: $ADMIN_TOKEN" \
      -H "Connection: keep-alive" \
      -H "Content-Type: application/json" \
      -H "Host: am.example.com:8081" \
      -H "If-None-Match: *" \
      -H "Origin: http://am.example.com:8081" \
      -H "Referer: http://am.example.com:8081/am/ui-admin/" \
      -H "User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36 Edg/135.0.0.0" \
      -H "X-Requested-With: XMLHttpRequest" \
      -d '{"coreOAuth2ClientConfig":{"defaultScopes":[],"redirectionUris":["http://enduser.example.com:8888/appAuthHelperRedirect.html","http://enduser.example.com:8888/sessionCheck.html"],"scopes":["openid","fr:idm:*"]}}' \
      -o /vagrant/curl_response.json \
      -v 2>> /vagrant/curl_error.log

    # Check the curl exit status
    if [ $? -ne 0 ]; then
      echo "curl request failed. Check /vagrant/curl_error.log for details."
      exit 1
    fi

    # Log completion
    echo "OAuth2Client 'end-user-ui' creation request completed at $(date)" >> /vagrant/curl_request.log


##### creating client end-user-ui in root
sudo echo "starting creating client end-user-ui in root"
 curl -X PUT "http://am.example.com:8081/am/json/realms/root/realm-config/agents/OAuth2Client/end-user-ui" \
      -H "Accept: application/json, text/javascript, */*; q=0.01" \
      -H "Accept-API-Version: protocol=2.0,resource=1.0" \
      -H "Accept-Encoding: gzip, deflate" \
      -H "Accept-Language: en-US" \
      -H "Cache-Control: no-cache" \
      -H "iPlanetDirectoryPro: $ADMIN_TOKEN" \
      -H "Connection: keep-alive" \
      -H "Content-Type: application/json" \
      -H "Host: am.example.com:8081" \
      -H "If-None-Match: *" \
      -H "Origin: http://am.example.com:8081" \
      -H "Referer: http://am.example.com:8081/am/ui-admin/" \
      -H "User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36 Edg/135.0.0.0" \
      -H "X-Requested-With: XMLHttpRequest" \
      -d '{"coreOAuth2ClientConfig":{"defaultScopes":[],"redirectionUris":["http://enduser.example.com:8888/appAuthHelperRedirect.html","http://enduser.example.com:8888/sessionCheck.html"],"scopes":["openid","fr:idm:*"]}}' \
      -o /vagrant/curl_response.json \
      -v 2>> /vagrant/curl_error.log

    # Check the curl exit status
    if [ $? -ne 0 ]; then
      echo "curl request failed. Check /vagrant/curl_error.log for details."
      exit 1
    fi

    # Log completion
    echo "OAuth2Client 'end-user-ui' creation request completed at $(date)" >> /vagrant/curl_request.log

#### update end-user-ui in alpha
sudo echo "starting update end-user-ui in alpha"

    # Make the HTTP PUT request to update end-user-ui OAuth2 client
    curl -X PUT "http://am.example.com:8081/am/json/realms/root/realms/alpha/realm-config/agents/OAuth2Client/end-user-ui" \
      -H "Accept: application/json, text/javascript, */*; q=0.01" \
      -H "Accept-API-Version: protocol=2.0,resource=1.0" \
      -H "Accept-Encoding: gzip, deflate" \
      -H "Accept-Language: en-US" \
      -H "Cache-Control: no-cache" \
      -H "iPlanetDirectoryPro: $ADMIN_TOKEN" \
      -H "Connection: keep-alive" \
      -H "Content-Type: application/json" \
      -H "Host: am.example.com:8081" \
      -H "If-Match: *" \
      -H "Origin: http://am.example.com:8081" \
      -H "Referer: http://am.example.com:8081/am/ui-admin/" \
      -H "User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36 Edg/135.0.0.0" \
      -H "X-Requested-With: XMLHttpRequest" \
      -d '{"_id":"end-user-ui","overrideOAuth2ClientConfig":{"issueRefreshToken":true,"validateScopePluginType":"PROVIDER","tokenEncryptionEnabled":false,"evaluateScopePluginType":"PROVIDER","oidcMayActScript":"[Empty]","oidcClaimsScript":"[Empty]","scopesPolicySet":"oauth2Scopes","accessTokenModificationPluginType":"PROVIDER","authorizeEndpointDataProviderClass":"org.forgerock.oauth2.core.plugins.registry.DefaultEndpointDataProvider","useForceAuthnForMaxAge":false,"oidcClaimsPluginType":"PROVIDER","providerOverridesEnabled":false,"authorizeEndpointDataProviderScript":"[Empty]","statelessTokensEnabled":false,"authorizeEndpointDataProviderPluginType":"PROVIDER","remoteConsentServiceId":null,"enableRemoteConsent":false,"validateScopeClass":"org.forgerock.oauth2.core.plugins.registry.DefaultScopeValidator","usePolicyEngineForScope":false,"evaluateScopeClass":"org.forgerock.oauth2.core.plugins.registry.DefaultScopeEvaluator","overrideableOIDCClaims":[],"accessTokenMayActScript":"[Empty]","evaluateScopeScript":"[Empty]","clientsCanSkipConsent":false,"accessTokenModificationScript":"[Empty]","issueRefreshTokenOnRefreshedToken":true,"validateScopeScript":"[Empty]"},"advancedOAuth2ClientConfig":{"logoUri":{"inherited":false,"value":[]},"subjectType":{"inherited":false,"value":"public"},"clientUri":{"inherited":false,"value":[]},"tokenExchangeAuthLevel":{"inherited":false,"value":0},"responseTypes":{"inherited":false,"value":["code","token","id_token","code token","token id_token","code id_token","code token id_token","device_code","device_code id_token"]},"mixUpMitigation":{"inherited":false,"value":false},"customProperties":{"inherited":false,"value":[]},"javascriptOrigins":{"inherited":false,"value":[]},"policyUri":{"inherited":false,"value":[]},"softwareVersion":{"inherited":false},"tosURI":{"inherited":false,"value":[]},"sectorIdentifierUri":{"inherited":false},"tokenEndpointAuthMethod":{"inherited":false,"value":"client_secret_basic"},"refreshTokenGracePeriod":{"inherited":false,"value":0},"isConsentImplied":{"inherited":false,"value":false},"softwareIdentity":{"inherited":false},"grantTypes":{"inherited":false,"value":["authorization_code"]},"require_pushed_authorization_requests":{"inherited":false,"value":false},"descriptions":{"inherited":false,"value":[]},"requestUris":{"inherited":false,"value":[]},"name":{"inherited":false,"value":[]},"contacts":{"inherited":false,"value":[]},"updateAccessToken":{"inherited":false}},"signEncOAuth2ClientConfig":{"tokenEndpointAuthSigningAlgorithm":{"inherited":false,"value":"RS256"},"idTokenEncryptionEnabled":{"inherited":false,"value":false},"tokenIntrospectionEncryptedResponseEncryptionAlgorithm":{"inherited":false,"value":"A128CBC-HS256"},"requestParameterSignedAlg":{"inherited":false},"authorizationResponseSigningAlgorithm":{"inherited":false,"value":"RS256"},"clientJwtPublicKey":{"inherited":false},"idTokenPublicEncryptionKey":{"inherited":false},"mTLSSubjectDN":{"inherited":false},"jwkStoreCacheMissCacheTime":{"inherited":false,"value":60000},"jwkSet":{"inherited":false},"idTokenEncryptionMethod":{"inherited":false,"value":"A128CBC-HS256"},"jwksUri":{"inherited":false},"tokenIntrospectionEncryptedResponseAlg":{"inherited":false,"value":"RSA-OAEP-256"},"authorizationResponseEncryptionMethod":{"inherited":false},"userinfoResponseFormat":{"inherited":false,"value":"JSON"},"mTLSCertificateBoundAccessTokens":{"inherited":false,"value":false},"publicKeyLocation":{"inherited":false,"value":"jwks_uri"},"tokenIntrospectionResponseFormat":{"inherited":false,"value":"JSON"},"requestParameterEncryptedEncryptionAlgorithm":{"inherited":false,"value":"A128CBC-HS256"},"userinfoSignedResponseAlg":{"inherited":false},"idTokenEncryptionAlgorithm":{"inherited":false,"value":"RSA-OAEP-256"},"requestParameterEncryptedAlg":{"inherited":false},"authorizationResponseEncryptionAlgorithm":{"inherited":false},"mTLSTrustedCert":{"inherited":false},"jwksCacheTimeout":{"inherited":false,"value":3600000},"userinfoEncryptedResponseAlg":{"inherited":false},"idTokenSignedResponseAlg":{"inherited":false,"value":"RS256"},"tokenIntrospectionSignedResponseAlg":{"inherited":false,"value":"RS256"},"userinfoEncryptedResponseEncryptionAlgorithm":{"inherited":false,"value":"A128CBC-HS256"}},"coreOAuth2ClientConfig":{"status":{"value":"Active","inherited":false},"scopes":{"value":["openid","fr:idm:*"],"inherited":false},"secretLabelIdentifier":{"value":"","inherited":false},"defaultScopes":{"value":[],"inherited":false},"refreshTokenLifetime":{"value":0,"inherited":false},"loopbackInterfaceRedirection":{"value":false,"inherited":false},"redirectionUris":{"value":["http://enduser.example.com:8888/appAuthHelperRedirect.html","http://enduser.example.com:8888/sessionCheck.html"],"inherited":false},"accessTokenLifetime":{"value":0,"inherited":false},"agentgroup":"","clientType":{"value":"Public","inherited":false},"authorizationCodeLifetime":{"value":0,"inherited":false},"clientName":{"value":[],"inherited":false}},"coreOpenIDClientConfig":{"claims":{"inherited":false,"value":[]},"backchannel_logout_uri":{"inherited":false},"defaultAcrValues":{"inherited":false,"value":[]},"jwtTokenLifetime":{"inherited":false,"value":0},"defaultMaxAgeEnabled":{"inherited":false,"value":false},"clientSessionUri":{"inherited":false},"defaultMaxAge":{"inherited":false,"value":600},"postLogoutRedirectUri":{"inherited":false,"value":[]},"backchannel_logout_session_required":{"inherited":false,"value":false}},"coreUmaClientConfig":{"claimsRedirectionUris":{"inherited":false,"value":[]}},"_type":{"_id":"OAuth2Client","name":"OAuth2 Clients","collection":true}}' \
      -o /vagrant/curl_response.json \
      -v 2>> /vagrant/curl_error.log

    # Check the curl exit status
    if [ $? -ne 0 ]; then
      echo "curl request failed. Check /vagrant/curl_error.log for details."
      exit 1
    fi

    # Log completion
    echo "Request completed at $(date)" >> /vagrant/curl_request.log


#### update end-user-ui in root
sudo echo "starting update end-user-ui in root"
     curl -X PUT "http://am.example.com:8081/am/json/realms/root/realm-config/agents/OAuth2Client/end-user-ui" \
      -H "Accept: application/json, text/javascript, */*; q=0.01" \
      -H "Accept-API-Version: protocol=2.0,resource=1.0" \
      -H "Accept-Encoding: gzip, deflate" \
      -H "Accept-Language: en-US" \
      -H "Cache-Control: no-cache" \
      -H "iPlanetDirectoryPro: $ADMIN_TOKEN" \
      -H "Connection: keep-alive" \
      -H "Content-Type: application/json" \
      -H "Host: am.example.com:8081" \
      -H "If-Match: *" \
      -H "Origin: http://am.example.com:8081" \
      -H "Referer: http://am.example.com:8081/am/ui-admin/" \
      -H "User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36 Edg/135.0.0.0" \
      -H "X-Requested-With: XMLHttpRequest" \
      -d '{"_id":"end-user-ui","overrideOAuth2ClientConfig":{"issueRefreshToken":true,"validateScopePluginType":"PROVIDER","tokenEncryptionEnabled":false,"evaluateScopePluginType":"PROVIDER","oidcMayActScript":"[Empty]","oidcClaimsScript":"[Empty]","scopesPolicySet":"oauth2Scopes","accessTokenModificationPluginType":"PROVIDER","authorizeEndpointDataProviderClass":"org.forgerock.oauth2.core.plugins.registry.DefaultEndpointDataProvider","useForceAuthnForMaxAge":false,"oidcClaimsPluginType":"PROVIDER","providerOverridesEnabled":false,"authorizeEndpointDataProviderScript":"[Empty]","statelessTokensEnabled":false,"authorizeEndpointDataProviderPluginType":"PROVIDER","remoteConsentServiceId":null,"enableRemoteConsent":false,"validateScopeClass":"org.forgerock.oauth2.core.plugins.registry.DefaultScopeValidator","usePolicyEngineForScope":false,"evaluateScopeClass":"org.forgerock.oauth2.core.plugins.registry.DefaultScopeEvaluator","overrideableOIDCClaims":[],"accessTokenMayActScript":"[Empty]","evaluateScopeScript":"[Empty]","clientsCanSkipConsent":false,"accessTokenModificationScript":"[Empty]","issueRefreshTokenOnRefreshedToken":true,"validateScopeScript":"[Empty]"},"advancedOAuth2ClientConfig":{"logoUri":{"inherited":false,"value":[]},"subjectType":{"inherited":false,"value":"public"},"clientUri":{"inherited":false,"value":[]},"tokenExchangeAuthLevel":{"inherited":false,"value":0},"responseTypes":{"inherited":false,"value":["code","token","id_token","code token","token id_token","code id_token","code token id_token","device_code","device_code id_token"]},"mixUpMitigation":{"inherited":false,"value":false},"customProperties":{"inherited":false,"value":[]},"javascriptOrigins":{"inherited":false,"value":[]},"policyUri":{"inherited":false,"value":[]},"softwareVersion":{"inherited":false},"tosURI":{"inherited":false,"value":[]},"sectorIdentifierUri":{"inherited":false},"tokenEndpointAuthMethod":{"inherited":false,"value":"client_secret_basic"},"refreshTokenGracePeriod":{"inherited":false,"value":0},"isConsentImplied":{"inherited":false,"value":false},"softwareIdentity":{"inherited":false},"grantTypes":{"inherited":false,"value":["authorization_code"]},"require_pushed_authorization_requests":{"inherited":false,"value":false},"descriptions":{"inherited":false,"value":[]},"requestUris":{"inherited":false,"value":[]},"name":{"inherited":false,"value":[]},"contacts":{"inherited":false,"value":[]},"updateAccessToken":{"inherited":false}},"signEncOAuth2ClientConfig":{"tokenEndpointAuthSigningAlgorithm":{"inherited":false,"value":"RS256"},"idTokenEncryptionEnabled":{"inherited":false,"value":false},"tokenIntrospectionEncryptedResponseEncryptionAlgorithm":{"inherited":false,"value":"A128CBC-HS256"},"requestParameterSignedAlg":{"inherited":false},"authorizationResponseSigningAlgorithm":{"inherited":false,"value":"RS256"},"clientJwtPublicKey":{"inherited":false},"idTokenPublicEncryptionKey":{"inherited":false},"mTLSSubjectDN":{"inherited":false},"jwkStoreCacheMissCacheTime":{"inherited":false,"value":60000},"jwkSet":{"inherited":false},"idTokenEncryptionMethod":{"inherited":false,"value":"A128CBC-HS256"},"jwksUri":{"inherited":false},"tokenIntrospectionEncryptedResponseAlg":{"inherited":false,"value":"RSA-OAEP-256"},"authorizationResponseEncryptionMethod":{"inherited":false},"userinfoResponseFormat":{"inherited":false,"value":"JSON"},"mTLSCertificateBoundAccessTokens":{"inherited":false,"value":false},"publicKeyLocation":{"inherited":false,"value":"jwks_uri"},"tokenIntrospectionResponseFormat":{"inherited":false,"value":"JSON"},"requestParameterEncryptedEncryptionAlgorithm":{"inherited":false,"value":"A128CBC-HS256"},"userinfoSignedResponseAlg":{"inherited":false},"idTokenEncryptionAlgorithm":{"inherited":false,"value":"RSA-OAEP-256"},"requestParameterEncryptedAlg":{"inherited":false},"authorizationResponseEncryptionAlgorithm":{"inherited":false},"mTLSTrustedCert":{"inherited":false},"jwksCacheTimeout":{"inherited":false,"value":3600000},"userinfoEncryptedResponseAlg":{"inherited":false},"idTokenSignedResponseAlg":{"inherited":false,"value":"RS256"},"tokenIntrospectionSignedResponseAlg":{"inherited":false,"value":"RS256"},"userinfoEncryptedResponseEncryptionAlgorithm":{"inherited":false,"value":"A128CBC-HS256"}},"coreOAuth2ClientConfig":{"status":{"value":"Active","inherited":false},"scopes":{"value":["openid","fr:idm:*"],"inherited":false},"secretLabelIdentifier":{"value":"","inherited":false},"defaultScopes":{"value":[],"inherited":false},"refreshTokenLifetime":{"value":0,"inherited":false},"loopbackInterfaceRedirection":{"value":false,"inherited":false},"redirectionUris":{"value":["http://enduser.example.com:8888/appAuthHelperRedirect.html","http://enduser.example.com:8888/sessionCheck.html"],"inherited":false},"accessTokenLifetime":{"value":0,"inherited":false},"agentgroup":"","clientType":{"value":"Public","inherited":false},"authorizationCodeLifetime":{"value":0,"inherited":false},"clientName":{"value":[],"inherited":false}},"coreOpenIDClientConfig":{"claims":{"inherited":false,"value":[]},"backchannel_logout_uri":{"inherited":false},"defaultAcrValues":{"inherited":false,"value":[]},"jwtTokenLifetime":{"inherited":false,"value":0},"defaultMaxAgeEnabled":{"inherited":false,"value":false},"clientSessionUri":{"inherited":false},"defaultMaxAge":{"inherited":false,"value":600},"postLogoutRedirectUri":{"inherited":false,"value":[]},"backchannel_logout_session_required":{"inherited":false,"value":false}},"coreUmaClientConfig":{"claimsRedirectionUris":{"inherited":false,"value":[]}},"_type":{"_id":"OAuth2Client","name":"OAuth2 Clients","collection":true}}' \
      -o /vagrant/curl_response.json \
      -v 2>> /vagrant/curl_error.log

    # Check the curl exit status
    if [ $? -ne 0 ]; then
      echo "curl request failed. Check /vagrant/curl_error.log for details."
      exit 1
    fi

    # Log completion
    echo "Request completed at $(date)" >> /vagrant/curl_request.log

#### update end-user-ui in alpha advcanced tab
sudo echo "starting end-user-ui in alpha advcanced tab"
  # Make the HTTP PUT request to update end-user-ui OAuth2 client
    curl -X PUT "http://am.example.com:8081/am/json/realms/root/realms/alpha/realm-config/agents/OAuth2Client/end-user-ui" \
      -H "Accept: application/json, text/javascript, */*; q=0.01" \
      -H "Accept-API-Version: protocol=2.0,resource=1.0" \
      -H "Accept-Encoding: gzip, deflate" \
      -H "Accept-Language: en-US" \
      -H "Cache-Control: no-cache" \
      -H "Connection: keep-alive" \
      -H "iPlanetDirectoryPro: $ADMIN_TOKEN" \
      -H "Content-Type: application/json" \
      -H "Host: am.example.com:8081" \
      -H "If-Match: *" \
      -H "Origin: http://am.example.com:8081" \
      -H "Referer: http://am.example.com:8081/am/ui-admin/" \
      -H "User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36 Edg/135.0.0.0" \
      -H "X-Requested-With: XMLHttpRequest" \
      -d '{"_id":"end-user-ui","overrideOAuth2ClientConfig":{"issueRefreshToken":true,"validateScopePluginType":"PROVIDER","tokenEncryptionEnabled":false,"evaluateScopePluginType":"PROVIDER","oidcMayActScript":"[Empty]","oidcClaimsScript":"[Empty]","scopesPolicySet":"oauth2Scopes","accessTokenModificationPluginType":"PROVIDER","authorizeEndpointDataProviderClass":"org.forgerock.oauth2.core.plugins.registry.DefaultEndpointDataProvider","useForceAuthnForMaxAge":false,"oidcClaimsPluginType":"PROVIDER","providerOverridesEnabled":false,"authorizeEndpointDataProviderScript":"[Empty]","statelessTokensEnabled":false,"authorizeEndpointDataProviderPluginType":"PROVIDER","remoteConsentServiceId":null,"enableRemoteConsent":false,"validateScopeClass":"org.forgerock.oauth2.core.plugins.registry.DefaultScopeValidator","usePolicyEngineForScope":false,"evaluateScopeClass":"org.forgerock.oauth2.core.plugins.registry.DefaultScopeEvaluator","overrideableOIDCClaims":[],"accessTokenMayActScript":"[Empty]","evaluateScopeScript":"[Empty]","clientsCanSkipConsent":false,"accessTokenModificationScript":"[Empty]","issueRefreshTokenOnRefreshedToken":true,"validateScopeScript":"[Empty]"},"advancedOAuth2ClientConfig":{"softwareVersion":{"value":"","inherited":false},"logoUri":{"value":[],"inherited":false},"requestUris":{"value":[],"inherited":false},"require_pushed_authorization_requests":{"value":false,"inherited":false},"sectorIdentifierUri":{"value":"","inherited":false},"contacts":{"value":[],"inherited":false},"name":{"value":[],"inherited":false},"policyUri":{"value":[],"inherited":false},"clientUri":{"value":[],"inherited":false},"grantTypes":{"value":["authorization_code","implicit"],"inherited":false},"tokenExchangeAuthLevel":{"value":0,"inherited":false},"descriptions":{"value":[],"inherited":false},"subjectType":{"value":"public","inherited":false},"isConsentImplied":{"value":true,"inherited":false},"tosURI":{"value":[],"inherited":false},"javascriptOrigins":{"value":[],"inherited":false},"tokenEndpointAuthMethod":{"value":"none","inherited":false},"softwareIdentity":{"value":"","inherited":false},"responseTypes":{"value":["code","token","id_token","code token","token id_token","code id_token","code token id_token","device_code","device_code id_token"],"inherited":false},"mixUpMitigation":{"value":false,"inherited":false},"updateAccessToken":{"value":"","inherited":false},"customProperties":{"value":[],"inherited":false},"refreshTokenGracePeriod":{"value":0,"inherited":false}},"signEncOAuth2ClientConfig":{"tokenEndpointAuthSigningAlgorithm":{"inherited":false,"value":"RS256"},"idTokenEncryptionEnabled":{"inherited":false,"value":false},"tokenIntrospectionEncryptedResponseEncryptionAlgorithm":{"inherited":false,"value":"A128CBC-HS256"},"requestParameterSignedAlg":{"inherited":false},"authorizationResponseSigningAlgorithm":{"inherited":false,"value":"RS256"},"clientJwtPublicKey":{"inherited":false},"idTokenPublicEncryptionKey":{"inherited":false},"mTLSSubjectDN":{"inherited":false},"jwkStoreCacheMissCacheTime":{"inherited":false,"value":60000},"jwkSet":{"inherited":false},"idTokenEncryptionMethod":{"inherited":false,"value":"A128CBC-HS256"},"jwksUri":{"inherited":false},"tokenIntrospectionEncryptedResponseAlg":{"inherited":false,"value":"RSA-OAEP-256"},"authorizationResponseEncryptionMethod":{"inherited":false},"userinfoResponseFormat":{"inherited":false,"value":"JSON"},"mTLSCertificateBoundAccessTokens":{"inherited":false,"value":false},"publicKeyLocation":{"inherited":false,"value":"jwks_uri"},"tokenIntrospectionResponseFormat":{"inherited":false,"value":"JSON"},"requestParameterEncryptedEncryptionAlgorithm":{"inherited":false,"value":"A128CBC-HS256"},"userinfoSignedResponseAlg":{"inherited":false},"idTokenEncryptionAlgorithm":{"inherited":false,"value":"RSA-OAEP-256"},"requestParameterEncryptedAlg":{"inherited":false},"authorizationResponseEncryptionAlgorithm":{"inherited":false},"mTLSTrustedCert":{"inherited":false},"jwksCacheTimeout":{"inherited":false,"value":3600000},"userinfoEncryptedResponseAlg":{"inherited":false},"idTokenSignedResponseAlg":{"inherited":false,"value":"RS256"},"tokenIntrospectionSignedResponseAlg":{"inherited":false,"value":"RS256"},"userinfoEncryptedResponseEncryptionAlgorithm":{"inherited":false,"value":"A128CBC-HS256"}},"coreOAuth2ClientConfig":{"secretLabelIdentifier":{"inherited":false},"status":{"inherited":false,"value":"Active"},"clientName":{"inherited":false,"value":[]},"clientType":{"inherited":false,"value":"Public"},"loopbackInterfaceRedirection":{"inherited":false,"value":false},"defaultScopes":{"inherited":false,"value":[]},"refreshTokenLifetime":{"inherited":false,"value":0},"scopes":{"inherited":false,"value":["openid","fr:idm:*"]},"accessTokenLifetime":{"inherited":false,"value":0},"redirectionUris":{"inherited":false,"value":["http://enduser.example.com:8888/appAuthHelperRedirect.html","http://enduser.example.com:8888/sessionCheck.html"]},"authorizationCodeLifetime":{"inherited":false,"value":0}},"coreOpenIDClientConfig":{"claims":{"inherited":false,"value":[]},"backchannel_logout_uri":{"inherited":false},"defaultAcrValues":{"inherited":false,"value":[]},"jwtTokenLifetime":{"inherited":false,"value":0},"defaultMaxAgeEnabled":{"inherited":false,"value":false},"clientSessionUri":{"inherited":false},"defaultMaxAge":{"inherited":false,"value":600},"postLogoutRedirectUri":{"inherited":false,"value":[]},"backchannel_logout_session_required":{"inherited":false,"value":false}},"coreUmaClientConfig":{"claimsRedirectionUris":{"inherited":false,"value":[]}},"_type":{"_id":"OAuth2Client","name":"OAuth2 Clients","collection":true}}' \
      -o /vagrant/curl_response.json \
      -v 2>> /vagrant/curl_error.log

    # Check the curl exit status
    if [ $? -ne 0 ]; then
      echo "curl request failed. Check /vagrant/curl_error.log for details."
      exit 1
    fi

    # Log completion
    echo "Request completed at $(date)" >> /vagrant/curl_request.log

#### update end-user-ui in root advcanced tab
sudo echo "starting update end-user-ui in root advcanced tab"
 # Make the HTTP PUT request to update end-user-ui OAuth2 client
    curl -X PUT "http://am.example.com:8081/am/json/realms/root/realm-config/agents/OAuth2Client/end-user-ui" \
      -H "Accept: application/json, text/javascript, */*; q=0.01" \
      -H "Accept-API-Version: protocol=2.0,resource=1.0" \
      -H "Accept-Encoding: gzip, deflate" \
      -H "Accept-Language: en-US" \
      -H "Cache-Control: no-cache" \
      -H "Connection: keep-alive" \
      -H "iPlanetDirectoryPro: $ADMIN_TOKEN" \
      -H "Content-Type: application/json" \
      -H "Host: am.example.com:8081" \
      -H "If-Match: *" \
      -H "Origin: http://am.example.com:8081" \
      -H "Referer: http://am.example.com:8081/am/ui-admin/" \
      -H "User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36 Edg/135.0.0.0" \
      -H "X-Requested-With: XMLHttpRequest" \
      -d '{"_id":"end-user-ui","overrideOAuth2ClientConfig":{"issueRefreshToken":true,"validateScopePluginType":"PROVIDER","tokenEncryptionEnabled":false,"evaluateScopePluginType":"PROVIDER","oidcMayActScript":"[Empty]","oidcClaimsScript":"[Empty]","scopesPolicySet":"oauth2Scopes","accessTokenModificationPluginType":"PROVIDER","authorizeEndpointDataProviderClass":"org.forgerock.oauth2.core.plugins.registry.DefaultEndpointDataProvider","useForceAuthnForMaxAge":false,"oidcClaimsPluginType":"PROVIDER","providerOverridesEnabled":false,"authorizeEndpointDataProviderScript":"[Empty]","statelessTokensEnabled":false,"authorizeEndpointDataProviderPluginType":"PROVIDER","remoteConsentServiceId":null,"enableRemoteConsent":false,"validateScopeClass":"org.forgerock.oauth2.core.plugins.registry.DefaultScopeValidator","usePolicyEngineForScope":false,"evaluateScopeClass":"org.forgerock.oauth2.core.plugins.registry.DefaultScopeEvaluator","overrideableOIDCClaims":[],"accessTokenMayActScript":"[Empty]","evaluateScopeScript":"[Empty]","clientsCanSkipConsent":false,"accessTokenModificationScript":"[Empty]","issueRefreshTokenOnRefreshedToken":true,"validateScopeScript":"[Empty]"},"advancedOAuth2ClientConfig":{"softwareVersion":{"value":"","inherited":false},"logoUri":{"value":[],"inherited":false},"requestUris":{"value":[],"inherited":false},"require_pushed_authorization_requests":{"value":false,"inherited":false},"sectorIdentifierUri":{"value":"","inherited":false},"contacts":{"value":[],"inherited":false},"name":{"value":[],"inherited":false},"policyUri":{"value":[],"inherited":false},"clientUri":{"value":[],"inherited":false},"grantTypes":{"value":["authorization_code","implicit"],"inherited":false},"tokenExchangeAuthLevel":{"value":0,"inherited":false},"descriptions":{"value":[],"inherited":false},"subjectType":{"value":"public","inherited":false},"isConsentImplied":{"value":true,"inherited":false},"tosURI":{"value":[],"inherited":false},"javascriptOrigins":{"value":[],"inherited":false},"tokenEndpointAuthMethod":{"value":"none","inherited":false},"softwareIdentity":{"value":"","inherited":false},"responseTypes":{"value":["code","token","id_token","code token","token id_token","code id_token","code token id_token","device_code","device_code id_token"],"inherited":false},"mixUpMitigation":{"value":false,"inherited":false},"updateAccessToken":{"value":"","inherited":false},"customProperties":{"value":[],"inherited":false},"refreshTokenGracePeriod":{"value":0,"inherited":false}},"signEncOAuth2ClientConfig":{"tokenEndpointAuthSigningAlgorithm":{"inherited":false,"value":"RS256"},"idTokenEncryptionEnabled":{"inherited":false,"value":false},"tokenIntrospectionEncryptedResponseEncryptionAlgorithm":{"inherited":false,"value":"A128CBC-HS256"},"requestParameterSignedAlg":{"inherited":false},"authorizationResponseSigningAlgorithm":{"inherited":false,"value":"RS256"},"clientJwtPublicKey":{"inherited":false},"idTokenPublicEncryptionKey":{"inherited":false},"mTLSSubjectDN":{"inherited":false},"jwkStoreCacheMissCacheTime":{"inherited":false,"value":60000},"jwkSet":{"inherited":false},"idTokenEncryptionMethod":{"inherited":false,"value":"A128CBC-HS256"},"jwksUri":{"inherited":false},"tokenIntrospectionEncryptedResponseAlg":{"inherited":false,"value":"RSA-OAEP-256"},"authorizationResponseEncryptionMethod":{"inherited":false},"userinfoResponseFormat":{"inherited":false,"value":"JSON"},"mTLSCertificateBoundAccessTokens":{"inherited":false,"value":false},"publicKeyLocation":{"inherited":false,"value":"jwks_uri"},"tokenIntrospectionResponseFormat":{"inherited":false,"value":"JSON"},"requestParameterEncryptedEncryptionAlgorithm":{"inherited":false,"value":"A128CBC-HS256"},"userinfoSignedResponseAlg":{"inherited":false},"idTokenEncryptionAlgorithm":{"inherited":false,"value":"RSA-OAEP-256"},"requestParameterEncryptedAlg":{"inherited":false},"authorizationResponseEncryptionAlgorithm":{"inherited":false},"mTLSTrustedCert":{"inherited":false},"jwksCacheTimeout":{"inherited":false,"value":3600000},"userinfoEncryptedResponseAlg":{"inherited":false},"idTokenSignedResponseAlg":{"inherited":false,"value":"RS256"},"tokenIntrospectionSignedResponseAlg":{"inherited":false,"value":"RS256"},"userinfoEncryptedResponseEncryptionAlgorithm":{"inherited":false,"value":"A128CBC-HS256"}},"coreOAuth2ClientConfig":{"secretLabelIdentifier":{"inherited":false},"status":{"inherited":false,"value":"Active"},"clientName":{"inherited":false,"value":[]},"clientType":{"inherited":false,"value":"Public"},"loopbackInterfaceRedirection":{"inherited":false,"value":false},"defaultScopes":{"inherited":false,"value":[]},"refreshTokenLifetime":{"inherited":false,"value":0},"scopes":{"inherited":false,"value":["openid","fr:idm:*"]},"accessTokenLifetime":{"inherited":false,"value":0},"redirectionUris":{"inherited":false,"value":["http://enduser.example.com:8888/appAuthHelperRedirect.html","http://enduser.example.com:8888/sessionCheck.html"]},"authorizationCodeLifetime":{"inherited":false,"value":0}},"coreOpenIDClientConfig":{"claims":{"inherited":false,"value":[]},"backchannel_logout_uri":{"inherited":false},"defaultAcrValues":{"inherited":false,"value":[]},"jwtTokenLifetime":{"inherited":false,"value":0},"defaultMaxAgeEnabled":{"inherited":false,"value":false},"clientSessionUri":{"inherited":false},"defaultMaxAge":{"inherited":false,"value":600},"postLogoutRedirectUri":{"inherited":false,"value":[]},"backchannel_logout_session_required":{"inherited":false,"value":false}},"coreUmaClientConfig":{"claimsRedirectionUris":{"inherited":false,"value":[]}},"_type":{"_id":"OAuth2Client","name":"OAuth2 Clients","collection":true}}' \
      -o /vagrant/curl_response.json \
      -v 2>> /vagrant/curl_error.log

    # Check the curl exit status
    if [ $? -ne 0 ]; then
      echo "curl request failed. Check /vagrant/curl_error.log for details."
      exit 1
    fi

    # Log completion
    echo "Request completed at $(date)" >> /vagrant/curl_request.log



#### creating Oauth provider in root realm 
sudo echo "starting creating Oauth provider in root realm "
    # Make the HTTP POST request to create OAuth2 provider
    curl -X POST "http://am.example.com:8081/am/json/realms/root/realm-config/services/oauth-oidc?_action=create" \
      -H "Accept: application/json, text/javascript, */*; q=0.01" \
      -H "Accept-API-Version: protocol=1.0,resource=1.0" \
      -H "Accept-Encoding: gzip, deflate" \
      -H "Accept-Language: en-US" \
      -H "Cache-Control: no-cache" \
      -H "iPlanetDirectoryPro: $ADMIN_TOKEN" \
      -H "Connection: keep-alive" \
      -H "Content-Type: application/json" \
      -H "Host: am.example.com:8081" \
      -H "Origin: http://am.example.com:8081" \
      -H "Referer: http://am.example.com:8081/am/ui-admin/" \
      -H "User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36 Edg/135.0.0.0" \
      -H "X-Requested-With: XMLHttpRequest" \
      -d '{"advancedOAuth2Config":{"supportedScopes":["am-introspect-all-tokens","am-introspect-all-tokens-any-realm","fr:idm:*","openid"],"passwordGrantAuthService":"[Empty]","persistentClaims":[]},"advancedOIDCConfig":{"authorisedOpenIdConnectSSOClients":[]},"pluginsConfig":{"oidcClaimsClass":"","accessTokenModifierClass":""}}' \
      -o /vagrant/curl_response.json \
      -v 2>> /vagrant/curl_error.log

    # Check the curl exit status
    if [ $? -ne 0 ]; then
      echo "curl request failed. Check /vagrant/curl_error.log for details."
      exit 1
    fi

    # Log completion
    echo "OAuth2 provider creation request completed at $(date)" >> /vagrant/curl_request.log

##Updating Oauth provider in root realms
sudo echo "starting Updating Oauth provider in root realms"
    # Make the HTTP PUT request to update OAuth2 provider
    curl -X PUT "http://am.example.com:8081/am/json/realms/root/realm-config/services/oauth-oidc" \
      -H "Accept: application/json, text/javascript, */*; q=0.01" \
      -H "Accept-API-Version: protocol=1.0,resource=1.0" \
      -H "Accept-Encoding: gzip, deflate" \
      -H "Accept-Language: en-US" \
      -H "Cache-Control: no-cache" \
      -H "Connection: keep-alive" \
      -H "iPlanetDirectoryPro: $ADMIN_TOKEN" \
      -H "Content-Type: application/json" \
      -H "Host: am.example.com:8081" \
      -H "Origin: http://am.example.com:8081" \
      -H "Referer: http://am.example.com:8081/am/ui-admin/" \
      -H "User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36 Edg/135.0.0.0" \
      -H "X-Requested-With: XMLHttpRequest" \
      -d '{"advancedOIDCConfig":{"supportedRequestParameterEncryptionEnc":["A256GCM","A192GCM","A128GCM","A128CBC-HS256","A192CBC-HS384","A256CBC-HS512"],"authorisedOpenIdConnectSSOClients":[],"supportedUserInfoEncryptionAlgorithms":["ECDH-ES+A256KW","ECDH-ES+A192KW","RSA-OAEP","ECDH-ES+A128KW","RSA-OAEP-256","A128KW","A256KW","ECDH-ES","dir","A192KW"],"supportedAuthorizationResponseEncryptionEnc":["A256GCM","A192GCM","A128GCM","A128CBC-HS256","A192CBC-HS384","A256CBC-HS512"],"supportedTokenIntrospectionResponseEncryptionAlgorithms":["ECDH-ES+A256KW","ECDH-ES+A192KW","RSA-OAEP","ECDH-ES+A128KW","RSA-OAEP-256","A128KW","A256KW","ECDH-ES","dir","A192KW"],"useForceAuthnForPromptLogin":false,"useForceAuthnForMaxAge":false,"alwaysAddClaimsToToken":false,"supportedTokenIntrospectionResponseSigningAlgorithms":["PS384","RS384","EdDSA","ES384","HS256","HS512","ES256","RS256","HS384","ES512","PS256","PS512","RS512"],"supportedTokenEndpointAuthenticationSigningAlgorithms":["PS384","ES384","RS384","HS256","HS512","ES256","RS256","HS384","ES512","PS256","PS512","RS512"],"supportedRequestParameterSigningAlgorithms":["PS384","ES384","RS384","HS256","HS512","ES256","RS256","HS384","ES512","PS256","PS512","RS512"],"includeAllKtyAlgCombinationsInJwksUri":false,"amrMappings":{},"loaMapping":{},"authorisedIdmDelegationClients":[],"idTokenInfoClientAuthenticationEnabled":true,"storeOpsTokens":true,"supportedUserInfoSigningAlgorithms":["ES384","HS256","HS512","ES256","RS256","HS384","ES512"],"supportedAuthorizationResponseSigningAlgorithms":["PS384","RS384","EdDSA","ES384","HS256","HS512","ES256","RS256","HS384","ES512","PS256","PS512","RS512"],"supportedUserInfoEncryptionEnc":["A256GCM","A192GCM","A128GCM","A128CBC-HS256","A192CBC-HS384","A256CBC-HS512"],"claimsParameterSupported":false,"supportedTokenIntrospectionResponseEncryptionEnc":["A256GCM","A192GCM","A128GCM","A128CBC-HS256","A192CBC-HS384","A256CBC-HS512"],"supportedAuthorizationResponseEncryptionAlgorithms":["ECDH-ES+A256KW","ECDH-ES+A192KW","RSA-OAEP","ECDH-ES+A128KW","RSA-OAEP-256","A128KW","A256KW","ECDH-ES","dir","A192KW"],"supportedRequestParameterEncryptionAlgorithms":["ECDH-ES+A256KW","ECDH-ES+A192KW","ECDH-ES+A128KW","RSA-OAEP","RSA-OAEP-256","A128KW","A256KW","ECDH-ES","dir","A192KW"],"defaultACR":[]},"advancedOAuth2Config":{"passwordGrantAuthService":"[Empty]","tokenCompressionEnabled":false,"tokenEncryptionEnabled":false,"requirePushedAuthorizationRequests":false,"tlsCertificateBoundAccessTokensEnabled":true,"includeSubnameInTokenClaims":true,"defaultScopes":[],"moduleMessageEnabledInPasswordGrant":false,"allowClientCredentialsInTokenRequestQueryParameters":false,"supportedSubjectTypes":["public","pairwise"],"refreshTokenGracePeriod":0,"tlsClientCertificateHeaderFormat":"URLENCODED_PEM","hashSalt":"changeme","macaroonTokenFormat":"V2","maxAgeOfRequestObjectNbfClaim":0,"tlsCertificateRevocationCheckingEnabled":false,"nbfClaimRequiredInRequestObject":false,"requestObjectProcessing":"OIDC","maxDifferenceBetweenRequestObjectNbfAndExp":0,"responseTypeClasses":["code|org.forgerock.oauth2.core.AuthorizationCodeResponseTypeHandler","id_token|org.forgerock.openidconnect.IdTokenResponseTypeHandler","token|org.forgerock.oauth2.core.TokenResponseTypeHandler"],"expClaimRequiredInRequestObject":false,"tokenValidatorClasses":["urn:ietf:params:oauth:token-type:id_token|org.forgerock.oauth2.core.tokenexchange.idtoken.OidcIdTokenValidator","urn:ietf:params:oauth:token-type:access_token|org.forgerock.oauth2.core.tokenexchange.accesstoken.OAuth2AccessTokenValidator"],"tokenSigningAlgorithm":"HS256","codeVerifierEnforced":"false","displayNameAttribute":"cn","tokenExchangeClasses":["urn:ietf:params:oauth:token-type:access_token=>urn:ietf:params:oauth:token-type:access_token|org.forgerock.oauth2.core.tokenexchange.accesstoken.AccessTokenToAccessTokenExchanger","urn:ietf:params:oauth:token-type:id_token=>urn:ietf:params:oauth:token-type:id_token|org.forgerock.oauth2.core.tokenexchange.idtoken.IdTokenToIdTokenExchanger","urn:ietf:params:oauth:token-type:access_token=>urn:ietf:params:oauth:token-type:id_token|org.forgerock.oauth2.core.tokenexchange.accesstoken.AccessTokenToIdTokenExchanger","urn:ietf:params:oauth:token-type:id_token=>urn:ietf:params:oauth:token-type:access_token|org.forgerock.oauth2.core.tokenexchange.idtoken.IdTokenToAccessTokenExchanger"],"parRequestUriLifetime":90,"allowedAudienceValues":[],"persistentClaims":[],"supportedScopes":["am-introspect-all-tokens","am-introspect-all-tokens-any-realm","fr:idm:*","openid"],"authenticationAttributes":["uid"],"grantTypes":["implicit","urn:ietf:params:oauth:grant-type:saml2-bearer","refresh_token","password","client_credentials","urn:ietf:params:oauth:grant-type:device_code","authorization_code","urn:openid:params:grant-type:ciba","urn:ietf:params:oauth:grant-type:uma-ticket","urn:ietf:params:oauth:grant-type:token-exchange","urn:ietf:params:oauth:grant-type:jwt-bearer"]},"clientDynamicRegistrationConfig":{"dynamicClientRegistrationScope":"dynamic_client_registration","allowDynamicRegistration":false,"requiredSoftwareStatementAttestedAttributes":["redirect_uris"],"dynamicClientRegistrationSoftwareStatementRequired":false,"generateRegistrationAccessTokens":true},"coreOIDCConfig":{"overrideableOIDCClaims":[],"oidcDiscoveryEndpointEnabled":false,"supportedIDTokenEncryptionMethods":["A256GCM","A192GCM","A128GCM","A128CBC-HS256","A192CBC-HS384","A256CBC-HS512"],"supportedClaims":[],"supportedIDTokenSigningAlgorithms":["PS384","ES384","RS384","HS256","HS512","ES256","RS256","HS384","ES512","PS256","PS512","RS512"],"supportedIDTokenEncryptionAlgorithms":["ECDH-ES+A256KW","ECDH-ES+A192KW","RSA-OAEP","ECDH-ES+A128KW","RSA-OAEP-256","A128KW","A256KW","ECDH-ES","dir","A192KW"],"jwtTokenLifetime":3600},"coreOAuth2Config":{"refreshTokenLifetime":604800,"scopesPolicySet":"oauth2Scopes","accessTokenMayActScript":"[Empty]","accessTokenLifetime":3600,"macaroonTokensEnabled":false,"codeLifetime":120,"statelessTokensEnabled":false,"usePolicyEngineForScope":false,"issueRefreshToken":true,"oidcMayActScript":"[Empty]","issueRefreshTokenOnRefreshedToken":true},"consent":{"savedConsentAttribute":"","supportedRcsRequestEncryptionMethods":["A256GCM","A192GCM","A128GCM","A128CBC-HS256","A192CBC-HS384","A256CBC-HS512"],"clientsCanSkipConsent":true,"remoteConsentServiceId":"[Empty]","enableRemoteConsent":false,"supportedRcsRequestEncryptionAlgorithms":["ECDH-ES+A256KW","ECDH-ES+A192KW","RSA-OAEP","ECDH-ES+A128KW","RSA-OAEP-256","A128KW","A256KW","ECDH-ES","dir","A192KW"],"supportedRcsRequestSigningAlgorithms":["PS384","ES384","RS384","HS256","HS512","ES256","RS256","HS384","ES512","PS256","PS512","RS512"],"supportedRcsResponseEncryptionMethods":["A256GCM","A192GCM","A128GCM","A128CBC-HS256","A192CBC-HS384","A256CBC-HS512"],"supportedRcsResponseSigningAlgorithms":["PS384","ES384","RS384","HS256","HS512","ES256","RS256","HS384","ES512","PS256","PS512","RS512"],"supportedRcsResponseEncryptionAlgorithms":["ECDH-ES+A256KW","ECDH-ES+A192KW","ECDH-ES+A128KW","RSA-OAEP","RSA-OAEP-256","A128KW","A256KW","ECDH-ES","dir","A192KW"]},"deviceCodeConfig":{"deviceUserCodeLength":8,"deviceCodeLifetime":300,"deviceUserCodeCharacterSet":"234567ACDEFGHJKLMNPQRSTWXYZabcdefhijkmnopqrstwxyz","devicePollInterval":5},"pluginsConfig":{"evaluateScopeClass":"org.forgerock.oauth2.core.plugins.registry.DefaultScopeEvaluator","validateScopeScript":"25e6c06d-cf70-473b-bd28-26931edc476b","accessTokenEnricherClass":"org.forgerock.oauth2.core.plugins.registry.DefaultAccessTokenEnricher","oidcClaimsPluginType":"SCRIPTED","authorizeEndpointDataProviderClass":"org.forgerock.oauth2.core.plugins.registry.DefaultEndpointDataProvider","authorizeEndpointDataProviderPluginType":"JAVA","userCodeGeneratorClass":"org.forgerock.oauth2.core.plugins.registry.DefaultUserCodeGenerator","evaluateScopeScript":"da56fe60-8b38-4c46-a405-d6b306d4b336","evaluateScopePluginType":"JAVA","authorizeEndpointDataProviderScript":"3f93ef6e-e54a-4393-aba1-f322656db28a","accessTokenModificationScript":"d22f9a0c-426a-4466-b95e-d0f125b0d5fa","validateScopePluginType":"JAVA","accessTokenModificationPluginType":"SCRIPTED","oidcClaimsScript":"36863ffb-40ec-48b9-94b1-9a99f71cc3b5","validateScopeClass":"org.forgerock.oauth2.core.plugins.registry.DefaultScopeValidator"},"cibaConfig":{"cibaMinimumPollingInterval":2,"supportedCibaSigningAlgorithms":["ES256","PS256"],"cibaAuthReqIdLifetime":600},"_id":"","_type":{"_id":"oauth-oidc","name":"OAuth2 Provider","collection":false}}' \
      -o /vagrant/curl_response.json \
      -v 2>> /vagrant/curl_error.log

    # Check the curl exit status
    if [ $? -ne 0 ]; then
      echo "curl request failed. Check /vagrant/curl_error.log for details."
      exit 1
    fi

    # Log completion
    echo "OAuth2 provider update request completed at $(date)" >> /vagrant/curl_request.log

#### creating Oauth provider in aplah realm 
sudo echo "starting Oauth provider in aplah realm"
    # Make the HTTP POST request to create OAuth2 provider
    curl -X POST "http://am.example.com:8081/am/json/realms/root/realms/alpha/realm-config/services/oauth-oidc?_action=create" \
      -H "Accept: application/json, text/javascript, */*; q=0.01" \
      -H "Accept-API-Version: protocol=1.0,resource=1.0" \
      -H "Accept-Encoding: gzip, deflate" \
      -H "Accept-Language: en-US" \
      -H "Cache-Control: no-cache" \
      -H "iPlanetDirectoryPro: $ADMIN_TOKEN" \
      -H "Connection: keep-alive" \
      -H "Content-Type: application/json" \
      -H "Host: am.example.com:8081" \
      -H "Origin: http://am.example.com:8081" \
      -H "Referer: http://am.example.com:8081/am/ui-admin/" \
      -H "User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36 Edg/135.0.0.0" \
      -H "X-Requested-With: XMLHttpRequest" \
      -d '{"advancedOAuth2Config":{"supportedScopes":["fr:idm:*","openid"],"passwordGrantAuthService":"[Empty]","persistentClaims":[]},"advancedOIDCConfig":{"authorisedOpenIdConnectSSOClients":[]},"pluginsConfig":{"oidcClaimsClass":"","accessTokenModifierClass":""}}' \
      -o /vagrant/curl_response.json \
      -v 2>> /vagrant/curl_error.log

    # Check the curl exit status
    if [ $? -ne 0 ]; then
      echo "curl request failed. Check /vagrant/curl_error.log for details."
      exit 1
    fi

    # Log completion
    echo "OAuth2 provider creation request completed at $(date)" >> /vagrant/curl_request.log

#### updating Oauth provider in aplah realm 
sudo echo "starting updating Oauth provider in aplah realm"
 # Make the HTTP PUT request to update OAuth2 provider in alpha realm
    curl -X PUT "http://am.example.com:8081/am/json/realms/root/realms/alpha/realm-config/services/oauth-oidc" \
      -H "Accept: application/json, text/javascript, */*; q=0.01" \
      -H "Accept-API-Version: protocol=1.0,resource=1.0" \
      -H "Accept-Encoding: gzip, deflate" \
      -H "Accept-Language: en-US" \
      -H "Cache-Control: no-cache" \
      -H "Connection: keep-alive" \
      -H "Content-Type: application/json" \
      -H "Host: am.example.com:8081" \
      -H "iPlanetDirectoryPro: $ADMIN_TOKEN" \
      -H "Origin: http://am.example.com:8081" \
      -H "Referer: http://am.example.com:8081/am/ui-admin/" \
      -H "User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36 Edg/135.0.0.0" \
      -H "X-Requested-With: XMLHttpRequest" \
      -d '{"advancedOIDCConfig":{"supportedRequestParameterEncryptionEnc":["A256GCM","A192GCM","A128GCM","A128CBC-HS256","A192CBC-HS384","A256CBC-HS512"],"authorisedOpenIdConnectSSOClients":[],"supportedUserInfoEncryptionAlgorithms":["ECDH-ES+A256KW","ECDH-ES+A192KW","RSA-OAEP","ECDH-ES+A128KW","RSA-OAEP-256","A128KW","A256KW","ECDH-ES","dir","A192KW"],"supportedAuthorizationResponseEncryptionEnc":["A256GCM","A192GCM","A128GCM","A128CBC-HS256","A192CBC-HS384","A256CBC-HS512"],"supportedTokenIntrospectionResponseEncryptionAlgorithms":["ECDH-ES+A256KW","ECDH-ES+A192KW","RSA-OAEP","ECDH-ES+A128KW","RSA-OAEP-256","A128KW","A256KW","ECDH-ES","dir","A192KW"],"useForceAuthnForPromptLogin":false,"useForceAuthnForMaxAge":false,"alwaysAddClaimsToToken":false,"supportedTokenIntrospectionResponseSigningAlgorithms":["PS384","RS384","EdDSA","ES384","HS256","HS512","ES256","RS256","HS384","ES512","PS256","PS512","RS512"],"supportedTokenEndpointAuthenticationSigningAlgorithms":["PS384","ES384","RS384","HS256","HS512","ES256","RS256","HS384","ES512","PS256","PS512","RS512"],"supportedRequestParameterSigningAlgorithms":["PS384","ES384","RS384","HS256","HS512","ES256","RS256","HS384","ES512","PS256","PS512","RS512"],"includeAllKtyAlgCombinationsInJwksUri":false,"amrMappings":{},"loaMapping":{},"authorisedIdmDelegationClients":[],"idTokenInfoClientAuthenticationEnabled":true,"storeOpsTokens":true,"supportedUserInfoSigningAlgorithms":["ES384","HS256","HS512","ES256","RS256","HS384","ES512"],"supportedAuthorizationResponseSigningAlgorithms":["PS384","RS384","EdDSA","ES384","HS256","HS512","ES256","RS256","HS384","ES512","PS256","PS512","RS512"],"supportedUserInfoEncryptionEnc":["A256GCM","A192GCM","A128GCM","A128CBC-HS256","A192CBC-HS384","A256CBC-HS512"],"claimsParameterSupported":false,"supportedTokenIntrospectionResponseEncryptionEnc":["A256GCM","A192GCM","A128GCM","A128CBC-HS256","A192CBC-HS384","A256CBC-HS512"],"supportedAuthorizationResponseEncryptionAlgorithms":["ECDH-ES+A256KW","ECDH-ES+A192KW","RSA-OAEP","ECDH-ES+A128KW","RSA-OAEP-256","A128KW","A256KW","ECDH-ES","dir","A192KW"],"supportedRequestParameterEncryptionAlgorithms":["ECDH-ES+A256KW","ECDH-ES+A192KW","ECDH-ES+A128KW","RSA-OAEP","RSA-OAEP-256","A128KW","A256KW","ECDH-ES","dir","A192KW"],"defaultACR":[]},"advancedOAuth2Config":{"passwordGrantAuthService":"[Empty]","tokenCompressionEnabled":false,"tokenEncryptionEnabled":false,"requirePushedAuthorizationRequests":false,"tlsCertificateBoundAccessTokensEnabled":true,"includeSubnameInTokenClaims":true,"defaultScopes":[],"moduleMessageEnabledInPasswordGrant":false,"allowClientCredentialsInTokenRequestQueryParameters":false,"supportedSubjectTypes":["public","pairwise"],"refreshTokenGracePeriod":0,"tlsClientCertificateHeaderFormat":"URLENCODED_PEM","hashSalt":"changeme","macaroonTokenFormat":"V2","maxAgeOfRequestObjectNbfClaim":0,"tlsCertificateRevocationCheckingEnabled":false,"nbfClaimRequiredInRequestObject":false,"requestObjectProcessing":"OIDC","maxDifferenceBetweenRequestObjectNbfAndExp":0,"responseTypeClasses":["code|org.forgerock.oauth2.core.AuthorizationCodeResponseTypeHandler","id_token|org.forgerock.openidconnect.IdTokenResponseTypeHandler","token|org.forgerock.oauth2.core.TokenResponseTypeHandler"],"expClaimRequiredInRequestObject":false,"tokenValidatorClasses":["urn:ietf:params:oauth:token-type:id_token|org.forgerock.oauth2.core.tokenexchange.idtoken.OidcIdTokenValidator","urn:ietf:params:oauth:token-type:access_token|org.forgerock.oauth2.core.tokenexchange.accesstoken.OAuth2AccessTokenValidator"],"tokenSigningAlgorithm":"HS256","codeVerifierEnforced":"false","displayNameAttribute":"cn","tokenExchangeClasses":["urn:ietf:params:oauth:token-type:access_token=>urn:ietf:params:oauth:token-type:access_token|org.forgerock.oauth2.core.tokenexchange.accesstoken.AccessTokenToAccessTokenExchanger","urn:ietf:params:oauth:token-type:id_token=>urn:ietf:params:oauth:token-type:id_token|org.forgerock.oauth2.core.tokenexchange.idtoken.IdTokenToIdTokenExchanger","urn:ietf:params:oauth:token-type:access_token=>urn:ietf:params:oauth:token-type:id_token|org.forgerock.oauth2.core.tokenexchange.accesstoken.AccessTokenToIdTokenExchanger","urn:ietf:params:oauth:token-type:id_token=>urn:ietf:params:oauth:token-type:access_token|org.forgerock.oauth2.core.tokenexchange.idtoken.IdTokenToAccessTokenExchanger"],"parRequestUriLifetime":90,"allowedAudienceValues":[],"persistentClaims":[],"supportedScopes":["fr:idm:*","openid"],"authenticationAttributes":["uid"],"grantTypes":["implicit","urn:ietf:params:oauth:grant-type:saml2-bearer","refresh_token","password","client_credentials","urn:ietf:params:oauth:grant-type:device_code","authorization_code","urn:openid:params:grant-type:ciba","urn:ietf:params:oauth:grant-type:uma-ticket","urn:ietf:params:oauth:grant-type:token-exchange","urn:ietf:params:oauth:grant-type:jwt-bearer"]},"clientDynamicRegistrationConfig":{"dynamicClientRegistrationScope":"dynamic_client_registration","allowDynamicRegistration":false,"requiredSoftwareStatementAttestedAttributes":["redirect_uris"],"dynamicClientRegistrationSoftwareStatementRequired":false,"generateRegistrationAccessTokens":true},"coreOIDCConfig":{"overrideableOIDCClaims":[],"oidcDiscoveryEndpointEnabled":false,"supportedIDTokenEncryptionMethods":["A256GCM","A192GCM","A128GCM","A128CBC-HS256","A192CBC-HS384","A256CBC-HS512"],"supportedClaims":[],"supportedIDTokenSigningAlgorithms":["PS384","ES384","RS384","HS256","HS512","ES256","RS256","HS384","ES512","PS256","PS512","RS512"],"supportedIDTokenEncryptionAlgorithms":["ECDH-ES+A256KW","ECDH-ES+A192KW","RSA-OAEP","ECDH-ES+A128KW","RSA-OAEP-256","A128KW","A256KW","ECDH-ES","dir","A192KW"],"jwtTokenLifetime":3600},"coreOAuth2Config":{"refreshTokenLifetime":604800,"scopesPolicySet":"oauth2Scopes","accessTokenMayActScript":"[Empty]","accessTokenLifetime":3600,"macaroonTokensEnabled":false,"codeLifetime":120,"statelessTokensEnabled":false,"usePolicyEngineForScope":false,"issueRefreshToken":true,"oidcMayActScript":"[Empty]","issueRefreshTokenOnRefreshedToken":true},"consent":{"clientsCanSkipConsent":true,"savedConsentAttribute":"","enableRemoteConsent":false,"remoteConsentServiceId":"[Empty]","supportedRcsRequestEncryptionMethods":["A256GCM","A192GCM","A128GCM","A128CBC-HS256","A192CBC-HS384","A256CBC-HS512"],"supportedRcsResponseEncryptionAlgorithms":["ECDH-ES+A256KW","ECDH-ES+A192KW","ECDH-ES+A128KW","RSA-OAEP","RSA-OAEP-256","A128KW","A256KW","ECDH-ES","dir","A192KW"],"supportedRcsResponseEncryptionMethods":["A256GCM","A192GCM","A128GCM","A128CBC-HS256","A192CBC-HS384","A256CBC-HS512"],"supportedRcsRequestEncryptionAlgorithms":["ECDH-ES+A256KW","ECDH-ES+A192KW","RSA-OAEP","ECDH-ES+A128KW","RSA-OAEP-256","A128KW","A256KW","ECDH-ES","dir","A192KW"],"supportedRcsRequestSigningAlgorithms":["PS384","ES384","RS384","HS256","HS512","ES256","RS256","HS384","ES512","PS256","PS512","RS512"],"supportedRcsResponseSigningAlgorithms":["PS384","ES384","RS384","HS256","HS512","ES256","RS256","HS384","ES512","PS256","PS512","RS512"]},"deviceCodeConfig":{"deviceUserCodeLength":8,"deviceCodeLifetime":300,"deviceUserCodeCharacterSet":"234567ACDEFGHJKLMNPQRSTWXYZabcdefhijkmnopqrstwxyz","devicePollInterval":5},"pluginsConfig":{"evaluateScopeClass":"org.forgerock.oauth2.core.plugins.registry.DefaultScopeEvaluator","validateScopeScript":"25e6c06d-cf70-473b-bd28-26931edc476b","accessTokenEnricherClass":"org.forgerock.oauth2.core.plugins.registry.DefaultAccessTokenEnricher","oidcClaimsPluginType":"SCRIPTED","authorizeEndpointDataProviderClass":"org.forgerock.oauth2.core.plugins.registry.DefaultEndpointDataProvider","authorizeEndpointDataProviderPluginType":"JAVA","userCodeGeneratorClass":"org.forgerock.oauth2.core.plugins.registry.DefaultUserCodeGenerator","evaluateScopeScript":"da56fe60-8b38-4c46-a405-d6b306d4b336","evaluateScopePluginType":"JAVA","authorizeEndpointDataProviderScript":"3f93ef6e-e54a-4393-aba1-f322656db28a","accessTokenModificationScript":"d22f9a0c-426a-4466-b95e-d0f125b0d5fa","validateScopePluginType":"JAVA","accessTokenModificationPluginType":"SCRIPTED","oidcClaimsScript":"36863ffb-40ec-48b9-94b1-9a99f71cc3b5","validateScopeClass":"org.forgerock.oauth2.core.plugins.registry.DefaultScopeValidator"},"cibaConfig":{"cibaMinimumPollingInterval":2,"supportedCibaSigningAlgorithms":["ES256","PS256"],"cibaAuthReqIdLifetime":600},"_id":"","_type":{"_id":"oauth-oidc","name":"OAuth2 Provider","collection":false}}' \
      -o /vagrant/curl_response.json \
      -v 2>> /vagrant/curl_error.log

    # Check the curl exit status
    if [ $? -ne 0 ]; then
      echo "curl request failed. Check /vagrant/curl_error.log for details."
      exit 1
    fi

    # Log completion
    echo "OAuth2 provider update request for alpha realm completed at $(date)" >> /vagrant/curl_request.log

#### Configuring IDM provisioning Service 
sudo echo "starting Configuring IDM provisioning Service"
    # Make the HTTP PUT request to update IDM integration service
    curl -X PUT "http://am.example.com:8081/am/json/global-config/services/idm-integration" \
      -H "Accept: application/json, text/javascript, */*; q=0.01" \
      -H "Accept-API-Version: protocol=1.0,resource=1.0" \
      -H "Accept-Encoding: gzip, deflate" \
      -H "iPlanetDirectoryPro: $ADMIN_TOKEN" \
      -H "Accept-Language: en-US" \
      -H "Cache-Control: no-cache" \
      -H "Connection: keep-alive" \
      -H "Content-Type: application/json" \
      -H "Host: am.example.com:8081" \
      -H "Origin: http://am.example.com:8081" \
      -H "Referer: http://am.example.com:8081/am/ui-admin/" \
      -H "User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36 Edg/135.0.0.0" \
      -H "X-Requested-With: XMLHttpRequest" \
      -d '{"provisioningClientScopes":["fr:idm:*"],"enabled":true,"idmProvisioningClient":"idm-provisioning","provisioningSigningAlgorithm":"","provisioningSigningKeyAlias":"","provisioningEncryptionMethod":"","useInternalOAuth2Provider":false,"jwtSigningCompatibilityMode":false,"configurationCacheDuration":0,"idmDeploymentUrl":"http://openidm.example.com:8080","provisioningEncryptionAlgorithm":"","provisioningEncryptionKeyAlias":"","idmDeploymentPath":"openidm","_id":"","_type":{"_id":"idm-integration","name":"IdmIntegrationService","collection":false}}' \
      -o /vagrant/curl_response.json \
      -v 2>> /vagrant/curl_error.log

    # Check the curl exit status
    if [ $? -ne 0 ]; then
      echo "curl request failed. Check /vagrant/curl_error.log for details."
      exit 1
    fi

    # Log completion
    echo "IDM integration service update request completed at $(date)" >> /vagrant/curl_request.log

###Creation of validation service
sudo echo "starting Creation of validation service"
    # Make the HTTP POST request to create Validation Service in alpha realm
    curl -X POST "http://am.example.com:8081/am/json/realms/root/realms/alpha/realm-config/services/validation?_action=create" \
      -H "Accept: application/json, text/javascript, */*; q=0.01" \
      -H "Accept-API-Version: protocol=1.0,resource=1.0" \
      -H "Accept-Encoding: gzip, deflate" \
      -H "Accept-Language: en-US" \
      -H "Cache-Control: no-cache" \
      -H "iPlanetDirectoryPro: $ADMIN_TOKEN" \
      -H "Connection: keep-alive" \
      -H "Content-Type: application/json" \
      -H "Host: am.example.com:8081" \
      -H "Origin: http://am.example.com:8081" \
      -H "Referer: http://am.example.com:8081/am/ui-admin/" \
      -H "User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36 Edg/135.0.0.0" \
      -H "X-Requested-With: XMLHttpRequest" \
      -d '{"validGotoDestinations":["http://admin.example.com:8082/*","http://admin.example.com:8082/*?*","http://login.example.com:8083/*","http://login.example.com:8083/*?*","http://enduser.example.com:8888/*","http://enduser.example.com:8888/*?*"]}' \
      -o /vagrant/curl_response.json \
      -v 2>> /vagrant/curl_error.log

    # Check the curl exit status
    if [ $? -ne 0 ]; then
      echo "curl request failed. Check /vagrant/curl_error.log for details."
      exit 1
    fi

    # Log completion
    echo "Validation Service creation request for alpha realm completed at $(date)" >> /vagrant/curl_request.log

#####  creating cross configuration
sudo echo "starting creating cross configuration"
# Make the HTTP POST request to create CORS Service configuration
    curl -X POST "http://am.example.com:8081/am/json/global-config/services/CorsService/configuration?_action=create" \
      -H "Accept: application/json, text/javascript, */*; q=0.01" \
      -H "Accept-API-Version: protocol=1.0,resource=1.0" \
      -H "Accept-Encoding: gzip, deflate" \
      -H "Accept-Language: en-US" \
      -H "Cache-Control: no-cache" \
      -H "Connection: keep-alive" \
      -H "iPlanetDirectoryPro: $ADMIN_TOKEN" \
      -H "Content-Type: application/json" \
      -H "Host: am.example.com:8081" \
      -H "Origin: http://am.example.com:8081" \
      -H "Referer: http://am.example.com:8081/am/ui-admin/" \
      -H "User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36 Edg/135.0.0.0" \
      -H "X-Requested-With: XMLHttpRequest" \
      -d '{"acceptedOrigins":["http://login.example.com:8083","http://admin.example.com:8082","http://enduser.example.com:8888","http://openidm.example.com:8080","https://openidm.example.com:8443"],"acceptedMethods":["DELETE","GET","HEAD","PATCH","POST","PUT"],"exposedHeaders":["WWW-Authenticate"],"acceptedHeaders":["accept-api-version","authorization","cache-control","content-type","if-match","if-none-match","user-agent","x-forgerock-transactionid","x-openidm-nosession","x-openidm-password","x-openidm-username","x-requested-with"],"_id":"Cors Configuration"}' \
      -o /vagrant/curl_response.json \
      -v 2>> /vagrant/curl_error.log

    # Check the curl exit status
    if [ $? -ne 0 ]; then
      echo "curl request failed. Check /vagrant/curl_error.log for details."
      exit 1
    fi

    # Log completion
    echo "CORS Service configuration creation request completed at $(date)" >> /vagrant/curl_request.log
#####  updating cross configuration
sudo echo "starting updating cross configuration"
 # Make the HTTP PUT request to update CORS Service configuration
    curl -X PUT "http://am.example.com:8081/am/json/global-config/services/CorsService/configuration/Cors%20Configuration" \
      -H "Accept: application/json, text/javascript, */*; q=0.01" \
      -H "Accept-API-Version: protocol=1.0,resource=1.0" \
      -H "Accept-Encoding: gzip, deflate" \
      -H "Accept-Language: en-US" \
      -H "Cache-Control: no-cache" \
      -H "Connection: keep-alive" \
      -H "iPlanetDirectoryPro: $ADMIN_TOKEN" \
      -H "Content-Type: application/json" \
      -H "Host: am.example.com:8081" \
      -H "Origin: http://am.example.com:8081" \
      -H "Referer: http://am.example.com:8081/am/ui-admin/" \
      -H "User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36 Edg/135.0.0.0" \
      -H "X-Requested-With: XMLHttpRequest" \
      -d '{"enabled":true,"acceptedOrigins":["http://login.example.com:8083","http://admin.example.com:8082","http://enduser.example.com:8888","http://openidm.example.com:8080","https://openidm.example.com:8443"],"allowCredentials":true,"acceptedMethods":["DELETE","GET","HEAD","PATCH","POST","PUT"],"acceptedHeaders":["accept-api-version","authorization","cache-control","content-type","if-match","if-none-match","user-agent","x-forgerock-transactionid","x-openidm-nosession","x-openidm-password","x-openidm-username","x-requested-with"],"exposedHeaders":["WWW-Authenticate"],"maxAge":600,"_id":"Cors Configuration","_type":{"_id":"configuration","name":"Cors Configuration","collection":true}}' \
      -o /vagrant/curl_response.json \
      -v 2>> /vagrant/curl_error.log

    # Check the curl exit status
    if [ $? -ne 0 ]; then
      echo "curl request failed. Check /vagrant/curl_error.log for details."
      exit 1
    fi

    # Log completion
    echo "CORS Service configuration update request completed at $(date)" >> /vagrant/curl_request.log

 