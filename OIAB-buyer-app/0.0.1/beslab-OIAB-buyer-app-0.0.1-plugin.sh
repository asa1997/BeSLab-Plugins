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

function install_docker_compose() {
	__besman_echo_no_colour "Checking if Docker Compose is installed..."

	if command -v docker-compose >/dev/null 2>&1; then
		__besman_echo_yellow "Docker Compose is already installed"
		docker-compose --version
	else
		__besman_echo_white "Docker Compose not found. Installing latest version..."

		# Download the latest version of Docker Compose directly from GitHub releases
		sudo curl -L "https://github.com/docker/compose/releases/download/latest/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose

		# check if operation successful
		if [ $? -ne 0 ]; then
			__besman_echo_red "Failed to download Docker Compose."
			return 1
		fi
		# Apply executable permissions
		sudo chmod +x /usr/local/bin/docker-compose

		__besman_echo_yellow "Docker Compose installed successfully!"
		docker-compose --version
		if [ $? -ne 0 ]; then
			__besman_echo_red "Failed to download Docker Compose."
			return 1
		fi
	fi
}


function __beslab_install_OIAB-buyer-app() {

	local env_file="$BESLAB_OIAB_BUYER_APP_DIR/.env.default"
    install_docker
    install_docker_compose || return 1
	if [[ -d $BESLAB_OIAB_BUYER_APP_DIR ]]; then
		__besman_echo_white "Buyer app code found"
	else
		__besman_echo_white "Cloning source code repo from $BESLAB_ORG/$BESLAB_OIAB_BUYER_APP"
		__besman_repo_clone "$BESLAB_ORG" "$BESLAB_OIAB_BUYER_APP" "$BESLAB_OIAB_BUYER_APP_DIR" || return 1
	fi
	cd "$BESLAB_OIAB_BUYER_APP_DIR" || return 1
	# Check if MongoDB port is already mapped to 27018
	if grep -q "27018:27017" docker-compose.yml; then
		__besman_echo_yellow "MongoDB port already mapped to 27018"
	else
		sed -i 's/27017:27017/27018:27017/' docker-compose.yml
		__besman_echo_white "Updated MongoDB port mapping to 27018:27017"
	fi

    if grep -q "$BESLAB_OIAB_BUYER_APP_PORT:$BESLAB_OIAB_BUYER_APP_PORT" docker-compose.yml; then
		__besman_echo_yellow "Buyer app port already mapped to $BESLAB_OIAB_BUYER_APP_PORT"
	else
		sed -i "s/$BESLAB_OIAB_BUYER_APP_PORT:$BESLAB_OIAB_BUYER_APP_PORT/$BESLAB_OIAB_BUYER_APP_PORT:$BESLAB_OIAB_BUYER_APP_PORT/" docker-compose.yml
		__besman_echo_white "Updated  port mapping to $BESLAB_OIAB_BUYER_APP_PORT:$BESLAB_OIAB_BUYER_APP_PORT"
	fi

	sed -i "s|PROTOCOL_SERVER_URL=.*|PROTOCOL_SERVER_URL=$BESLAB_IP_ADDRESS:5001|g" "$env_file"
	sed -i "s|BAP_ID=.*|BAP_ID=$BESLAB_BAP_ID|g" "$env_file"
	sed -i "s|BAP_URI=.*|BAP_URI=$BESLAB_BAP_URI|g" "$env_file"

	__besman_echo_white "Installing $BESLAB_OIAB_BUYER_APP"
	__besman_echo_yellow "Building buyer app"
	sudo docker-compose up --build -d
	cd "$HOME" || return 1
}

function __beslab_uninstall_OIAB-buyer-app() {

	__besman_echo_no_colour "Stopping and removing $BESLAB_OIAB_BUYER_APP"
	cd "$BESLAB_OIAB_BUYER_APP_DIR" || return 1
	sudo docker compose down --rmi all --volumes >/dev/null 2>&1
	cd "$HOME" || return 1
}

function __beslab_plugininfo_OIAB-buyer-ui()
{
	__besman_echo_no_colour "################ Plugin: OIAB-buyer-app ################"
	__besman_echo_no_colour "-------------------------------------------------------"
	__besman_echo_no_colour ""
	__besman_echo_no_colour "This plugin installs and runs the app which contain the business logic of OSSVerse marketplace ui."
	__besman_echo_no_colour "It will receive requests from the marketplace ui, running on $BESLAB_IP_ADDRESS:$BESLAB_OIAB_BUYER_UI_PORT".
	__besman_echo_no_colour "It will send requests to the protocol server running on $BESLAB_IP_ADDRESS:5001"
	__besman_echo_yellow "Buyer app is running on port $BESLAB_OIAB_BUYER_APP_PORT"

}