Introduction
------------

This project aims to provide a simple, standard vagrant environment that
facilitates an easy method sharing of defined VMs, largely independant of the
provider being used. At present, vmware\_fusion and virtualbox providers are
supported.

 While geared towards Puppet development, it is easily extended to support any
 of the vagrant provisioners.

Configuration
-------------

Configuration of the environment is handled entirely done in YAML.  The default
configuration, which applies to all other nodes, is configured in default.yaml

Subsequent hosts are declared in YAML configuration files located in vms.d/

Example
-------

    # $basedir/vms.d/default.yaml
    # this is implied, but we'll still set it
    template: true
    vm:
      box: centos6-min
      cpus: 1
      memory: 384
      provision:

    # $basedir/vms.d/puppet-dev.yaml
    template: true
    vm:
      provision:
      - shell:
        inline: "echo 10.0.0.0 puppet puppet.lan >> /etc/hosts"

    # $basedir/vms.d/master.yaml
    ---
    templates:
    - puppet-dev
    vm:
      hostname: puppet.lan
      cpu: 2
      memory: 1024
      provision:
      - shell:
          path: "util/scripts/install-repo-puppetlabs.sh"
      - shell:
          path: "util/scripts/install-puppet-2.7.sh"
      - puppet:
          manifest_path: 'util/manifests/'
          manifest_file: 'master.pp'
          module_path: 'util/modules/'
      network:
      - private_network:
        ip: 10.0.0.0
      - forwarded_port:
        guest: 8140
        host: 8140
      - forwarded_port:
        guest: 80
        host: 8080
      - forwarded_port:
        guest: 443
        host: 8443
      synced_folder:
      -
        - puppet/manifests
        - /tmp/master/manifests
      -
        - puppet/modules
        - /tmp/master/modules
