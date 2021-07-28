#!/bin/bash

function install_nvm() {
    echo '>>> Installing NodeJS NVM'

    apt-get install build-essential libssl-dev make python g++ curl libssl-dev

    echo 'Install NVM'
    (cat <<'EOF'
mkdir -p $CIRCLECI_PKG_DIR/.nvm
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.37.2/install.sh | NVM_DIR=$CIRCLECI_PKG_DIR/.nvm bash
echo "export NVM_DIR=$CIRCLECI_PKG_DIR/.nvm" >> ~/.circlerc
echo 'source $NVM_DIR/nvm.sh' >> ~/.circlerc
EOF
    ) | as_user CIRCLECI_PKG_DIR=$CIRCLECI_PKG_DIR bash

}

function install_yarn() {
    local version=$1

    (cat <<EOF
source ~/.circlerc
curl -o- -L https://yarnpkg.com/install.sh | bash -s -- --version $version
EOF
    ) | as_user version=$version bash
}

function install_nodejs_version_nvm() {
    NODEJS_VERSION=$1
    (cat <<'EOF'
source ~/.circlerc
nvm install $NODEJS_VERSION
rm -rf ~/nvm/src
hash -r
nvm use $NODEJS_VERSION
# Install some common libraries
npm install -g npm
npm install -g coffee-script
npm install -g grunt
npm install -g bower
npm install -g grunt-cli
npm install -g nodeunit
npm install -g mocha
hash -r
EOF
    ) | as_user NODEJS_VERSION=$NODEJS_VERSION bash
}

function install_nodejs_version() {
    local VERSION=$1

    install_nodejs_version_nvm $VERSION
}

function install_nodejs() {
    local NODEJS_VERSION=$1

    [[ -e $CIRCLECI_PKG_DIR/.nvm ]] || install_nvm
    install_nodejs_version $NODEJS_VERSION
}
