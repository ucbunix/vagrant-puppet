# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  # Every Vagrant virtual environment requires a box to build off of.
  config.vm.box = "centos6-eu"
  config.vm.provision :shell, :inline => "echo 10.0.0.10   puppet puppet.lan pm pm.lan >> /etc/hosts"
  config.vm.provision :shell, :inline => "echo 10.0.0.11   git git.lan >> /etc/hosts"

  # Puppet Master
  #
  config.vm.define :master do |master|
    master.vm.synced_folder "bootstrap/", "/bs"
    master.vm.network :private_network, ip: "10.0.0.10"
    master.vm.provision :shell, :inline => "hostname pm.lan"
    master.vm.provision :puppet do |puppet|
      puppet.manifests_path = 'bootstrap/manifests/'
      puppet.manifest_file = 'puppet-master.pp'
      puppet.module_path = [ 'bootstrap/modules', 'bootstrap/opt-modules' ]
    end
  end

  # Gitolite Server
  #
  config.vm.define :git do |git|
    git.vm.synced_folder "bootstrap/", "/bs"
    git.vm.network :private_network, ip: "10.0.0.11"
    git.vm.provision :shell, :inline => "hostname git.lan"
    git.vm.provision :puppet do |puppet|
      puppet.manifests_path = 'bootstrap/manifests/'
      puppet.manifest_file = 'git-server.pp'
      puppet.module_path = [ 'bootstrap/modules', 'bootstrap/opt-modules' ]
    end # git.vm.provision
  end # :git
end
