# Introduction

This repo contains a standard Vagrant environment geared towards Puppet
testing and development.

## Module Path Configuration

The configured module path for this environment is:

```
modulepath=dev/:puppet/modules:puppet/opt-modules
```

Any development work should take place in dev/<modulename>

Your production modules should be symlinked into puppet/modules

A final module directory is presented in puppet/opt-modules, as we tend to put
3rd-party modules inside of their own directory in the modulepath.

## Manifests

The vagrant/nodes symlink points to puppet/manifests/nodes, and is where Puppet
has been configured to look for node manifets.

In vagrant/puppet/manifests/puppet-master.pp, you will find a puppet manifest
that will bootstrap a puppetmaster, configured autosign and pipe in the correct
manifest and modulepaths.

Currently, the puppet-master.pp requires the eu::repos::epel class, which is in
our private repository.  If you wish to use this and dont have access to this
class, you'll want to comment it out and either provide another class that
installs epel, or make sure you've got epel baked into the box.
