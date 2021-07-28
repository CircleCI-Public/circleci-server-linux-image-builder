#!/bin/bash

function install_base_requirements() {
    echo "Setting Timezone & Locale to Etc/UTC & C.UTF-8"

    ln -sf /usr/share/zoneinfo/Etc/UTC /etc/localtime
    locale-gen C.UTF-8 || true
    update-locale LANG=en_US.UTF-8
    export LANG=C.UTF-8

    echo "export LANG=C.UTF-8" > ${CIRCLECI_HOME}/.bashrc

    echo ">>> Make Apt non interactive"

    echo 'force-confnew' >> /etc/dpkg/dpkg.cfg

    (cat <<'EOF'
// the /etc/apt/apt.conf file for the slave AMI

// Auto "-y" for apt-get
APT {
  Get {
    Assume-Yes "true";
    force-yes "true";
  };
};

// Disable HTTP pipelining, S3 doesn't support it properly.
Acquire {
  http {
    Pipeline-Depth 0;
  }
}

// Don't ask to update
DPkg {
  Options {
    "--force-confnew";
  };
};
EOF
) > /etc/apt/apt.conf

    echo 'Defaults    env_keep += "DEBIAN_FRONTEND"' >> /etc/sudoers.d/env_keep
    export DEBIAN_FRONTEND=noninteractive

    apt-get update -y
    apt-get install -y software-properties-common
    apt-add-repository ppa:git-core/ppa
    apt-get update -y
    add-apt-repository universe
    apt-get update -y

    # Install base packages
    apt-get install $(tr '\n' ' ' <<EOS
autoconf
build-essential
cmake
curl
dpkg-repack
ffmpeg
gfortran
git
gnupg2
imagemagick
libarchive-tools
libicu-dev
liblapack-dev
lzop
make
mercurial
parallel
protobuf-compiler
unzip
zip
EOS
)

# Test the last package to ensure that all the packages were installed
zip -v

    # configure ulimit
    cat <<'EOF' > /etc/security/limits.d/01-openfiles.conf
*               soft    nofile          65536
*               hard    nofile          65536
EOF

    # For tests
    git clone https://github.com/sstephenson/bats.git && cd bats && ./install.sh /usr/local
}
