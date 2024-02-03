#! /bin/bash

# Check if SteamCMD is installed
if ! command -v steamcmd &> /dev/null/; then
  echo "steamcmd is already installed."
else
  echo "steamcmd not found. Installing steamcmd..."
  sudo add-apt-repository multiverse -y
  sudo dpkg --add-architecture i386
  sudo apt update
  sudo apt install steamcmd -y
fi

# Install applications with SteamCMD
echo "Installing applications with SteamCMD..."
echo "SteamSDK is being installed..."
/usr/games/steamcmd +login anonymous +app_update 1007 validate +quit
sleep 10

echo "Palworld is being installed..."
/usr/games/steamcmd +login anonymous +app_update 2394010 validate +quit

# Wait for 5 seconds so that SteamAPI_Init succeeds
echo "Waiting..."
sleep 10

# Fix SteamCMD SDK errors
echo "Creating directory and copying steamclient.so..."
mkdir -p /home/manny/.steam/sdk64/
cp /home/manny/Steam/steamapps/common/Steamworks\ SDK\ Redist/linux64/steamclient.so /home/manny/.steam/sdk64/#

# Wait for 5 seconds so that SteamAPI_Init succeeds
echo "Waiting..."
sleep 10

# Start the Palworld server
echo "Starting PalServer..."
/home/manny/Steam/steamapps/common/PalServer/PalServer.sh -useperfthreads -NoAsyncLoadingThread -UseMultithreadForDS 

# port=8211 players=32

# Wait for 5 seconds so that SteamAPI_Init succeeds
echo "Waiting..."
sleep 10

# Create a service for PalServer
echo "Creating Palworld service..."
SERVICE_FILE=/etc/systemd/system/palworld.service
cat << EOF | sudo tee $SERVICE_FILE
[Unit]
Description=Palworld Dedicated Server
After=network.target

[Service]
User=$USER
Group=$USER
Type=simple
ExecStart=/home/$USER/Steam/steamapps/common/PalServer/PalServer.sh -useperfthreads -NoAsyncLoadingThread -UseMultithreadForDS
Restart=always
RestartSec=300

[Install]
WantedBy=multi-user.target
EOF
# port=8211 players=32 @ line 42

# Enable and start palworld.service
sudo systemctl enable palworld.service
sudo systemctl start palworld.service

# Allow User to control palworld.service without sudo
echo "Setting up policy for non-sudo control..."
POLICY_FILE=/etc/polkit-1/localauthority/50-local.d/palworld-service-control.pkla
cat << EOF | sudo tee $POLICY_FILE
[Allow $USER control of palworld.service]
Identity=unix-user:$USER
Action=org.freedesktop.systemd1.manage-units
ResultActive=yes
ResultInactive=yes
ResultAny=yes
EOF

sudo systemctl restart polkit.service

echo "Setup complete!"
