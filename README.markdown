Introduction
------------

This repo contains a standard vagrant development environment, with the primary
intention of providing an out-of-the-box ready Puppet development environment.

Configuration
-------------

Configuration of the environment is handled entirely done in YAML.  The default
configuration, which applies to all other nodes, is configured in default.yaml

Subsequent hosts are declared in YAML configuration files located in vms.d/

Example
-------


Future Work
-----------

- Template Configurations

  The ability to specify templates to base one or more other configurations off
  of.

