#!/bin/bash

loadkeys fr-latin1
timedatectl set-ntp true
timedatectl set-timezone Europe/Paris
parted -s /dev/sda mktable gpt
parted -s /dev/sda mkpart primary fat32 0 550MB
parted -s /dev/sda set 1 esp on
parted -s /dev/sda mkpart primary ext2 550MB 16550MB
parted -s /dev/sda set 2 lvm on
parted -s /dev/sda mkpart primary ext4 16550MB 26550MB
parted -s /dev/sda mkpart primary ext4 26550MB 31050MB
parted -s /dev/sda mkpart primary ext2 31050MB 31550MB
parted -s /dev/sda mkpart primary linux-swap 31550MB 32050MB
vgcreate arch /dev/sda2
lvcreate -L 9G arch -n root
lvcreate -L 5G arch -n home
lvcreate -L 400M arch -n boot
lvcreate -L 500M arch -n swap
mkfs.fat -F32 /dev/sda1
mkfs.ext4 /dev/arch/root
mkfs.ext4 /dev/arch/home
mkfs.ext2 /dev/arch/boot
mkswap /dev/arch/swap
mkfs.ext4 /dev/sda3
mkfs.ext4 /dev/sda4
mkfs.ext2 /dev/sda5
mkswap /dev/sda6
swapon /dev/arch/swap
mount /dev/arch/root /mnt
mkdir /mnt/boot
mkdir /mnt/efi
mkdir /mnt/home
mount /dev/arch/home /mnt/home
mount /dev/arch/boot /mnt/boot
mount /dev/sda1 /mnt/efi
pacstrap /mnt base linux linux-firmware vim nano
sed -i 's/HOOKS.*/HOOKS\=\(dev udev autodetec modconf block lvm2 filesystems keyboard fsck\)/g' /mnt/etc/mkinitcpio
chmod 644 /mnt/etc/mkinitcpio.conf
genfstab -U /mnt >> /mnt/etc/fstab
mkdir /mnt/hostlvm
mount --bind /run/lvm /mnt/hostlvm
arch-chroot /mnt
pacman -S dhcpcd
systemctl enable dhcpcd
pacman -S lvm2
mkinitcpio -p linux # (deja fait lors de l'install de lvm2 mais osef)
ln -s /hostlvm /run/lvm
ln -sf /usr/share/zoneinfo/Europe/Paris /etc/localtime
hwclock --systohc --utc
echo "en_US.UTF-8 UTF-8" > /etc/locale.gen
locale-gen
echo "LANG=en_US.UTF-8" > /etc/locale.conf
echo "KEYMAP=fr-latin1" > /etc/vconsole.conf
echo "arch" > /etc/hostname
cat << EOF > /etc/hosts
127.0.0.1 localhost
::1	      localhost
127.0.1.1 arch localhost.localdomain
EOF
chmod 644 /etc/hosts
pacman -S lvm2
mkinitcpio -p linux
echo "Now set your password"
passwd
exit
umount -R /mnt
echo "systemctl start dhcpcd (a faire au prochain lancement de la vm)"
