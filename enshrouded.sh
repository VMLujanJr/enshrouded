#! /bin/bash

echo "Starting Enshrouded Dedicated Server..."
/usr/games/steamcmd +@sSteamCmdForcePlatformType windows +force_install_dir /home/manny/EnshroudedServer/ +login anonymous +app_update 2278520 validate +quit
/usr/bin/wine64 /home/manny/EnshroudedServer/enshrouded_server.exe

## 50. SteamCMD

### Create a New User

> **Important:** To run SteamCMD safely, its best to isolate it from the rest of the operating system by creating a new user and downloading the required files in its own home directory. 

50.1 - `sudo useradd -m steam` create a user.

- `-m` (create home) option creates the user's home directory if it does not exist.

- `sudo passwd steam` to *add or update* current password.

### Switch Users

50.2 - `sudo -u steam -s`

Change directories
`cd /home/steam`

### Enable Multiverse and x86 Packages

> **Important:** To install SteamCMD, the multiverse repository and x86 packages *must* be enabled.

50.3 - `sudo add-apt-repository multiverse`

50.4 - `sudo dpkg --add-architecture i386`

### Update Packages

50.5 - `sudo apt update`

50.6 - `sudo apt upgrade`

### Install 32-bit Library
`sudo apt install lib32gcc-s1`

### Install SteamCMD  
50.7 - `sudo apt install steamcmd`


> **Important:** Agree to the Steam Terms & Conditions.
>
> > 1. Enter `Ok`.
> >
> > 2. Select `I AGREE`, then enter `Ok`.

Start SteamCMD
`steamcmd`

[steamdb.info](https://www.steamdb.info)

### Setup an Installation Directory

`force_install_dir /home/steam/Palworld/`

### Steam Login

SteamCMD Login
`login anonymous` followed by your `<password>`.
> **Important**: You may also login as your own `login <steam-username>` followed by your `<steam-password>`, however, the dedicated server has to be tied to your account.
> 
> If Steam Guard is activated on the user account, check your e-mail for a Steam Guard access code and enter it.

Install or Update the App
`app_update <app_id> validate`
E.g. app_update 2394010

Shorthand `steamcmd +login <username> +app_update <app_id> validate +quit`

```
#!/bin/bash

# Check if steamcmd is installed
if ! command -v steamcmd &> /dev/null; then
    echo "steamcmd not found. Installing steamcmd..."
    sudo add-apt-repository multiverse -y
    sudo dpkg --add-architecture i386
    sudo apt update
    sudo apt install steamcmd -y
else
    echo "steamcmd is already installed."
fi

# Install Applications with SteamCMD
echo "Installing applications with SteamCMD..."
steamcmd +login anonymous +app_update 2394010 validate +quit
steamcmd +login anonymous +app_update 1007 validate +quit

# Fix Steam SDK Errors
echo "Creating directory and copying steamclient.so..."
mkdir -p ~/.steam/sdk64/
cp ~/Steam/steamapps/common/Steamworks\ SDK\ Redist/linux64/steamclient.so ~/.steam/sdk64/#

# Start the Pal Server
echo "Starting Pal Server..."
./PalServer.sh -useperfthreads -NoAsyncLoadingThread -UseMultithreadForDS port=8211 players=32

# Create a Service for Pal Server
echo "Creating Pal Server service..."
SERVICE_FILE=/etc/systemd/system/palserver.service
cat << EOF | sudo tee $SERVICE_FILE
[Unit]
Description=Pal Server
After=network.target

[Service]
User=$USER
Group=$USER
Type=simple
ExecStart=/home/$USER/Steam/steamapps/common/PalServer/PalServer.sh -useperfthreads -NoAsyncLoadingThread -UseMultithreadForDS port=8211 players=32
Restart=always
RestartSec=300

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl enable palserver.service
sudo systemctl start palserver.service

# Allow User to Control palworld.service Without Sudo
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

echo "Setup complete!"```

`sudo nano /etc/systemd/system/palworld.service` then paste this script.

`
[Unit]
Description=PalWorld Dedicated Server
After=network.target

[Service]
Type=simple
User=manny
Group=manny
ExecStart=/home/manny/palserver.sh

[Install]
WantedBy=multi-user.target
`

`sudo systemctl daemon-reload`

`sudo systemctl start palworld`

`sudo systemctl status palworld`

`sudo systemctl enable palworld` start up the service when the computer does

CRON to restart server on a daily basis
`sudo apt install cron`

`sudo systemctl status cron`

`sudo crontab -e` select `nano` or type `1`

copy and paste into the crontab
`00 04 * * * /usr/bin/systemctl restart palworld.service`

/STEAM CLIENT PORT RANGE
ufw allow 11200:11299/tcp
ufw allow 11200:11299/udp