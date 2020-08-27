#/bin/bash -e

if [  "$EUID" == 0 ]
then
	echo "Please do not run directly as root"
	exit 1
fi

HOME_PATH=$HOME
FILES=.config .fonts .urxvt .Xressources .bashrc .zshrc .vimrc

ask() {
    local prompt default reply
    prompt="y/n"
    default="y"
    while true; do
        echo -n "$1 [$prompt] "
        read reply </dev/tty
        if [ -z "$reply" ]; then
            reply=$default
        fi
        case "$reply" in
            Y*|y*) return 0 ;;
            N*|n*) return 1 ;;
            *) echo "Please type [Y]es or [N]o"
        esac
    done
}

install_zsh() {
	echo "Installing zsh"
	sudo dnf install zsh
	
	echo "Download ohmyzsh + installation"
	wget --no-check-certificate http://install.ohmyz.sh -O - | sh
	
	echo "Installing dependencies zsh fedora switch"
	sudo dnf install util-linux-user -y
	chsh -s /usr/bin/zsh
}

install_dependencies() {
	echo "Installing the dependencies"
	sudo dnf install libxcb-devel xcb-util-keysyms-devel xcb-util-devel xcb-util-wm-devel xcb-util-xrm-devel yajl-devel libXrandr-devel startup-notification-devel libev-devel xcb-util-cursor-devel libXinerama-devel libxkbcommon-devel libxkbcommon-x11-devel pcre-devel pango-devel git gcc automake i3status i3lock polybar rofi git xbacklight dunst acpi mpd mpc dnsutils bmon nm-connection-editor firefox scrot maim viewnior zip unzip lxmusic vim firefox discord rxvt-unicode neofetch
}

install_config() {
	echo "Cleaning HOME"
	cd $HOME_PATH && rm -rf $FILES

	echo "Clones DotFiles"
	git clone https://github.com/Heliferepo/TheBloatedDotFiles dotfiles

	echo "Enter dotfiles"
	cd dotfiles
	
	echo "Checkout to fedora rice"
	git checkout fedora_rice

	echo "Removing useless files in repo"
	rm -rf LICENSE README.md .git install_fedora_rice.sh

	echo "Moving config"
	mv $FILES $HOME_PATH
}

install_i3_gaps() {
	echo "Clone i3 gaps"
	git clone https://www.github.com/Airblader/i3 i3-gaps
	
	echo "Enter i3 gaps folder"
	cd i3-gaps
	
	echo "Autoreconf i3 gaps"
	autoreconf --force --install

	echo "Make sure there is no build folder"
	rm -rf build/

	echo "Create build folder"
	mkdir -p build
	
	echo "Enter build folder"
	cd build
	
	echo "Configure build folder"
	../configure --prefix=/usr --sysconfdir=/etc --disable-sanitizers
	
	echo "Make program"
	make
	echo "Make install program"
	sudo make install
}

clean_folders() {
	echo "Remove i3-gaps"
	rm -rf i3-gaps
	echo "Remove dotfiles"
	rm -rf dotfiles
}

if ask "Are you sure that you want to get my fedora_voidrice this will erase your own configurations files so make sure to make a backup" || (echo -e "\nExiting ..." && exit)

if ask "Do you want to install zsh ?" && install_zsh
if ask "Do you want to install dependencies ?" && install_dependencies
if ask "Do you want to get Helife's dotfiles ?" && install_config
if ask "Do you want to install i3-gaps ?" && install_i3_gaps


clear && neofetch && echo "Success"
