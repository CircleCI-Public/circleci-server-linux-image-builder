#!/bin/bash
export VERBOSE=false
export CIRCLECI_USER=${CIRCLECI_USER:-circleci}

set -exo pipefail

# Keep packages up to date when we cut a release.
# This is especially important for packages such as `openssh-*`, `ca-certificates`, etc.
sudo apt-get update && sudo apt-get upgrade -y

cp circleci-install /usr/local/bin/circleci-install
cp -r circleci-provision-scripts /opt/circleci-provision-scripts
circleci-install base_requirements && circleci-install circleci_specific

# Installing Java early because a few things have it as a dependency
circleci-install java openjdk8
circleci-install java openjdk11
circleci-install maven 3.8.3
circleci-install gradle 7.1.1
circleci-install ant

for package in sysadmin devtools jq yq; do circleci-install $package; done

# Browsers
circleci-install firefox_version 90.0+build3-0ubuntu0.20.04.1 && circleci-install chrome 91.0.4472.114-1

# Install deployment tools
circleci-install gcloud 348.0.0
for package in awscli heroku; do circleci-install $package; done

circleci-install python 2.7.18
circleci-install python 3.9.6
sudo -H -i -u ${CIRCLECI_USER} pyenv global 2.7.18 3.9.6

circleci-install nodejs 12.22.3
circleci-install nodejs 14.17.3
circleci-install nodejs 15.14.0
circleci-install nodejs 16.4.2
sudo -H -i -u ${CIRCLECI_USER} nvm alias default 14.17.3
circleci-install yarn 1.22.10

circleci-install golang 1.16.6

circleci-install ruby 3.0.2
sudo -H -i -u ${CIRCLECI_USER} rvm use 3.0.2 --default

circleci-install clojure 2.9.6

circleci-install scala 1.5.5

circleci-install snap

# Docker have be last - to utilize cache better
circleci-install docker 5:20.10.7~3-0~ubuntu-focal 1.4.3-1
circleci-install docker_compose 1.29.2

circleci-install socat

circleci-install nsenter

# For some reason dpkg might start throwing errors after VM creation
# auto correction allows to avoid
sudo dpkg --configure -a

# apt-daily and apt-daily-upgrade services can potentially run on start up and lock dpkg
sudo systemctl mask apt-daily.service
sudo systemctl mask apt-daily-upgrade.service
sudo systemctl mask apt-daily.timer
sudo systemctl mask apt-daily-upgrade.timer


##
# Cleanup
##

# circleci-install is intended to be an internal script. Now that we're done
# using it, remove it from the final image.
rm /usr/local/bin/circleci-install

true
