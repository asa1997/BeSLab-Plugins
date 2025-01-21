#!/bin/bash

function install_docker() {

	__besman_echo_no_colour "Checking if Docker is installed..."

	if command -v docker >/dev/null 2>&1; then
		__besman_echo_yellow "Docker is already installed"
		docker --version
	else
		__besman_echo_white "Docker not found. Installing Docker..."

		# Update package index
		sudo apt-get update

		# Install required packages
		sudo apt-get install -y \
			apt-transport-https \
			ca-certificates \
			curl \
			gnupg \
			lsb-release

		# Add Docker's official GPG key
		curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

		# Set up stable repository
		echo \
			"deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
          $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list >/dev/null

		# Install Docker Engine
		sudo apt-get update
		sudo apt-get install -y docker-ce docker-ce-cli containerd.io

		# Start Docker service
		sudo systemctl start docker
		sudo systemctl enable docker

		# Add current user to docker group
		sudo groupadd docker
		sudo usermod -aG docker $USER
		# newgrp docker


		__besman_echo_yellow "Docker installed successfully!"
		docker --version
	fi
}

# function __beslab_init_OIAB-buyer-ui()
# {
	
# }

function __beslab_install_OIAB-buyer-ui() {
	install_docker
	if [[ -d $BESLAB_OIAB_BUYER_UI_DIR ]]; then
		__besman_echo_white "Buyer ui code found"
	else
		__besman_echo_white "Cloning source code repo from $BESLAB_ORG/$BESLAB_OIAB_BUYER_UI"
		__besman_repo_clone "$BESLAB_ORG" "$BESLAB_OIAB_BUYER_UI" "$BESLAB_OIAB_BUYER_UI_DIR" || return 1
	fi
	cd "$BESLAB_OIAB_BUYER_UI_DIR" || return 1
	__besman_echo_white "Installing $BESLAB_OIAB_BUYER_UI"
	__besman_echo_yellow "Building OIAB buyer ui"

	# Check Dockerfile port
	if grep -q "EXPOSE $BESLAB_OIAB_BUYER_UI_PORT" Dockerfile; then
		__besman_echo_yellow "Port $BESLAB_OIAB_BUYER_UI_PORT already exposed in Dockerfile"
	else
		sed -i "s/EXPOSE 80/EXPOSE $BESLAB_OIAB_BUYER_UI_PORT/g" Dockerfile
		__besman_echo_white "Updated Dockerfile port to $BESLAB_OIAB_BUYER_UI_PORT"
	fi

	# Check nginx.conf port
	if grep -q "listen $BESLAB_OIAB_BUYER_UI_PORT;" nginx.conf; then
		__besman_echo_yellow "Port $BESLAB_OIAB_BUYER_UI_PORT already configured in nginx.conf"
	else
		sed -i "s/listen 80;/listen $BESLAB_OIAB_BUYER_UI_PORT;/g" nginx.conf
		__besman_echo_white "Updated nginx.conf port to $BESLAB_OIAB_BUYER_UI_PORT"
	fi

	sudo docker build --build-arg VITE_API_BASE_URL="$BESLAB_IP_ADDRESS:$BESLAB_OIAB_BUYER_APP_PORT" -t oiab-buyer-ui .
	sudo docker run -d --name oiab-buyer-ui -p $BESLAB_OIAB_BUYER_UI_PORT:$BESLAB_OIAB_BUYER_UI_PORT oiab-buyer-ui
	cd "$HOME" || return 1
}

function __beslab_uninstall_OIAB-buyer-ui()
{
	__besman_echo_yellow "Stopping and removing buyer ui"
	sudo docker stop oiab-buyer-ui
	sudo docker image rm oiab-buyer-ui

	if [[ -d $BESLAB_OIAB_BUYER_UI_DIR ]]; then
		rm -rf "$BESLAB_OIAB_BUYER_UI_DIR"
	fi
}

function __beslab_plugininfo_OIAB-buyer-ui()
{
	cat <<EOF
### Plugin Information

#### Description:

This plugin installs the marketplace/buyer ui.

#### Version:

latest

#### Default Port:

8001

#### Dependencies:

- docker

#### Usage:

To use the plugin, run the following command:

bli install plugin OIAB-buyer-ui 0.0.1

EOF

}