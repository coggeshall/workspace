FROM jupyter/all-spark-notebook:latest

USER root
RUN export DEBIAN_FRONTEND=noninteractive && \
apt-get update && \
apt-get -y install dnsutils vim whois net-tools iputils-ping socat gcc make gnupg2 curl unzip rclone \
xvfb x11vnc novnc dbus dbus-x11 ffmpeg tcpdump uuid-runtime wget gtk2-engines-pixbuf \
xfonts-cyrillic xfonts-100dpi xfonts-75dpi xfonts-base xfonts-scalable imagemagick x11-apps \
jq tshark netbase bc espeak libespeak1 telnet firefox xfce4 xfce4-panel xfce4-session xfce4-settings \
xorg manpages man-db pwgen netcat onboard vlc youtube-dl perl-tk libreoffice && \
apt-get clean

RUN export DEBIAN_FRONTEND=noninteractive && \
wget https://s3.amazonaws.com/turbovnc-pr/main/linux/`curl -q https://s3.amazonaws.com/turbovnc-pr/main/linux/index.html | awk -F'"' '/_amd64\.deb/ {print $2}'` -O turbovnc_latest_amd64.deb && \
apt-get update && \
apt-get install -y -q ./turbovnc_latest_amd64.deb && \
apt-get remove -y -q light-locker && \
rm ./turbovnc_latest_amd64.deb && \
apt-get update && \
apt-get autoclean && \
ln -s /opt/TurboVNC/bin/* /usr/local/bin/ && \
rm -rf /var/lib/apt/lists/*s

ADD . /opt/install
RUN fix-permissions /opt/install

RUN (yes | unminimize) || :

USER $NB_UID
RUN npm install -g tslab puppeteer-core axios && tslab install

RUN mamba install --quiet --yes -c conda-forge 'voila' 'tensorflow' 'beautifulsoup4' 'requests' \
'selenium' 'schedule' 'jupyterlab-git' 'jupytext' 'ipyparallel' 'bqplot' 'tensorflow' 'keras' \
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
holoviews bokeh geoviews param colorcet pyttsx3

RUN tslab install

RUN jupyter labextension install luxwidget && \
jupyter lab build && \
rm -rf "/home/${NB_USER}/.local" && \
fix-permissions "${CONDA_DIR}" && \
fix-permissions "/home/${NB_USER}"

RUN cd /opt/install && \
conda env update -n base --file environment.yml
