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


function __beslab_install_PurpleLlama() {

	local env_file="$BESLAB_PURPLELLAMA_DIR/.env.default"
    #install_docker
    #install_docker_compose || return 1
	if [[ -d $BESLAB_PURPLELLAMA_DIR ]]; then
		__besman_echo_white "PurpleLlama code found"
	else
		__besman_echo_white "Cloning source code repo from $BESLAB_ORG/$BESLAB_PURPLELLAMA"
		__besman_repo_clone "$BESLAB_ORG" "$BESLAB_PURPLELLAMA" "$BESLAB_PURPLELLAMA_DIR" || return 1
	fi
	cd "$BESLAB_PURPLELLAMA_DIR" || return 1

        sudo apt update && sudo apt upgrade -y

	PYTHON_VERSION=$(pythin3 --version 2>/dev/null 2>&1)

	if [[ -z "$PYTHON_VERSION" || "$(printf "%s/n" "3.9" "$PYTHON_VERSION" | sort -V | head -n1)" != "3.9" ]];then
           sudo apt install python3 python3-pip python3-venv
	fi

        if command -v cargo >/dev/null 2>&1; then
           __besman_echo_yellow "Docker is already installed"
           docker --version
        else
	  curl https://sh.rustup.rs -sSf | sh

        fi


        cargo install weggli --rev=9d97d462854a9b682874b259f70cc5a97a70f2cc --git=https://github.com/weggli-rs/weggli
	
	export WEGGLI_PATH=weggli

	python3 -m venv ~/.venvs/CyberSecurityBenchmarks

	source ~/.venvs/CyberSecurityBenchmarks/bin/activate

	pip3 install -r CyberSecurityBednchmarks/requirements.txt

	cd "$HOME" || return 1
}

function __beslab_uninstall_PurpleLlama() {

	__besman_echo_no_colour "Removing $BESLAB_PURPLELLAMA"
	cd "$BESLAB_PURPLELLAMA_DIR" || return 1
	
        rm -rf .

	cd "$HOME" || return 1
}

function __beslab_plugininfo_PurpleLlama()
{
	cat <<EOF
### Plugin Information

#### Description:

This plugin installs PurpleLlama. It helps in security analysis of AI models.

#### Version:

latest

#### Environment Variables

BESLAB_ORG: Namespace on github

BESLAB_PURPLELLAMA: Name of PurpleLlama repository in github to download.

BESLAB_PURPLELLAMA_DIR: Directory where PurpleLlama is installed.

#### Usage:

To use the plugin, run the following command:

bli install plugin OIAB-buyer-app 0.0.1

EOF

}
