#!/bin/bash

service(){
cat > net-speeder.service <<-EOF
[Unit]
Description=net-speeder(/etc/systemd/system/net-speeder.service)
After=network.target
Wants=network-online.target
[Service]
Type=simple
User=root
ExecStart=/root/net-speeder-master/net_speeder eth0 "ip"
Restart=on-failure
RestartSec=10s
[Install]
WantedBy=multi-user.target
EOF
}

wget https://github.com/manatsu525/net-speeder/releases/download/v1.0/net-speeder-master.zip
unzip net-speeder-master.zip
cd net-speeder-master/
apt install libnet1-dev -y
apt install libpcap0.8-dev -y
apt install gcc -y
if hostnamectl status | grep -q openvz;then
    sh build.sh -DCOOKED
    service
    sed -i "s/eth0/venet0/g" net-speeder.service
    mv net-speeder.service /etc/systemd/system/
else
    sh build.sh
    service
    mv net-speeder.service /etc/systemd/system/
fi
systemctl daemon-reload
systemctl enable net-speeder.service
systemctl start net-speeder.service
