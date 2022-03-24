FROM jupyter/all-spark-notebook:latest

USER root
RUN export DEBIAN_FRONTEND=noninteractive && \
apt update && \
apt -y install dnsutils \
vim \
whois \
net-tools \
iputils-ping \
socat

USER $NB_UID
RUN npm install -g tslab && \
tslab install

RUN mamba install --quiet --yes -c conda-forge voila && \
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
pytz

RUN jupyter serverextension enable voila && \
jupyter server extension enable voila && \
rm -rf "/home/${NB_USER}/.local" && \
fix-permissions "${CONDA_DIR}" && \
fix-permissions "/home/${NB_USER}"
