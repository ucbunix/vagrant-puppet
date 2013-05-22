# -*- mode: ruby -*-
# vi: set ft=ruby :

home = File.dirname(__FILE__)

# Primary VagrantFile
# handles the setting up of our puppetmaster

# Define our default box, in case we dont override it in the VagrantInit
# file. We'll also add our puppet hosts entry
Vagrant.configure("2") do |config|
  config.vm.box = "centos6-eu"
  config.vm.provision :shell, :inline => "echo 10.0.0.10   puppet puppet.lan pm pm.lan >> /etc/hosts"
end

# In this file, we should put any additional config options that should apply
# to all hosts, such as entries into /etc/hosts, and the default box
load "#{home}/config.d/VagrantInit"

Vagrant.configure("2") do |config|
  # Puppet Master
  #
  config.vm.define :master do |master|
    master.vm.network :private_network, ip: "10.0.0.10"
    master.vm.provision :shell, :inline => "hostname pm.lan"
    master.vm.provision :puppet do |puppet|
      puppet.manifests_path = 'puppet/manifests'
      puppet.manifest_file = 'puppet-master.pp'
      puppet.module_path = [ 'dev',
                              'puppet/modules', 
                              'puppet/opt-modules' ]
    end
  end
end

load "#{home}/config.d/Vagrantfile"
