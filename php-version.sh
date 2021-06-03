#!/bin/bash
# Install desired SYSTEM-WIDE php version on a CentOS/RHEL webserver
# That is, /usr/bin/php
# Synopsis
# php-version latest
# php-version 7.4
# Requirements:
# lastversion, remi Repo configuration, yum-utils
# TODO check repo availability for desired version and validate input better
# TODO ensure can be used with Ansible, e.g. different short output (with --quiet option) for changed/retained PHP version

# If any commands fail, we bail.
set -eo pipefail

if [ -z "$1" ]; then
  echo 'No argument supplied, specify "latest", or specific PHP version, e.g. 7.0'
fi

CURRENT_PHP_VERSION=$(/usr/bin/php -v 2>/dev/null | cut -d' ' -f2 | head -1 | cut -d'.' -f1,2)
CURRENT_PHP_VERSION_DOTLESS=$(echo "$CURRENT_PHP_VERSION" | cut -d. -f1,2 | sed 's@\.@@')

WANTED_PHP_VERSION=$1
if [ "${WANTED_PHP_VERSION}" == "latest" ]; then
  ## Update to the latest PHP
  WANTED_PHP_VERSION=$(lastversion php | cut -d. -f1,2) # 8.0
fi
WANTED_PHP_VERSION_DOTLESS=$(echo "$WANTED_PHP_VERSION" | cut -d. -f1,2 | sed 's@\.@@')
echo "Installing system PHP: ${WANTED_PHP_VERSION}"

RHEL=$(rpm -E %{rhel})
rpm -q remi-release >/dev/null 2>&1 || yum -y install "https://rpms.remirepo.net/enterprise/remi-release-${RHEL}.rpm"
if [ "$RHEL" -gt "7" ]; then
  rpm -q dnf-plugins-core >/dev/null 2>&1 || yum -y install dnf-plugins-core
  dnf -y module reset php
  dnf -y module install "php:remi-${WANTED_PHP_VERSION}"
else
  rpm -q yum-utils /dev/null 2>&1 || yum -y install yum-utils
  yum-config-manager --disable 'remi-php*'
  yum-config-manager --enable "remi-php${WANTED_PHP_VERSION_DOTLESS}" >/dev/null 2>&1
fi

if [[ -z $CURRENT_PHP_VERSION ]]; then
  # TODO install common extensions for a webserver?
  yum -y install php-common
elif [[ "$WANTED_PHP_VERSION_DOTLESS" > "$CURRENT_PHP_VERSION_DOTLESS" ]]; then
  # Ensure the latest release, as it might have desired PHP version sub-repo
  yum -y update remi-release
  yum -y upgrade "php-*"
elif [[ "$WANTED_PHP_VERSION_DOTLESS" < "$CURRENT_PHP_VERSION_DOTLESS" ]]; then
  yum -y downgrade "php-*"
  # because some packages like php-pear could be downgraded unnecessarily in prior steps
  yum -y update "php-*"
else
  echo "Nothing to do. Already on ${WANTED_PHP_VERSION}"
fi
