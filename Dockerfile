FROM jupyter/pyspark-notebook:latest

USER root
RUN export DEBIAN_FRONTEND=noninteractive && \
apt-get update && \
apt-get -y install dnsutils vim whois net-tools iputils-ping socat gcc make gnupg2 curl unzip rclone \
xvfb dbus dbus-x11 ffmpeg tcpdump uuid-runtime wget gtk2-engines-pixbuf \
xfonts-cyrillic xfonts-100dpi xfonts-75dpi xfonts-base xfonts-scalable imagemagick x11-apps \
jq tshark golang && \
rm -rf /var/lib/apt/lists/*s

RUN wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add -
RUN sh -c 'echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google-chrome.list'
RUN export DEBIAN_FRONTEND=noninteractive && \
apt-get update && \
apt-get -y install google-chrome-stable

RUN wget -O /tmp/chromedriver.zip \
http://chromedriver.storage.googleapis.com/`curl -sS chromedriver.storage.googleapis.com/LATEST_RELEASE`/chromedriver_linux64.zip && \
unzip /tmp/chromedriver.zip chromedriver -d /usr/local/bin/

USER $NB_UID
RUN npm install -g tslab puppeteer-core axios && tslab install

RUN mamba install --quiet --yes -c conda-forge 'voila' 'tensorflow' 'beautifulsoup4' 'requests' \
'selenium' 'schedule' 'jupyterlab-git' 'jupytext' 'ipyparallel' 'xeus-cling' 'bqplot' 'lfortran' && \
fix-permissions "${CONDA_DIR}" && \
fix-permissions "/home/${NB_USER}"

RUN mamba clean --all -f -y && \
fix-permissions "${CONDA_DIR}" && \
fix-permissions "/home/${NB_USER}"

RUN curl -Lo coursier https://git.io/coursier-cli && \
chmod +x coursier && \
./coursier launch --fork almond -M almond.ScalaKernel -- --install && \
rm -f coursier

RUN jupyter lab build

RUN pip install nest_asyncio ipwhois py-radix websockets tldextract urlextract pytz xvfbwrapper \
jupyter-server-proxy jupyterlab_latex jupyter-tensorboard jtbl

RUN env GO111MODULE=on && \
go get github.com/gopherdata/gophernotes && \
mkdir -p "${HOME}/.local/share/jupyter/kernels/gophernotes" && \
cd "${HOME}/.local/share/jupyter/kernels/gophernotes" && \
cp "$(go env GOPATH)"/pkg/mod/github.com/gopherdata/gophernotes@*/kernel/*  "." && \
chmod +w ./kernel.json && \
sed "s|gophernotes|$(go env GOPATH)/bin/gophernotes|" < kernel.json.in > kernel.json

RUN jupyter lab build && \
rm -rf "/home/${NB_USER}/.local" && \
fix-permissions "${CONDA_DIR}" && \
fix-permissions "/home/${NB_USER}"
