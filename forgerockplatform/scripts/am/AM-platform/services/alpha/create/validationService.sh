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
