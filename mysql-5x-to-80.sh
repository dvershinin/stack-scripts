#!/bin/bash

# Stop service first
systemctl stop mysqld

# See what we need to install first,
# e.g.: Percona-Server-client-57 Percona-Server-devel-57 Percona-Server-server-57 Percona-Server-shared-57
MYSQL_8_PKGS=$(yum list installed | grep --perl-regexp --only-matching "^Percona-Server-[\w-]+" | sed -r 's@-[0-9]+$@@' | sed 's@Percona-Server@percona-server@' | xargs)

# Now remove existing 5.x packages without dependencies:
rpm -qa | grep --perl-regexp "^Percona-Server-[\w-]+-5" | xargs rpm -e --nodeps

# Install "back" same packages with 5.7 version:
yum -y install $MYSQL_8_PKGS

# Bring back the service
systemctl start mysqld

# Fix MySQL schema changes
mysql_upgrade
