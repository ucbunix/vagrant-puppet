#!/bin/bash

cat <<EOF
Setting up the environment...
This can take a minute or so the first time...
EOF

echo "Generating necessary directories"
mkdir -p logs
mkdir -p puppet/manifests 2>logs/setup-errors.log >/dev/null
mkdir -p puppet/modules 2>logs/setup-errors.log >/dev/null

echo "Creating symlinks to save time"
[[ ! -x dev ]] && ln -s puppet/modules/ dev 2>/dev/null
[[ ! -x nodes ]] && ln -s puppet/manifests/ nodes 2>/dev/null

if [ ! -d vms.d/ ]; then
  echo "New installation detected -- setting up vms.d/ directory"
  mkdir -p vms.d 2>logs/setup-errors.log >/dev/null
  cp vm-examples/{default,master}.yaml vms.d/
fi

echo "downloading our required submodules..."
# setup our required module dependencies
git sub init 2>logs/setup-errors.log >/dev/null; [[ $? -eq 1 ]] && ERROR=1
git sub update 2>logs/setup-errors.log >/dev/null; [[ $? -eq 1 ]] && ERROR=1
[[ $ERROR -ne 0 ]] \
  && echo "errors occurred... please check the logs/setup-errors.log"; exit 1

cat <<EOF
Setup Complete!

Run "vagrant up master" to boot your puppet master!

By default, port forwarding has been setup so that connections to your host on
port tcp/80, tcp/443 and tcp/8140 are forwarded to your master.

You can change that by updating the appropriate configuration items in
vms.d/master.yaml
EOF
