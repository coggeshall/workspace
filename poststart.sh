#!/bin/bash

mkdir -p /home/jovyan/.vnc
pwgen -s 8 1 | tee /tmp/vncpw | vncpasswd -f > /home/jovyan/.vnc/passwd
xinit /etc/X11/Xsession startxfce4 -- /usr/local/bin/Xvnc :1 -depth 24 -desktop Desktop-GUI -geometry 1600x900 -pn -SecurityTypes VNC -rfbport 5901 -rfbauth /home/jovyan/.vnc/passwd -rfbwait 30000&
