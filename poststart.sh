#!/bin/bash

mkdir -p /home/jovyan/.vnc
pwgen -s 8 1 | tee /tmp/vncpw | vncpasswd -f > /home/jovyan/.vnc/passwd
PASSWORD=$(cat /tmp/vncpw)

cp -r /opt/install/www /tmp
cp /opt/install/etc/bash.bashrc /home/jovyan/.bashrc

sed -i -e "s/RFBSECRET/$PASSWORD/g" /tmp/www/core/rfb.js
