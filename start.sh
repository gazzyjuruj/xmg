#!/usr/bin/env bash

# set -e

# [ ! $# -eq 3 ] && echo need user and worker name && exit 1

# user_name=$1
# worker_name=$2

# SYSTEM UPDATE AND INSTALL COMPILER DEPENDENCIEES
apt-get update
apt-get upgrade -y
apt-get install -y automake autoconf pkg-config libcurl4-openssl-dev libjansson-dev libssl-dev libgmp-dev make g++

# INSTALL SOME USEFUL UTILITIES
apt-get install -y htop bmon vim tmux

# GET SOURCE AND COMPILE
cd /root # MAKING SURE WE START FROM A KNOWN PATH
git pull https://github.com/magi-project/m-cpuminer-v2.git xmg-miner
cd xmg-miner
./autogen.sh
./configure CFLAGS="-O3 -march=native" --with-crypto --with-curl
./make
./make install

echo "Time to edit the config file! :)"

# CREATE A BARE CONFIG FILE
cat << EOF > /root/mining-confs/xmg-miner.json
{
     "url" : "stratum+tcp://xmg.minerclaim.net:3333",
     "user" : "gazzyjuruj.rig1",
     "pass" : "x",
     
     "cpu-efficiency" : 95,
     "threads" : 8,
     
     "quiet" : true,
     "background" : true
}
EOF

vim /root/mining-confs/xmg-miner.json

# CREATE BOOT SERVICE
cat << EOF > /lib/systemd/system/magicoind.service
# cat << EOF > /tmp/magicoind
[Unit]
Description=MagiCoin service
After=network.target

[Service]
Type=simple
ExecStart=/root/xmg-miner/m-minerd -c /root/mining-confs/xmg-miner.json
WorkingDirectory=/root/xmg-miner
RestartSec=10
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF

# START BOOT SERVICE
systemctl enable magicoind.service
systemctl daemon-reload
systemctl start magicoind.service
