FROM jupyter/pyspark-notebook:latest

USER root
RUN export DEBIAN_FRONTEND=noninteractive && \
apt update && \
apt -y install dnsutils \
vim \
whois \
net-tools \
iputils-ping \
socat \
gcc \
make \
gnupg2 \
curl \
unzip \
rclone && \
rm -rf /var/lib/apt/lists/*s

RUN wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add -
RUN sh -c 'echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google-chrome.list'
RUN export DEBIAN_FRONTEND=noninteractive && \
apt update && \
apt -y install google-chrome-stable

RUN wget -O /tmp/chromedriver.zip http://chromedriver.storage.googleapis.com/`curl -sS chromedriver.storage.googleapis.com/LATEST_RELEASE`/chromedriver_linux64.zip && \
unzip /tmp/chromedriver.zip chromedriver -d /usr/local/bin/

USER $NB_UID
RUN npm install -g tslab && \
tslab install

RUN jupyter labextension install jupyterlab_voyager

RUN mamba install --quiet --yes -c conda-forge 'voila' \
'tensorflow' \
'beautifulsoup4' \
'requests' \
'selenium' \
'schedule' \
'jupyterlab-git' \
'jupytext' && \
fix-permissions "${CONDA_DIR}" && \
fix-permissions "/home/${NB_USER}"

RUN mamba clean --all -f -y && \
fix-permissions "${CONDA_DIR}" && \
fix-permissions "/home/${NB_USER}"

RUN jupyter lab build

RUN pip install nest_asyncio \
ipwhois \
py-radix \
websockets \
tldextract \
pytz \
jupyter-server-proxy \
jupyterlab_latex \
jupyter-tensorboard

RUN jupyter serverextension enable voila && \
jupyter server extension enable voila && \
jupyter serverextension enable --sys-prefix jupyter_server_proxy && \
jupyter lab build && \
rm -rf "/home/${NB_USER}/.local" && \
fix-permissions "${CONDA_DIR}" && \
fix-permissions "/home/${NB_USER}"
