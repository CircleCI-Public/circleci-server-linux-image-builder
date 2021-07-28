#!/bin/bash

function install_pyenv() {
    echo '>>> Installing Python'

    # FROM https://github.com/yyuu/pyenv/wiki/Common-build-problems
    apt-get install -y make build-essential libssl-dev zlib1g-dev libbz2-dev \
        libreadline-dev libsqlite3-dev wget curl llvm libncurses5-dev liblzma-dev

    # Installing system pip because sometimes our app uses `pyenv global system`. e.g. CodeDeploy
    apt-get install python3-pip

    echo 'Installing pyenv'
    (cat <<'EOF'
git clone https://github.com/yyuu/pyenv.git $CIRCLECI_PKG_DIR/.pyenv
EOF
    ) | as_user CIRCLECI_PKG_DIR=$CIRCLECI_PKG_DIR bash

    echo "export PYENV_ROOT=$CIRCLECI_PKG_DIR/.pyenv" >> ${CIRCLECI_HOME}/.circlerc
    echo 'export PATH=$PYENV_ROOT/bin:$PATH' >> ${CIRCLECI_HOME}/.circlerc
    echo 'eval "$(pyenv init -)"' >> ${CIRCLECI_HOME}/.circlerc
}

function install_python_version_pyenv() {
    PYTHON_VERSION=$1
    (cat <<'EOF'
source ~/.circlerc
pyenv install $PYTHON_VERSION
pyenv global $PYTHON_VERSION
pyenv rehash
pip install -U virtualenv
pip install -U nose
pip install -U pep8
EOF
    ) | as_user PYTHON_VERSION=$PYTHON_VERSION bash
}

function install_python_version() {
    local VERSION=$1

    install_python_version_pyenv $VERSION
}

function install_python() {
    local VERSION=$1
    [[ -e $CIRCLECI_PKG_DIR/.pyenv ]] || install_pyenv
    install_python_version $1
}
