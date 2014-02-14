#!/bin/sh

FILES_DIR="/mnt/files"
EXTRACT_DIR="/tmp"

PE_INSTALL_NAME="puppet-enterprise-3.1.0-el-6-x86_64"
PE_INSTALL_ARCHIVE="${FILES_DIR}/${PE_INSTALL_NAME}.tar.gz"
PE_EXTRACT_DIR="${EXTRACT_DIR}/${PE_INSTALL_NAME}"
PE_ANSWER_FILE="${FILES_DIR}/puppet-master.ans"

if [ "$(hostname -s)" == "puppet-ca" ]; then
  PE_ANSWER_FILE="${FILES_DIR}/puppet-ca.ans"
fi

# extract our installer
cd $EXTRACT_DIR
tar -xzf $PE_INSTALL_ARCHIVE

# install puppet enterprise
$PE_EXTRACT_DIR/puppet-enterprise-installer -a ${PE_ANSWER_FILE} -l ${EXTRACT_DIR}/pe-install.log
