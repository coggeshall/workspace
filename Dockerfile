FROM jupyter/all-spark-notebook:latest

USER root

RUN date > /etc/build-date

RUN DEBIAN_FRONTEND=noninteractive && \
apt-get update && \
apt-get -y install software-properties-common

RUN echo -e 'Package: firefox*\n\
Pin: release o=Ubuntu*\n\
Pin-Priority: -1\n' > /etc/apt/preferences.d/firefox-no-snap && \
add-apt-repository ppa:mozillateam/ppa

RUN echo -e 'Package: snapd*\n\
Pin: release a=*\n\
Pin-Priority: -10\n' > /etc/apt/preferences.d/nosnap.pref

RUN (yes | unminimize) || :

RUN export DEBIAN_FRONTEND=noninteractive && \
apt-get update && \
apt-get -y install dnsutils vim whois net-tools iputils-ping socat gcc make gnupg2 curl unzip rclone \
xvfb x11vnc dbus dbus-x11 ffmpeg tcpdump uuid-runtime wget gtk2-engines-pixbuf cowsay \
xfonts-cyrillic xfonts-100dpi xfonts-75dpi xfonts-base xfonts-scalable imagemagick x11-apps \
jq tshark netbase bc espeak libespeak1 telnet firefox xfce4 xfce4-panel xfce4-session xfce4-settings \
xorg manpages man-db pwgen netcat xvkbd vlc youtube-dl perl-tk libreoffice tree remmina texlive-full \
transmission-gtk icedtea-netx \
forensics-full gfio gnuradio gnuradio-dev gnuradio-doc qgis gummi scilab scilab-doc scilab-data \
scilab-full-bin ruby-full rustc cargo airspy calibre \
obs-studio handbrake vmpk denemo ocrfeeder texstudio texworks bless \
gnome-clocks krita kstars ubuntu-gnome-desktop \
inetutils-traceroute torbrowser-launcher build-essential dh-python python3-all \
python3-stdeb python3-pyqt5 python3-gpg python3-requests python3-socks python3-packaging \
gnupg2 tor libgpgme-dev fakeroot swig ack-grep gimp wireguard wireguard-tools automake \
python3-dev pdftk && \
apt-get clean

RUN export DEBIAN_FRONTEND=noninteractive && \
wget https://s3.amazonaws.com/turbovnc-pr/main/linux/`curl -q https://s3.amazonaws.com/turbovnc-pr/main/linux/index.html |\
awk -F'"' '/_amd64\.deb/ {print $2}'` -O turbovnc_latest_amd64.deb && \
wget https://s3.amazonaws.com/virtualgl-pr/main/linux/`curl -q https://s3.amazonaws.com/virtualgl-pr/main/linux/index.html |\
awk -F'"' '/_amd64\.deb/ && /virtualgl_/  {print $2}'` -O virtualgl_latest_amd64.deb && \
apt-get update && \
apt-get install -y -q ./turbovnc_latest_amd64.deb && \
apt-get install -y -q ./virtualgl_latest_amd64.deb && \
apt-get remove -y -q light-locker && \
rm ./turbovnc_latest_amd64.deb && \
rm ./virtualgl_latest_amd64.deb && \
apt-get -y autoremove && \
apt-get update && \
apt-get autoclean && \
ln -s /opt/TurboVNC/bin/* /usr/local/bin/ && \
rm -rf /var/lib/apt/lists/*s

ADD . /opt/install
RUN fix-permissions /opt/install && \
fix-permissions "/home/${NB_USER}"

RUN passwd -d jovyan

USER $NB_UID

RUN npm install -g tslab puppeteer-core axios && tslab install

RUN mamba install --quiet --yes -c conda-forge 'voila' 'beautifulsoup4' 'requests' \
'selenium' 'schedule' 'jupyterlab-git' 'jupytext' 'ipyparallel' 'bqplot' 'keras' \
'ipywidgets' 'jupyter_bokeh' 'jupyterlab-lsp' 'python-lsp-server' 'lux-api' 'basemap' \
'websockify' && \
fix-permissions "${CONDA_DIR}" && \
fix-permissions "/home/${NB_USER}"

RUN mamba clean --all -f -y && \
fix-permissions "${CONDA_DIR}" && \
fix-permissions "/home/${NB_USER}"

RUN jupyter lab build

RUN pip install nest_asyncio ipwhois py-radix websockets tldextract urlextract pytz xvfbwrapper \
jupyter-server-proxy jupyterlab_latex jupyter-tensorboard jtbl jupyterlab-github \
jlab-enhanced-cell-toolbar jupyterlab_autoscrollcelloutput pyviz_comms panel datashader hvplot \
holoviews bokeh param colorcet pyttsx3 distro gpg stem stdeb pyspark apachelogs PySparkIP \
xmltodict torch torchvision

RUN tslab install

RUN jupyter labextension install luxwidget && \
jupyter lab build && \
rm -rf "/home/${NB_USER}/.local" && \
fix-permissions "${CONDA_DIR}" && \
fix-permissions "/home/${NB_USER}"

RUN curl -LO https://get.golang.org/Linux/go_installer && \
chmod +x go_installer && \
./go_installer && \
rm go_installer

#RUN cd /opt/install && \
#conda env update -n base --file environment.yml
