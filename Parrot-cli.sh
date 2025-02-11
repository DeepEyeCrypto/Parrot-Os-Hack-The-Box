#!/data/data/com.termux/files/usr/bin/bash
R="$(printf '\033[1;31m')"                           
G="$(printf '\033[1;32m')"
Y="$(printf '\033[1;33m')"
B="$(printf '\033[1;34m')"
C="$(printf '\033[1;36m')"                                        
W="$(printf '\033[1;37m')"

banner() {
clear
printf "\033[33m╭━━━╮╱╱╱╱╱╱╱╱╱╭╮╱╭━━━┳━━━╮\033[0m\n"
printf "\033[33m┃╭━╮┃╱╱╱╱╱╱╱╱╭╯╰╮┃╭━╮┃╭━╮┃\033[0m\n"
printf "\033[33m┃╰━╯┣━━┳━┳━┳━┻╮╭╯┃┃╱┃┃╰━━╮\033[0m\n"
printf "\033[33m┃╭━━┫╭╮┃╭┫╭┫╭╮┃┃╱┃┃╱┃┣━━╮┃\033[0m\n"
printf "\033[33m┃┃╱╱┃╭╮┃┃┃┃┃╰╯┃╰╮┃╰━╯┃╰━╯┃\033[0m\n"
printf "\033[33m╰╯╱╱╰╯╰┻╯╰╯╰━━┻━╯╰━━━┻━━━╯\033[0m\n"
printf "\033[32m   A modded gui of parrot\033[0m\n"
printf "\033[32m      Code by @DeepEyeCrypto \033[0m\n"

}

device_arch=$(dpkg --print-architecture)

setup_rootfs(){
    case "$device_arch" in
        aarch64)
            archtype="arm64"
            ;;
        arm)
            archtype="armhf"
            ;;
        *)
            echo "unknown architecture"; exit 1 ;;
    esac

    base_url="https://raw.githubusercontent.com/risecid/AndronixOrigin/master/Rootfs/Parrot/$archtype/parrot-rootfs-$archtype.tar.xz"
rootfs_file="parrot-rootfs-$archtype.tar.xz"

if [ -f "$rootfs_file" ]; then
  local filename="$rootfs_file"

  echo "${G}File found:${W} ${Y}$filename${W}"
  echo "${B}1) Remove the file${W}"
  echo "${B}2) Rename the file${W}"
  echo "${B}3) Continue with the file${W}"

  read -p "${G}Enter your choice (1/2/3): ${W}" choice

  case $choice in
    1)
      rm "$filename"
      echo "${Y}$filename ${W}${B}File removed.${W}"
      wget "$base_url"
      ;;
    2)
	    new_name="parrot-rootfs-${archtype}-$(date +%s).tar.xz"
      mv "$rootfs_file" "$new_name"
      echo "$rootfs_file renamed to $new_name."
	    wget "$base_url"
      ;;
    3)
      echo "${B}Continuing with the file.${W}"
      wget "$base_url"
      ;;
    *)
      echo "Invalid choice. Please try again."
      ;;
  esac

  get_sha=$(sha256sum "$rootfs_file")
else
  echo "${R}File not found:${W} ${Y}$rootfs_file${W}"
  wget "$base_url"
get_sha=$(sha256sum "$rootfs_file" | cut -d' ' -f1)
fi
}

add_distro(){
banner
    echo -e "${R} [${W}-${R}]${C} Checking required packages...${W}"
    sed -i 's/parrot/ /g' /data/data/com.termux/files/usr/bin/proot-distro
    folder_path="/data/data/com.termux/files/usr/var/lib/proot-distro"
    if [ -d "$folder_path" ]; then
        mkdir "${folder_path}/dlcache"
        mv "$rootfs_file" "${folder_path}/dlcache"
    else
        mkdir "$folder_path"
	mkdir "${folder_path}/dlcache"
        mv "$rootfs_file" "${folder_path}/dlcache"
    fi

    touch "$PREFIX/etc/proot-distro/parrot.sh"
    cat <<EOF > "$PREFIX/etc/proot-distro/parrot.sh"
# If you want to customize installation, please make a copy.
DISTRO_NAME="parrot Linux"
TARBALL_URL['$device_arch']="$base_url"
TARBALL_SHA256['$device_arch']="$get_sha"
EOF
}

check_pack() {
	banner
	termux-setup-storage
	echo -e "${R} [${W}-${R}]${C} Checking required packages..."${W}
if [[ `command -v pulseaudio` && `command -v proot-distro` && `command -v wget` ]]; then
        echo -e "\n${R} [${W}-${R}]${G} Packages already installed."${W}
    else
        packs=(pulseaudio proot proot-distro wget)
        for hulu in "${packs[@]}"; do
            type -p "$hulu" &>/dev/null || {
                echo -e "\n${R} [${W}-${R}]${G} Installing package : ${Y}$hulu${C}"${W}
                apt update -y
                apt upgrade -y
                apt install "$hulu" -y
            }
        done
    fi

}


install_rootfs() {
	banner
	echo -e "${R} [${W}-${R}]${C} Setting up Environment..."${W}
    if [[ -d "$PREFIX/var/lib/proot-distro/installed-rootfs/parrot" ]]; then
        echo -e "\n${R} [${W}-${R}]${G} Distro already installed."${W}
        exit 0
    else
        proot-distro install parrot
        termux-reload-settings
    fi

    if [[ -d "$PREFIX/var/lib/proot-distro/installed-rootfs/parrot" ]]; then
        echo -e "\n${R} [${W}-${R}]${G} Installed Successfully !!"${W}
    else
        echo -e "\n${R} [${W}-${R}]${G} Error Installing Distro !\n"${W}
        exit 0
    fi
    if [[ -e "$PREFIX/var/lib/proot-distro/installed-rootfs/parrot/root/install-parrot-desktop" ]]; then
        chmod +x $PREFIX/var/lib/proot-distro/installed-rootfs/parrot/root/install-parrot-desktop
    else
        wget https://raw.githubusercontent.com/LinuxDroidMaster/parrotOS-GUI-proot/main/builder/install-parrot-desktop
        mv -f install-parrot-desktop $PREFIX/var/lib/proot-distro/installed-rootfs/parrot/root/install-parrot-desktop
        chmod +x $PREFIX/var/lib/proot-distro/installed-rootfs/parrot/root/install-parrot-desktop
    fi
}

add_sound() {
    banner
    echo -e "\n${R} [${W}-${R}]${C} Fixing Sound Problem..."${W}
    if [[ ! -e "$HOME/.sound" ]]; then
        touch $HOME/.sound
    fi

    echo "pulseaudio --start --exit-idle-time=-1" > $HOME/.sound
    echo "pacmd load-module module-native-protocol-tcp auth-ip-acl=127.0.0.1 auth-anonymous=1" >> $HOME/.sound
}

notes() {
	 echo "proot-distro login parrot --bind /dev/null:/proc/sys/kernel/cap_last_last --shared-tmp --fix-low-ports" > $PREFIX/bin/parrot
    if [[ -e "$PREFIX/bin/parrot" ]]; then
        chmod +x $PREFIX/bin/parrot
        termux-reload-settings
	echo -e "\n${R} [${W}-${R}]${G} parrot-letest(CLI) is now Installed on your Termux"${W}
        echo -e "\n${R} [${W}-${R}]${G} Type ${C}parrot${G} to run parrot CLI."${W}
        echo -e "\n${R} [${W}-${R}]${G} If you Want to Use parrot in GUI MODE then ,"${W}
        echo -e "\n${R} [${W}-${R}]${G} Run ${C}parrot${G} first & then type ${C}./install-parrot-desktop "${W}
        echo -e "\n"
        exit 0
    else
        echo -e "\n${R} [${W}-${R}]${G} Error Installing Distro !"${W}
        exit 0
    fi
}

check_pack
setup_rootfs
add_distro
install_rootfs
add_sound
notes
