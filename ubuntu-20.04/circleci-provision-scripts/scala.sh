function install_scala() {
    local SBT_VERSION=$1

	wget https://scala.jfrog.io/artifactory/debian/sbt-${SBT_VERSION}.deb
    dpkg -i sbt-${SBT_VERSION}.deb
    rm sbt-${SBT_VERSION}.deb
    sbt -V
    sudo -u ${CIRCLECI_USER} sbt -V
}
