#!/bin/bash

function install_circleci_specific() {
    # CircleCI specific commands

    echo '>>> Installing CircleCI Specific things'

    echo 'source ~/.bashrc &>/dev/null' >> ${CIRCLECI_HOME}/.bash_profile
    echo 'source ~/.circlerc &>/dev/null' > ${CIRCLECI_HOME}/.bashrc

    # For an unknown reason BASH_ENV is not getting loaded automatically (unlike
    # in Ubuntu 16) so the workaround here is to source it via .bashrc when the
    # shell is a non-interactive shell (as per normal bash behaviour for BASH_ENV),
    # and BASH_ENV env var is defined and the file exists.
    echo 'if ! echo $- | grep -q "i" && [ -n "$BASH_ENV" ] && [ -f "$BASH_ENV" ]; then . "$BASH_ENV"; fi' >> ${CIRCLECI_HOME}/.bashrc

    chown $CIRCLECI_USER:$CIRCLECI_USER ${CIRCLECI_HOME}/.bash_profile
    chown $CIRCLECI_USER:$CIRCLECI_USER ${CIRCLECI_HOME}/.bashrc

    (cat <<'EOF'
export GIT_ASKPASS=echo
export SSH_ASKPASS=false
export PATH=~/bin:$PATH
export CIRCLECI_PKG_DIR="/opt/circleci"
EOF
) | as_user tee ${CIRCLECI_HOME}/.circlerc

    as_user mkdir -p ${CIRCLECI_HOME}/bin

    # Configure SSH so it can talk to servers OK

    cat <<'EOF' > /etc/ssh/ssh_config
Host *
  StrictHostKeyChecking no
  HashKnownHosts no
  SendEnv LANG LC_*
EOF

    # Some optimizations for the sshd daemon
    sed -i 's/PasswordAuthentication yes/PasswordAuthoentication no/g' /etc/ssh/sshd_config

    cat <<'EOF' >> /etc/ssh/sshd_config
UseDns no
MaxStartups 1000
MaxSessions 1000
PermitTunnel yes
AddressFamily inet
EOF

    # Setup xvfb

    apt-get install xvfb xfwm4

    cat <<'EOF' >> /etc/systemd/system/xvfb.service
[Unit]
Description=XVFB Service
After=network.target

[Service]
ExecStart=/usr/bin/Xvfb :99 -screen 0 1280x1024x24
Type=simple

[Install]
WantedBy=multi-user.target
EOF

    chmod 0644 /etc/systemd/system/xvfb.service

    echo 'export DISPLAY=:99' >> $CIRCLECI_HOME/.circlerc

    systemctl enable xvfb.service
    systemctl start xvfb.service

    # Avoid GPG signatures errors
    sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-key 514A2AD631A57A16DD0047EC749D6EEC0353B12C
    sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-key 58118E89F3A912897C070ADBF76221572C52609D

    # A tweak to make selenium tests stable
    # https://github.com/SeleniumHQ/docker-selenium/issues/87
    echo 'export DBUS_SESSION_BUS_ADDRESS=/dev/null' >> $CIRCLECI_HOME/.circlerc

    # CIRCLE-28258 Fix intermittent connection reset errors
    # (related: https://github.com/moby/libnetwork/issues/1090)
    # This fix can likely be removed when https://github.com/moby/libnetwork/pull/2275 is merged
    iptables -I INPUT -m conntrack --ctstate INVALID -j DROP

    # Allow iptable rules to be saved
    echo iptables-persistent iptables-persistent/autosave_v4 boolean true | sudo debconf-set-selections
    echo iptables-persistent iptables-persistent/autosave_v6 boolean true | sudo debconf-set-selections
    apt-get -y install iptables-persistent

}
