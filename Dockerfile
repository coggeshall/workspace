FROM jupyter/all-spark-notebook:latest

USER root
RUN export DEBIAN_FRONTEND=noninteractive && \
apt update && \
apt -y install dnsutils \
vim \
whois \
net-tools \
iputils \
socat

USER $NB_UID
RUN npm install -g tslab && \
tslab install

RUN conda clean --all -f -y && \
fix-permissions "${CONDA_DIR}" && \
fix-permissions "/home/${NB_USER}"

RUN jupyter lab build

RUN pip install nest_asyncio \
ipwhois \
py-radix \
websockets \
tldextract \
pytz
