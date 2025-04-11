####Install docker 
sudo echo "**************Starting installing docker********************"
   sudo apt-get update
sudo apt-get install \
    ca-certificates \
    curl \
    gnupg -y

sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg
echo \
  "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y


sudo echo "**************Completed installing docker********************"
######Pulling forgerock platform images 
sudo echo "**************Starting pulling platform images for docker********************"
sudo /usr/bin/docker pull gcr.io/forgerock-io/platform-admin-ui:7.5.0
sudo /usr/bin/docker pull gcr.io/forgerock-io/platform-enduser-ui:7.5.0
sudo /usr/bin/docker pull gcr.io/forgerock-io/platform-login-ui:7.5.0

sudo echo "**************completed pulling platform images for docker********************"
####Create environment file 

sudo echo "**************creating platform_env for docker********************"
sudo cat > /app/platform_env <<EOF
AM_URL=https://platform.example.com:9443/am
AM_ADMIN_URL=https://platform.example.com:9443/am/ui-admin
IDM_REST_URL=https://platform.example.com:9443/openidm
IDM_ADMIN_URL=https://platform.example.com:9443/admin
IDM_UPLOAD_URL=https://platform.example.com:9443/upload
IDM_EXPORT_URL=https://platform.example.com:9443/export
ENDUSER_UI_URL=https://platform.example.com:9443/enduser-ui
PLATFORM_ADMIN_URL=https://platform.example.com:9443/platform-ui/
ENDUSER_CLIENT_ID=end-user-ui
ADMIN_CLIENT_ID=idm-admin-ui
THEME=default
PLATFORM_UI_LOCALE=en 
EOF
# Run containers in detached mode (-d) instead of interactive (-it)
sudo /usr/bin/docker run -d --rm -p 8083:8080 --env-file=/app/platform_env gcr.io/forgerock-io/platform-login-ui:7.5.0
sudo /usr/bin/docker run -d --rm -p 8082:8080 --env-file=/app/platform_env gcr.io/forgerock-io/platform-admin-ui:7.5.0
sudo /usr/bin/docker run -d --rm -p 8888:8080 --env-file=/app/platform_env gcr.io/forgerock-io/platform-enduser-ui:7.5.0

echo "************** Docker containers started successfully ********************"
