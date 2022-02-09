#!/bin/bash

function _install_openjdk() {

    local version=$1
    local package="openjdk-$version-jdk"

    add-apt-repository -y ppa:openjdk-r/ppa
    apt-get update
    apt-get install $package
}

function install_openjdk8() {
    _install_openjdk 8
}

function install_openjdk11() {
    _install_openjdk 11
    update-alternatives --set  "java" "/usr/lib/jvm/java-11-openjdk-amd64/bin/java"
    update-alternatives --set  "javac" "/usr/lib/jvm/java-11-openjdk-amd64/bin/javac"
    update-alternatives --set  "javadoc" "/usr/lib/jvm/java-11-openjdk-amd64/bin/javadoc"
}

function install_java() {
    local VERSION=$1
    install_$VERSION
}

function install_ant() {
    echo '>>> Installing ant'
    apt-get install ant
}

function install_maven() {
    local MAVEN_VERSION=$1
    echo ">>> Installing Maven $MAVEN_VERSION"

    # Install Maven
    curl -sSL -o /tmp/maven.tar.gz https://archive.apache.org/dist/maven/maven-3/${MAVEN_VERSION}/binaries/apache-maven-${MAVEN_VERSION}-bin.tar.gz
    tar -xz -C /usr/local -f /tmp/maven.tar.gz
    ln -sf /usr/local/apache-maven-${MAVEN_VERSION} /usr/local/apache-maven
    rm -rf /tmp/maven.tar.gz

    as_user mkdir -p ${CIRCLECI_HOME}/.m2

    echo 'export M2_HOME=/usr/local/apache-maven' >> ${CIRCLECI_HOME}/.circlerc
    echo 'export MAVEN_OPTS=-Xmx2048m' >> ${CIRCLECI_HOME}/.circlerc
    echo 'export PATH=$M2_HOME/bin:$PATH' >> ${CIRCLECI_HOME}/.circlerc
}

function install_gradle() {
    local GRADLE_VERSION=$1
    echo ">>> Installing Gradle $GRADLE_VERSION"
    URL=https://services.gradle.org/distributions/gradle-${GRADLE_VERSION}-bin.zip

    curl -sSL -o /tmp/gradle.zip $URL
    unzip -d /usr/local /tmp/gradle.zip

    echo "export PATH=\$PATH:/usr/local/gradle-${GRADLE_VERSION}/bin" >> ${CIRCLECI_HOME}/.circlerc
    rm -rf /tmp/gradle.zip
}
