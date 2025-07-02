#!/bin/bash

function __beslab_install_PIA-CriticalityScore() {

    if ! [ -x "$(command -v go)" ];then
         sudo snap install go --classic
	 export GPATH=$HOME/go
	 export PATH=$PATH:/usr/local/go/bin:$GOPATH/bin

    fi
    go install github.com/ossf/criticality_score/v2/cmd/criticality_score@latest


}

function __beslab_uninstall_PIA-CriticalityScore() {

	__besman_echo_no_colour "Stopping and removing $BESLAB_OIAB_BUYER_APP"
	cd "$BESLAB_OIAB_BUYER_APP_DIR" || return 1
        go install github.com/ossf/criticality_score/v2/cmd/criticality_score@none	
	cd "$HOME" || return 1
}

function __beslab_plugininfo_PIA-CriticalityScore()
{
	cat <<EOF
### Plugin Information

#### Description:

This plugin is to install criticality score utility to assess how critical the project under test.

#### Version:

latest


#### Usage:

To use the plugin, run the following command:

bli install plugin PIA-CriticalityScore 0.0.1

EOF

}
