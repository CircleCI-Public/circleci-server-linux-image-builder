#!/bin/bash

function install_gcloud() {
  local VERSION=$1
  # nest the sdk in /opt/google instead of /opt to prevent permissions issues
  # with creating temporary files when 'gcloud components update' tries to create
  # temporary files in the parent directory
  mkdir -p /opt/google
  pushd /opt/google
  curl -s https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-sdk-$VERSION-linux-x86_64.tar.gz | tar xz
  popd
  /opt/google/google-cloud-sdk/bin/gcloud config set --installation component_manager/disable_update_check true
  /opt/google/google-cloud-sdk/bin/gcloud config set disable_usage_reporting false
  chown -R $CIRCLECI_USER:$CIRCLECI_USER "/opt/google"
  # gcloud installation script needs to install .config/gcloud dir under user's $HOME directory.
  mkdir -p ${CIRCLECI_HOME}/.config
  chown -R $CIRCLECI_USER:$CIRCLECI_USER ${CIRCLECI_HOME}/.config
  echo 'export PATH=/opt/google/google-cloud-sdk/bin:$PATH' >> ${CIRCLECI_HOME}/.circlerc
  sudo -u ${CIRCLECI_USER} -H /opt/google/google-cloud-sdk/bin/gcloud config set --installation component_manager/disable_update_check true
  sudo -u ${CIRCLECI_USER} -H /opt/google/google-cloud-sdk/bin/gcloud config set disable_usage_reporting false
}
