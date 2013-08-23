#!/bin/bash

mkdir -p logs
mkdir -p puppet/{manifests,modules} 2>logs/setup-errors.log >dev/null

[[ ! -x dev ]] && ln -s puppet/modules/ dev
[[ ! -x nodes ]] && ln -s puppet/manifests/ nodes

if [ ! -d vms.d/ ]; then
  mkdir -p vms.d 2>logs/setup-errors.log >/dev/null
  cp vm-examples/{default,master}.yaml vms.d/
fi

# setup our required module dependencies
git sub init 2>logs/setup-errors.log >/dev/null; [[ $? -eq 1 ]] && ERROR=1
git sub update 2>logs/setup-errors.log >/dev/null; [[ $? -eq 1 ]] && ERROR=1
[[ $ERROR -ne 0 ]] \
  && echo "errors occurred... please check the logs/setup-errors.log"; exit 1

cat <<EOF
Setup Complete!
EOF
