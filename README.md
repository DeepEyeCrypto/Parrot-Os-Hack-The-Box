# Parrot-Os-Hack-The-Box
```bash
pkg update
pkg install x11-repo
pkg install termux-x11-nightly
pkg install pulseaudio
pkg install proot-distro
pkg update -y && pkg upgrade -y
pkg install git wget -y
git clone https://github.com/LinuxDroidMaster/parrotOS-GUI-proot
cd parrotOS-GUI-proot
chmod +x setup-parrot-cli
./setup-parrot-cli
#Inside parrot OS
./install-parrot-desktop
sudo apt search parrot-tool # To show all the available packages
sudo apt install parrot-tools-web #or any other package
apt install parrot-desktop-mate
