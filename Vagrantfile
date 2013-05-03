# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  # Every Vagrant virtual environment requires a box to build off of.
  config.vm.box = "centos6-eu"
  config.vm.provision :shell, :inline => "echo 10.0.0.10   puppet puppet.lan pm pm.lan >> /etc/hosts"
  config.vm.provision :shell, :inline => "echo 10.0.0.11   git git.lan >> /etc/hosts"
  config.vm.provision :shell, :inline => "echo 10.0.0.12   nrpe nrpe.lan >> /etc/hosts"
  config.vm.provision :shell, :inline => "echo 10.0.0.254  burn burn.lan >> /etc/hosts"

  # Puppet Master
  #
  config.vm.define :master do |master|
    master.vm.synced_folder "bootstrap/", "/bs"
    master.vm.network :private_network, ip: "10.0.0.10"
    master.vm.provision :shell, :inline => "hostname pm.lan"
    master.vm.provision :puppet do |puppet|
      puppet.manifests_path = 'bootstrap/manifests/nodes/'
      puppet.manifest_file = 'puppet-master.pp'
      puppet.module_path = [ 'bootstrap/development', 'bootstrap/modules' ]
    end
  end

  # Gitolite Server
  #
  config.vm.define :git do |git|
    git.vm.synced_folder "bootstrap/", "/bs"
    git.vm.network :private_network, ip: "10.0.0.11"
    git.vm.provision :shell, :inline => "hostname git.lan"
    git.vm.provision :puppet do |puppet|
      puppet.manifests_path = 'bootstrap/manifests/nodes/'
      puppet.manifest_file = 'git-server.pp'
      puppet.module_path = [ 'bootstrap/development', 'bootstrap/modules', 'bootstrap/opt-modules' ]
    end # git.vm.provision
  end # :git

  config.vm.define :nrpe do |nrpe|
    nrpe.vm.network :private_network, ip: "10.0.0.12"
    nrpe.vm.provision :shell, :inline => "hostname nrpe.lan"
    nrpe.vm.provision :puppet_server do |puppet|
      puppet.puppet_server = 'pm.lan'
      puppet.puppet_node = 'nrpe.lan'
    end
  end

  config.vm.define :burn do |burn|
    burn.vm.network :private_network, ip: "10.0.0.250"
    burn.vm.provision :shell, :inline => "hostname burn.lan"
  end
end
