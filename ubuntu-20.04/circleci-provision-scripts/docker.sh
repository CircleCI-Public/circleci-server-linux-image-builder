#!/bin/bash

function install_docker() {
    # Check available versions from apt-cache madison docker-ce
    local DOCKER_VERSION=$1
    local CONTAINERD_VERSION=$2
    echo ">>>> Installing Docker version $DOCKER_VERSION and containerd version $CONTAINERD_VERSION"
    apt-get -y install gnupg-agent
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
    apt-key fingerprint 0EBFCD88
    add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
    apt-get -y update
    apt-get install -y docker-ce=$DOCKER_VERSION docker-ce-cli=$DOCKER_VERSION containerd.io=$CONTAINERD_VERSION
    sudo usermod -aG docker circleci
    docker version
}

function install_circleci_docker() {
    echo '>>> Install CircleCI Docker fork that runs on user namespaces'

    # Install LXC and btrfs-tools
    apt-get -y install lxc btrfs-tools

    # DNS forwarding doesn't work without this line which causes container unable to resolve DNS
    sed -i 's|10.0.3|10.0.4|g' /etc/default/lxc-net

    # Divert plain docker
    sudo dpkg-divert --add --rename --divert /usr/bin/docker.plain /usr/bin/docker

    # Replace with CircleCI's patched docker
    sudo curl -L -o /usr/bin/docker.circleci 'https://s3.amazonaws.com/circle-downloads/docker-1.9.1-circleci'
    sudo chmod 0755 /usr/bin/docker.circleci

    # --userland-proxy=false: Docker's userland proxy is broken. Don't use it.
    echo 'DOCKER_OPTS="-s btrfs -e lxc -D --userland-proxy=false"' > /etc/default/docker

    sudo ln -s /usr/bin/docker.circleci /usr/bin/docker
}

function install_docker_compose() {
    echo '>>>> Installing Docker compose'

    VERSION="$1"

    curl -sSfL -o /tmp/docker-compose https://github.com/docker/compose/releases/download/${VERSION}/docker-compose-Linux-x86_64
    chmod +x /tmp/docker-compose
    sudo mv /tmp/docker-compose /usr/local/bin/docker-compose
    docker-compose version
}
