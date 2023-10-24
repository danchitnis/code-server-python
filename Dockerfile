FROM python:3.11

USER root

RUN apt-get update && \
    apt-get install -y \
    python3-pip \
    python3-dev \
    build-essential \
    wget \
    curl \
    jq \
    sudo && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*


# Download and install the appropriate package for the system architecture
RUN ARCH=$(dpkg --print-architecture) && \
    download_url=$(curl -s https://api.github.com/repos/coder/code-server/releases/latest | \
    jq -r --arg ARCH "$ARCH" '.assets[] | select(.name | contains($ARCH + ".deb")).browser_download_url') && \
    wget -O code-server.deb $download_url && \
    dpkg -i code-server.deb && \
    rm code-server.deb


RUN mkdir -p /etc/sudoers.d && \
    adduser --gecos '' --disabled-password coder && \
    echo "coder ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers.d/nopasswd



USER coder

# Install a VS Code extension:
# Note: we use a different marketplace than VS Code. See https://github.com/cdr/code-server/blob/main/docs/FAQ.md#differences-compared-to-vs-code
RUN code-server --install-extension ms-python.python
RUN code-server --install-extension ms-toolsai.jupyter

# Install a pip packages
RUN python3 -m pip install --upgrade --no-cache pip
RUN python3 -m pip install --no-cache numpy matplotlib ipykernel


EXPOSE 8080


# copy vscode settings
COPY settings.json /home/coder/.local/share/code-server/User/settings.json

ARG START_DIR=/home/coder/project

USER coder

RUN sudo mkdir -p $START_DIR && \
    sudo chown -R coder:coder $START_DIR && \
    sudo chmod -R 755 $START_DIR

WORKDIR $START_DIR

ENTRYPOINT ["/usr/bin/code-server", "--bind-addr", "0.0.0.0:8080", ".", "--auth", "none"]