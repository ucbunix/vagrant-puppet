# -*- mode: ruby -*-
# vi: set ft=ruby :

require 'yaml'

home = File.dirname(__FILE__)

# load our configs
app = YAML::load_file("#{home}/config.yaml")
app = { } if app == nil
vm_dir = app['vm_dir'].is_a?(String) ? config['vm_dir'] : "#{home}/vms.d"
vm_configs = Dir.glob("#{vm_dir}/*.yaml") if File.directory?("#{vm_dir}")

vms = { }
vm_configs.each do |vconf|
  vms[File.basename(vconf).sub('.yaml','')] = YAML::load_file(vconf)
end

# define our vms
Vagrant.configure('2') do |vc|
  # given a vm obj and the root of the config, we'll build our vm
  def apply_config( vm_obj, cfg )
    # Vagrant uses the config_map to dynamically insantiate configuration
    # classes.  The primary mechanism for this is catching the method_missing
    # function, which insantiates our class for us and returns the resulting
    # object.
    config_map = vm_obj.instance_variable_get(:@config_map)
    cfg.each do |namespace,namespace_config|
      if config_map.to_hash.has_key?(namespace.to_sym)
        vm_ns_obj = vm_obj.method_missing(namespace.to_sym)
        apply_settings(vm_ns_obj, namespace_config )
      else
        # skip unhandled namespaces
        # TODO: work in support for creating templates 
        next
      end
    end
  end

  # apply settings for a particular namespace.  All we need to do is provide
  # the appropriate object for that particular namespace and the rest of the
  # configuration object, peeling off the other namespace settings.
  def apply_settings( vm_obj, cfg )
    cfg.each do |setting,value|
      case value
      when String,Fixnum
        apply_setting(vm_obj, setting, value)
      when Hash
        apply_hash(vm_obj, value)
      when Array
        value.each do |value0|
          if value0.is_a?(Hash)
            apply_hash(vm_obj.method(setting.to_s), value0)
          else
            apply_setting(vm_obj.method(setting.to_s), value, value0)
          end
        end
      end
    end 
  end

  def apply_hash( vm_obj, hash )
    hash.each do |k,v|
      vm_obj.call("#{k}".to_sym, v)
    end
  end

  def apply_setting( vm_obj, setting, value )
    vm_obj.send("#{setting}=".to_sym, value )
  end

  # define the default vm
  apply_config(vc, vms['default']) if vms['default'] != nil
  
  # setup the other vms
  vms.each do |name,cfg|
    next if name == 'default'
    vc.vm.define name.to_s do |vm_cfg|
       vm_cfg.vm.hostname = name
       apply_config(vm_cfg, cfg)
    end
  end
end
