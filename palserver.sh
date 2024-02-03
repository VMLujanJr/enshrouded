#! /bin/bash

echo "starting PalServer"
/usr/games/steamcmd +login anonymous +app_update 2394010 validate +quit
/home/manny/Steam/steamapps/common/PalServer/PalServer.sh
