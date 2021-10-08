#!/bin/bash

function install_snap() {

	echo ">>> Setting up snapd and snapcraft"

	# This adds snap binaries to PATH. Without this users would need to do
	# `snap run <snap-name>` instead of just `<snap-name>`.
	echo 'export PATH=$PATH:/snap/bin' >> ${CIRCLECI_HOME}/.circlerc

	# Pre-install the two most recent base snaps. Most snaps will need at least
	# one of these in order to run. These are also used when building snaps.
	if ! sudo snap list core18 || ! sudo snap list core20
	then
		sudo snap install core18 core20
	fi

	# Install snapcraft, which is the tool used to build/package snaps.
	sudo snap install --classic snapcraft

	# This allows snapcraft to build a snap. The end-user will need to run
	# `snapcraft --use-lxd`. By default Snapcraft would use Multipass instead
	# of LXD but we don't currently support it. If and when machine images get
	# nested virtualization, we can install multipass and drop the LXD
	# workaround for Snapcraft.
	sudo lxd init --auto
}
