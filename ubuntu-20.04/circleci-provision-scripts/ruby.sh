#!/bin/bash

function install_rvm() {
    echo '>>> Installing RVM and Ruby'

    apt-get install libmagickwand-dev

	as_user gpg2 --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 7D2BAF1CF37B13E2069D6956105BD0E739499BDB
    curl -sSL https://get.rvm.io | as_user bash -s -- --path $CIRCLECI_PKG_DIR/.rvm

    echo "[[ -s '$CIRCLECI_PKG_DIR/.rvm/scripts/rvm' ]] && . $CIRCLECI_PKG_DIR/.rvm/scripts/rvm # Load RVM function" | as_user tee -a ${CIRCLECI_HOME}/.circlerc

    # Setting up user rmvrc

    (cat <<'EOF'
export rvm_gemset_create_on_use_flag=1
export rvm_install_on_use_flag=1
export rvm_trust_rvmrcs_flag=1
export rvm_verify_downloads_flag=1
EOF
    ) | as_user tee ${CIRCLECI_HOME}/.rvmrc

    # Setting up default gemrc
    (cat <<'EOF'
:sources:
- https://rubygems.org
gem:  --no-ri --no-rdoc
EOF
    ) | as_user tee ${CIRCLECI_HOME}/.gemrc

    (cat <<'EOF'
source ~/.circlerc
rvm rvmrc warning ignore allGemfiles
EOF
    ) | as_user bash

    # Make sure bundler is installed in all versions
    (cat <<'EOF'
source ~/.circlerc
echo 'bundler' >> $rvm_path/gemsets/default.gems
EOF
    ) | as_user bash
}

function install_ruby_version_rvm() {
    INSTALL_RUBY_VERSION=$1
    RUBYGEMS_MAJOR_RUBY_VERSION=${2:-2}
    (cat <<'EOF'
echo Installing Ruby version: $INSTALL_RUBY_VERSION
source ~/.circlerc
rvm use $INSTALL_RUBY_VERSION
# TODO: Avoid this for jruby
rvm rubygems latest-${RUBYGEMS_MAJOR_RUBY_VERSION}
# For projects without gemfiles
rvm @global do gem install rspec
EOF
    ) | as_user INSTALL_RUBY_VERSION=$INSTALL_RUBY_VERSION RUBYGEMS_MAJOR_RUBY_VERSION=$RUBYGEMS_MAJOR_RUBY_VERSION bash
}

function install_ruby_version() {
    local VERSION=$1

    install_ruby_version_rvm $VERSION
}

function install_ruby() {
    local VERSION=$1

    [[ -e $CIRCLECI_PKG_DIR/.rvm ]] || install_rvm
    install_ruby_version $VERSION
}
