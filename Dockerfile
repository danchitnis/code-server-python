FROM python:3.11

RUN apt-get update && apt-get install -y \
    python3-pip \
    python3-dev \
    build-essential

RUN apt-get install -y \
    wget \
    curl \
    jq \
    sudo \
    dumb-init 


# Download the appropriate package for the system architecture
RUN ARCH=$(dpkg --print-architecture) && \
    download_url=$(curl -s https://api.github.com/repos/coder/code-server/releases/latest | \
    jq -r --arg ARCH "$ARCH" '.assets[] | select(.name | contains($ARCH + ".deb")).browser_download_url') && \
    wget -O code-server.deb $download_url


RUN mkdir -p /etc/sudoers.d && \
    adduser --gecos '' --disabled-password coder && \
    echo "coder ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers.d/nopasswd



COPY entrypoint.sh /usr/bin/entrypoint.sh
RUN chmod +x /usr/bin/entrypoint.sh

# Install the package
RUN dpkg -i code-server.deb



USER coder


# Install a VS Code extension:
# Note: we use a different marketplace than VS Code. See https://github.com/cdr/code-server/blob/main/docs/FAQ.md#differences-compared-to-vs-code
RUN code-server --install-extension ms-python.python
RUN code-server --install-extension ms-toolsai.jupyter

# Install a pip packages
RUN python3 -m pip install --upgrade pip
RUN python3 -m pip install numpy matplotlib
RUN python3 -m pip install ipykernel

# copy examples into the project folder
# COPY examples/ /home/coder/project/examples
# Set the directory permissions to allow access
# RUN sudo chmod 755 /home/coder/project/examples
# RUN sudo chown -R coder:coder /home/coder/project/examples


EXPOSE 8080


# copy vscode settings
COPY settings.json /home/coder/.local/share/code-server/User/settings.json

USER coder
ENTRYPOINT ["/usr/bin/entrypoint.sh", "--bind-addr", "0.0.0.0:8080", "/home/coder/project", "--auth", "none"]