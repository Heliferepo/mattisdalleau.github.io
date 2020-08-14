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

if [ "$(id -u)" == "0" ]; then
    echo "This script must not be run as root" 1>&2
    exit 1
fi

if ask "Are you sure that you want to get my voidrice this will erase you own configurations files so make sure to make a backup" || (echo -e "\nExiting ..." && exit)

echo -e "\nLaunching ..."

git clone https://github.com/Heliferepo/TheBloatedDotFiles

if [ ! -d "TheBloatedDotFiles" ]
    echo -e "\nCould not clone the repo\n\nAborting..."
fi

rm -rf $HOME/.config $HOME/.urxvt $HOME/.Xressources $HOME/.bashrc $HOME/.vimrc $HOME/.zshrc
cd TheBloatedDotFiles
rm -rf README.md LICENSE .git
mv * $HOME 
cd .. && rm -rf TheBloatedDotFiles

echo "\nDone"
