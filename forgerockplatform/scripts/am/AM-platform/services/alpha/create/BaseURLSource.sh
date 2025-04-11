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
