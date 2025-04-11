get_property() {
  local key=$1
  local file=$2
  grep "^${key}=" "$file" | cut -d'=' -f2- | tr -d '\r'
}

PROPERTIES_FILE="/vagrant/config.properties"
install_locaion=$(get_property "install_locaion" "$PROPERTIES_FILE")
secret_location=$(get_property "secret_location" "$PROPERTIES_FILE")
secret_file=$(get_property "secret_file" "$PROPERTIES_FILE")
echo  ${install_locaion}rahil
echo ${secret_location}${secret_file}

#!/bin/bash
# next_script.sh
echo "Using session cookie: $ADMIN_TOKEN"