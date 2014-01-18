function status {
  printf "%-25s\n" "$1..."
}

status "install lsb_release"
/usr/bin/yum install -y redhat-lsb-core

status "install puppetlabs repo"
osmaj=$(echo $(expr "$(lsb_release -r -s)" : '\([0-9]*\)'))
wget \
    http://yum.puppetlabs.com/puppetlabs-release-el-${osmaj}.noarch.rpm \
      -O /tmp/puppetlabs-release.noarch.rpm
/usr/bin/yum install -y /tmp/puppetlabs-release.noarch.rpm
#rm /tmp/puppetlabs-release.noarch.rpm
