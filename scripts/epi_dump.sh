#!/usr/bin/sh

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

check_git() {
        if [ ! -f "/usr/bin/git" ]; then
                sudo dnf install git -y
                if [ ! -f "/usr/bin/git" ]; then
                        echo "Could not install git"
                        exit 1
                fi
        fi
}

check_repo() {
        if [ ! -d "dump" ]; then
                echo "Could not clone repository"
                exit 1
        fi
}

download_dump() {
        cd /tmp
        git clone https://github.com/epitech/dump dump
        check_repo
        cd dump
        chmod +x install_packages_dump.sh
        sudo sh install_packages_dump.sh
}

repair_docker() {
        sudo dnf remove docker-* -y
        sudo dnf config-manager --disable docker-* -y
        sudo grubby --update-kernel=ALL --args="systemd.unified_cgroup_hierarchy=0"
        sudo firewall-cmd --permanent --zone=trusted --add-interface=docker0
        sudo firewall-cmd --permanent --zone=FedoraWorkstation --add-masquerade
        sudo dnf install moby-engine docker-compose
        sudo systemctl enable docker
        sudo systemctl reboot
        sudo docker run hello-world
        sudo groupadd docker
        sudo usermod -aG docker $USER
}
        
main() {
        check_sudo_privileges
        check_fedora_version
        check_git
        download_dump
        repair_docker
}

main
