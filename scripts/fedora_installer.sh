#/bin/bash -e

if [  "$EUID" == 0 ]
then
	echo "Please do not run directly as root"
	exit 1
fi

HOME_PATH=$HOME
FILES=".config .fonts .urxvt .Xressources .bashrc .zshrc .vimrc"

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
	sudo dnf install libxcb-devel xcb-util-keysyms-devel 
	sudo dnf install xcb-util-devel xcb-util-wm-devel 
	sudo dnf install xcb-util-xrm-devel yajl-devel libXrandr-devel
	sudo dnf install startup-notification-devel libev-devel 
	sudo dnf install xcb-util-cursor-devel libXinerama-devel nitrogen
	sudo dnf install libxkbcommon-devel libxkbcommon-x11-devel pcre-devel
	sudo dnf install pango-devel gcc automake i3status i3lock polybar
	sudo dnf install rofi git xbacklight dunst acpi mpc dnsutils bmon
	sudo dnf install nm-connection-editor firefox scrot maim viewnior
	sudo dnf install zip unzip lxmusic vim firefox rxvt-unicode neofetch
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

install_dependencies
install_zsh
install_config
install_i3_gaps
clean_folders

clear && neofetch && echo "Success"
