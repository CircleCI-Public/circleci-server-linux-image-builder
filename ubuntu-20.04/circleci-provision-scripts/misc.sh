#/bin/bash

function install_sysadmin() {
    apt-get install htop
}

function install_devtools() {
    apt-get install $(tr '\n' ' ' <<EOS
ack-grep
emacs
gdb
lsof
nano
tmux
vim
tightvncserver
EOS
)
}

function install_jq() {
    local url="https://github.com/stedolan/jq/releases/download/jq-1.6/jq-linux64"
    local install_path="/usr/local/bin/jq"

    curl -L -o $install_path $url
    chmod +x $install_path
}

function install_yq() {

	VERSION=v4.7.1
	wget https://github.com/mikefarah/yq/releases/download/${VERSION}/yq_linux_amd64.tar.gz -O - | \
	tar xz && mv yq_linux_amd64 /usr/local/bin/yq
}

function install_socat() {
    apt-get install socat
}

function install_nsenter() {
    apt-get install build-essential libncurses5-dev libslang2-dev gettext zlib1g-dev libselinux1-dev debhelper lsb-release pkg-config po-debconf autoconf automake autopoint libtool
    pushd /tmp
    git clone git://git.kernel.org/pub/scm/utils/util-linux/util-linux.git util-linux
    cd util-linux/
    ./autogen.sh
    ./configure --without-python --disable-all-programs --enable-nsenter
    make
    mv nsenter /usr/local/bin/nsenter
    popd
}
