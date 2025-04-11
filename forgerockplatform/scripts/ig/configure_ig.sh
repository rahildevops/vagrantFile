# 2. Log In as an Administrator (from Postman collection)
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
###updating the external login url for root realms
 # Make the HTTP PUT request to update authentication configuration
    curl -X PUT "http://am.example.com:8081/am/json/realms/root/realm-config/authentication" \
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
      -d '{"statelessSessionsEnabled":false,"defaultAuthLevel":0,"identityType":["agent","user"],"userStatusCallbackPlugins":[],"locale":"en_US","twoFactorRequired":false,"externalLoginPageUrl":"https://platform.example.com:9443/platform-login"}' \
      -o /vagrant/curl_response.json \
      -v 2>> /vagrant/curl_error.log

    # Check the curl exit status
    if [ $? -ne 0 ]; then
      echo "curl request failed. Check /vagrant/curl_error.log for details."
      exit 1
    fi

    # Log completion
    echo "Authentication configuration update request completed at $(date)" >> /vagrant/curl_request.log
  ####adding the validation service for root realms
    # Make the HTTP POST request to create Validation Service
    curl -X POST "http://am.example.com:8081/am/json/realms/root/realm-config/services/validation?_action=create" \
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
      -d '{"validGotoDestinations":["https://platform.example.com:9443/*","https://platform.example.com:9443/*?*"]}' \
      -o /vagrant/curl_response.json \
      -v 2>> /vagrant/curl_error.log

    # Check the curl exit status
    if [ $? -ne 0 ]; then
      echo "curl request failed. Check /vagrant/curl_error.log for details."
      exit 1
    fi

    # Log completion
    echo "Validation Service creation request completed at $(date)" >> /vagrant/curl_request.log
####creating base url service to root realm
# Make the HTTP POST request to create Base URL Source service
sudo echo "creating base url service"
    curl -X POST "http://am.example.com:8081/am/json/realms/root/realm-config/services/baseurl?_action=create" \
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
      -d '{"fixedValue":"https://platform.example.com:9443","extensionClassName":""}' \
      -o /vagrant/curl_response.json \
      -v 2>> /vagrant/curl_error.log

    # Check the curl exit status
    if [ $? -ne 0 ]; then
      echo "curl request failed. Check /vagrant/curl_error.log for details."
      exit 1
    fi

    # Log completion
    echo "Base URL Source service creation request completed at $(date)" >> /vagrant/curl_request.log

####updating base url service to root realm
# Make the HTTP PUT request to configure Base URL Source service
sudo echo "updating base url service"
    curl -X PUT "http://am.example.com:8081/am/json/realms/root/realm-config/services/baseurl" \
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
      -d '{"source":"FIXED_VALUE","contextPath":"/am","fixedValue":"https://platform.example.com:9443","extensionClassName":"","_id":"","_type":{"_id":"baseurl","name":"Base URL Source","collection":false}}' \
      -o /vagrant/curl_response.json \
      -v 2>> /vagrant/curl_error.log

    # Check the curl exit status
    if [ $? -ne 0 ]; then
      echo "curl request failed. Check /vagrant/curl_error.log for details."
      exit 1
    fi

    # Log completion
    echo "Base URL Source service configuration request completed at $(date)" >> /vagrant/curl_request.log

####creating base url service to alpha realm
# Make the HTTP POST request to create Base URL Source service
sudo echo "creating base url service"
curl -X POST "http://am.example.com:8081/am/json/realms/root/realms/alpha/realm-config/services/baseurl?_action=create" \
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
  -d '{"fixedValue":"https://platform.example.com:9443","extensionClassName":""}' \
  -o /vagrant/curl_response.json \
  -v 2>> /vagrant/curl_error.log

# Check the curl exit status
if [ $? -ne 0 ]; then
  echo "curl request failed. Check /vagrant/curl_error.log for details."
  exit 1
fi

# Log completion
echo "Base URL Source service creation request completed at $(date)" >> /vagrant/curl_request.log

####updating base url service to alpha realm
# Make the HTTP PUT request to configure Base URL Source service
sudo echo "updating base url service"
curl -X PUT "http://am.example.com:8081/am/json/realms/root/realms/alpha/realm-config/services/baseurl" \
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
  -d '{"source":"FIXED_VALUE","contextPath":"/am","fixedValue":"https://platform.example.com:9443","extensionClassName":"","_id":"","_type":{"_id":"baseurl","name":"Base URL Source","collection":false}}' \
  -o /vagrant/curl_response.json \
  -v 2>> /vagrant/curl_error.log

# Check the curl exit status
if [ $? -ne 0 ]; then
  echo "curl request failed. Check /vagrant/curl_error.log for details."
  exit 1
fi

# Log completion
echo "Base URL Source service configuration request completed at $(date)" >> /vagrant/curl_request.log

####Adding External login page url for alpha realm
 # Make the HTTP PUT request to update authentication configuration with External Login Page URL
    curl -X PUT "http://am.example.com:8081/am/json/realms/root/realms/alpha/realm-config/authentication" \
      -H "Accept: application/json, text/javascript, */*; q=0.01" \
      -H "Accept-API-Version: protocol=1.0,resource=1.0" \
      -H "Accept-Encoding: gzip, deflate" \
      -H "Accept-Language: en-US" \
      -H "iPlanetDirectoryPro: $ADMIN_TOKEN" \
      -H "Cache-Control: no-cache" \
      -H "Connection: keep-alive" \
      -H "Content-Type: application/json" \
      -H "Host: am.example.com:8081" \
      -H "Origin: http://am.example.com:8081" \
      -H "Referer: http://am.example.com:8081/am/ui-admin/" \
      -H "User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36 Edg/135.0.0.0" \
      -H "X-Requested-With: XMLHttpRequest" \
      -d '{"statelessSessionsEnabled":false,"identityType":["agent","user"],"locale":"en_US","externalLoginPageUrl":"https://platform.example.com:9443/enduser-login","userStatusCallbackPlugins":[],"twoFactorRequired":false,"defaultAuthLevel":0}' \
      -o /vagrant/curl_response.json \
      -v 2>> /vagrant/curl_error.log

    # Check the curl exit status
    if [ $? -ne 0 ]; then
      echo "curl request failed. Check /vagrant/curl_error.log for details."
      exit 1
    fi

    # Log completion
    echo "Authentication configuration update request completed at $(date)" >> /vagrant/curl_request.log
##Updating the oauth client idm-admin-ui for platform configuration.





### updating the ui-configuration file to point to platform url

jq '.configuration.platformSettings.amUrl = "https://platform.example.com:9443/am"' "$UI_CONFIG_JSON" > tmp.json && mv tmp.json "$UI_CONFIG_JSON"
