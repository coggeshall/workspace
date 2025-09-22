FROM debian:12

USER root

RUN date > /etc/build-date

RUN DEBIAN_FRONTEND=noninteractive && \
apt-get update && \
apt-get -y install software-properties-common

RUN export DEBIAN_FRONTEND=noninteractive && \
apt-get update && \
apt-get -y install dnsutils vim whois net-tools iputils-ping socat gcc make gnupg2 curl unzip rclone \
xvfb x11vnc dbus dbus-x11 ffmpeg tcpdump uuid-runtime wget gtk2-engines-pixbuf cowsay \
xfonts-100dpi xfonts-75dpi xfonts-base xfonts-scalable imagemagick x11-apps \
jq tshark netbase bc espeak libespeak1 telnet xfce4 xfce4-panel xfce4-session xfce4-settings \
xorg manpages man-db pwgen xvkbd vlc youtube-dl perl-tk libreoffice tree remmina texlive-full \
transmission-gtk icedtea-netx img2pdf forensics-full gfio gnuradio gnuradio-dev gnuradio-doc \
qgis gummi scilab scilab-doc scilab-data scilab-full-bin ruby-full rustc cargo airspy calibre \
obs-studio handbrake vmpk denemo ocrfeeder texstudio texworks bless krita kstars \
inetutils-traceroute build-essential dh-python python3-all python3-stdeb python3-pyqt5 \
python3-gpg python3-requests python3-socks python3-packaging gnupg2 tor libgpgme-dev \
fakeroot swig ack-grep gimp wireguard wireguard-tools automake python3-dev pdftk git && \
apt-get clean

RUN export DEBIAN_FRONTEND=noninteractive && \
apt-get update && \
apt-get -y install pipx

RUN export DEBIAN_FRONTEND=noninteractive && \
wget https://s3.amazonaws.com/turbovnc-pr/main/linux/`curl -q https://s3.amazonaws.com/turbovnc-pr/main/linux/index.html |\
awk -F'"' '/_amd64\.deb/ {print $2}'` -O turbovnc_latest_amd64.deb && \
apt-get update && \
apt-get install -y -q ./turbovnc_latest_amd64.deb && \
apt-get remove -y -q light-locker && \
rm ./turbovnc_latest_amd64.deb && \
apt-get -y autoremove && \
apt-get update && \
apt-get autoclean && \
ln -s /opt/TurboVNC/bin/* /usr/local/bin/ && \
rm -rf /var/lib/apt/lists/*s

RUN adduser --disabled-password --gecos "" --shell /bin/bash user
RUN passwd -d user
RUN mkdir -p /var/local/run && \
mkdir -p /var/www && \
chown -R user:user /var/local/run

ADD workspace /var/www/workspace

USER user

RUN pipx install websockify && \
pipx ensurepath

ENV PATH $PATH:/home/user/.local/bin

WORKDIR /var/local/run

ADD startup .
CMD ["./startup"]
