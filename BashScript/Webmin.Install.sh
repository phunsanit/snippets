#!/bin/bash

#install webmin
#by pitt phunsanit
#https://pitt.plusmagi.com
#phunsanit@gmail.com

cd ~

#https://webmin.com/download/

# Function to validate port number
validate_port() {
  local port="$1"

  # Check if the port is a number
  if [[ ! "$port" =~ ^[0-9]+$ ]]; then
    echo "Invalid port number: $port must be a positive integer."
    return 1
  fi

  # Check if the port has 5 digits
  if [[ ${#port} -ne 5 ]]; then
    echo "Invalid port number: $port must have exactly 5 digits."
    return 1
  fi

  # If validation passes, return 0
  return 0
}

curl -o setup-repos.sh https://raw.githubusercontent.com/webmin/webmin/master/setup-repos.sh
sh setup-repos.sh

apt-get install webmin --install-recommends

# Define default values
default_port=$(shuf -i 44300-44399 -n 1)

read -p "Enter new Webmin 5-digit port number (e.g., $default_port): " port

# Use parameter expansion for default values
port=${port:-$default_port}

# Validate user input (optional)
if [[ -z "$port" ]]; then
  echo "Error: Please provide all required information."
  exit 1
fi

# Validate the port number
if ! validate_port "$port"; then
  exit 1
fi

#change default port
sudo sed -i "s/^port=.*/port=$port/" /etc/webmin/miniserv.conf

#new port to UFW (Uncomplicated Firewall)
sudo ufw allow $port/tcp

#restart webmin
sudo systemctl restart webmin

MY_IP=$(hostname -I | cut -d " " -f 1)

echo -e "Your Webmin IP is: \e]8;;http://$MY_IP:$port\a$MY_IP:$port\e]8;;\a"
echo -e "or: \e]8;;http://127.0.0.1:$port\a127.0.0.1:$port\e]8;;\a"

rm setup-repos.sh