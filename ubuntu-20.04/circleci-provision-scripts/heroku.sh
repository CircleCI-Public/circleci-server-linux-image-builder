#!/bin/bash

function install_heroku() {
    echo '>>> Installing heroku'

    curl https://cli-assets.heroku.com/install-ubuntu.sh | sh
    mkdir -p ${CIRCLECI_HOME}/.config
    chown -R $CIRCLECI_USER:$CIRCLECI_USER ${CIRCLECI_HOME}/.config

    # Run once to bootstrap heroku cli
    (cat <<'EOF'
heroku --version
EOF
    ) | as_user bash
}
