# -*- mode: ruby -*-
# vi: set ft=ruby :

require 'yaml'

home = File.dirname(__FILE__)
$defaults = {
  :debug => 1,
  :vm_dir => "#{home}/vms.d",
}

$cfg = { }
begin
  $cfg = YAML::load_file( "#{home}/.vagrant.yaml" )
  $cfg = $defaults.merge($cfg)
rescue
  $cfg = $defaults
end


def debug(msg, level = 2, indent = 0)
  if $cfg[:debug] >= level
    printf "%#{indent}s%s\n" % [ "",  msg ]
  end
end

# load our vm configs once
config_files = Dir.glob("#{$cfg[:vm_dir]}/*.yaml") if File.directory?("#{$cfg[:vm_dir]}")
$vms = { }
config_files.each do |conf|
  $vms[File.basename(conf).sub('.yaml','')] = YAML::load_file(conf)
end


# apply our vm configuration
#
# == Paramters:
#
# [*vagrant*]
#   The vagrant configuration object
#
# [*name*]
#   The name of the host configuration to apply
#
# [*apply_to*]
#   The virtual machine to apply the named host configuration to. If not set,
#   defaults to the named configuration.
#
def configure_vm(vagrant,name,apply_to=nil)
  debug("virtual machine: #{name}") unless apply_to
  apply_to ||= name

  # config to apply
  vmcfg=$vms[name]

  # apply our default config first
  configure_vm(vagrant,'default',apply_to) if apply_to == name

  # apply our templates
  vmcfg['templates'] ||= [ ]
  vmcfg['templates'].each do |tmpl|
    configure_vm(vagrant,tmpl,apply_to)
  end

  debug("applying template: #{name}",2,2) unless apply_to == name
  debug("applying host config: #{name}",2,2) if apply_to == name
  # apply remaining config
  vagrant.vm.define apply_to do |host|
    # configure our node
    host.vm.box = vmcfg['vm']['box'] if vmcfg['vm']['box']
    host.vm.hostname = vmcfg['vm']['hostname'] if vmcfg['vm']['hostname'] and apply_to == name
    # vagrant is setting the hostname properly. here's a hacky workaround
    host.vm.provision "shell", inline: "hostname #{vmcfg['vm']['hostname']}" \
      if vmcfg['vm']['hostname'] and apply_to == name

    configure_providers(host,vmcfg)

    # configure our provisioner and networking
    [ 'provision', 'network' ].each do |setting|
      vmcfg['vm'][setting] ||= [ ]
      vmcfg['vm'][setting].each do |data|
        data.each do |type,opts|
          host.vm.send(setting,type.to_sym, opts)
        end
      end
    end

    # setup synced folder
    vmcfg['vm']['synced_folder'] ||= [ ]
    vmcfg['vm']['synced_folder'].each do |folders|
      host.vm.synced_folder *folders
    end
  end
end

# configure provider-specific settings. currently supports virtualbox and
# vmware_fusion. can be easily extended
#
# == parameters:
#
# [*host*]
#   the vagrant host configuration object
#
# [*vmcfg*]
#   the loaded host configuration file
#
def configure_providers(host,vmcfg)
  providers = [ 'virtualbox', 'vmware_fusion' ]
  vmcfg['vm']['gui'] ||= false
  providers.each do |p|
    host.vm.provider p do |pcfg|
      pcfg.gui = true if vmcfg['vm']['gui']
    end
    begin
      send("configure_#{p}",host,vmcfg)
    rescue NoMethodError
      # do nothing
    end
  end
end

# configure virtualbox specific settings.
#
# == parameters:
#
# [*host*]
#   the vagrant host configuration object
#
# [*vmcfg*]
#   the loaded host configuration file
#
def configure_virtualbox(host,vmcfg)
  host.vm.provider "virtualbox" do |pcfg|
    pcfg.memory = vmcfg['vm']['memory'] if vmcfg['vm']['memory']
    pcfg.customize ["modifyvm", :id, "--cpus", vmcfg['vm']['cpu']] if vmcfg['vm']['cpu'] 
  end
end

# configure vmware fusion specific settings.
#
# == parameters:
#
# [*host*]
#   the vagrant host configuration object
#
# [*vmcfg*]
#   the loaded host configuration file
#
def configure_vmware_fusion(host,vmcfg)
  host.vm.provider "vmware_fusion" do |pcfg|
    pcfg.vmx['memsize'] = vmcfg['vm']['memory'] if vmcfg['vm']['memory']
    pcfg.vmx['numvcpus'] = vmcfg['vm']['cpu'] if vmcfg['vm']['cpu']
  end
end

def run_app()
  Vagrant.configure("2") do |vagrant|
    debug("\n"+"#"*80+"\n"+"YAML Config Generator".center(80),2)
    debug("#"*80,2)
    $vms.each do |vm,cfg|
      # skip the default config
      next if vm == 'default'
      # apply our config if it's not a template
      configure_vm(vagrant,vm) unless cfg['template']
    end
    debug("\n"+"#"*80+"\n"+"YAML Config Generator Complete!".center(80),2)
    debug("#"*80+"\n",2)
  end
end

# run our app
run_app
