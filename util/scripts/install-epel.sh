#!/bin/sh

cat <<"EOF" >/etc/yum.repos.d/epel.repo
[epel]
name=Extra Packages for Enterprise Linux 6
mirrorlist=https://mirrors.fedoraproject.org/metalink?repo=epel-$releasever&arch=$basearch
failovermethod=priority
gpgcheck=0
EOF

yum install -y epel-release
mv -f /etc/yum.repos.d/epel.repo.rpmnew /etc/yum.repos.d/epel.repo
