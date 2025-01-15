# Parrot-Os-Hack-The-Box
```bash
pkg update
pkg install x11-repo
pkg install termux-x11-nightly
pkg install pulseaudio
pkg install proot-distro
pkg update -y && pkg upgrade -y
pkg install git wget -y
wget https://github.com/DeepEyeCrypto/Parrot-Os-Hack-The-Box/raw/refs/heads/main/Parrot-cli.sh
chmod +x Parrot-cli.sh
./Parrot-cli.sh
