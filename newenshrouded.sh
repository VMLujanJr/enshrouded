#! /bin/bash

# Update and upgrade Ubuntu
sudo apt update -y
sudo apt upgrade -y

# Install necessary packages
sudo apt install software-properties-common lsb-release wget

# Install Wine
sudo mkdir -pm755 /etc/apt/keyrings
sudo wget -O /etc/apt/keyrings/winehq-archive.key https://dl.winehq.org/wine-builds/winehq.key
sudo wget -NP /etc/apt/sources.list.d/ https://dl.winehq.org/wine-builds/$(lsb_release -is | tr '[:upper:]' '[:lower:]')/dists/$(lsb_release -cs)/winehq-$(lsb_release -cs).sources
sudo apt update
sudo apt install --install-recommends winehq-staging -y

# Install necessary packages after Wine installation
sudo apt install cabextract winbind screen xvfb -y

# Install SteamCMD
sudo dpkg --add-architecture i386
sudo apt-add-repository multiverse
sudo apt update
sudo apt install steamcmd

# Create a New User
# sudo useradd -m enshrouded
# sudo -u enshrouded -s
# cd ~

# Install Enshrouded Dedicated Server
# /usr/games/steamcmd +@sSteamCmdForcePlatformType windows +force_install_dir /home/manny/enshroudedserver/ +login anonymous +app_update 2278520 validate +quit
/usr/games/steamcmd +@sSteamCmdForcePlatformType windows +login anonymous +app_update 2278520 validate +quit

wine64 /home/manny/Steam/steamapps/common/EnshroudedServer/enshrouded_server.exe

# Edit Config File
# nano /home/manny/Steam/steamapps/common/EnshroudedServer/enshrouded_server.json
# change server name
# change password if you want a private server, or leave it alone if not
# change slotCOunt = limit of players

# Setting up a Service
[Unit]
Description=Enshrouded Server
Wants=network-online.target
After=network-online.target

[Service]
User=manny
Group=manny
WorkingDIrectory=/home/manny/
ExecStartPre=/usr/games/steamcmd +@sSteamCmdForcePlatformType windows +login anonymous +app_update 2278520 +quit
ExecStart=/usr/bin/wine64 /home/manny/Steam/steamapps/common/EnshroudedServer/enshrouded_server.exe
Restart=always

[Install]
WantedBy=multi-user.target

# Enable the Enshrouded service
sudo systemctl enable enshrouded

# Start the Enshrouded Server
sudo systemctl start enshrouded.service

# Stop the Enshrouded Server
sudo systemctl stop enshrouded.service

# Disable the Enshrouded service
sudo systemctl disable enshrouded.service
