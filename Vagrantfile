# -*- mode: ruby -*-
# vi: set ft=ruby :

require 'yaml'

home = File.dirname(__FILE__)
vm_dir = "#{home}/vms.d"

# load our configs once
config_files = Dir.glob("#{vm_dir}/*.yaml") if File.directory?("#{vm_dir}")
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
  puts "virtual machine: #{name}" unless apply_to
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

  puts "  applying template: #{name}" unless apply_to == name
  puts "  applying host config: #{name}" if apply_to == name
  # apply remaining config
  vagrant.vm.define apply_to do |host|
    # configure our node
    host.vm.box = vmcfg['vm']['box'] if vmcfg['vm']['box']
    host.vm.hostname = vmcfg['vm']['hostname'] if vmcfg['vm']['hostname']

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

def run_app()
  Vagrant.configure("2") do |vagrant|
    printf("\n"+"#"*80+"\n%s\n", "YAML Config Generator".center(80))
    printf("#"*80+"\n\n")
    $vms.each do |vm,cfg|
      # skip the default config
      next if vm == 'default'
      # apply our config if it's not a template
      configure_vm(vagrant,vm) unless cfg['template']
    end
    printf("\n"+"#"*80+"\n%s\n", "YAML Config Generator Complete!".center(80))
    printf("#"*80+"\n\n")
  end
end

# run our app
run_app
