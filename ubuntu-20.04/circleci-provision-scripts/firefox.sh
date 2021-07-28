#!/bin/bash

function install_firefox_version() {
    # version should match a version in apt-cache madison firefox
    VERSION="$1"
    echo ">>> Installing Firefox $VERSION"
    apt-get install firefox=${VERSION}
    firefox --version
}
