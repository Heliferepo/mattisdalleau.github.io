#/bin/bash -e

if [  "$EUID" == 0 ]
then
	echo "Please do not run directly as root"
	exit (1)
fi

HOME_PATH=$HOME

install_zsh() {
	sudo dnf install zsh
	wget --no-check-certificate http://install.ohmyz.sh -O - | sh
	sudo dnf install util-linux-user -y
	sudo chsh -s /usr/bin/zsh
}

install_dependencies() {
	sudo dnf install libxcb-devel xcb-util-keysyms-devel xcb-util-devel xcb-util-wm-devel xcb-util-xrm-devel yajl-devel libXrandr-devel startup-notification-devel libev-devel xcb-util-cursor-devel libXinerama-devel libxkbcommon-devel libxkbcommon-x11-devel pcre-devel pango-devel git gcc automake i3status i3lock polybar rofi git xbacklight dunst acpi xfce4-power-manager-settings mpd mpc dnsutils nmcli nmtui bmon nm-connection-editor termite firefox scrot maim viewnior amixer zip unzip lxmusic vim firefox discord rxvt-unicode
}

install_config() {
	cd $HOME_PATH && rm -rf .config .fonts .urxvt .Xressources .bashrc .zshrc .vimrc

	git clone https://github.com/Heliferepo/TheBloatedDotFiles dotfiles

	cd dotfiles
	git checkout fedora_rice

	rm -rf LICENSE README.md .git

	mv .* $HOME_PATH
}

install_i3_gaps() {
	git clone https://www.github.com/Airblader/i3 i3-gaps
	cd i3-gaps
	
	autoreconf --force --install
	rm -rf build/
	mkdir -p build
	cd build
	../configure --prefix=/usr --sysconfdir=/etc --disable-sanitizers
	
	make
	sudo make install
}

install_zsh
install_dependencies
install_config
install_i3_gaps
