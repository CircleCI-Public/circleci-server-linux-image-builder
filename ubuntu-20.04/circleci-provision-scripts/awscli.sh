#!/bin/bash

function install_awscli() {
    pushd /tmp
    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
    unzip awscliv2.zip
    ./aws/install -i /usr/local/aws-cli -b /usr/local/bin
    rm -rf awscliv2*
    popd
    echo 'export AWS_PAGER=""' >> ${CIRCLECI_HOME}/.circlerc
}
