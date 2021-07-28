#!/bin/bash

function install_chrome_browser() {
    local CHROME_VERSION=$1
    echo '>>> Installing Chrome'

    wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add -

    echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google.list

    apt-get update
    apt-get install google-chrome-stable=$CHROME_VERSION

    # Disable sandboxing - it conflicts with unprivileged lxc containers
    sed -i 's|HERE/chrome"|HERE/chrome" --disable-setuid-sandbox --enable-logging --no-sandbox|g' \
               "/opt/google/chrome/google-chrome"

    google-chrome --version
}


# Chrome Driver

function install_chromedriver() {
    CHROMEDRIVER_RELEASE=$(google-chrome --version | awk '{print $3}' | awk -F'.' '{print $1"."$2"."$3}')
    CHROMEDRIVER_VERSION=$(curl --silent --show-error --location --fail --retry 4 --retry-delay 5 http://chromedriver.storage.googleapis.com/LATEST_RELEASE_${CHROMEDRIVER_RELEASE})
    curl --silent --show-error --location --fail --retry 4 --retry-delay 5 --output /tmp/chromedriver.zip "http://chromedriver.storage.googleapis.com/$CHROMEDRIVER_VERSION/chromedriver_linux64.zip"
    unzip -p /tmp/chromedriver.zip > /usr/local/bin/chromedriver
    chmod +x /usr/local/bin/chromedriver
    rm -rf /tmp/chromedriver.zip
    chromedriver --version
}

function install_chrome() {
    local CHROME_VERSION=$1
    install_chrome_browser $CHROME_VERSION
    install_chromedriver
}
