#!/bin/bash
# Requirements:
# lastversion, remi Repo configuration, yum-utils


if [ -z "$1" ]; then
  echo 'No argument supplied, specify "latest", or specific PHP version, e.g. 7.0'
fi

WANTED_PHP_VERSION=$1
if [ "${WANTED_PHP_VERSION}" == "latest" ]; then
  WANTED_PHP_VERSION=$(lastversion php | cut -d. -f1,2) # 8.0
fi

## Update CentOS/RHEL server to the latest PHP

RHEL=$(rpm -E %{rhel})
yum -y update remi-release
CONFIG_MANAGER="yum-config-manager"
if [ "$RHEL" -gt "7" ]; then
  CONFIG_MANAGER="dnf config-manager"
  if ! rpm -q dnf-plugins-core >/dev/null 2>&1; then
    yum -y install dnf-plugins-core
  fi
fi
LATEST_PHP_VERSION=$(lastversion php | cut -d. -f1,2) #80
echo "Updating PHP to {LATEST_PHP_VERSION}"
LATEST_PHP_VERSION_DOTLESS=$(echo $LATEST_PHP_VERSION | cut -d. -f1,2 | sed 's@\.@@')

${CONFIG_MANAGER} --disable 'remi-php*'
yum-config-manager --enable   "remi-php${LATEST_PHP_VERSION_DOTLESS}" >/dev/null 2>&1

yum -y update php-common

# php-version 7.4

SELECTED_PHP_VERSION=7.4
SELECTED_PHP_VERSION_DOTLESS=$(echo $SELECTED_PHP_VERSION | cut -d. -f1,2 | sed 's@\.@@')

yum-config-manager --disable 'remi-php*'
yum-config-manager --enable   "remi-php${WANTED_PHP_VERSION}"
# or yum history undo last -y
yum downgrade php-*
yum update php-* # because some packages like php-pear could be downgraded unneccessarily in prior step