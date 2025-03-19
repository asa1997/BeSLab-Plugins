#!/bin/bash

function __beslab_install_Criticality_Score() {

    if ! [ -x "$(command -v go)" ];then
         sudo snap install go --classic
	 export GPATH=$HOME/go
	 export PATH=$PATH:/usr/local/go/bin:$GOPATH/bin

    fi
    go install github.com/ossf/criticality_score/v2/cmd/criticality_score@latest


}

function __beslab_uninstall_Criticality_Score() {

	__besman_echo_no_colour "Stopping and removing $BESLAB_OIAB_BUYER_APP"
	cd "$BESLAB_OIAB_BUYER_APP_DIR" || return 1
        go install github.com/ossf/criticality_score/v2/cmd/criticality_score@none	
	cd "$HOME" || return 1
}

function __beslab_plugininfo_Criticality_Score()
{
	cat <<EOF
### Plugin Information

#### Description:

This plugin is to install criticality score utility to assess the github repository score.

#### Version:

latest


#### Usage:

To use the plugin, run the following command:

bli install plugin Criticality_Score 0.0.1

EOF

}
