#!/usr/bin/bash

check_sudo_privileges() {
        if [[ $EUID -ne 0 ]]; then
                echo "This script must be runned as root"
                exit 1
        fi
}

check_fedora_version() {
        cat /etc/fedora-release | grep "Fedora release 32"
        if [[ $? -ne 0 ]]; then
                echo "You need to run this script on Fedora 32"
                exit 1
        fi
}

check_deps() {
        sudo dnf install git gcc g++ make cmake emacs-nox -y
        
        if [[ $? -ne 0 ]]; then
                echo "Some dependecies download might have failed aborting..."
                exit 1
        fi
}

download_dump_manager() {
        cd /tmp
        if [ -d "epidump_manager" ]; then
                cd epidump_manager
                git pull
        else 
                git clone https://github.com/Heliferepo/epidump_manager epidump_manager
                if [ ! -d "epidump_manager" ]; then
                        echo "Could not clone repository"
                        exit 1
                fi
                cd epidump_manager
        fi

        chmod +x install.sh
        sudo sh install.sh
        epidump_manager -d && epidump_manager -a && epidump_manager -sdec
        #Plusieurs fois au cas ou de toute facon apres avoir installé tout le plus c'est la sfml et le epitech-emacs
        #aka -s et -e
}
        
main() {
        check_sudo_privileges
        check_fedora_version
        check_deps
        download_dump_manager
}

main
