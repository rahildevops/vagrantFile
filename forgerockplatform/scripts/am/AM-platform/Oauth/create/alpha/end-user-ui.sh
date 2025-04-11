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
