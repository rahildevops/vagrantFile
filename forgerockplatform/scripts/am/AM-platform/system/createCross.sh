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
      -d '{"acceptedOrigins":["https://platform.example.com:9443","http://login.example.com:8083","http://admin.example.com:8082","http://enduser.example.com:8888","http://openidm.example.com:8080","https://openidm.example.com:8443"],"acceptedMethods":["DELETE","GET","HEAD","PATCH","POST","PUT"],"exposedHeaders":["WWW-Authenticate"],"acceptedHeaders":["accept-api-version","authorization","cache-control","content-type","if-match","if-none-match","user-agent","x-forgerock-transactionid","x-openidm-nosession","x-openidm-password","x-openidm-username","x-requested-with"],"_id":"Cors Configuration"}' \
      -o /vagrant/curl_response.json \
      -v 2>> /vagrant/curl_error.log

    # Check the curl exit status
    if [ $? -ne 0 ]; then
      echo "curl request failed. Check /vagrant/curl_error.log for details."
      exit 1
    fi

    # Log completion
    echo "CORS Service configuration creation request completed at $(date)" >> /vagrant/curl_request.log
