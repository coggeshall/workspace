#!/bin/bash

mkdir -p /home/jovyan/.vnc
pwgen -s 8 1 | tee /tmp/vncpw | vncpasswd -f > /home/jovyan/.vnc/passwd
