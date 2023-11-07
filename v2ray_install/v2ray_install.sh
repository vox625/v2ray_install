#!/bin/bash

# Function: Check if a file exists
check_file() {
  if [ -f "$1" ]; then
    echo "File $1 exists."
    return 0
  else
    echo "File $1 does not exist."
    return 1
  fi
}

# Function: Check and execute a command
run_command() {
  if "$@"; then
    echo "Command executed successfully."
  else
    echo "Command execution failed."
    exit 1
  fi
}

# Main script

# Check if the v2ray-linux-64.zip file exists
check_file "v2ray-linux-64.zip" || exit 1

# Use sudo to unzip the file
run_command sudo unzip v2ray-linux-64.zip

# Set file permissions
run_command sudo chmod 755 v2ray systemd/system/v2ray.service systemd/system/v2ray@.service

# Copy files to the target directories
run_command sudo cp v2ray /usr/local/bin/
run_command sudo cp systemd/system/v2ray.service /etc/systemd/system/
run_command sudo cp systemd/system/v2ray@.service /etc/systemd/system/

# Create directories and copy files
run_command sudo mkdir -p /usr/local/share/v2ray/
run_command sudo cp geoip.dat /usr/local/share/v2ray/
run_command sudo cp geosite.dat /usr/local/share/v2ray/

# Create log directory and files
run_command sudo mkdir -p /var/log/v2ray/
run_command sudo touch /var/log/v2ray/access.log /var/log/v2ray/error.log
run_command sudo chmod 755 /var/log/v2ray/access.log /var/log/v2ray/error.log

# Copy and rename the configuration file
run_command sudo cp nodel.json /usr/local/etc/v2ray/config.json

# Start V2Ray
run_command sudo systemctl start v2ray

# Set V2Ray to start at boot
run_command sudo systemctl enable v2ray

# Add proxy setting functions to the user's ~/.bashrc file
proxy_functions="# Set proxy\nfunction setproxy() {\n    export http_proxy=socks5://127.0.0.1:10808\n    export https_proxy=socks5://127.0.0.1:10808\n    export ftp_proxy=socks5://127.0.0.1:10808\n}\n\n# Unset proxy\nfunction unsetproxy() {\n    unset http_proxy https_proxy ftp_proxy\n}"
if ! grep -q "setproxy()" ~/.bashrc; then
  echo -e "\n$proxy_functions" >> ~/.bashrc
  echo "Proxy setting functions added to the ~/.bashrc file."
else
  echo "Proxy setting functions already exist in the ~/.bashrc file."
fi

